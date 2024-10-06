# 使用 Python 官方基础镜像
FROM python:3.9-slim

# 设置工作目录
WORKDIR /app

# 复制 requirements.txt 文件
COPY requirements.txt .

# 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 安装必要的系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openjdk-11-jdk \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g cordova && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 复制应用程序代码
COPY . .

# 设定环境变量
ENV FLASK_ENV=production

# 暴露 Flask 默认端口
EXPOSE 10000

# 启动 Flask 应用
CMD ["python", "app.py"]
