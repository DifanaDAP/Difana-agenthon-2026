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

## 🔄 Flowchart Alur Kerja

```
┌─────────────────────────────────────────────────────────────────┐
│                         GINA (Orchestrator)                      │
│                   Kamu → Ngobrol → Delegasi → Review             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │      📋 USER TASK       │
              │  (Niche/Topic/Platform)  │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   🔍 DATADRIFT          │
              │   Research Agent        │
              │                         │
              │ • Scrape Instagram 🇮🇩  │
              │ • Scrape TikTok 🇮🇩     │
              │ • Analisis hashtag      │
              │ • Competitor benchmark  │
              │ • Save to research_db   │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   ✅ QUALITY GATE       │
              │   (Gina review data)    │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   ✍️ COPYFORGE          │
              │   Content Agent         │
              │                         │
              │ • Baca data dari DB     │
              │ • Generate caption      │
              │ • Pilih hashtag + CTA   │
              │ • Simpan ke content_db  │
              │ • Jadwal via Repliz     │
              │ • (Gambar/video dari    │
              │   user, kita simpan     │
              │   link media_url)       │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   ✅ QUALITY GATE       │
              │   (Gina review caption) │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   💬 ECHOGUARD          │
              │   Engagement Agent      │
              │                         │
              │ • Pantau komentar       │
              │ • Auto-reply           │
              │ • Balas DM (existing)  │
              │ • Filter spam          │
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │   🗄️ POSTGRESQL        │
              │   4 schemas, 14 tables  │
              └─────────────────────────┘
```

## 📝 Cara Kerja CopyForge (Content Creator)

1. **Input**: DataDrift udah nyimpan tren hashtag + data kompetitor ke `research_db`
2. **Generate**: CopyForge baca data itu, terus bikin 3-5 konsep konten:
   - Hook (pembuka yang menarik)
   - Caption (teks utama)
   - Hashtags (dari data trending)
   - CTA (ajakan: like, comment, share)
3. **Media**: Kamu kirim gambar/video → kita simpen **link** di kolom `media_url`
4. **Schedule**: Jadwal posting via Repliz → otomatis ke Instagram/TikTok
5. **Save**: Semua tersimpan di `content_db.content_drafts`

## ⚠️ Keterbatasan yang Diketahui

| Feature | Status | Notes |
|---------|--------|-------|
| ❌ **Start DM baru** | Tidak bisa | Repliz/Meta API gak izinin ngirim DM ke user baru — cuma bisa reply ke DM yg udah masuk |
| ❌ **Like postingan** | Tidak bisa | Repliz API gak punya endpoint like — limitasi platform API |
| ❌ **Image generation** | Skip | Kamu kirim sendiri medianya, kita simpen link aja |
| ✅ **Komen di postingan** | ✅ Bisa | Sudah dites — IG + TikTok berhasil! |
| ✅ **Jadwal posting** | ✅ Bisa | Sudah dites — ⏰ bisa jadwal + gambar |
| ✅ **Reply DM existing** | ✅ Bisa | Balas DM yg udah masuk ke akun |

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
