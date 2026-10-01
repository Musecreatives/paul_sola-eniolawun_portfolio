# syntax=docker/dockerfile:1
#
# The Sola-Eniolawun Collection: Flutter web build served by nginx.
#
#   docker build -t portfolio-web .
#
# Flutter comes from the official release archive (checksum-pinned), so the
# version always matches pubspec.lock, which was resolved with Flutter 3.47.5.
# Keep FLUTTER_VERSION in step with .github/workflows/ci.yml. To upgrade, take
# the version and sha256 of the linux archive from
# https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json
#
# Behind a TLS-inspecting proxy, pass its CA bundle as a build secret (used only
# by the download steps, never stored in the image):
#   docker build --secret id=ca_bundle,src=/path/to/ca-bundle.pem .

ARG FLUTTER_VERSION=3.47.5
ARG FLUTTER_SHA256=2132e990f236f8d22e7c6314b29a191a95b10d7cbcfec9b4e2e303d996652cbb
ARG NGINX_VERSION=1.30.5-alpine

# ---------- Stage 1: build ----------
# buildpack-deps already has curl, git, xz and unzip, which is all Flutter needs.
FROM buildpack-deps:trixie AS build

ARG FLUTTER_VERSION
ARG FLUTTER_SHA256

ENV FLUTTER_ROOT=/opt/flutter \
    PUB_CACHE=/opt/pub-cache \
    PATH=/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:$PATH \
    FLUTTER_SUPPRESS_ANALYTICS=true \
    CI=true

RUN --mount=type=secret,id=ca_bundle,target=/etc/ssl/certs/ca-certificates.crt,required=false \
    set -eu; \
    archive="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"; \
    curl -fsSL --retry 3 -o "/tmp/$archive" \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/$archive"; \
    echo "${FLUTTER_SHA256}  /tmp/$archive" | sha256sum -c -; \
    tar -xJf "/tmp/$archive" -C /opt --no-same-owner; \
    rm "/tmp/$archive"; \
    git config --global --add safe.directory /opt/flutter; \
    flutter config --no-analytics --no-cli-animations >/dev/null; \
    flutter precache --web --no-android --no-ios --no-linux --no-windows --no-macos --no-fuchsia; \
    flutter --version

WORKDIR /app

# Dependencies first so this layer is cached until pubspec changes.
COPY pubspec.yaml pubspec.lock ./
RUN --mount=type=secret,id=ca_bundle,target=/etc/ssl/certs/ca-certificates.crt,required=false \
    flutter pub get --enforce-lockfile

COPY . .

# --no-web-resources-cdn: serve CanvasKit from /canvaskit/ instead of gstatic.
# --csp: no eval() in main.dart.js, so the CSP needs no 'unsafe-eval'.
# Then drop debug symbol files and pre-compress text assets for gzip_static.
RUN --mount=type=secret,id=ca_bundle,target=/etc/ssl/certs/ca-certificates.crt,required=false \
    flutter build web --release --no-web-resources-cdn --csp --no-wasm-dry-run \
 && find build/web -name '*.symbols' -delete \
 && find build/web -type f \( -name '*.js' -o -name '*.mjs' -o -name '*.css' \
      -o -name '*.html' -o -name '*.json' -o -name '*.wasm' -o -name '*.svg' \
      -o -name '*.ttf' -o -name '*.otf' -o -name 'NOTICES' \) \
      -size +1k -exec gzip -9 -k -n {} +

# ---------- Stage 2: serve ----------
FROM nginx:${NGINX_VERSION}

RUN rm -f /etc/nginx/conf.d/default.conf \
 && mkdir -p /etc/nginx/snippets

COPY deploy/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY deploy/nginx/proxy.conf deploy/nginx/security-headers.conf deploy/nginx/csp.conf /etc/nginx/snippets/
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null http://127.0.0.1/healthz || exit 1
