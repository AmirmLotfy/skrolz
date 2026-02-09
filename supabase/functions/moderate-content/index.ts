// moderate-content: runs on content create + AI-generated content; moderation API; quarantine/reject
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// Explicit caching helper for reusable system instructions
// Cache TTL: 1 hour (3600 seconds) - default for Gemini API
async function getOrCreateCache(
  apiKey: string,
  systemInstructions: string,
  ttlSeconds: number = 3600
): Promise<string | null> {
  try {
    // Try to create cache entry for system instructions
    // This allows reusing cached tokens in subsequent requests
    const cacheRes = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/cachedContents?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          model: "models/gemini-3-flash-preview",
          contents: [{ parts: [{ text: systemInstructions }] }],
          ttl: `${ttlSeconds}s`,
        }),
      }
    );
    
    if (cacheRes.ok) {
      const cacheData = await cacheRes.json();
      return cacheData.name || null; // Return cache name/token
    }
  } catch (error) {
    // Cache creation failed, continue without explicit cache
    console.warn("[Moderation] Cache creation failed, using implicit cache:", error);
  }
  return null;
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const { content_type, content_id, text } = (await req.json()) as {
      content_type?: string;
      content_id?: string;
      text: string;
    };
    if (!text || typeof text !== "string") {
      return new Response(
        JSON.stringify({ error: "text required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Rule-based fallback; when GEMINI_API_KEY is set, use Gemini safety.
    let isSafe = !/\b(spam|harm)\b/i.test(text);
    const apiKey = Deno.env.get("GEMINI_API_KEY");
    if (apiKey && text.length > 0) {
      // System instructions first for implicit cache optimization
      const systemInstructions = `Role: You are a content moderation system.
Goal: Evaluate if content violates safety guidelines.
Constraints: Use built-in safety filters only, no additional analysis needed.`;
      
      // Try to use explicit caching for system instructions (optional optimization)
      // Falls back to implicit caching if explicit cache fails
      const cacheToken = await getOrCreateCache(apiKey, systemInstructions);
      
      let retries = 0;
      const maxRetries = 3;
      let lastError: Error | null = null;
      
      while (retries < maxRetries) {
        try {
          // Build request body with optional explicit cache
          const requestBody: any = {
            generationConfig: {
              thinkingLevel: "low",
            },
            safetySettings: [
              { category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
              { category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
              { category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
              { category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" },
            ],
          };
          
          // Use explicit cache if available, otherwise use implicit cache (system instructions first)
          if (cacheToken) {
            requestBody.cachedContent = cacheToken;
            requestBody.contents = [{ parts: [{ text: `Content to moderate: "${text}"` }] }];
          } else {
            // Implicit cache: system instructions first
            requestBody.contents = [{ parts: [{ text: `${systemInstructions}\n\nContent to moderate: "${text}"` }] }];
          }
          
          const res = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${apiKey}`,
            {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify(requestBody),
            }
          );
          
          if (!res.ok) {
            // Handle rate limits (429) with exponential backoff
            if (res.status === 429 && retries < maxRetries - 1) {
              const delay = Math.pow(2, retries) * 1000; // 1s, 2s, 4s
              await new Promise(resolve => setTimeout(resolve, delay));
              retries++;
              continue;
            }
            throw new Error(`API error: ${res.status} ${res.statusText}`);
          }
          
          const data = await res.json();
          
          // Log usage metadata for cost monitoring
          if (data?.usageMetadata) {
            console.log(`[Moderation] Tokens - Input: ${data.usageMetadata.promptTokenCount}, Output: ${data.usageMetadata.candidatesTokenCount}, Total: ${data.usageMetadata.totalTokenCount}`);
          }
          
          const block = data?.promptFeedback?.blockReason != null;
          isSafe = !block;
          break; // Success, exit retry loop
        } catch (error) {
          lastError = error as Error;
          if (retries < maxRetries - 1) {
            const delay = Math.pow(2, retries) * 1000;
            await new Promise(resolve => setTimeout(resolve, delay));
            retries++;
          } else {
            // Max retries reached, use rule-based fallback
            console.error(`[Moderation] Failed after ${maxRetries} retries:`, lastError);
            break;
          }
        }
      }
    }
    const status = isSafe ? "approved" : "quarantined";

    return new Response(
      JSON.stringify({ status, content_type, content_id }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
