-- Disable rate limiting triggers for bulk insert
ALTER TABLE public.posts DISABLE TRIGGER rate_limit_posts;

-- =============================================
-- MORE POSTS (Micro-learning) - Batch 2
-- =============================================

-- Tech
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Zero Knowledge Proofs: A method to prove you know something (like a password) without revealing the thing itself. It''s crucial for privacy-preserving authentication and secure transactions.', 'hard', 50, 'approved' FROM public.categories WHERE slug = 'tech';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'RISC-V is an open standard instruction set architecture (ISA). Unlike proprietary ARM or x86, it''s free to use. It''s enabling a new wave of custom, efficient chips for IoT and AI.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'tech';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'GraphQL vs REST: GraphQL allows clients to request exactly the data they need, preventing over-fetching. REST endpoints return fixed structures. GraphQL is more flexible for complex frontends.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'tech';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Solid State Batteries: Replacing the liquid electrolyte in Li-ion batteries with a solid one. They are safer, charge faster, and hold more energy. They are the holy grail for EVs.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'tech';

-- Science
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Epigenetics: Your genes aren''t your destiny. Environmental factors (diet, stress) can switch genes on or off without changing the DNA sequence itself. These changes can even be inherited.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'science';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Neutron Stars: The collapsed core of a massive star. They are so dense that a teaspoon of neutron star material would weigh about 6 billion tons on Earth.', 'easy', 30, 'approved' FROM public.categories WHERE slug = 'science';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Double Slit Experiment: Light behaves as both a particle and a wave. When observed, it acts like particles. When unobserved, it acts like waves. Observation affects reality at the quantum level.', 'hard', 55, 'approved' FROM public.categories WHERE slug = 'science';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Mycelium Networks: Fungi create vast underground networks ("Wood Wide Web") that connect trees, allowing them to share nutrients and send warning signals about pests.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'science';

-- Productivity
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Batching: Grouping similar tasks together (e.g., checking email only twice a day). It reduces the "switching cost" of your brain jumping between different contexts.', 'easy', 30, 'approved' FROM public.categories WHERE slug = 'productivity';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Eisenhower Matrix: Categorize tasks by Urgency and Importance. Do (Urgent & Important), Decide (Important, Not Urgent), Delegate (Urgent, Not Important), Delete (Neither).', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'productivity';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Digital Minimalism: Curating your digital tools to support your values. Turning off non-human notifications and greyscaling your phone screen can drastically reduce screen time.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'productivity';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Zeigarnik Effect: Unfinished tasks occupy more mental space than finished ones. Writing them down in a trusted system (like GTD) clears your mind and reduces anxiety.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'productivity';

-- Design
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Color Theory: Complementary colors (opposite on wheel) create high contrast and impact. Analogous colors (next to each other) create harmony and serenity.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'design';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Golden Ratio (1.618): A mathematical ratio found in nature (nautilus shells) that humans find aesthetically pleasing. Use it to proportion layout grids and typography.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'design';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Skeuomorphism vs Flat: Skeuomorphism mimics real-world textures (leather, wood). Flat design removes them. Neumorphism blends them with soft shadows for a "soft plastic" look.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'design';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Gestalt Principles: The brain groups visual elements. Proximity (things close together belong together) and Similarity (things looking alike belong together) are key for UI grouping.', 'hard', 50, 'approved' FROM public.categories WHERE slug = 'design';

-- Business
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Flywheel Effect: Small wins accumulate over time, creating momentum. Eventually, the wheel spins on its own. Amazon''s flywheel: Lower prices -> More customers -> More sellers -> Lower cost structure -> Lower prices.', 'medium', 50, 'approved' FROM public.categories WHERE slug = 'business';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'TAM, SAM, SOM: Total Addressable Market (everyone who could buy), Serviceable Available Market (who you can reach), Serviceable Obtainable Market (who you can realistically capture).', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'business';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Churn Rate: The percentage of customers who stop using your product. High churn kills growth. It''s cheaper to retain an existing customer than to acquire a new one.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'business';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Moat: A sustainable competitive advantage. Examples: Brand (Apple), Switching Costs (Salesforce), Network Effects (Facebook), Cost Advantage (Costco).', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'business';

