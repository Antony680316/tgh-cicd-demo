"""TGH CI/CD demo service.

A minimal HTTP service used to exercise the CI/CD pipeline end to end:
build -> scan -> push -> test deploy -> DAST -> approval -> promote -> deploy.
Only the Python standard library is used, so there are no third-party
dependencies to patch.
"""

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

APP_VERSION = os.environ.get("APP_VERSION", "dev")
APP_ENV = os.environ.get("APP_ENV", "local")

SECURITY_HEADERS = {
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "DENY",
    "Referrer-Policy": "no-referrer",
    "Content-Security-Policy": "default-src 'none'; style-src 'unsafe-inline'; frame-ancestors 'none'",
    "Permissions-Policy": "geolocation=(), camera=(), microphone=()",
    "Cross-Origin-Resource-Policy": "same-origin",
    "Cache-Control": "no-store",
}

INDEX_HTML = """<!doctype html>
<html lang="zh-Hant"><head><meta charset="utf-8">
<title>CI/CD 範例服務</title></head>
<body style="font-family:sans-serif;margin:2rem">
<h1>CI/CD 範例服務</h1>
<p>版本：{version}　環境：{env}</p>
<p>健康檢查：<code>/health</code></p>
</body></html>
"""


def health_payload():
    return {"status": "ok", "version": APP_VERSION, "env": APP_ENV}


class Handler(BaseHTTPRequestHandler):
    server_version = "tgh-demo"
    sys_version = ""

    def _send(self, code, body, content_type):
        data = body.encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        for key, value in SECURITY_HEADERS.items():
            self.send_header(key, value)
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(data)

    def do_GET(self):
        path = self.path.split("?", 1)[0]
        if path == "/health":
            self._send(200, json.dumps(health_payload()), "application/json; charset=utf-8")
        elif path == "/":
            html = INDEX_HTML.format(version=APP_VERSION, env=APP_ENV)
            self._send(200, html, "text/html; charset=utf-8")
        elif path == "/robots.txt":
            self._send(200, "User-agent: *\nDisallow: /\n", "text/plain; charset=utf-8")
        else:
            self._send(404, "not found\n", "text/plain; charset=utf-8")

    do_HEAD = do_GET

    def log_message(self, fmt, *args):  # one line per request to stdout
        print("%s %s" % (self.address_string(), fmt % args), flush=True)


def main():
    port = int(os.environ.get("PORT", "8080"))
    ThreadingHTTPServer(("0.0.0.0", port), Handler).serve_forever()


if __name__ == "__main__":
    main()
