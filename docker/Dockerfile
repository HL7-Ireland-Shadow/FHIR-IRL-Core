# syntax=docker/dockerfile:1
#
# HL7 FHIR IG publishing toolchain.
#
# Everything needed to take a SUSHI/FSH project all the way to a rendered IG:
#   - JDK (runs the IG Publisher and the FHIR Validator)
#   - HL7 FHIR IG Publisher (publisher.jar)
#   - HL7 FHIR Validator (validator_cli.jar)
#   - Node.js + SUSHI (FSH -> FHIR) + GoFSH (FHIR -> FSH)
#   - Ruby + Jekyll (the IG Publisher shells out to Jekyll to render pages)
#   - Graphviz (dot, used by the Publisher's PlantUML diagram rendering)
#   - git / curl / unzip / jq / python3 (IG templates and helper scripts expect them)

ARG JAVA_VERSION=21
FROM eclipse-temurin:${JAVA_VERSION}-jdk-jammy

# Tool versions. "latest" resolves to the current GitHub release / npm dist-tag at
# build time; pin these (e.g. IG_PUBLISHER_VERSION=1.8.12) for a reproducible image.
ARG IG_PUBLISHER_VERSION=latest
ARG VALIDATOR_VERSION=latest
ARG SUSHI_VERSION=latest
ARG GOFSH_VERSION=latest
ARG JEKYLL_VERSION=4.3.4
ARG NODE_MAJOR=22

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    FHIR_HOME=/opt/fhir \
    HOME=/home/fhir \
    IG_DIR=/ig

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl gnupg git jq unzip zip xz-utils \
        graphviz \
        ruby-full ruby-dev build-essential zlib1g-dev \
        python3 \
        fonts-dejavu-core tzdata  \
    && rm -rf /var/lib/apt/lists/*

# Node.js (NodeSource) - SUSHI needs a current LTS.
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash -  \
    && apt-get install -y --no-install-recommends nodejs  \
    && rm -rf /var/lib/apt/lists/*

# Jekyll: the IG Publisher invokes `jekyll build` to render the HTML pages.
RUN gem install --no-document bundler "jekyll:${JEKYLL_VERSION}"

# SUSHI compiles FSH; GoFSH decompiles existing FHIR back to FSH.
RUN npm install -g "fsh-sushi@${SUSHI_VERSION}" "gofsh@${GOFSH_VERSION}"  \
    && npm cache clean --force

# IG Publisher + Validator jars.
RUN set -euo pipefail; mkdir -p "${FHIR_HOME}"; \
    if [ "${IG_PUBLISHER_VERSION}" = "latest" ]; then \
        pub_url="https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"; \
    else \
        pub_url="https://github.com/HL7/fhir-ig-publisher/releases/download/${IG_PUBLISHER_VERSION}/publisher.jar"; \
    fi; \
    if [ "${VALIDATOR_VERSION}" = "latest" ]; then \
        val_url="https://github.com/hapifhir/org.hl7.fhir.core/releases/latest/download/validator_cli.jar"; \
    else \
        val_url="https://github.com/hapifhir/org.hl7.fhir.core/releases/download/${VALIDATOR_VERSION}/validator_cli.jar"; \
    fi; \
    curl -fsSL --retry 3 -o "${FHIR_HOME}/publisher.jar" "${pub_url}"; \
    curl -fsSL --retry 3 -o "${FHIR_HOME}/validator_cli.jar" "${val_url}"

COPY fhir-tools /usr/local/bin/fhir-tools
COPY record-versions.sh /usr/local/bin/record-versions

# Record exactly what landed in the image (surfaced by `fhir-tools versions`).
RUN chmod +x /usr/local/bin/fhir-tools /usr/local/bin/record-versions && record-versions

# A real passwd entry is required, not just $HOME: SUSHI (Node) reads $HOME, but the
# JVM resolves user.home from /etc/passwd, so running as root cached packages to
# /root/.fhir - outside the mounted volume - while SUSHI used $HOME. One user, one cache.
#
# Dirs are world-writable so the container also runs as `--user $(id -u):$(id -g)` on
# Linux hosts (keeping bind-mounted output owned by the invoking user), and so named
# volumes mounted over temp/ and input-cache/ inherit writable ownership.
RUN groupadd --gid 1000 fhir \
    && useradd --uid 1000 --gid 1000 --home-dir "${HOME}" --create-home --shell /bin/bash fhir \
    && mkdir -p "${HOME}/.fhir" "${IG_DIR}/temp" "${IG_DIR}/input-cache" \
    && chown -R fhir:fhir "${HOME}" "${IG_DIR}" \
    && chmod -R 777 "${HOME}" "${IG_DIR}"

# Mount named volumes at $HOME/.fhir (FHIR package + IG template cache) and over
# temp/ + input-cache/ (see docker-compose.yml). The scratch dirs MUST NOT sit on a
# Windows/macOS bind mount: the Publisher writes SQLite into temp/ and the host
# filesystem driver corrupts it (SQLITE_CORRUPT in DBBuilder).
USER fhir
WORKDIR /ig

ENTRYPOINT ["/usr/local/bin/fhir-tools"]
CMD ["publish"]
