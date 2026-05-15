-- =========================================================
-- Gina Agency — Database Schema untuk Social Media Engine
-- Target: PostgreSQL (Supabase / Railway / Render)
-- =========================================================

-- Buat schema per agent
CREATE SCHEMA IF NOT EXISTS research_db;
CREATE SCHEMA IF NOT EXISTS content_db;
CREATE SCHEMA IF NOT EXISTS engagement_db;
CREATE SCHEMA IF NOT EXISTS system_db;

-- =========================================================
-- AGENT 01: RESEARCH_DB
-- Hasil scraping Apify & analisis TikTok
-- =========================================================

CREATE TABLE research_db.niches (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(255) NOT NULL UNIQUE,
    keywords        TEXT[] DEFAULT '{}',
    tone_of_voice   VARCHAR(100),
    target_platforms TEXT[] DEFAULT '{}',
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE research_db.hashtag_results (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche_id    UUID NOT NULL REFERENCES research_db.niches(id) ON DELETE CASCADE,
    hashtag     VARCHAR(255) NOT NULL,
    score       INT DEFAULT 0,
    post_count  BIGINT DEFAULT 0,
    platform    VARCHAR(50) NOT NULL,
    scraped_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE research_db.content_ideas (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche_id    UUID NOT NULL REFERENCES research_db.niches(id) ON DELETE CASCADE,
    title       VARCHAR(255) NOT NULL,
    angle       TEXT,
    platform    VARCHAR(50),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE research_db.competitor_benchmarks (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche_id          UUID NOT NULL REFERENCES research_db.niches(id) ON DELETE CASCADE,
    competitor_handle VARCHAR(255) NOT NULL,
    platform          VARCHAR(50) NOT NULL,
    top_posts         JSONB DEFAULT '[]',
    avg_engagement    FLOAT DEFAULT 0,
    scraped_at        TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- AGENT 02: CONTENT_DB
-- Draft konten, gambar AI, jadwal posting
-- =========================================================

CREATE TABLE content_db.content_drafts (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche_id      UUID REFERENCES research_db.niches(id) ON DELETE SET NULL,
    idea_id       UUID REFERENCES research_db.content_ideas(id) ON DELETE SET NULL,
    caption       TEXT NOT NULL,
    platform      VARCHAR(50) NOT NULL,
    status        VARCHAR(50) DEFAULT 'draft' CHECK (status IN ('draft', 'review', 'approved', 'scheduled', 'posted', 'cancelled')),
    scheduled_at  TIMESTAMPTZ,
    posted_at     TIMESTAMPTZ,
    created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE content_db.image_assets (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    draft_id      UUID NOT NULL REFERENCES content_db.content_drafts(id) ON DELETE CASCADE,
    storage_path  VARCHAR(500) NOT NULL,
    prompt_used   TEXT,
    model         VARCHAR(100),
    generated_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE content_db.post_schedule (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    draft_id      UUID NOT NULL REFERENCES content_db.content_drafts(id) ON DELETE CASCADE,
    platform      VARCHAR(50) NOT NULL,
    scheduled_at  TIMESTAMPTZ NOT NULL,
    posted_at     TIMESTAMPTZ,
    post_url      VARCHAR(500),
    status        VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'posted', 'failed', 'cancelled'))
);

-- =========================================================
-- AGENT 03: ENGAGEMENT_DB
-- Komentar, reply otomatis, spam filter
-- =========================================================

CREATE TABLE engagement_db.comment_logs (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id           UUID REFERENCES content_db.post_schedule(id) ON DELETE SET NULL,
    platform          VARCHAR(50) NOT NULL,
    commenter_handle  VARCHAR(255) NOT NULL,
    comment_text      TEXT NOT NULL,
    sentiment         VARCHAR(50) CHECK (sentiment IN ('positive', 'negative', 'neutral', 'spam')),
    received_at       TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE engagement_db.reply_logs (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    comment_id    UUID NOT NULL REFERENCES engagement_db.comment_logs(id) ON DELETE CASCADE,
    reply_text    TEXT NOT NULL,
    generated_by  VARCHAR(100) DEFAULT 'ai',
    status        VARCHAR(50) DEFAULT 'sent' CHECK (status IN ('sent', 'pending_review', 'rejected')),
    replied_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE engagement_db.spam_filters (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche_id    UUID REFERENCES research_db.niches(id) ON DELETE CASCADE,
    pattern     VARCHAR(500) NOT NULL,
    action      VARCHAR(50) NOT NULL CHECK (action IN ('hide', 'delete', 'flag', 'silence')),
    is_active   BOOLEAN DEFAULT TRUE,
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE engagement_db.dm_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    niche_id        UUID REFERENCES research_db.niches(id) ON DELETE SET NULL,
    sender_handle   VARCHAR(255) NOT NULL,
    message_text    TEXT NOT NULL,
    reply_text      TEXT,
    platform        VARCHAR(50) NOT NULL,
    received_at     TIMESTAMPTZ DEFAULT NOW()
);

-- =========================================================
-- SHARED: SYSTEM_DB
-- Config user, run log, audit trail
-- =========================================================

CREATE TABLE system_db.users (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email       VARCHAR(255) UNIQUE NOT NULL,
    plan        VARCHAR(50) DEFAULT 'free' CHECK (plan IN ('free', 'pro', 'enterprise')),
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE system_db.api_credentials (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID REFERENCES system_db.users(id) ON DELETE CASCADE,
    service         VARCHAR(100) NOT NULL,
    api_key_enc     TEXT NOT NULL,  -- encrypted via pgcrypto or app-level
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE system_db.agent_run_logs (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent       VARCHAR(100) NOT NULL,
    niche_id    UUID REFERENCES research_db.niches(id) ON DELETE SET NULL,
    status      VARCHAR(50) NOT NULL CHECK (status IN ('started', 'running', 'completed', 'failed')),
    error_msg   TEXT,
    started_at  TIMESTAMPTZ DEFAULT NOW(),
    finished_at TIMESTAMPTZ
);

-- =========================================================
-- Indexes untuk performa query
-- =========================================================

CREATE INDEX idx_hashtag_niche ON research_db.hashtag_results(niche_id);
CREATE INDEX idx_hashtag_platform ON research_db.hashtag_results(platform);
CREATE INDEX idx_ideas_niche ON research_db.content_ideas(niche_id);
CREATE INDEX idx_competitor_niche ON research_db.competitor_benchmarks(niche_id);
CREATE INDEX idx_drafts_status ON content_db.content_drafts(status);
CREATE INDEX idx_drafts_niche ON content_db.content_drafts(niche_id);
CREATE INDEX idx_schedule_status ON content_db.post_schedule(status);
CREATE INDEX idx_comments_post ON engagement_db.comment_logs(post_id);
CREATE INDEX idx_comments_sentiment ON engagement_db.comment_logs(sentiment);
CREATE INDEX idx_spam_active ON engagement_db.spam_filters(is_active);
CREATE INDEX idx_run_logs_agent ON system_db.agent_run_logs(agent);
CREATE INDEX idx_run_logs_status ON system_db.agent_run_logs(status);
