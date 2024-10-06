# 使用带有 Java JDK 的基础镜像
FROM openjdk:11-jdk-slim

# 设置环境变量
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin

# 安装必需的依赖
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    curl \
    lib32z1 \
    lib32stdc++6 \
    lib32ncurses6 \
    && apt-get clean

# 下载 Android SDK 命令行工具
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && cd ${ANDROID_HOME}/cmdline-tools \
    && wget https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip -O commandlinetools.zip \
    && unzip commandlinetools.zip -d latest \
    && rm commandlinetools.zip

# 设置 JAVA_HOME 环境变量
ENV JAVA_HOME=/usr/local/openjdk-11
ENV PATH=$JAVA_HOME/bin:$PATH

# 手动接受 Android SDK 许可证和安装 SDK 组件
RUN mkdir -p ~/.android/ \
    && touch ~/.android/repositories.cfg \
    && yes | sdkmanager --licenses \
    && sdkmanager --install "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# 安装 Cordova
RUN npm install -g cordova

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY . /app

# 安装 Python 依赖项
RUN pip3 install -r requirements.txt

# 暴露端口
EXPOSE 10000

# 启动应用程序
CMD ["python3", "app.py"]
