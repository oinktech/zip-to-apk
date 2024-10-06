# 使用 Python 基础镜像
FROM python:3.10-slim

# 设置工作目录
WORKDIR /app

# 复制需求文件和应用代码
COPY requirements.txt ./
COPY app.py ./
COPY templates ./templates
COPY uploads ./uploads
COPY apks ./apks
COPY static ./static

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    openjdk-11-jdk \
    npm \
    && npm install -g cordova \
    && rm -rf /var/lib/apt/lists/*

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 暴露端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python", "app.py"]
