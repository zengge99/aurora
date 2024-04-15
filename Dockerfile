# 使用 Go 1.21 官方镜像作为构建环境
FROM devopsworks/golang-upx:1.22 AS builder

# 禁用 CGO
ENV CGO_ENABLED=0

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 并下载依赖
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码并构建应用
COPY . .
RUN go build -ldflags "-s -w" -o /app/nginx . && \
  strip /app/nginx && \
  /usr/local/bin/upx -9 /app/nginx

# 使用 Alpine Linux 作为最终镜像
FROM alpine:latest
# FROM nginx:latest

# 设置工作目录
WORKDIR /app

# 从构建阶段复制编译好的应用和资源
COPY --from=builder /app/nginx /app/nginx
COPY harPool /app/harPool

# 使用数据库储存 conversation_id 和 oai-device-id 的关系
ENV USE_DB=true

# 暴露端口
EXPOSE 8080

CMD ["/app/nginx"]
