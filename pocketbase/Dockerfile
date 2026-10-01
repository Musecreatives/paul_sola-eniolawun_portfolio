# syntax=docker/dockerfile:1
#
# PocketBase server (there is no official image). Built for linux/amd64 or
# linux/arm64 from the release zip, checksum-verified, run as a non-root user.
# Uses only what ships in the alpine base (busybox wget/unzip/sha256sum,
# ca-certificates-bundle), so no package index is needed at build time.
#
#   docker build -t portfolio-pocketbase ./pocketbase
#
# Upgrading: read the release notes (https://github.com/pocketbase/pocketbase/releases),
# then set PB_VERSION here and in docker-compose.yml, and copy the two
# linux_amd64 / linux_arm64 lines from that release's checksums.txt into
# PB_SHA256_AMD64 / PB_SHA256_ARM64.

ARG ALPINE_VERSION=3.24.2

# ---------- download + verify ----------
FROM alpine:${ALPINE_VERSION} AS download

ARG PB_VERSION=0.40.4
# From https://github.com/pocketbase/pocketbase/releases/download/v0.40.4/checksums.txt
ARG PB_SHA256_AMD64=9042ec818570e79c3628dadcd0a756c1496d9e1173918ec409d133c02f82e5fa
ARG PB_SHA256_ARM64=86095bf8ed9345954f0d2bf0a5fb9b57584ae60b77ebf3b6cd23a8003a3fd418
# Set by BuildKit from --platform (defaults to the host architecture).
ARG TARGETARCH

WORKDIR /tmp/pb

# Optional: behind a TLS-inspecting proxy, pass its CA bundle as a build secret
# (used for this step only, never stored in the image):
#   docker build --secret id=ca_bundle,src=/path/to/ca-bundle.pem ./pocketbase
RUN --mount=type=secret,id=ca_bundle,target=/etc/ssl/certs/ca-certificates.crt,required=false \
    set -eu; \
    arch="${TARGETARCH:-amd64}"; \
    case "$arch" in \
      amd64) sha="$PB_SHA256_AMD64" ;; \
      arm64) sha="$PB_SHA256_ARM64" ;; \
      *) echo "Unsupported TARGETARCH: $arch (amd64 or arm64 only)" >&2; exit 1 ;; \
    esac; \
    zip="pocketbase_${PB_VERSION}_linux_${arch}.zip"; \
    wget -q -O "$zip" "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/${zip}"; \
    echo "${sha}  ${zip}" | sha256sum -c -; \
    unzip -q "$zip" pocketbase; \
    chmod 0755 pocketbase; \
    ./pocketbase --version

# ---------- runtime ----------
FROM alpine:${ALPINE_VERSION}

RUN addgroup -S -g 10001 pocketbase \
 && adduser -S -D -H -u 10001 -G pocketbase -s /sbin/nologin pocketbase \
 && mkdir -p /pb_data /pb_migrations /pb_hooks \
 && chown pocketbase:pocketbase /pb_data

COPY --from=download /tmp/pb/pocketbase /usr/local/bin/pocketbase

USER pocketbase
VOLUME ["/pb_data"]
EXPOSE 8090

HEALTHCHECK --interval=15s --timeout=5s --start-period=20s --retries=5 \
  CMD wget -q -O /dev/null http://127.0.0.1:8090/api/health || exit 1

ENTRYPOINT ["/usr/local/bin/pocketbase"]
CMD ["serve", "--http=0.0.0.0:8090", "--dir=/pb_data", "--migrationsDir=/pb_migrations", "--hooksDir=/pb_hooks"]
