# =========================
# Stage 0: fetch artifacts
# =========================
FROM ubuntu:noble AS fetcher
ARG DEBIAN_FRONTEND=noninteractive
ARG FLUTTER_SDK_VERSION=3.35.1-stable
ARG ANDROID_CMDLINE_TOOLS_ZIP=commandlinetools-linux-8512546_latest.zip
ARG FLUTTER_SHA256=
ARG CMDLINE_TOOLS_SHA256=
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl wget xz-utils && rm -rf /var/lib/apt/lists/*

# Flutter tarball
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_SDK_VERSION}.tar.xz" -o /tmp/flutter.tar.xz && \
    if [ -n "${FLUTTER_SHA256}" ]; then echo "${FLUTTER_SHA256}  /tmp/flutter.tar.xz" | sha256sum -c -; fi

# Android cmdline-tools zip
RUN wget -qO /tmp/cmdtools.zip "https://dl.google.com/android/repository/${ANDROID_CMDLINE_TOOLS_ZIP}" && \
    if [ -n "${CMDLINE_TOOLS_SHA256}" ]; then echo "${CMDLINE_TOOLS_SHA256}  /tmp/cmdtools.zip" | sha256sum -c -; fi

# =========================
# Stage 1: final (runtime)
# =========================
FROM ubuntu:noble
ARG DEBIAN_FRONTEND=noninteractive
ARG ANDROID_SDK_ROOT=/usr/lib/android-sdk
ARG FLUTTER_SDK_ROOT=/usr/lib/flutter
ARG ANDROID_PLATFORM=android-35
ARG ANDROID_BUILD_TOOLS=35.0.0

ENV ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT} \
    ANDROID_HOME=${ANDROID_SDK_ROOT} \
    FLUTTER_SDK_ROOT=${FLUTTER_SDK_ROOT} \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="${PATH}:${FLUTTER_SDK_ROOT}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools"

# Deps mínimas
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates unzip xz-utils zip git watchman curl wget \
      openjdk-17-jdk-headless libglu1-mesa \
      libc6:amd64 libstdc++6:amd64 lib32z1 libbz2-1.0:amd64 && \
    rm -rf /var/lib/apt/lists/*

# Git config básica
RUN git config --global --add safe.directory ${FLUTTER_SDK_ROOT} && \
    git config --global user.name "Dev Container" && \
    git config --global user.email "devcontainer@example.com"

# Artefatos do stage fetcher
COPY --from=fetcher /tmp/flutter.tar.xz /tmp/flutter.tar.xz
COPY --from=fetcher /tmp/cmdtools.zip /tmp/cmdtools.zip

# Android SDK + componentes
RUN set -eux; \
    mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"; \
    unzip -q /tmp/cmdtools.zip -d "${ANDROID_SDK_ROOT}/cmdline-tools"; \
    mv "${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools" "${ANDROID_SDK_ROOT}/cmdline-tools/latest"; \
    rm -f /tmp/cmdtools.zip; \
    yes | "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" --licenses; \
    "${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager" \
      "platform-tools" \
      "platforms;${ANDROID_PLATFORM}" \
      "build-tools;${ANDROID_BUILD_TOOLS}"

# Flutter + precache
RUN set -eux; \
    tar -xJf /tmp/flutter.tar.xz -C /usr/lib/; \
    rm -f /tmp/flutter.tar.xz; \
    flutter --disable-analytics; \
    flutter config --android-sdk "${ANDROID_SDK_ROOT}"; \
    flutter precache --android

# (Opcional) aceitar licenças via Flutter
RUN yes | flutter doctor --android-licenses

SHELL ["/bin/bash", "-c"]
WORKDIR /workspace
