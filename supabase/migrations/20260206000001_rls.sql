-- RLS: enable on all tables and add policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.collection_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mutes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_stats_daily ENABLE ROW LEVEL SECURITY;

-- Profiles: read all, update own
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Categories: read all
CREATE POLICY "Categories are viewable by everyone" ON public.categories FOR SELECT USING (true);

-- Posts: read approved, insert/update/delete own
CREATE POLICY "Approved posts viewable by everyone" ON public.posts FOR SELECT USING (moderation_status = 'approved');
CREATE POLICY "Users can insert own posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts" ON public.posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own posts" ON public.posts FOR DELETE USING (auth.uid() = author_id);

-- Lessons: same as posts
CREATE POLICY "Approved lessons viewable by everyone" ON public.lessons FOR SELECT USING (moderation_status = 'approved');
CREATE POLICY "Users can insert own lessons" ON public.lessons FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own lessons" ON public.lessons FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own lessons" ON public.lessons FOR DELETE USING (auth.uid() = author_id);

-- Lesson sections: read with lesson, write with lesson owner
CREATE POLICY "Lesson sections viewable with lesson" ON public.lesson_sections FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.lessons l WHERE l.id = lesson_id AND l.moderation_status = 'approved'));
CREATE POLICY "Users can manage sections of own lessons" ON public.lesson_sections FOR ALL
  USING (EXISTS (SELECT 1 FROM public.lessons l WHERE l.id = lesson_id AND l.author_id = auth.uid()));

-- Collections: read public or own
CREATE POLICY "Public collections viewable" ON public.collections FOR SELECT USING (is_public OR owner_id = auth.uid());
CREATE POLICY "Users can manage own collections" ON public.collections FOR ALL USING (auth.uid() = owner_id);

-- Collection items: with collection access
CREATE POLICY "Collection items viewable with collection" ON public.collection_items FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.collections c WHERE c.id = collection_id AND (c.is_public OR c.owner_id = auth.uid())));
CREATE POLICY "Users can manage items in own collections" ON public.collection_items FOR ALL
  USING (EXISTS (SELECT 1 FROM public.collections c WHERE c.id = collection_id AND c.owner_id = auth.uid()));

-- Content sources: with lesson access
CREATE POLICY "Content sources viewable with lesson" ON public.content_sources FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.lessons l WHERE l.id = lesson_id AND l.moderation_status = 'approved'));
CREATE POLICY "Users can manage sources of own lessons" ON public.content_sources FOR ALL
  USING (EXISTS (SELECT 1 FROM public.lessons l WHERE l.id = lesson_id AND l.author_id = auth.uid()));

-- Follows: read all, insert/delete own
CREATE POLICY "Follows viewable by everyone" ON public.follows FOR SELECT USING (true);
CREATE POLICY "Users can follow" ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow" ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- Comments: read all, insert/update/delete own
CREATE POLICY "Comments viewable by everyone" ON public.comments FOR SELECT USING (true);
CREATE POLICY "Users can insert comments" ON public.comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own comments" ON public.comments FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own comments" ON public.comments FOR DELETE USING (auth.uid() = author_id);

-- Reactions: read all, insert/delete own
CREATE POLICY "Reactions viewable by everyone" ON public.reactions FOR SELECT USING (true);
CREATE POLICY "Users can add reactions" ON public.reactions FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can remove own reactions" ON public.reactions FOR DELETE USING (auth.uid() = user_id);

-- Reports: insert own, read own
CREATE POLICY "Users can report" ON public.reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Users can view own reports" ON public.reports FOR SELECT USING (auth.uid() = reporter_id);

-- Blocks: own rows only
CREATE POLICY "Users can view own blocks" ON public.blocks FOR SELECT USING (auth.uid() = blocker_id);
CREATE POLICY "Users can block" ON public.blocks FOR INSERT WITH CHECK (auth.uid() = blocker_id);
CREATE POLICY "Users can unblock" ON public.blocks FOR DELETE USING (auth.uid() = blocker_id);

-- Mutes: own rows only
CREATE POLICY "Users can view own mutes" ON public.mutes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can mute" ON public.mutes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unmute" ON public.mutes FOR DELETE USING (auth.uid() = user_id);

-- User interactions: own only
CREATE POLICY "Users can view own interactions" ON public.user_interactions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own interactions" ON public.user_interactions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Creator stats: read own or public profile
CREATE POLICY "Creator stats viewable for profile" ON public.creator_stats_daily FOR SELECT
  USING (profile_id = auth.uid() OR true);
