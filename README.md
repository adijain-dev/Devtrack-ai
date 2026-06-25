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

### Phase 2 — Internship Tracker
- Add / Edit / Delete internship applications
- Status tracking: Applied, Interview, Offer, Rejected
- Recruiter notes, salary, job link fields
- Search & filter by company/role/location
- Stats summary row

### Phase 3 — DSA Tracker + Analytics
- Add / Edit / Delete DSA topics
- Category & difficulty filtering
- Daily streak calculation
- Solve/unsolve toggle with practice count
- **Analytics Dashboard:**
  - Internship status Pie Chart
  - DSA category-wise Bar Chart
  - Streak & summary stats cards

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
- [ ] Phase 4 — AI Resume Generator & Mock Interview
- [ ] Phase 5 — Notifications, Dark Mode, Profile, Deployment
