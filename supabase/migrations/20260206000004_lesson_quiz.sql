-- Lesson quiz questions (Option A from plan)
CREATE TABLE public.lesson_quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  sort_order INT NOT NULL DEFAULT 0,
  question TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]',
  correct_index INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_lesson_quiz_questions_lesson ON public.lesson_quiz_questions(lesson_id, sort_order);

-- Lesson attempts: store quiz answers for analytics/streaks
CREATE TABLE public.lesson_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  answers_json JSONB NOT NULL DEFAULT '{}',
  score INT,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (lesson_id, user_id)
);

CREATE INDEX idx_lesson_attempts_user ON public.lesson_attempts(user_id);

-- RLS
ALTER TABLE public.lesson_quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Quiz questions viewable with lesson" ON public.lesson_quiz_questions FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.lessons l WHERE l.id = lesson_id AND l.moderation_status = 'approved'));
CREATE POLICY "Users can manage quiz of own lessons" ON public.lesson_quiz_questions FOR ALL
  USING (EXISTS (SELECT 1 FROM public.lessons l WHERE l.id = lesson_id AND l.author_id = auth.uid()));

CREATE POLICY "Users can view own attempts" ON public.lesson_attempts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own attempts" ON public.lesson_attempts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own attempts" ON public.lesson_attempts FOR UPDATE USING (auth.uid() = user_id);
