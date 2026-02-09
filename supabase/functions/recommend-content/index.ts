// recommend-content: Content recommendation engine using user preferences and engagement
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

    const { user_id, limit = 20, content_type } = (await req.json()) as {
      user_id?: string;
      limit?: number;
      content_type?: "post" | "lesson" | null;
    };

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(supabaseUrl, serviceRoleKey);

    const take = Math.min(limit, 50);
    const recommendations: { id: string; type: string; score: number; reason: string }[] = [];

    if (user_id) {
      // Get user preferences
      const { data: profile } = await admin
        .from("profiles")
        .select("preferences")
        .eq("id", user_id)
        .single();

      const interests = (profile?.preferences as Record<string, unknown>)?.interests as string[] | undefined;
      const followedIds = await admin
        .from("follows")
        .select("following_id")
        .eq("follower_id", user_id)
        .then((res) => (res.data ?? []).map((r) => r.following_id));

      // Get user's past interactions to avoid duplicates
      const { data: interactions } = await admin
        .from("user_interactions")
        .select("content_type, content_id")
        .eq("user_id", user_id)
        .limit(100);

      const seen = new Set(
        (interactions ?? []).map((i) => `${i.content_type}:${i.content_id}`)
      );

      // Content from followed creators (high priority)
      if (followedIds.length > 0) {
        const [followPosts, followLessons] = await Promise.all([
          content_type !== "lesson"
            ? admin
                .from("posts")
                .select("id, author_id, engagement_score, created_at")
                .eq("moderation_status", "approved")
                .in("author_id", followedIds)
                .order("created_at", { ascending: false })
                .limit(10)
            : Promise.resolve({ data: [] }),
          content_type !== "post"
            ? admin
                .from("lessons")
                .select("id, author_id, engagement_score, created_at")
                .eq("moderation_status", "approved")
                .in("author_id", followedIds)
                .order("created_at", { ascending: false })
                .limit(10)
            : Promise.resolve({ data: [] }),
        ]);

        for (const item of [...(followPosts.data ?? []), ...(followLessons.data ?? [])]) {
          const key = `${item.id.startsWith("post") ? "post" : "lesson"}:${item.id}`;
          if (!seen.has(key)) {
            recommendations.push({
              id: item.id,
              type: item.id.startsWith("post") ? "post" : "lesson",
              score: Number(item.engagement_score ?? 0) + 20,
              reason: "From creators you follow",
            });
            seen.add(key);
          }
        }
      }

      // Content matching interests
      if (interests && interests.length > 0) {
        const { data: categories } = await admin
          .from("categories")
          .select("id")
          .in("slug", interests);

        const categoryIds = (categories ?? []).map((c) => c.id);

        if (categoryIds.length > 0) {
          const [interestPosts, interestLessons] = await Promise.all([
            content_type !== "lesson"
              ? admin
                  .from("posts")
                  .select("id, engagement_score, created_at")
                  .eq("moderation_status", "approved")
                  .in("category_id", categoryIds)
                  .order("engagement_score", { ascending: false })
                  .limit(15)
              : Promise.resolve({ data: [] }),
            content_type !== "post"
              ? admin
                  .from("lessons")
                  .select("id, engagement_score, created_at")
                  .eq("moderation_status", "approved")
                  .in("category_id", categoryIds)
                  .order("engagement_score", { ascending: false })
                  .limit(15)
              : Promise.resolve({ data: [] }),
          ]);

          for (const item of [...(interestPosts.data ?? []), ...(interestLessons.data ?? [])]) {
            const key = `${item.id.startsWith("post") ? "post" : "lesson"}:${item.id}`;
            if (!seen.has(key)) {
              recommendations.push({
                id: item.id,
                type: item.id.startsWith("post") ? "post" : "lesson",
                score: Number(item.engagement_score ?? 0) + 10,
                reason: "Matches your interests",
              });
              seen.add(key);
            }
          }
        }
      }
    }

    // Add trending content as fallback
    const [trendingPosts, trendingLessons] = await Promise.all([
      content_type !== "lesson"
        ? admin.from("mv_trending_posts").select("id, engagement_score").limit(20)
        : Promise.resolve({ data: [] }),
      content_type !== "post"
        ? admin.from("mv_trending_lessons").select("id, engagement_score").limit(20)
        : Promise.resolve({ data: [] }),
    ]);

    const seenSet = new Set(recommendations.map((r) => `${r.type}:${r.id}`));
    for (const item of [...(trendingPosts.data ?? []), ...(trendingLessons.data ?? [])]) {
      const type = item.id.startsWith("post") ? "post" : "lesson";
      const key = `${type}:${item.id}`;
      if (!seenSet.has(key)) {
        recommendations.push({
          id: item.id,
          type,
          score: Number(item.engagement_score ?? 0),
          reason: "Trending now",
        });
        seenSet.add(key);
      }
    }

    // Sort by score and return top results
    recommendations.sort((a, b) => b.score - a.score);

    return new Response(
      JSON.stringify({
        items: recommendations.slice(0, take).map((r) => ({
          id: r.id,
          type: r.type,
          why_shown: r.reason,
        })),
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
