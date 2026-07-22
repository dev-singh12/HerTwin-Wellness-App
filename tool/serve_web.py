#!/usr/bin/env python3
"""Dev server for the built Flutter web app: SPA fallback + Firebase auth proxy.

Two things a plain `python3 -m http.server` gets wrong for this app:

1. SPA routing. The app uses path URLs, so /legal or /profile are client-side
   routes with no file on disk. Unknown paths must fall back to index.html.

2. Firebase auth. `authDomain` is hertwin-wellness.firebaseapp.com, so the
   sign-in popup runs cross-origin from localhost and its cookies are
   THIRD-PARTY cookies. Chrome blocks those by default, the popup closes
   itself, and Firebase reports it as "popup closed by user" — i.e. it blames
   the user for something the browser did.

   The documented fix is to serve the auth handler from your own origin. This
   proxies /__/auth/* and /__/firebase/* through to the real Firebase host, so
   as far as the browser is concerned everything is first-party. main.dart
   points authDomain at this origin when running on localhost.

    python3 tool/serve_web.py [port]
"""

# macOS ships Python 3.9 at /usr/bin/python3, which predates `X | None` in
# annotations. This keeps the file runnable on the system interpreter.
from __future__ import annotations

import functools
import os
import sys
import urllib.error
import urllib.request
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "build", "web")
FIREBASE_HOST = "https://hertwin-wellness.firebaseapp.com"
PROXY_PREFIXES = ("/__/auth/", "/__/firebase/")

# Hop-by-hop headers must not be forwarded.
STRIP = {
    "connection", "keep-alive", "proxy-authenticate", "proxy-authorization",
    "te", "trailers", "transfer-encoding", "upgrade", "content-length",
    "content-encoding",
}


class DevHandler(SimpleHTTPRequestHandler):
    # -- Firebase auth proxy ------------------------------------------------

    def _should_proxy(self) -> bool:
        return self.path.startswith(PROXY_PREFIXES)

    def _proxy(self, body: bytes | None = None) -> None:
        url = FIREBASE_HOST + self.path
        headers = {
            k: v for k, v in self.headers.items() if k.lower() not in STRIP
        }
        # The upstream must see its own host, not ours.
        headers["Host"] = "hertwin-wellness.firebaseapp.com"
        headers.pop("Accept-Encoding", None)

        req = urllib.request.Request(
            url, data=body, headers=headers, method=self.command
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as upstream:
                payload = upstream.read()
                self.send_response(upstream.status)
                for k, v in upstream.headers.items():
                    if k.lower() in STRIP:
                        continue
                    # Rewrite redirects back through this origin so the flow
                    # never escapes to the third-party host mid-way.
                    if k.lower() == "location":
                        v = v.replace(FIREBASE_HOST, "")
                    self.send_header(k, v)
                self.send_header("Content-Length", str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)
        except urllib.error.HTTPError as e:
            payload = e.read()
            self.send_response(e.code)
            self.send_header("Content-Length", str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except Exception as e:  # noqa: BLE001 - dev server, report and move on
            self.send_error(502, f"auth proxy failed: {e}")

    # -- Routing ------------------------------------------------------------

    def do_GET(self):  # noqa: N802
        if self._should_proxy():
            return self._proxy()
        path = self.translate_path(self.path)
        if os.path.isfile(path) or (
            os.path.isdir(path) and os.path.isfile(os.path.join(path, "index.html"))
        ):
            return super().do_GET()
        self.path = "/index.html"
        return super().do_GET()

    def do_POST(self):  # noqa: N802
        if not self._should_proxy():
            return self.send_error(405)
        length = int(self.headers.get("Content-Length") or 0)
        return self._proxy(self.rfile.read(length) if length else None)

    def do_OPTIONS(self):  # noqa: N802
        if self._should_proxy():
            return self._proxy()
        self.send_response(204)
        self.end_headers()

    def end_headers(self):
        # No caching during local review, or you debug a change that did
        # rebuild and is simply being served stale.
        self.send_header("Cache-Control", "no-store, must-revalidate")
        super().end_headers()

    def log_message(self, fmt, *args):
        msg = fmt % args
        if "404" in msg or "502" in msg or "/__/auth/" in msg:
            super().log_message(fmt, *args)


def main() -> int:
    if not os.path.isdir(ROOT):
        print("build/web not found. Run: flutter build web --no-tree-shake-icons")
        return 1

    port = int(sys.argv[1]) if len(sys.argv) > 1 else 5051
    handler = functools.partial(DevHandler, directory=ROOT)
    with ThreadingHTTPServer(("127.0.0.1", port), handler) as httpd:
        print(f"HerTwin on http://localhost:{port}")
        print(f"  SPA fallback: on")
        print(f"  Firebase auth proxied to {FIREBASE_HOST} (same-origin cookies)")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nstopped")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
