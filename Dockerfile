# 使用带有JDK的基础镜像
FROM openjdk:11-jdk-slim

# 设置环境变量
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# 安装必要依赖
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    zip \
    curl \
    lib32z1 \
    lib32ncurses6 \
    lib32stdc++6 \
    build-essential \
    && apt-get clean

# 下载并安装 Android SDK 的命令行工具
RUN mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools" \
    && cd "$ANDROID_SDK_ROOT/cmdline-tools" \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O tools.zip \
    && unzip tools.zip -d latest \
    && rm tools.zip

# 接受 SDK 许可证并安装 Android SDK 组件
RUN yes | sdkmanager --licenses \
    && sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --install \
    "platform-tools" \
    "platforms;android-30" \
    "build-tools;30.0.3"

# 安装 Cordova
RUN npm install -g cordova

# 设置工作目录
WORKDIR /app

# 复制当前目录到工作目录
COPY . /app

# 安装 Python 依赖
RUN pip3 install -r requirements.txt

# 暴露端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "app.py"]
