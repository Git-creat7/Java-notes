+++
date = '2026-05-17'
draft = false
title = 'Docker'
tags = []
categories = ["部署"]
+++

> 本文更新于 2026-05-17

# 常见命令

## 镜像操作

| 命令                                     | 说明           |
| -------------------------------------- | ------------ |
| `docker pull <镜像名>:<tag>`              | 拉取镜像         |
| `docker images`                        | 查看本地镜像列表     |
| `docker rmi <镜像名/ID>`                  | 删除镜像         |
| `docker build -t <名称>:<tag> .`         | 构建镜像         |
| `docker save -o <文件名>.tar <镜像名>:<tag>` | 导出镜像为 tar 文件 |
| `docker load -i <文件名>.tar`             | 从 tar 文件加载镜像 |

## 容器操作

| 命令 | 说明 |
|------|------|
| `docker run` | 创建并运行容器 |
| `docker ps` | 查看运行中的容器 |
| `docker ps -a` | 查看所有容器（含已停止） |
| `docker stop <容器名/ID>` | 停止容器 |
| `docker start <容器名/ID>` | 启动已停止的容器 |
| `docker restart <容器名/ID>` | 重启容器 |
| `docker rm <容器名/ID>` | 删除容器（需先停止） |
| `docker rm -f <容器名/ID>` | 强制删除容器 |
| `docker logs <容器名/ID>` | 查看容器日志 |
| `docker logs -f <容器名/ID>` | 持续跟踪日志输出 |
| `docker exec -it <容器名/ID> bash` | 进入容器内部 |

## docker run 常用参数

```bash
docker run -d \
  --name <容器名> \
  -p <宿主机端口>:<容器端口> \
  -e <环境变量>=<值> \
  -v <挂载路径> \
  --network <网络名> \
  <镜像名>:<tag>
```

| 参数                 | 说明              |
| ------------------ | --------------- |
| `-d`               | 后台运行（detached）  |
| `--name`           | 指定容器名称          |
| `-p`               | 端口映射，宿主机:容器     |
| `-e`               | 设置环境变量          |
| `-v`               | 挂载数据卷或目录        |
| `--network`        | 指定网络            |
| `--restart=always` | 容器随 Docker 自动重启 |
| `<tag>`            | 版本号             |

---

# 挂载

容器内的数据默认随容器删除而丢失，通过挂载可以将数据持久化到宿主机。

## 数据卷挂载

数据卷（Volume）是 Docker 管理的特殊目录，存储在 Docker 的默认路径下（Linux 为 `/var/lib/docker/volumes/`）。

```bash
# 创建数据卷
docker volume create <卷名>

# 查看所有数据卷
docker volume ls

# 查看数据卷详情
docker volume inspect <卷名>

# 删除数据卷
docker volume rm <卷名>

# 删除所有未使用的数据卷
docker volume prune
```

使用方式：

```bash
docker run -d --name nginx \
  -p 80:80 \
  -v html:/usr/share/nginx/html \
  nginx
```

`-v <卷名>:<容器内路径>`，如果卷名不存在会自动创建。

## 本地目录挂载

直接将宿主机的目录或文件映射到容器内，路径必须以 `/` 或 `./` 开头（以此区分数据卷挂载）。

```bash
docker run -d --name mysql \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=123456 \
  -v /root/mysql/data:/var/lib/mysql \
  -v /root/mysql/conf:/etc/mysql/conf.d \
  mysql
```

| 对比 | 数据卷挂载 | 本地目录挂载 |
|------|-----------|-------------|
| 语法 | `-v 卷名:容器路径` | `-v /宿主机路径:容器路径` |
| 管理方式 | Docker 管理 | 用户自行管理 |
| 可移植性 | 高 | 依赖宿主机路径 |
| 适用场景 | 不关心数据存放位置 | 需要直接访问或编辑文件 |

---

# 自定义镜像

## Dockerfile

Dockerfile 是构建镜像的脚本文件，包含一系列指令：

| 指令 | 说明 |
|------|------|
| `FROM` | 指定基础镜像 |
| `ENV` | 设置环境变量 |
| `COPY` | 将本地文件复制到镜像中 |
| `ADD` | 类似 COPY，支持自动解压 tar 和远程 URL |
| `RUN` | 构建时执行命令（安装依赖等） |
| `EXPOSE` | 声明容器运行时监听的端口 |
| `WORKDIR` | 设置工作目录 |
| `ENTRYPOINT` | 容器启动时执行的命令（不可被覆盖） |
| `CMD` | 容器启动时的默认命令（可被覆盖） |

## 示例：构建 Java 应用镜像

```dockerfile
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/app.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

构建并运行：

```bash
docker build -t my-app:1.0 .
docker run -d --name my-app -p 8080:8080 my-app:1.0
```

## 镜像分层

每条 Dockerfile 指令都会生成一个镜像层（Layer），层可以被缓存和复用。将不常变动的指令（如安装依赖）放在前面，频繁变动的（如 COPY 源码）放在后面，可以充分利用缓存加速构建。

---

# 网络

## 默认网络

Docker 安装后自动创建三种网络：

| 网络 | 说明 |
|------|------|
| `bridge` | 默认网络，容器通过 IP 互通，但 IP 会变化 |
| `host` | 容器直接使用宿主机网络，无端口映射 |
| `none` | 无网络 |

默认 bridge 网络中，容器之间只能通过 IP 通信，不支持容器名解析。

## 自定义网络

自定义网络支持通过**容器名**互相访问（DNS 解析），推荐使用。

```bash
# 创建自定义网络
docker network create <网络名>

# 查看网络列表
docker network ls

# 查看网络详情
docker network inspect <网络名>

# 删除网络
docker network rm <网络名>
```

使用方式：

```bash
# 运行容器时指定网络
docker run -d --name app --network my-net my-app:1.0
docker run -d --name db --network my-net mysql

# 容器内可直接通过容器名访问
# 例如 app 中连接数据库：jdbc:mysql://db:3306/mydb
```

---

# Docker Compose

用于定义和运行多容器应用，通过一个 `docker-compose.yml` 文件描述所有服务。

## 常用命令

```bash
# 启动所有服务（后台）
docker compose up -d

# 停止并移除所有容器
docker compose down

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f <服务名>

# 重新构建并启动
docker compose up -d --build
```

## 示例：docker-compose.yml

```yaml
version: "3.8"

services:
  app:
    build: .
    container_name: my-app
    ports:
      - "8080:8080"
    environment:
      - SPRING_DATASOURCE_URL=jdbc:mysql://db:3306/mydb
    depends_on:
      - db
    networks:
      - my-net

  db:
    image: mysql:8.0
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=123456
      - MYSQL_DATABASE=mydb
    volumes:
      - db-data:/var/lib/mysql
    networks:
      - my-net

networks:
  my-net:

volumes:
  db-data:
```

`depends_on` 控制启动顺序，但不会等待服务就绪。如需等待数据库就绪，可配合健康检查使用。