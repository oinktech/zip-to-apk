# 使用官方的 Cordova 映像作为基础
FROM beevelop/cordova

# 設置必要的環境變量
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/build-tools/30.0.3

# 安裝必要的依賴
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    openjdk-11-jdk \
    && apt-get clean

# 下載並安裝 Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools \
    && curl -o sdk-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip \
    && unzip sdk-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools \
    && rm sdk-tools.zip \
    && mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest

# 接受所有的 Android SDK 許可協議
RUN yes | sdkmanager --licenses

# 安裝平台工具和必要的 Android 构建工具
RUN sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install \
    "platform-tools" \
    "platforms;android-30" \
    "build-tools;30.0.3"

# 安裝其他必要的 Cordova 插件和工具
RUN cordova telemetry off

# 創建應用工作目錄
WORKDIR /app




# 默認命令
CMD ["bash"]
