// AI Post Generator: topic + tone + length -> 1-3 variants; then moderate-content before return
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

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

    const { topic, tone, target_length } = (await req.json()) as {
      topic: string;
      tone?: string;
      target_length?: "short" | "medium";
    };
    if (!topic) {
      return new Response(
        JSON.stringify({ error: "topic required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    let variants: string[] = [];
    if (apiKey) {
      // System instructions first for implicit cache optimization
      const systemInstructions = `Role: You are an expert social media content creator.
Goal: Generate engaging, unique social media posts.
Constraints:
- Maximum 280 characters per post
- Each post must be distinct and engaging
- No numbering, labels, or prefixes
Output Format: Return only the posts, one per line, no additional text.`;
      
      // Optimized prompt structure: Role + Goal + Constraints + Output format
      // Token ordering: system instructions first for implicit cache hits
      const prompt = `${systemInstructions}

Topic: "${topic}"
Tone: ${tone ?? "neutral"}
Length: ${target_length ?? "short"}

Generate exactly 3 different post variants:`;

      let retries = 0;
      const maxRetries = 3;
      let lastError: Error | null = null;
      
      while (retries < maxRetries) {
        try {
          const res = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${apiKey}`,
            {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({
                contents: [{ parts: [{ text: prompt }] }],
                generationConfig: {
                  maxOutputTokens: 1024,
                  temperature: 1.0, // Gemini 3 default for optimal reasoning
                  thinkingLevel: "low",
                },
              }),
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
            console.log(`[GeneratePost] Tokens - Input: ${data.usageMetadata.promptTokenCount}, Output: ${data.usageMetadata.candidatesTokenCount}, Total: ${data.usageMetadata.totalTokenCount}`);
          }
          
          const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
          if (text && typeof text === "string") {
            // Enhanced validation: filter and validate each variant
            variants = text
              .split("\n")
              .map((s: string) => s.trim())
              .filter((s: string) => {
                // Validate: non-empty, within character limit, not just numbers/bullets
                return s.length > 0 && 
                       s.length <= 280 && 
                       !/^[\d\-\*\+\.\s]+$/.test(s); // Reject lines that are just formatting
              })
              .slice(0, 3);
            
            // Ensure we have at least one valid variant
            if (variants.length === 0) {
              throw new Error("No valid variants generated");
            }
          }
          break; // Success, exit retry loop
        } catch (error) {
          lastError = error as Error;
          if (retries < maxRetries - 1) {
            const delay = Math.pow(2, retries) * 1000;
            await new Promise(resolve => setTimeout(resolve, delay));
            retries++;
          } else {
            // Max retries reached, use fallback
            console.error(`[GeneratePost] Failed after ${maxRetries} retries:`, lastError);
            break;
          }
        }
      }
    }
    if (variants.length === 0) {
      variants = [`Post about "${topic}" (${tone ?? "neutral"}, ${target_length ?? "short"}).`];
    }

    return new Response(
      JSON.stringify({ variants }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
