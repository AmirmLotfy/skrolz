// revenuecat-webhook: receives RevenueCat events; updates profiles.subscription_status
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const body = await req.json() as Record<string, unknown>;
    const appUserId = body.app_user_id as string | undefined;
    const eventType = body.event?.type as string | undefined;

    if (!appUserId) {
      return new Response(
        JSON.stringify({ error: "app_user_id required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let subscriptionStatus = "free";
    if (eventType === "INITIAL_PURCHASE" || eventType === "RENEWAL" || eventType === "PRODUCT_CHANGE") {
      subscriptionStatus = "premium";
    } else if (eventType === "CANCELLATION" || eventType === "EXPIRATION") {
      subscriptionStatus = "cancelled";
    } else if (eventType === "TRIAL_STARTED") {
      subscriptionStatus = "trialing";
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceKey);

    const { error } = await supabase
      .from("profiles")
      .update({ subscription_status: subscriptionStatus, updated_at: new Date().toISOString() })
      .eq("id", appUserId);

    if (error) {
      return new Response(
        JSON.stringify({ error: error.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ ok: true }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
