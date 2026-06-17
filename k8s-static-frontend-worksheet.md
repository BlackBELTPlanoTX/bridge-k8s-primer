# Local Kubernetes Primer Worksheet

This repo now includes all starter files, so you can focus on the Docker and Kubernetes flow.

---

# 🔧 **BEFORE YOU START: CREATE YOUR OWN BRANCH**

```bash
git checkout -b your-name/k8s-primer
```

**Make all changes on your personal branch, not on main.**

---

## Included Files

- `app1/index.html`
- `app1/styles.css`
- `app1/Dockerfile`
- `app1/k8s/pod.yaml`
- `app1/k8s/service.yaml`
- `app1/k8s/configmap.yaml`
- `app2/index.html`
- `app2/styles.css`
- `app2/Dockerfile`
- `app2/k8s/namespace.yaml`
- `app2/k8s/pod.yaml`
- `app2/k8s/service.yaml`
- `app2/k8s/configmap.yaml`

---

## 0) Prerequisites

You should have Docker Desktop running with Kubernetes enabled.

Reminder: unless a step says otherwise, run commands from the repo root folder.

Run:

```powershell
docker --version
kubectl version --client
kubectl get nodes
```

What this means:

- If `kubectl get nodes` shows a `Ready` node, your local Kubernetes cluster is active.

Open the local HTML file directly in your browser (before Docker/Kubernetes):

Windows (PowerShell):

```powershell
start .\app1\index.html
```

Ubuntu (Terminal):

```bash
xdg-open ./app1/index.html
```

macOS (Terminal):

```bash
open ./app1/index.html
```

Concept:

- This opens the file directly from your filesystem (no web server required).
- Later steps use Docker and Kubernetes so the page is served over HTTP.

---

## 1) Build the First Image

Move to app1 and build:

Reminder: this `docker build` must run inside `app1` because Docker uses files from the current folder.

```powershell
cd app1
docker build -t local/frontend-one:1.0 .
```

Concept:

- The image tag `local/frontend-one:1.0` is the identifier Kubernetes will reference.
- `nginx:alpine` is used as a lightweight static web server base image.

Optional quick local test before Kubernetes:

```powershell
docker run --rm -d -p 8080:80 --name frontend-one-test local/frontend-one:1.0
```

Open http://localhost:8080, then stop test container:

```powershell
docker stop frontend-one-test
```

Return to repo root:

Reminder: switch back to repo root before running `kubectl apply -f app1/k8s/...` or `app2/k8s/...` commands.

```powershell
cd ..
```

---

## 2) Create the Pod

Apply the ConfigMap first (recommended):

Reminder: run these from repo root so `app1/k8s/...` paths resolve correctly.

```powershell
kubectl apply -f app1/k8s/configmap.yaml
```

Then apply the Pod manifest:

```powershell
kubectl apply -f app1/k8s/pod.yaml
kubectl get pods -o wide
```

Concept:

- A Pod is the smallest runnable unit in Kubernetes.
- This Pod runs one container that serves your static files on port 80.
- The Pod reads `BG_COLOR` from ConfigMap when available.
- If `BG_COLOR` is not provided, the app uses its internal default background color.

---

## 3) Expose the Pod with NodePort

Apply the Service manifest:

Reminder: stay in repo root for this command.

```powershell
kubectl apply -f app1/k8s/service.yaml
kubectl get svc frontend-one-svc
```

Open the app at:

- http://localhost:30080

Optional check:

```powershell
kubectl get svc frontend-one-svc
```

- You should see `30080` in the `PORT(S)` column.

If `localhost:30080` is not reachable on your machine:

```powershell
kubectl port-forward svc/frontend-one-svc 30080:80
```

- Keep that terminal running, then browse to `http://localhost:30080`.
- Use `Ctrl+C` in that terminal to stop port forwarding.

Concept:

- A Service gives your Pod a stable network endpoint.
- `NodePort` maps a fixed port on the node to your Pod-backed service.
- Here we use fixed ports to keep the lesson predictable.

---

## 4) Quick Debug Commands

If the Pod is not ready:

Reminder: these can be run from any directory, because they do not use local file paths.

```powershell
kubectl describe pod frontend-one-pod
kubectl logs frontend-one-pod
```

If Service routing is not working:

```powershell
kubectl get pod --show-labels
kubectl describe svc frontend-one-svc
```

What to check:

- Pod label and Service selector must match (`app: frontend-one`).
- Image tag in manifest must exist locally (`local/frontend-one:1.0`).

---

## 5) Bonus: Second App in Another Namespace

The files are already provided for you under `app2` and `app2/k8s`.

### Build image

Reminder: change into `app2` first, then return to repo root after build.

```powershell
cd app2
docker build -t local/frontend-two:1.0 .
cd ..
```

### Deploy to bonus namespace

Reminder: run these from repo root so `app2/k8s/...` paths work.

```powershell
kubectl apply -f app2/k8s/namespace.yaml
kubectl apply -f app2/k8s/configmap.yaml
kubectl apply -f app2/k8s/pod.yaml
kubectl apply -f app2/k8s/service.yaml
kubectl get all -n lesson-bonus
```

Access bonus app:

- http://localhost:30081

Optional check:

```powershell
kubectl get svc frontend-two-svc -n lesson-bonus
```

- You should see `30081` in the `PORT(S)` column.

If `localhost:30081` is not reachable on your machine:

```powershell
kubectl port-forward svc/frontend-two-svc 30081:80 -n lesson-bonus
```

- Keep that terminal running, then browse to `http://localhost:30081`.
- Use `Ctrl+C` in that terminal to stop port forwarding.

Hints to reinforce learning:

1. Namespace keeps resources isolated by name and scope.
2. Pod and Service need to be in the same namespace to connect via selector.
3. Use `kubectl get svc -n lesson-bonus` to verify `PORT(S)`.
4. ConfigMap sets `BG_COLOR` to `#DDDDDD`, and default color still works if omitted.

---

## 6) Cleanup

Reminder: run cleanup from repo root to avoid path errors.

```powershell
kubectl delete -f app1/k8s/service.yaml
kubectl delete -f app1/k8s/pod.yaml
kubectl delete -f app1/k8s/configmap.yaml

kubectl delete -f app2/k8s/service.yaml
kubectl delete -f app2/k8s/pod.yaml
kubectl delete -f app2/k8s/configmap.yaml
kubectl delete -f app2/k8s/namespace.yaml
```

Optional Docker cleanup:

```powershell
docker rmi local/frontend-one:1.0
docker rmi local/frontend-two:1.0
```
