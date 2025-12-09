FROM        python:3.14.2-alpine@sha256:2a77c2640cc80f5506babd027c883abc55f04d44173fd52eeacea9d3b978e811

# renovate: datasource=repology depName=alpine_3_23/gcc versioning=loose
ARG         GCC_VERSION="15.2.0-r2"
# renovate: datasource=repology depName=alpine_3_23/build-base versioning=loose
ARG         BUILD_BASE_VERSION="0.5-r3"
# renovate: datasource=repology depName=alpine_3_23/libffi-dev versioning=loose
ARG         LIBFFI_VERSION="3.5.2-r0"
# renovate: datasource=repology depName=alpine_3_23/libretls-dev versioning=loose
ARG         LIBRETLS_VERSION="3.8.1-r0"
# renovate: datasource=repology depName=alpine_3_23/cargo versioning=loose
ARG         CARGO_VERSION="1.91.1-r0"
# renovate: datasource=repology depName=alpine_3_23/fuse3 versioning=loose
ARG         FUSE3_VERSION="3.17.3-r1"

ARG         TARGETPLATFORM

WORKDIR     /app

ADD         requirements.txt .

RUN         --mount=type=cache,sharing=locked,target=/root/.cache,id=home-cache-$TARGETPLATFORM \
            --mount=type=cache,sharing=locked,target=/root/.cargo,id=home-cargo-$TARGETPLATFORM \
            apk add --no-cache \
              fuse3=${FUSE3_VERSION} \
              libgcc=${GCC_VERSION} \
            && \
            sed -i 's/#user_allow_other/user_allow_other/g' /etc/fuse.conf && \
            apk add --no-cache --virtual .build-deps \
              gcc=${GCC_VERSION} \
              build-base=${BUILD_BASE_VERSION} \
              libffi-dev=${LIBFFI_VERSION} \
              libretls-dev=${LIBRETLS_VERSION} \
              fuse3-dev=${FUSE3_VERSION} \
              cargo=${CARGO_VERSION} \
            && \
            pip install -r requirements.txt && \
            apk del .build-deps && \
            chown -R nobody:nogroup /app

COPY        --chown=nobody:nogroup tgmount .

USER        nobody
WORKDIR     /app/data
STOPSIGNAL  SIGINT
ENV         PYTHONUNBUFFERED=1

HEALTHCHECK --interval=5m --timeout=1m --start-period=2m --retries=5 \
    CMD mountpoint -q /app/data/mnt

ENTRYPOINT  [ "python", "../tgmount.py" ]
