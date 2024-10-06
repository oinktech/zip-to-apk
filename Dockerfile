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
    unzip \
    build-essential \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 和 Cordova
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g cordova && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 安装 Android SDK
RUN mkdir -p /opt/android-sdk-linux && \
    cd /opt/android-sdk-linux && \
    wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip && \
    unzip sdk-tools-linux-4333796.zip && \
    rm sdk-tools-linux-4333796.zip

# 设置环境变量
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# 同步 Android SDK
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --install "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# 复制 requirements.txt 文件并安装 Python 依赖
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# 复制应用程序代码
COPY . .

# 设置环境变量
ENV FLASK_ENV=production

# 暴露 Flask 默认端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python3", "app.py"]
