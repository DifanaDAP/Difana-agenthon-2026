# Database Schema — Gina Agency (Social Media Engine)

## Overview
PostgreSQL dengan 4 schemas untuk menyimpan data dari 3 agents.
Schema-per-agent pattern — satu database, namespace terpisah.

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│              PostgreSQL (single instance)                      │
├──────────────┬──────────────┬──────────────┬─────────────────┤
│  research_db │  content_db  │ engagement_db│   system_db     │
│  (Agent 01)  │  (Agent 02)  │  (Agent 03)  │   (Shared)      │
├──────────────┴──────────────┴──────────────┴─────────────────┤
│                    🔑 14 tables total                          │
└──────────────────────────────────────────────────────────────┘
```

## Schema Details

### 🔍 research_db (Scraping Results)

| Table | Columns | Description |
|---|---|---|
| `niches` | id, name, keywords[], tone_of_voice, target_platforms[], created_at | Daftar niche yang di-monitor |
| `hashtag_results` | id, niche_id FK, hashtag, score, post_count, platform, scraped_at | Hashtag trending + engagement score |
| `content_ideas` | id, niche_id FK, title, angle, platform, created_at | Ide konten dari data viral |
| `competitor_benchmarks` | id, niche_id FK, competitor_handle, platform, top_posts(JSONB), avg_engagement, scraped_at | Benchmark kompetitor |

### ✍️ content_db (Content & Drafts)

| Table | Columns | Description |
|---|---|---|
| `content_drafts` | id, niche_id FK, idea_id FK, **caption**, hashtags, cta, media_url, image_prompt, video_prompt, platform, status, scheduled_at, posted_at, created_at | Caption + prompt AI image/video + media links |
| `image_assets` | id, draft_id FK, storage_path, prompt_used, model, generated_at | Path gambar AI + prompt |
| `post_schedule` | id, draft_id FK, platform, scheduled_at, posted_at, post_url, status | Jadwal posting |

### 💬 engagement_db (Interactions)

| Table | Columns | Description |
|---|---|---|
| `comment_logs` | id, post_id FK, platform, commenter_handle, **comment_text**, sentiment, received_at | Semua komentar masuk |
| `reply_logs` | id, comment_id FK, **reply_text**, generated_by, status, replied_at | Balasan yang dikirim |
| `spam_filters` | id, niche_id FK, pattern, action, is_active, created_at | Pola spam + tindakan |
| `dm_logs` | id, niche_id FK, sender_handle, message_text, reply_text, platform, received_at | Inbox DM |

### ⚙️ system_db (Shared Config)

| Table | Columns | Description |
|---|---|---|
| `users` | id, email, plan, created_at | Data user/langganan |
| `api_credentials` | id, user_id FK, service, api_key_enc, created_at | API key terenkripsi |
| `agent_run_logs` | id, agent, niche_id FK, status, error_msg, started_at, finished_at | Log eksekusi agent |

## Setup

```bash
# 1. Create database & run schema
psql "$DATABASE_URL" -f init_db.sql

# 2. Verify
psql "$DATABASE_URL" -c "\dn"  # should show 4 schemas
```

## Hosting

- **Production:** sumobase.my.id (PostgreSQL 16)
- **Future:** bisa migrasi ke Supabase / Railway / RDS kapan aja
