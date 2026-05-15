# 🏢 Gina Agency — Multi-Agent Social Media Marketing Engine

> **Gina Agency** adalah sistem multi-agent otomatis untuk riset tren, pembuatan konten, dan manajemen engagement sosial media —全部 dalam satu pipeline.

## 🧠 Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                        GINA (Orchestrator)                    │
│                  Entry point — kamu hanya ngobrol sama Gina   │
├──────────────────┬──────────────────┬────────────────────────┤
│   🔍 DataDrift   │   ✍️ CopyForge   │   💬 EchoGuard        │
│   Research Agent │   Content Agent  │   Engagement Agent     │
├──────────────────┴──────────────────┴────────────────────────┤
│                    PostgreSQL (4 Schemas)                      │
│   research_db  │  content_db  │  engagement_db  │  system_db  │
└──────────────────────────────────────────────────────────────┘
```

## 🔄 Alur Data

```
User Input → RESEARCH (scrape Instagram/TikTok) 
           → QUALITY GATE (Gina review) 
           → CONTENT (generate caption + visual prompt) 
           → QUALITY GATE (Gina review) 
           → ENGAGEMENT (monitor comments, auto-reply, DM)
           → DATABASE (semua data tersimpan)
```

## 🤖 Agents

| Agent | Nama | Tugas | Tools |
|---|---|---|---|
| 🔍 Research | **DataDrift** | Scrape trending, analisis hashtag, competitor benchmark | Apify (Instagram + TikTok) |
| ✍️ Content | **CopyForge** | Generate caption, hook, visual prompt | LLM (GLM 5.1) |
| 💬 Engagement | **EchoGuard** | Auto-reply komentar, DM, spam filter | Repliz API |

## 🗄️ Database Schema

PostgreSQL — 4 schemas, 14 tables:

| Schema | Tabel | Fungsi |
|---|---|---|
| `research_db` | niches, hashtag_results, content_ideas, competitor_benchmarks | Data riset & tren |
| `content_db` | content_drafts, image_assets, post_schedule | Draft konten & jadwal |
| `engagement_db` | comment_logs, reply_logs, spam_filters, dm_logs | Engagement & reply |
| `system_db` | users, api_credentials, agent_run_logs | Konfigurasi & audit |

## 🚀 Stack

- **Runtime:** OpenClaw (Node.js)
- **Model:** GLM 5.1 (via SumoPod API)
- **Database:** PostgreSQL 16 (sumobase)
- **Scraping:** Apify (Instagram Scraper + TikTok Scraper)
- **Engagement:** Repliz API
- **Hosting:** Self-hosted (VPS Ubuntu)

## 📦 Setup

1. Clone repo
2. Copy `.env.example` → `.env` dan isi credentials
3. Jalankan `init_db.sql` ke PostgreSQL
4. Register agents di OpenClaw config
5. Mulai!

## 📄 Lisensi

Internal — Fauzan © 2026
