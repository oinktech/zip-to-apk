FROM beevelop/cordova

ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-tools/30.0.3

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    openjdk-11-jdk \
    && apt-get clean

RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip \
    && unzip sdk-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && rm sdk-tools.zip \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest

RUN yes | sdkmanager --licenses

RUN sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install \
    "platform-tools" \
    "platforms;android-30" \
    "build-tools;30.0.3"

RUN cordova telemetry off

WORKDIR /app

CMD ["python", "app.py"]
