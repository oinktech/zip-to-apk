# 使用带有 Java JDK 的基础镜像
FROM openjdk:11-jdk-slim

# 设置环境变量
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# 安装必要的依赖项
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    zip \
    lib32z1 \
    lib32ncurses6 \
    lib32stdc++6 \
    && apt-get clean

# 下载 Android SDK 命令行工具
RUN mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools" \
    && cd "$ANDROID_SDK_ROOT/cmdline-tools" \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O tools.zip \
    && unzip tools.zip -d latest \
    && rm tools.zip

# 为了避免 sdkmanager 无法找到 Java 可执行文件，设置 JAVA_HOME
ENV JAVA_HOME=/usr/local/openjdk-11

# 更新环境变量以确保 sdkmanager 可执行
ENV PATH=$JAVA_HOME/bin:$PATH

# 安装 SDK 组件
RUN yes | sdkmanager --licenses \
    && sdkmanager --install "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# 安装 Cordova
RUN npm install -g cordova

# 创建应用程序工作目录
WORKDIR /app

# 复制当前目录的内容到 Docker 容器中
COPY . /app

# 安装 Python 依赖项
RUN pip3 install -r requirements.txt

# 暴露端口
EXPOSE 10000

# 启动 Flask 应用程序
CMD ["python3", "app.py"]
