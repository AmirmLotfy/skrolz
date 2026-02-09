// rank-feed: fetch candidates from mv_trending_* and follows, score, diversity pass; premium use_curated can use Gemini later
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { user_id, limit = 20, use_curated = false } = (await req.json()) as {
      user_id?: string;
      limit?: number;
      use_curated?: boolean;
    };

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceRoleKey);

    const take = Math.min(limit, 50);
    const candidates: { id: string; type: string; score: number; author_id?: string; is_mature?: boolean }[] = [];

    // 1. Fetch blocked users and preferences if user_id is present
    const blockedIds = new Set<string>();
    let matureFilter = true; // Default to filtering mature content

    if (user_id) {
      const [blocksRes, profileRes] = await Promise.all([
        admin.from("blocks").select("blocked_id").eq("blocker_id", user_id),
        admin.from("profiles").select("preferences").eq("id", user_id).single(),
      ]);
      
      if (blocksRes.data) {
        blocksRes.data.forEach((r) => blockedIds.add(r.blocked_id));
      }

      if (profileRes.data?.preferences) {
        const prefs = profileRes.data.preferences as any;
        if (prefs.content_prefs?.mature_filter === false) {
          matureFilter = false;
        }
      }
    }

    // 2. Fetch trending content
    const [postsRes, lessonsRes] = await Promise.all([
      admin.from("mv_trending_posts").select("id, author_id, engagement_score, body, created_at, is_mature").range(0, take - 1),
      admin.from("mv_trending_lessons").select("id, author_id, engagement_score, title, created_at, is_mature").range(0, take - 1),
    ]);

    const postMeta = new Map<string, { body?: string; created_at?: string }>();
    for (const row of postsRes.data ?? []) {
      if (blockedIds.has(row.author_id)) continue; // Filter blocked
      if (matureFilter && row.is_mature) continue; // Filter mature

      postMeta.set(row.id, { body: row.body, created_at: row.created_at });
      candidates.push({
        id: row.id,
        type: "post",
        score: Number(row.engagement_score ?? 0),
        author_id: row.author_id,
        is_mature: row.is_mature,
      });
    }

    const lessonMeta = new Map<string, { title?: string; created_at?: string }>();
    for (const row of lessonsRes.data ?? []) {
      if (blockedIds.has(row.author_id)) continue; // Filter blocked
      if (matureFilter && row.is_mature) continue; // Filter mature

      lessonMeta.set(row.id, { title: row.title, created_at: row.created_at });
      candidates.push({
        id: row.id,
        type: "lesson",
        score: Number(row.engagement_score ?? 0),
        author_id: row.author_id,
        is_mature: row.is_mature,
      });
    }

    // 3. Fetch following content
    if (user_id) {
      const { data: followRows } = await admin.from("follows").select("following_id").eq("follower_id", user_id);
      const followingIds = new Set((followRows ?? []).map((r) => r.following_id));
      
      // Remove blocked users from following list (just in case)
      for (const blocked of blockedIds) followingIds.delete(blocked);

      if (followingIds.size > 0) {
        const [followPosts, followLessons] = await Promise.all([
          admin.from("posts").select("id, author_id, engagement_score, body, created_at, is_mature").eq("moderation_status", "approved").in("author_id", [...followingIds]).order("created_at", { ascending: false }).limit(10),
          admin.from("lessons").select("id, author_id, engagement_score, title, created_at, is_mature").eq("moderation_status", "approved").in("author_id", [...followingIds]).order("created_at", { ascending: false }).limit(10),
        ]);
        
        for (const row of followPosts.data ?? []) {
          if (matureFilter && row.is_mature) continue;
          if (!candidates.some((c) => c.id === row.id && c.type === "post")) {
            postMeta.set(row.id, { body: row.body, created_at: row.created_at });
            candidates.push({ id: row.id, type: "post", score: Number(row.engagement_score ?? 0) + 10, author_id: row.author_id, is_mature: row.is_mature });
          }
        }
        for (const row of followLessons.data ?? []) {
          if (matureFilter && row.is_mature) continue;
          if (!candidates.some((c) => c.id === row.id && c.type === "lesson")) {
            lessonMeta.set(row.id, { title: row.title, created_at: row.created_at });
            candidates.push({ id: row.id, type: "lesson", score: Number(row.engagement_score ?? 0) + 10, author_id: row.author_id, is_mature: row.is_mature });
          }
        }
      }
    }

    candidates.sort((a, b) => b.score - a.score);

    const diversityLimit = 3;
    const items: { id: string; type: string; why_shown?: string; body?: string; title?: string; author_id?: string; created_at?: string }[] = [];
    let consecutiveSameAuthor = 0;
    let lastAuthorId: string | null = null;
    const seen = new Set<string>();

    for (const c of candidates) {
      if (items.length >= take) break;
      const key = `${c.type}:${c.id}`;
      if (seen.has(key)) continue;
      
      const aid = c.author_id ?? null;
      if (aid === lastAuthorId) {
        consecutiveSameAuthor++;
        if (consecutiveSameAuthor >= diversityLimit) continue;
      } else {
        consecutiveSameAuthor = 0;
        lastAuthorId = aid;
      }
      seen.add(key);
      const meta = c.type === "post" ? postMeta.get(c.id) : lessonMeta.get(c.id);
      items.push({
        id: c.id,
        type: c.type,
        author_id: c.author_id,
        ...(c.type === "post" && meta ? { body: meta.body, created_at: meta.created_at } : {}),
        ...(c.type === "lesson" && meta ? { title: meta.title, created_at: meta.created_at } : {}),
        ...(use_curated ? { why_shown: "From your interests and trending" } : {}),
      });
    }

    return new Response(
      JSON.stringify({ items: items.slice(0, take), cached: false }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
