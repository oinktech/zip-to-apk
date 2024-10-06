# 基础镜像，带有Java JDK和Android SDK
FROM openjdk:11-jdk-slim

# 设置环境变量
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/tools/bin
ENV ANDROID_HOME=$ANDROID_SDK_ROOT

# 安装依赖库
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    zip \
    wget \
    build-essential \
    lib32z1 \
    lib32ncurses6 \
    lib32stdc++6 \
    python3 \
    python3-pip \
    git \
    && apt-get clean

# 下载并安装Android SDK
RUN mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools" \
    && cd "$ANDROID_SDK_ROOT/cmdline-tools" \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O tools.zip \
    && unzip tools.zip -d tools \
    && rm tools.zip

# 接受所有SDK许可证
RUN yes | sdkmanager --licenses

# 安装需要的Android SDK组件
RUN sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install \
    "platform-tools" \
    "platforms;android-30" \
    "build-tools;30.0.3" \
    "cmdline-tools;latest" \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# 安装 Cordova
RUN npm install -g cordova

# 创建 Flask app 目录并拷贝当前目录内容
WORKDIR /app
COPY . /app

# 安装 Python 依赖
RUN pip3 install -r requirements.txt

# 暴露端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "app.py"]
