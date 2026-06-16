# Jenkins Monorepo CI Pipeline

A production-grade CI pipeline built with Jenkins for a monorepo containing multiple microservices in different languages. The pipeline automatically detects which services changed, runs quality checks in parallel using isolated Docker agents, and publishes container images to DockerHub.

## Architecture

```
Push to GitHub → Jenkins detects changes → Lint → Test → Scan → Manual Approval → Docker Build & Push → Slack Notification
```

The monorepo contains two services:

- **user-service** — Node.js application
- **transaction-service** — Python (FastAPI) application

Each service goes through the full CI pipeline independently and in parallel.

## Pipeline Stages

| Stage | Description | Tools |
|-------|-------------|-------|
| **Detect** | Identifies which services changed using `git diff` | `shared/ci/detect.sh` |
| **Lint** | Static code analysis, runs in parallel per service | ESLint (Node), Flake8 (Python) |
| **Test** | Unit tests with JUnit reporting, runs in parallel | Jest (Node), Pytest (Python) |
| **Scan** | Dependency vulnerability scanning, runs in parallel | npm audit (Node), pip-audit (Python) |
| **Approval** | Manual quality gate before publishing images | Jenkins `input` step |
| **Build & Push** | Builds Docker images and pushes to DockerHub | Docker |
| **Notify** | Sends build result to Slack (success/failure) | Slack Incoming Webhook |

## Key Design Decisions

### Docker Agents (Docker-outside-of-Docker)

Each CI stage runs inside an ephemeral Docker container rather than directly on the Jenkins controller. This provides:

1. **Version isolation** — Node 20 and Python 3.12 run in separate containers without conflicts
2. **Security isolation** — Untrusted code runs in containers that cannot access the Jenkins controller filesystem where credentials are stored

Jenkins uses DooD (Docker-outside-of-Docker) via Docker socket mounting, meaning the Jenkins container communicates with the host's Docker daemon to spin up sibling containers.

### Parallelism Strategy

- **Across services**: parallel (independent services, maximizes speed)
- **Within a service**: sequential (lint → test → scan, cheapest stage first for fail-fast)
- **`failFast: false`**: chosen for a two-service pipeline to maximize error information per build

### Shared CI Scripts

CI logic lives in `shared/ci/` shell scripts, not inline in the Jenkinsfile. Each script receives a service name as argument and uses a `case` block to select the right tools. Benefits:

- Scripts can be tested locally without Jenkins
- Portable across CI systems (GitHub Actions, GitLab CI, etc.)
- Adding a new service only requires a new `case` block

### Credentials Management

Secrets are stored in Jenkins Credentials and injected at runtime via `withCredentials`. They are:

- Masked in console output (shown as `****`)
- Scoped to the block where they are used
- Never written to the workspace or logs

## Project Structure

```
jenkins-monorepo-ci/
├── Jenkinsfile                  # Pipeline orchestrator
├── jenkins/
│   ├── Dockerfile               # Custom Jenkins image
│   └── docker-compose.yml       # Jenkins + DooD setup
├── shared/
│   └── ci/
│       ├── detect.sh            # Change detection via git diff
│       ├── lint.sh              # Lint dispatcher per service
│       ├── test.sh              # Test dispatcher per service
│       └── scan.sh              # Scan dispatcher per service
├── user-service/
│   ├── Dockerfile               # Production image
│   ├── app.js                   # Application code
│   ├── app.test.js              # Unit tests
│   ├── package.json             # Dependencies + scripts
│   └── .eslintrc.js             # Linter config
└── transaction-service/
    ├── Dockerfile               # Production image
    ├── main.py                  # Application code
    ├── test_main.py             # Unit tests
    └── requirements.txt         # Dependencies
```

## Prerequisites

- Docker and Docker Compose installed on the host
- DockerHub account
- Slack workspace with an Incoming Webhook configured

## Setup

### 1. Start Jenkins

```bash
cd jenkins
docker compose up -d
```

### 2. Configure Jenkins

1. Get the initial admin password: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`
2. Open `http://localhost:8080` and complete the setup wizard
3. Install the **Docker Pipeline** plugin (Manage Jenkins → Plugins)

### 3. Add Credentials

In **Manage Jenkins → Credentials → Global**:

- **DockerHub**: Kind `Username with password`, ID `dockerhub-credentials`
- **Slack**: Kind `Secret text`, ID `slack-webhook`

### 4. Create Pipeline Job

1. New Item → Pipeline
2. Set SCM to Git: `https://github.com/DaNaHiju/jenkins-monorepo-ci.git`
3. Branch: `main`
4. Script path: `Jenkinsfile`

## Technologies

- **CI Server**: Jenkins (Docker-based)
- **Containerization**: Docker, Docker Compose, Docker-outside-of-Docker (DooD)
- **Languages**: Node.js 20, Python 3.12
- **Linting**: ESLint, Flake8
- **Testing**: Jest, Pytest, JUnit XML reporting
- **Security Scanning**: npm audit, pip-audit
- **Container Registry**: DockerHub
- **Notifications**: Slack Incoming Webhooks
- **SCM**: Git, GitHub
