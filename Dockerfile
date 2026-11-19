# Base image is pinned by digest; Dependabot proposes digest updates as PRs.
FROM docker.io/library/python:3.12-slim@sha256:5e2bdb1b0d542d5039cffb8181c65930093949194a65c365dfb1b0fe13a4fa5b

LABEL org.opencontainers.image.title="tgh-cicd-demo" \
      org.opencontainers.image.description="CI/CD pipeline demo service"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080

# Apply Debian security updates published after the pinned base image was built.
# (The release gate blocks HIGH/CRITICAL vulnerabilities that have a fix.)
RUN apt-get update \
 && apt-get -y --no-install-recommends upgrade \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 10001 --no-create-home --shell /usr/sbin/nologin app
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
