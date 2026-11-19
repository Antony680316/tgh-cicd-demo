# Base image is pinned by digest; Dependabot proposes digest updates as PRs.
# Alpine is used because the production registry (Harbor cicd-prod) refuses any
# image with a High/Critical finding, and Debian slim carries many High CVEs
# that have no upstream fix yet.
FROM docker.io/library/python:3.15-alpine@sha256:0f9552bb28711333da16915ec146f5e6bb44a7fdac9ced15dc17c2e0206346dd

LABEL org.opencontainers.image.title="tgh-cicd-demo" \
      org.opencontainers.image.description="CI/CD pipeline demo service"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

# Apply Alpine security updates published after the pinned base image was built.
# (The release gate blocks HIGH/CRITICAL vulnerabilities that have a fix.)
RUN apk upgrade --no-cache

RUN adduser -S -D -H -u 10001 -s /sbin/nologin app
WORKDIR /app
COPY --chown=root:root app/ /app/
# Code is owned by root and read-only for the runtime user, independent of the
# build host's umask.
RUN chmod -R u=rwX,go=rX /app

USER 10001
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD ["python", "-c", "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8080/health',timeout=2).status==200 else 1)"]
ENTRYPOINT ["python", "/app/server.py"]
