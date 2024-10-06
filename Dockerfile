# 使用官方的 Ubuntu 基础镜像
FROM ubuntu:20.04

# 设置工作目录
WORKDIR /app

# 安装必要的工具和依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    curl \
    openjdk-11-jdk \
    wget \
    build-essential \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Android SDK
RUN mkdir -p /opt/android-sdk && \
    cd /opt/android-sdk && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-103.0.0_latest.zip && \
    unzip commandlinetools-linux-103.0.0_latest.zip && \
    rm commandlinetools-linux-103.0.0_latest.zip && \
    mkdir -p cmdline-tools/latest && \
    mv cmdline-tools/* cmdline-tools/latest/

# 设置环境变量
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin
ENV PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools
ENV PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin

# 安装 Node.js 和 Cordova
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g cordova && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 复制 requirements.txt 文件并安装 Python 依赖
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# 复制应用程序代码
COPY . .

# 设置 Android SDK 和 Java 环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# 暴露 Flask 默认端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "app.py"]
