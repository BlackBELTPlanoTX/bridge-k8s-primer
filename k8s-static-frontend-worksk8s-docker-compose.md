# Static Frontend Worksheet: Docker Compose

In this sheet, you will take the existing Kubernetes pod/service/configmap settings for app1 and app2 and express them as Docker Compose services.

Use this sheet when students do not have local Kubernetes available (for example, Kubernetes is disabled in Docker Desktop). It is the fallback runtime path for the same two frontends.

---

# 🔧 **BEFORE YOU START: CREATE YOUR OWN BRANCH**

```bash
git checkout -b your-name/docker-compose-worksheet
```

**Make all changes on your personal branch, not on main.**

---

## Learning goals

- Map Kubernetes container settings to Docker Compose.
- Use `environment` values to mimic ConfigMap-driven settings.
- Expose each frontend on a stable host port.

## Starter context

You already have:

- `app1/Dockerfile`
- `app2/Dockerfile`
- `app1/k8s/*.yaml`
- `app2/k8s/*.yaml`

Use those files to create a root-level `docker-compose.yml`.

## Tasks

1. Create `docker-compose.yml` in the repo root.
2. Add service `frontend-one`.
3. Add service `frontend-two`.
4. Configure each service to build from its app folder and run on ports that mirror your NodePorts.
5. Set `BG_COLOR` for each service from the existing ConfigMap values.

## Suggested structure

Use this skeleton and complete the missing values:

```yaml
services:
  frontend-one:
    build:
      context: ./app1
    image: local/frontend-one:1.0
    container_name: frontend-one
    environment:
      BG_COLOR: "#f2f4f8"
    ports:
      - "30080:80"

  frontend-two:
    build:
      context: ./app2
    image: local/frontend-two:1.0
    container_name: frontend-two
    environment:
      BG_COLOR: "#DDDDDD"
    ports:
      - "30081:80"
```

## Run and verify

From repo root:

Windows (PowerShell):

```powershell
docker compose up --build -d
docker compose ps
```

macOS/Linux (bash/zsh):

```bash
docker compose up --build -d
docker compose ps
```

Check in browser:

- http://localhost:30080
- http://localhost:30081

## Reflection questions

1. Which Kubernetes fields map directly to Compose `environment` and `ports`?
2. What does Compose replace compared to Pod + Service for this local-only setup?
3. Why is this approach useful for local developer workflows?

## Cleanup

Windows (PowerShell):

```powershell
docker compose down
```

macOS/Linux (bash/zsh):

```bash
docker compose down
```

## Instructor note

Reference answer is available in:

- `solutions/app1/docker-compose.app1.yml`
- `solutions/app2/docker-compose.app2.yml`
- `solutions/docker-compose.yml`
