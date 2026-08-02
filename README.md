# PNG Game

A full-stack multiplayer room-based game platform with a web frontend and a **NestJS backend**.  
This repository is organized for end-to-end game feature development, local orchestration with Docker, and iterative UI/API improvements.

---

## ✨ What this project is

PNG Game is a room/session-based game platform where players interact through a frontend client backed by a NestJS API service.  
The project supports fast iteration on gameplay and room experience features (for example, room display improvements).

---

## 🧱 Tech stack

Based on repository composition and current structure:

- **Languages:** TypeScript, Dart, C++, C, CMake, JavaScript
- **Backend (active):** NestJS (`nestjs-backend/`)
- **Frontend:** Web client (`frontend/`)
- **Infra:** Docker Compose (`docker-compose.yml`)
- **Supporting/native modules:** C/C++ and CMake-based components (if used by your workflow)

---

## 📁 Repository structure

```text
.
├── frontend/                     # Frontend client application
├── nestjs-backend/               # ✅ Active backend service (NestJS)
├── scripts/                      # Utility scripts for dev/workflows
├── Enhance Room Display Page/    # Feature/design/task-specific artifacts
├── docker-compose.yml            # Multi-service local environment
├── ISSUES.md                     # Product/engineering issue tracking notes
├── .github/                      # CI/workflow/repo automation
└── .vscode/                      # Workspace/editor settings
```

> Note: `backend/` is no longer the active backend. Use `nestjs-backend/`.

---

## 🚀 Quick start

### Option A — Run with Docker (recommended)

```bash
git clone https://github.com/oriemiobang/png_game.git
cd png_game
docker compose up --build
```

### Option B — Run services manually

#### 1) Start NestJS backend

```bash
cd nestjs-backend
npm install
npm run start:dev
```

#### 2) Start frontend (new terminal)

```bash
cd frontend
npm install
npm run dev
```

---

## ⚙️ Configuration

Create environment files where needed:

```bash
nestjs-backend/.env
frontend/.env
```

Typical settings include:
- API host/port
- DB connection URL
- Auth/JWT secrets
- CORS origin
- Realtime/socket options (if applicable)

If using Docker, check `docker-compose.yml` for env wiring.

---

## 🧪 Testing

Run tests per active service:

```bash
# NestJS backend tests
cd nestjs-backend
npm test

# Frontend tests
cd ../frontend
npm test
```

---

## 🛠 Development workflow

1. Create a feature branch
2. Implement backend changes in `nestjs-backend/`
3. Update frontend integration in `frontend/`
4. Run tests and local validation
5. Open PR and link related backlog items from `ISSUES.md`

---

## 📌 Docs and planning

- `ISSUES.md` — backlog / known issues / planning
- `Enhance Room Display Page/` — feature-specific references

---

## 🤝 Contributing

Contributions are welcome:

- Keep commits focused and descriptive
- Add/update tests for behavior changes
- Document any API or config changes
- Update README when setup or run commands change

---

## 📄 License

Add a `LICENSE` file (MIT/Apache-2.0/etc.) and reference it here.
