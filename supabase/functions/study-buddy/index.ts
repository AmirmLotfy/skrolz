// Study Buddy (premium): "2 tips + 1 action + 1 micro-quiz question" format; result moderated
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

    const { topic, content_id } = (await req.json()) as { topic?: string; content_id?: string };
    const subject = topic ?? (content_id ? `content ${content_id}` : "this topic");

    const apiKey = Deno.env.get("GEMINI_API_KEY");
    let result = {
      tips: ["Review key terms.", "Practice once before bed."],
      action: "Spend 5 minutes summarizing in your own words.",
      question: "What is the main idea?",
      options: ["Option A", "Option B", "Option C"],
      correct_index: 0,
    };
    if (apiKey) {
      // System instructions first for implicit cache optimization
      const systemInstructions = `Role: You are an expert study buddy and educational assistant.
Goal: Generate personalized study tips, actionable steps, and quiz questions.
Constraints:
- Tips must be practical and actionable
- Actions must be specific and time-bound
- Quiz questions must test understanding, not memorization
- Options must be plausible distractors
Output Format: Valid JSON only, no markdown formatting.`;
      
      // Optimized prompt structure: Role + Goal + Constraints + Examples + Output format
      const prompt = `${systemInstructions}

Topic: "${subject}"

Generate a JSON object with exactly:
{
  "tips": ["tip1", "tip2"],  // Exactly 2 short study tips (strings, max 100 chars each)
  "action": "concrete action",  // One specific action (string, max 150 chars)
  "question": "quiz question",  // One multiple-choice question (string, max 200 chars)
  "options": ["option1", "option2", "option3"],  // Exactly 3 answer options (strings, max 100 chars each)
  "correct_index": 0  // 0-based index of correct option (number, 0-2)
}`;

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
                  responseMimeType: "application/json",
                  maxOutputTokens: 1024,
                  thinkingLevel: "high",
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
            console.log(`[StudyBuddy] Tokens - Input: ${data.usageMetadata.promptTokenCount}, Output: ${data.usageMetadata.candidatesTokenCount}, Total: ${data.usageMetadata.totalTokenCount}`);
          }
          
          const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
          if (text && typeof text === "string") {
            // Enhanced JSON parsing with better error handling
            let parsed: any;
            try {
              const cleaned = text.replace(/^```json\s*|\s*```$/g, "").trim();
              parsed = JSON.parse(cleaned);
            } catch (parseError) {
              // Try to extract JSON from markdown or other formats
              const jsonMatch = text.match(/\{[\s\S]*\}/);
              if (jsonMatch) {
                parsed = JSON.parse(jsonMatch[0]);
              } else {
                throw new Error("No valid JSON found in response");
              }
            }
            
            // Schema validation with type checking
            if (parsed && typeof parsed === "object") {
              if (Array.isArray(parsed.tips) && parsed.tips.length >= 2) {
                result.tips = parsed.tips.slice(0, 2).filter((t: any) => typeof t === "string" && t.length <= 100);
              }
              if (typeof parsed.action === "string" && parsed.action.length <= 150) {
                result.action = parsed.action;
              }
              if (typeof parsed.question === "string" && parsed.question.length <= 200) {
                result.question = parsed.question;
              }
              if (Array.isArray(parsed.options) && parsed.options.length >= 3) {
                result.options = parsed.options.slice(0, 3).filter((o: any) => typeof o === "string" && o.length <= 100);
              }
              if (typeof parsed.correct_index === "number" && 
                  parsed.correct_index >= 0 && 
                  parsed.correct_index < (parsed.options?.length ?? result.options.length)) {
                result.correct_index = parsed.correct_index;
              }
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
            // Max retries reached, use default result
            console.error(`[StudyBuddy] Failed after ${maxRetries} retries:`, lastError);
            break;
          }
        }
      }
    }

    return new Response(
      JSON.stringify(result),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
