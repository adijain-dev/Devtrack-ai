# DevTrack AI 🚀

A full-stack **Flutter + Spring Boot** application for students to track internship applications, manage DSA practice, and get AI-powered career tools.

---

## 📂 Project Structure

```
devtrack-ai/
├── devtrack_backend/    # Spring Boot backend (Java, PostgreSQL, JWT)
└── devtrack_frontend/   # Flutter frontend (Riverpod, GoRouter, Dio)
```

---

## ✅ Features Built

### Phase 1 — Setup & Authentication
- JWT-based login & register (Spring Security)
- Secure token storage on device (flutter_secure_storage)
- GoRouter-based protected routing
- **Forgot & Reset Password**: 6-digit verification code recovery flow
- **Token Refresh**: Refresh token persistence with automatic 401 Dio retry interceptor
- **Profile & Account Management**: Update display name, avatar URL, and change password directly from settings

### Phase 2 — Internship Tracker
- Add / Edit / Delete internship applications
- Status tracking: Applied, Interview, Offer, Rejected
- Recruiter notes, salary, job link fields
- Search & filter by company/role/location
- Stats summary row
- **Interview Deadlines & Calendar Agenda**: Schedule date & time, toggle reminder alarms, and view upcoming interviews alert banner
- **Document & Resume Attachment**: Attach specific resume document versions, filenames, and cloud links per application

### Phase 3 — DSA Tracker + Analytics
- Add / Edit / Delete DSA topics
- Category & difficulty filtering
- Daily streak calculation
- Solve/unsolve toggle with practice count
- **LeetCode & Codeforces Profile Sync**: One-tap profile sync fetching solved problem counts, contest ratings, ranking, and auto-importing recent solved problems into the tracker
- **Spaced Repetition / Revision Schedule**: Automated reminders for problems solved 7 or 14+ days ago, spaced repetition interval progression (7d → 14d → 30d → 60d), dedicated "Due for Revision" filter and quick-review actions
- **Analytics Dashboard:**
  - Internship status Pie Chart
  - DSA category-wise Bar Chart
  - Streak & summary stats cards

### Phase 4 — AI Resume Generator & Mock Interview (Groq API)
- **AI Resume Generator**: Generate ATS-friendly impact bullets based on role, experience, and custom context
- **Resume PDF Export**: ATS-formatted PDF generation & downloader using OpenPDF (download, save, and ATS-compliant layout)
- **AI Session History**: Full database persistence for generated resumes and mock interview sessions with rounds, answers, and AI feedback
- **Voice / Speech-to-Text Input**: Real-time microphone listening and voice transcription for answering mock interview questions aloud, plus dictation fallback
- **Interactive Mock Interview**: Multi-round technical interview simulator with AI feedback, round tracking, and history review

### Phase 5 — System Notifications, Dark Mode, Offline Cache & CI/CD
- **OS & Local Push Notifications**: Integrated `flutter_local_notifications` for system-level alert banners, upcoming interview alarms, and spaced repetition prompts
- **Offline Cache**: Resilient local cache (`OfflineCacheService`) allowing full offline viewing of internships, DSA problems, and notifications
- **Theme & Dark Mode**: Seamless dark/light theme switching with persistence (`theme_provider.dart`)
- **Docker Deployment**: Multi-stage `Dockerfile` and `docker-compose.yml` for containerized backend and PostgreSQL
- **CI/CD Pipelines**: GitHub Actions workflows for continuous integration (`ci.yml`) and automated Android Release APK & AAB builds (`mobile-release.yml`)

---

## 🛠️ Tech Stack

| Layer     | Technology               |
|-----------|--------------------------|
| Frontend  | Flutter, Riverpod, GoRouter, Dio, fl_chart |
| Backend   | Spring Boot, Spring Security, JWT |
| Database  | PostgreSQL               |
| Auth      | JWT (Bearer Token)       |
| Build     | Maven (backend), Flutter CLI (frontend) |

---

## 🚀 Getting Started

### Backend
```bash
cd devtrack_backend
./mvnw spring-boot:run
```
> Requires PostgreSQL running on `localhost:5432` with database `devtrack`  
> Username: `postgres` | Password: `postgres`

### Frontend
```bash
cd devtrack_frontend
flutter pub get
flutter run
```

---

## 📌 Roadmap

- [x] Phase 1 — Auth
- [x] Phase 2 — Internship Tracker
- [x] Phase 3 — DSA Tracker + Analytics
- [x] Phase 4 — AI Resume Generator & Mock Interview (Groq API)
- [x] Phase 5 — Notifications, Dark Mode, Profile, Deployment (Docker)
