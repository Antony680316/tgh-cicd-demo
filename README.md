# tgh-cicd-demo

Minimal containerised HTTP service used to demonstrate a governed CI/CD flow:

1. A contributor forks this repository and opens a pull request.
2. GitHub runs CodeQL, secret scanning and Dependabot; the internal Jenkins
   pipeline runs unit tests, secret / dependency / configuration scans and a
   test image build, then reports a required status check on the PR.
3. After internal review and merge to `main`, Jenkins builds the image once,
   scans it, pushes it to the internal registry and deploys it by digest to the
   test environment, where a DAST baseline scan runs.
4. A named release approver approves; the identical digest is promoted and
   deployed. Every release produces an evidence bundle keyed by `release_id`.

The pipeline itself lives in `tgh-cicd-pipeline-lib`; this repository only
declares which application to build (`Jenkinsfile`).

| Path | Purpose |
|---|---|
| `app/server.py` | Service (Python standard library only) |
| `tests/` | Unit tests (`python -m unittest discover -s tests`) |
| `Dockerfile` | Non-root image, base pinned by digest |
| `deploy/compose.yaml` | Runtime definition; image always referenced by digest |
