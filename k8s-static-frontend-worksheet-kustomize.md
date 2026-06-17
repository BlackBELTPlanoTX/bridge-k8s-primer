# Static Frontend Worksheet: Kustomize (Per-App Base + Overlays)

In this sheet, you will organize each app independently with Kustomize using `dev`, `test`, and `prod` overlays.

---

# 🔧 **BEFORE YOU START: CREATE YOUR OWN BRANCH**

```bash
git checkout -b your-name/kustomize-worksheet
```

**Make all changes on your personal branch, not on main.**

---

## Learning goals

- Create a reusable Kustomize `base`.
- Apply environment-specific changes using overlays.
- Keep YAML DRY while preserving clear environment differences.

## Folder target

Create this structure:

```text
app1/
  k8s/
    kustomize/
      base/
        configmap.yaml
        pod.yaml
        service.yaml
        kustomization.yaml
      overlays/
        dev/
          kustomization.yaml
          namespace.yaml
          configmap-patch.yaml
          pod-patch.yaml
          service-patch.yaml
        test/
          kustomization.yaml
          namespace.yaml
          configmap-patch.yaml
          pod-patch.yaml
          service-patch.yaml
        prod/
          kustomization.yaml
          namespace.yaml
          configmap-patch.yaml
          pod-patch.yaml
          service-patch.yaml
app2/
  k8s/
    kustomize/
      base/
        configmap.yaml
        pod.yaml
        service.yaml
        kustomization.yaml
      overlays/
        dev/
          kustomization.yaml
          namespace.yaml
          configmap-patch.yaml
          pod-patch.yaml
          service-patch.yaml
        test/
          kustomization.yaml
          namespace.yaml
          configmap-patch.yaml
          pod-patch.yaml
          service-patch.yaml
        prod/
          kustomization.yaml
          namespace.yaml
          configmap-patch.yaml
          pod-patch.yaml
          service-patch.yaml
```

## Step 1: Build each app base

1. Copy app1 pod/service/configmap resources into `app1/k8s/kustomize/base`.
2. Copy app2 pod/service/configmap resources into `app2/k8s/kustomize/base`.
3. Keep resource names the same.
4. Remove hard-coded namespace values from base resources.
5. Add `kustomization.yaml` in each app base folder.

## Step 2: Build overlays for each app

For each app and each overlay (`dev`, `test`, `prod`):

1. Create a namespace manifest.
2. Reference `../../base`.
3. Set `namespace` in the overlay `kustomization.yaml`.
4. Use `patchesStrategicMerge` in overlay `kustomization.yaml` to include patch files.
5. Add separate patch files in each overlay:
  - `configmap-patch.yaml` for BG_COLOR values
  - `pod-patch.yaml` for image tags
  - `service-patch.yaml` for NodePort values

## Suggested values

Use these namespaces:

- dev: `lesson-dev`
- test: `lesson-test`
- prod: `lesson-prod`

Use these NodePorts:

- app1 dev `30080`, test `31080`, prod `32080`
- app2 dev `30081`, test `31081`, prod `32081`

## Build and apply

Syntax note: use `kubectl kustomize <path>` (not `kubectl kustomize build <path>`).

Preview app1 dev overlay:

Windows (PowerShell):

```powershell
kubectl kustomize app1/k8s/kustomize/overlays/dev
```

macOS/Linux (bash/zsh):

```bash
kubectl kustomize app1/k8s/kustomize/overlays/dev
```

Apply app1 dev overlay:

Windows (PowerShell):

```powershell
kubectl apply -k app1/k8s/kustomize/overlays/dev
kubectl get all -n lesson-dev
```

macOS/Linux (bash/zsh):

```bash
kubectl apply -k app1/k8s/kustomize/overlays/dev
kubectl get all -n lesson-dev
```

Preview and apply app2 dev overlay:

Windows (PowerShell):

```powershell
kubectl kustomize app2/k8s/kustomize/overlays/dev
kubectl apply -k app2/k8s/kustomize/overlays/dev
kubectl get all -n lesson-dev
```

macOS/Linux (bash/zsh):

```bash
kubectl kustomize app2/k8s/kustomize/overlays/dev
kubectl apply -k app2/k8s/kustomize/overlays/dev
kubectl get all -n lesson-dev
```

Repeat for `test` and `prod` overlays for each app.

## Validate service deployment

Check that both pods and services are running:

Windows (PowerShell):

```powershell
kubectl get pods -n lesson-dev
kubectl get svc -n lesson-dev
```

macOS/Linux (bash/zsh):

```bash
kubectl get pods -n lesson-dev
kubectl get svc -n lesson-dev
```

Expected output:
- Both `frontend-one-pod` and `frontend-two-pod` should show `STATUS: Running`
- `frontend-one-svc` and `frontend-two-svc` should show `TYPE: NodePort`
- `frontend-one-svc` should have port mapping including `30080`
- `frontend-two-svc` should have port mapping including `30081`

## Access and verify in browser

Once pods are running, open your browser and navigate to:

- **App 1 (Dev):** http://localhost:30080
- **App 2 (Dev):** http://localhost:30081

You should see the static HTML pages with dev environment colors:
- App 1 dev: light blue background (#e7f7ff)
- App 2 dev: light yellow background (#fff6df)

## If browser access fails on Windows

Use `kubectl port-forward` to route traffic:

Windows (PowerShell):

```powershell
kubectl port-forward svc/frontend-one-svc 30080:80 -n lesson-dev
```

Then open http://localhost:30080 in your browser. Use `Ctrl+C` to stop port forwarding.

## Quick test with curl

Windows (PowerShell):

```powershell
curl http://localhost:30080
curl http://localhost:30081
```

macOS/Linux (bash/zsh):

```bash
curl http://localhost:30080
curl http://localhost:30081
```

Both should return HTTP 200 and HTML content.

## Reflection questions

1. Why should each app keep its own Kustomize base and overlays?
2. What types of fields are safest to patch in overlays?
3. How does this compare to copying three full sets of YAML files per app?

## Cleanup

Windows (PowerShell):

```powershell
kubectl delete -k app1/k8s/kustomize/overlays/dev
kubectl delete -k app1/k8s/kustomize/overlays/test
kubectl delete -k app1/k8s/kustomize/overlays/prod

kubectl delete -k app2/k8s/kustomize/overlays/dev
kubectl delete -k app2/k8s/kustomize/overlays/test
kubectl delete -k app2/k8s/kustomize/overlays/prod
```

macOS/Linux (bash/zsh):

```bash
kubectl delete -k app1/k8s/kustomize/overlays/dev
kubectl delete -k app1/k8s/kustomize/overlays/test
kubectl delete -k app1/k8s/kustomize/overlays/prod

kubectl delete -k app2/k8s/kustomize/overlays/dev
kubectl delete -k app2/k8s/kustomize/overlays/test
kubectl delete -k app2/k8s/kustomize/overlays/prod
```

## Instructor note

Reference answer is available in:

- `solutions/app1/k8s/kustomize`
- `solutions/app2/k8s/kustomize`
- `solutions/app1.k8s.kustomize.kustomization.yml`
- `solutions/app2.k8s.kustomize.kustomization.yml`
