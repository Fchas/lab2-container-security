# Lab 2: Container Security

This repository contains exercises from Lab 2 in the DevSecOps course, focusing on container security. The lab covers identifying vulnerabilities in containers, hardening them, generating SBOMs, and testing policy enforcement with Gatekeeper in Kubernetes.

---

## Project Structure

```
lab2-container-security/
├── app.py                    # Example Flask application
├── Dockerfile.vulnerable     # Intentionally vulnerable Dockerfile
├── Dockerfile.hardened       # Hardened Dockerfile
├── requirements.txt          # Dependencies for hardened image
├── sbom.json                 # Generated SBOM for hardened image
├── scan-before.txt           # Trivy scan of vulnerable image
├── scan-after.txt            # Trivy scan of hardened image
├── serviceaccounts.yaml      # Defined ServiceAccounts
├── policies/
│   ├── require-labels-template.yaml
│   └── require-team-label.yaml
├── api-deployment-hardened.yaml  # Kubernetes Deployment for hardened pod
└── screenshots/              # Screenshots from the lab (currently not needed)
```

---

## Step 1: Build and Scan Vulnerable Image

Build the intentionally vulnerable image:

```
docker build --network=host -f Dockerfile.vulnerable -t my-app:vulnerable .
```

Scan with Trivy:

```
trivy image --severity CRITICAL,HIGH my-app:vulnerable > scan-before.txt
```

This identifies critical and high CVEs in Flask 1.0.0 and Python 3.8.

---

## Step 2: Harden the Dockerfile

1. Use a newer Python version (`3.12-slim`) and a non-root user in `Dockerfile.hardened`.
2. Pin all dependencies in `requirements.txt`.
3. Add resource limits, read-only filesystem, and other security settings.

Build and scan the hardened image:

```
docker build --network=host -f Dockerfile.hardened -t my-app:hardened .
trivy image --severity CRITICAL,HIGH my-app:hardened > scan-after.txt
```

Compare the results with `scan-before.txt` to see the reduced vulnerabilities.

---

## Step 3: Generate SBOM

Generate a CycloneDX SBOM for the hardened image:

```
trivy image --format cyclonedx --output sbom.json my-app:hardened
```

The SBOM provides a complete list of dependencies and versions, making it easier to track and fix vulnerabilities.

---

## Step 4: Gatekeeper Policy Enforcement

1. Apply ServiceAccounts:

```
kubectl apply -f serviceaccounts.yaml
```

2. Apply your hardened pod/deployment YAML (`api-deployment-hardened.yaml`) and test with Gatekeeper:

- Ensures all pods have labels, non-root users, resource limits, and non-default ServiceAccounts.
- Example results:
  - **Hardened Pod:** ALLOWED (0 warnings)
  - **Bad Pod:** DENIED with a list of policy violations

3. Policy templates are located in the `policies/` folder:
   - `require-labels-template.yaml` – Template enforcing labels
   - `require-team-label.yaml` – Constraint requiring team label

---

## Screenshots

Screenshots from the lab are stored in `screenshots/`:

- `currently no screenshots are needed`

---

## Running the Hardened API Pod

To test the hardened API pod locally:

```
kubectl apply -f api-deployment-hardened.yaml
kubectl get pods -n lillteamet
kubectl port-forward deployment/api 3000:3000 -n lillteamet
```

Then open `http://localhost:3000` in your browser to verify the app is running.