-- Health
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Hormesis: "What doesn''t kill you makes you stronger." Controlled stress (like exercise, sauna, cold plunges) triggers adaptive responses that improve resilience and health.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'health';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Gut Microbiome: Your gut bacteria influence your mood, immune system, and weight. Eating fermented foods (yogurt, kimchi) and fiber supports a healthy diverse microbiome.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'health';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Zone 2 Cardio: Exercise at an intensity where you can hold a conversation. It builds mitochondrial efficiency and endurance base without the fatigue of high-intensity intervals.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'health';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Cortisol: The stress hormone. Chronic high cortisol (from constant stress) leads to inflammation, weight gain, and sleep issues. Stress management is a health necessity.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'health';

-- Learning
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Memory Palace (Method of Loci): Visualize a familiar place (your house). Place items you want to remember in specific locations. Walking through the "palace" allows you to recall the items.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'learning';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Diffuse vs Focused Mode: Focused mode is concentrated study. Diffuse mode is letting your mind wander (shower, walk). Deep insights often come when the brain connects dots in diffuse mode.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'learning';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Pareto Distribution in Learning: 20% of the vocabulary allows you to understand 80% of a language. Focus on the most frequently used concepts first.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'learning';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Sleep-Dependent Memory Processing: Your brain replays and consolidates what you learned while you sleep. pulling an all-nighter to study is counter-productive; you need sleep to keep the memories.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'learning';

-- History
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Silk Road: Not just a trade route for silk, but a superhighway for ideas, religions (Buddhism), and technologies (gunpowder, paper) between East and West for centuries.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'history';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Rosetta Stone: Discovered in 1799, it contained the same text in Greek, Demotic, and Hieroglyphics. This allowed scholars to finally decipher Ancient Egyptian hieroglyphs.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'history';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Black Death (1347): Killed 30-60% of Europe''s population. Ironically, the labor shortage empowered surviving peasants to demand higher wages, helping end the feudal system.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'history';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'The Wright Brothers (1903): Their first flight lasted only 12 seconds and covered 120 feet. Within 66 years, humans landed on the moon. Technological progress is exponential.', 'easy', 30, 'approved' FROM public.categories WHERE slug = 'history';

-- Psychology
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Loss Aversion: The pain of losing $100 is psychologically twice as powerful as the pleasure of gaining $100. This bias drives conservative decision-making and insurance markets.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'psychology';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Flow State: The optimal zone where challenge matches skill. Too hard = anxiety; too easy = boredom. Flow is where peak performance and happiness occur.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'psychology';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Groupthink: The desire for harmony in a group results in irrational decision-making. Dissenting opinions are suppressed. To avoid it, appoint a "Devil''s Advocate" in meetings.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'psychology';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Reciprocity: If someone does something nice for you, you feel a deep urge to do something nice back. Marketers use this by giving "free samples" to trigger a purchase.', 'easy', 35, 'approved' FROM public.categories WHERE slug = 'psychology';

-- Finance
INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Asset Allocation: How you divide your portfolio (stocks, bonds, cash, crypto). It is the single biggest determinant of your investment returns, more than picking individual stocks.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'finance';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Bull vs Bear Markets: Bull = optimism, prices rising. Bear = pessimism, prices falling (usually >20%). Markets cycle. "Bull markets are born on pessimism, grow on skepticism, mature on optimism, and die on euphoria."', 'easy', 40, 'approved' FROM public.categories WHERE slug = 'finance';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'FIRE (Financial Independence, Retire Early): The concept that if you save 25x your annual expenses, you can retire and live off the 4% withdrawal rate from your investments indefinitely.', 'medium', 45, 'approved' FROM public.categories WHERE slug = 'finance';

INSERT INTO public.posts (author_id, category_id, body, difficulty, time_to_read_sec, moderation_status)
SELECT '00000000-0000-0000-0000-000000000001', id, 'Arbitrage: Buying an asset in one market and selling it in another for a higher price. It exploits price differences. Risk-free profit, theoretically, though transaction costs apply.', 'medium', 40, 'approved' FROM public.categories WHERE slug = 'finance';

-- Re-enable rate limiting triggers
ALTER TABLE public.posts ENABLE TRIGGER rate_limit_posts;
