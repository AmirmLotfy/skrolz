// notify-digest: daily digest "3 stories" push via OneSignal REST API
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const ONE_SIGNAL_APP_ID = Deno.env.get("ONE_SIGNAL_APP_ID");
    const ONE_SIGNAL_REST_KEY = Deno.env.get("ONE_SIGNAL_REST_KEY");
    if (!ONE_SIGNAL_APP_ID || !ONE_SIGNAL_REST_KEY) {
      return new Response(
        JSON.stringify({ ok: false, error: "OneSignal not configured" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceRoleKey);

    // Get profile ids (in a real app, filter by user_settings.notifications_enabled or OneSignal segments)
    const { data: profiles } = await admin.from("profiles").select("id").limit(500);
    const externalUserIds = (profiles ?? []).map((p) => p.id as string).filter(Boolean);
    if (externalUserIds.length === 0) {
      return new Response(
        JSON.stringify({ ok: true, sent: 0 }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Build digest message from trending (3 stories)
    const [postsRes, lessonsRes] = await Promise.all([
      admin.from("mv_trending_posts").select("body").limit(2),
      admin.from("mv_trending_lessons").select("title").limit(1),
    ]);
    const parts: string[] = [];
    for (const row of postsRes.data ?? []) parts.push((row as { body?: string }).body ?? "");
    for (const row of lessonsRes.data ?? []) parts.push((row as { title?: string }).title ?? "");
    const headline = parts.length > 0 ? `3 stories for you: ${parts.slice(0, 3).join(" · ").slice(0, 80)}...` : "Your daily digest is ready.";

    const notifRes = await fetch("https://api.onesignal.com/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Basic ${ONE_SIGNAL_REST_KEY}`,
      },
      body: JSON.stringify({
        app_id: ONE_SIGNAL_APP_ID,
        contents: { en: headline },
        include_external_user_ids: externalUserIds.slice(0, 1000),
      }),
    });
    const notifData = await notifRes.json();
    const sent = notifData.recipients ?? 0;

    return new Response(
      JSON.stringify({ ok: true, sent, id: notifData.id }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
