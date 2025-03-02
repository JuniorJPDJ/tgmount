FROM        python:3.13.2-alpine@sha256:323a717dc4a010fee21e3f1aac738ee10bb485de4e7593ce242b36ee48d6b352

# renovate: datasource=repology depName=alpine_3_21/gcc versioning=loose
ARG         GCC_VERSION="14.2.0-r4"
# renovate: datasource=repology depName=alpine_3_21/build-base versioning=loose
ARG         BUILD_BASE_VERSION="0.5-r3"
# renovate: datasource=repology depName=alpine_3_21/libffi-dev versioning=loose
ARG         LIBFFI_VERSION="3.4.7-r0"
# renovate: datasource=repology depName=alpine_3_21/libretls-dev versioning=loose
ARG         LIBRETLS_VERSION="3.7.0-r2"
# renovate: datasource=repology depName=alpine_3_21/cargo versioning=loose
ARG         CARGO_VERSION="1.83.0-r0"
# renovate: datasource=repology depName=alpine_3_21/fuse3 versioning=loose
ARG         FUSE3_VERSION="3.16.2-r1"

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

ENTRYPOINT  [ "python", "../tgmount.py" ]
