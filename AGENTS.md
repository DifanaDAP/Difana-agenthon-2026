# AGENTS.md — Gina Agency Multi-Agent System

## ⚙️ System Overview

**Gina Agency** — multi-agent social media marketing engine.
Gina (main agent) acts as **Orchestrator**, managing 3 specialist sub-agents:

```
┌─────────────────────────────────────────────────────────┐
│                    GINA (Orchestrator)                    │
│     Strategy · Quality Control · Client Liaison           │
├──────────┬──────────────────────┬───────────────────────┤
│ Agent 01  │     Agent 02         │      Agent 03          │
│ Research  │   Content Creator    │    Engagement           │
│ 🔍        │     ✍️               │      💬                 │
│ DataDrift │   CopyForge          │    EchoGuard            │
├──────────┴──────────────────────┴───────────────────────┤
│               PostgreSQL (4 Schemas)                      │
│   research_db │ content_db │ engagement_db │ system_db     │
└─────────────────────────────────────────────────────────┘
```

## Agent Locations

| Agent | ID | Workspace |
|---|---|---|
| 🔍 Research (DataDrift) | `research_agent` | `./research_agent/` |
| ✍️ Content (CopyForge) | `content_creator` | `./content_creator/` |
| 💬 Engagement (EchoGuard) | `engagement_agent` | `./engagement_agent/` |

## Services & API Keys

| Service | Fungsi | API Key |
|---|---|---|
| **Apify** | Scrape Instagram + TikTok | `APIFY_API_TOKEN` |
| **Repliz** | Comment/DM automation | `REPLIZ_API_KEY` |
| **PostgreSQL** | Database (sumobase) | `DATABASE_URL` |

> ⚠️ API keys disimpan di `.env` — jangan di-commit ke GitHub.

## Platform Fokus

- **Instagram** (primary) — via `apify/instagram-scraper`
- **TikTok** (secondary) — via `clockworks/free-tiktok-scraper`
- **Lokasi:** Indonesia only

## Orchestration Rules

1. **Gina is the sole entry point.** Fauzan only talks to Gina.
2. **Data flows sequentially:** Research → Content → Engagement.
3. **Sub-agents spawned on-demand** via `sessions_spawn`.
4. **Quality gate at each handoff:** Gina reviews before passing to next agent.
5. **Output files:** `Trend_Report.md` → `Content_Calendar.md` → `Engagement_Report.md`.
6. **All data saved to DB** after each agent run.

## Database Schema

Single PostgreSQL instance, 4 schemas:

| Schema | Tabel | Data |
|---|---|---|
| `research_db` | niches, hashtag_results, content_ideas, competitor_benchmarks | Hasil scraping & analisis |
| `content_db` | content_drafts, image_assets, post_schedule | Draft konten & caption |
| `engagement_db` | comment_logs, reply_logs, spam_filters, dm_logs | Interaksi & auto-reply |
| `system_db` | users, api_credentials, agent_run_logs | Konfigurasi & audit |
