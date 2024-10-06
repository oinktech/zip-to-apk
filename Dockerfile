# 使用官方的 Ubuntu 基础镜像
FROM ubuntu:20.04

# 设置工作目录
WORKDIR /app

# 安装必要的工具和依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openjdk-11-jdk \
    wget \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Android SDK 命令行工具
RUN mkdir -p /opt/android-sdk && \
    cd /opt/android-sdk && \
    curl -LO https://dl.google.com/android/repository/commandlinetools-linux-103.0.0_latest.zip && \
    ls -l && \  # 检查 ZIP 文件是否存在
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

# 复制应用程序代码
COPY . .

# 暴露 Flask 默认端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "app.py"]
