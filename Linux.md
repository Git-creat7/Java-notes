+++
date = '2026-05-17'
draft = false
title = 'Linux'
tags = []
categories = ["部署"]
+++

> 本文更新于 2026-05-17


# 目录结构

Linux 采用树状目录结构，所有目录都从根目录 `/` 出发，不同于 Windows 的盘符（C:、D:）。
```text
/ (根目录)
├── bin -> usr/bin          # 所有用户可执行的基础命令 (如 ls, cd)
├── boot                    # 系统启动核心文件与内核
├── dev                     # 硬件设备文件 (一切皆文件，如硬盘 sda)
├── etc                     # 系统与软件的全局配置文件 (如 nginx.conf)
│   ├── nginx/
│   ├── my.cnf
│   └── sysconfig/
├── home                    # 普通用户的家目录起点
│   ├── zhangkun/           # 具体普通用户的个人工作台
│   └── test_user/
├── lib -> usr/lib          # 系统和程序运行的基础动态链接库
├── media                   # 自动挂载的媒体设备 (如 U 盘)
├── mnt                     # 手动挂载临时文件系统的挂载点
├── opt                     # 给大型第三方额外软件准备的安装目录
├── proc                    # 虚拟文件系统，反映当前内存中的内核与进程状态
├── root                    # 超级管理员 (root) 的专属家目录
├── sbin -> usr/sbin        # 管理员专用的系统命令 (如 shutdown, fdisk)
├── sys                     # 虚拟文件系统，存放内核感知的硬件设备信息
├── tmp                     # 临时文件存放地 (系统会定期自动清理)
├── usr                     # 庞大的用户应用程序资源目录 (类似 Program Files)
│   ├── bin/                # 后期安装的大多数用户命令
│   ├── local/              # 开发者最常手动编译安装软件的地方 (如 redis, tomcat)
│   └── share/              # 共享数据和帮助文档
└── var                     # 动态变化的数据目录
    ├── log/                # 核心日志存放地 (如 nginx/error.log)
    └── run/                # 运行中的进程 PID 文件
```

| 目录 | 说明 |
| --- | --- |
| `/` | 根目录，所有目录的起点 |
| `/bin` | 存放普通用户可用的基础命令（如 `ls`、`cp`、`mv`） |
| `/sbin` | 存放系统管理命令，通常需要 root 权限 |
| `/etc` | 系统配置文件目录（如 `/etc/passwd`、`/etc/hosts`） |
| `/home` | 普通用户的家目录，每个用户对应一个子目录（如 `/home/tom`） |
| `/root` | root 用户的家目录 |
| `/usr` | 用户应用程序及文件目录，类似 Windows 的 `Program Files` |
| `/usr/local` | 本地手动安装的软件目录 |
| `/var` | 经常变化的文件，如日志（`/var/log`）、邮件、缓存 |
| `/tmp` | 临时文件目录，重启后通常会被清理 |
| `/opt` | 第三方大型软件的安装目录 |
| `/proc` | 虚拟文件系统，反映内核和进程信息 |
| `/dev` | 设备文件目录（如 `/dev/sda`、`/dev/null`） |
| `/mnt`、`/media` | 外部设备挂载点（U 盘、光盘等） |
| `/boot` | 系统启动相关文件（内核、引导加载器） |
| `/lib`、`/lib64` | 系统核心共享库 |

## 路径表示

- 绝对路径：从 `/` 开始，如 `/home/tom/test.txt`
- 相对路径：相对于当前工作目录，如 `./test.txt`、`../docs/note.md`
- 特殊符号：
  - `.` 当前目录
  - `..` 上级目录
  - `~` 当前用户的家目录
  - `-` 上一次所在的目录（配合 `cd -`）

# 文件操作

## 查看目录与文件

```bash
pwd                 # 显示当前所在目录的绝对路径
ls                  # 列出当前目录内容
ls -l               # 长格式显示（权限、所有者、大小、时间）
ls -a               # 显示隐藏文件（以 . 开头）
ls -lh              # 文件大小以人类可读格式显示（K/M/G）
ls -lt              # 按修改时间排序
ls -lS              # 按文件大小排序
ll                  # 等价于 ls -l（部分发行版自带别名）
tree                # 以树状结构显示目录（需安装 tree）
tree -L 2           # 限制显示 2 层
```

## 切换目录

```bash
cd /etc             # 切换到绝对路径
cd ../              # 返回上一级
cd ~                # 进入家目录
cd                  # 不带参数也回到家目录
cd -                # 返回上一次所在的目录
```

## 创建与删除

```bash
mkdir dir1                  # 创建目录
mkdir -p a/b/c              # 递归创建多级目录
mkdir dir1 dir2 dir3        # 一次创建多个目录

touch file.txt              # 创建空文件，或更新已有文件的时间戳
touch a.txt b.txt           # 一次创建多个文件

rm file.txt                 # 删除文件（会确认）
rm -f file.txt              # 强制删除，不提示
rmdir empty_dir             # 仅能删除空目录
```

> 注意：`rm -rf` 是高危命令，遇到批量删除场景应停下来与用户确认，避免误删。

## 查看文件内容

```bash
cat file.txt                # 一次性输出全部内容
cat -n file.txt             # 显示行号
tac file.txt                # 倒序输出（行序反转）

more file.txt               # 分页查看，空格翻页，q 退出
less file.txt               # 更强大的分页查看，支持上下翻、搜索（推荐）

head file.txt               # 默认查看前 10 行
head -n 20 file.txt         # 查看前 20 行
tail file.txt               # 默认查看后 10 行
tail -n 20 file.txt         # 查看最后 20 行
tail -f app.log             # 实时跟踪文件追加内容（看日志常用）
```

## 文件信息与统计

```bash
file demo.txt               # 查看文件类型
stat demo.txt               # 查看文件详细元信息（权限、大小、时间戳等）
du -sh dir/                 # 查看目录占用空间
df -h                       # 查看磁盘整体使用情况
wc -l file.txt              # 统计行数
wc -w file.txt              # 统计单词数
wc -c file.txt              # 统计字节数
```

# 拷贝移动

## cp 复制

```bash
cp source.txt target.txt            # 复制文件并重命名
cp file.txt /tmp/                   # 复制到指定目录
cp -r dir1 dir2                     # 递归复制目录（必须加 -r）
cp -i a.txt b.txt                   # 覆盖前提示确认
cp -f a.txt b.txt                   # 强制覆盖，不提示
cp -p a.txt b.txt                   # 保留权限、所有者、时间戳
cp -a dir1 dir2                     # 归档复制（等价于 -dpR，常用于备份）
cp -v src dst                       # 显示复制过程
cp *.txt /backup/                   # 配合通配符批量复制
```

### cp 参数详解

| 参数 | 作用 |
| --- | --- |
| `-r` / `-R` | **递归复制**。复制目录时必须加，否则会报 `omitting directory`。会把目录及其所有子文件/子目录一并复制 |
| `-p` | **保留原属性**。包括权限（mode）、所有者（owner/group）、时间戳（mtime/atime）。不加 `-p` 时新文件的时间戳是「现在」，所有者是当前用户 |
| `-a` | **归档模式**，等价于 `-dpR`：保留链接、保留属性、递归。备份目录的首选 |
| `-d` | 复制符号链接本身，而不是链接指向的文件 |
| `-i` | 覆盖前**交互确认**（提示 y/n） |
| `-f` | **强制覆盖**，目标文件存在时直接覆盖，不提示 |
| `-n` | 已存在则**不覆盖**（与 `-f` 相反） |
| `-u` | 仅当源文件**比目标新**或目标不存在时才复制（增量备份常用） |
| `-v` | 显示详细过程，每复制一个文件打印一行 |
| `-l` | 创建硬链接而非复制 |
| `-s` | 创建符号链接而非复制 |

> 经验：备份目录用 `cp -a`；普通复制用 `cp -r`；增量同步用 `cp -au` 或更专业的 `rsync`。

## mv 移动 / 重命名
- 为文件或目录重命名、或将文件或目录移动到其它位置(对**第二个参数是已存在的目录执行移动**)
`mv source dest`
```bash
mv old.txt new.txt                  # 同目录下相当于重命名
mv file.txt /tmp/                   # 移动到目标目录
mv file.txt /tmp/new.txt            # 移动并重命名
mv -i a.txt b.txt                   # 覆盖前提示
mv -f a.txt b.txt                   # 强制覆盖
mv -n a.txt b.txt                   # 已存在则不覆盖
mv dir1 dir2                        # 移动目录（不需要 -r）
```

### mv 参数详解

| 参数 | 作用 |
| --- | --- |
| `-i` | 覆盖前提示确认 |
| `-f` | 强制覆盖，不提示（默认行为，写出来更明确） |
| `-n` | 目标已存在则**不覆盖**，直接跳过 |
| `-u` | 仅当源比目标新或目标不存在时才移动 |
| `-v` | 显示移动过程 |
| `-b` | 覆盖前先把目标备份成 `xxx~` |

> `mv` 没有 `-r`：移动目录天然就是整体操作，不需要递归参数。

> `mv` 在同一文件系统下是原子操作（仅修改 inode 指向），跨文件系统时等价于「复制 + 删除」。

## 跨主机复制 scp

```bash
# 本地 -> 远程
scp file.txt user@192.168.1.10:/home/user/

# 远程 -> 本地
scp user@192.168.1.10:/home/user/file.txt ./

# 复制目录
scp -r dir/ user@host:/path/

# 指定端口
scp -P 2222 file.txt user@host:/path/
```

## 高效同步 rsync

```bash
rsync -av src/ dst/                 # 归档模式 + 显示详情
rsync -avz src/ user@host:/dst/     # 压缩传输到远程
rsync -av --delete src/ dst/        # 让 dst 与 src 完全一致（删除多余文件）
rsync -av --exclude='*.log' src/ dst/   # 排除指定文件
```

> `rsync` 仅传输差异部分，比 `scp` 快得多，适合大目录同步与增量备份。
> 注意源路径末尾 `/` 的差别：`src/` 表示复制目录内容，`src` 表示复制目录本身。

# 打包压缩

Linux 中「打包」与「压缩」通常是两个独立概念：
- 打包：把多个文件合并成一个文件（如 `.tar`）
- 压缩：减小文件体积（如 `.gz`、`.bz2`、`.xz`）

## tar（最常用）

```bash
# 打包（不压缩）
tar -cvf archive.tar dir/           # 仅打包成 .tar
tar -xvf archive.tar                # 解包

# 打包 + gzip 压缩（最常见）
tar -czvf archive.tar.gz dir/       # 打包并 gzip 压缩
tar -xzvf archive.tar.gz            # 解压
tar -xzvf archive.tar.gz -C /opt/   # 解压到指定目录

# 打包 + bzip2（压缩率更高，速度较慢）
tar -cjvf archive.tar.bz2 dir/
tar -xjvf archive.tar.bz2

# 打包 + xz（压缩率最高）
tar -cJvf archive.tar.xz dir/
tar -xJvf archive.tar.xz

# 查看包内文件，不解压
tar -tvf archive.tar.gz
```

参数说明：

| 参数 | 作用 |
| --- | --- |
| `-c` | **创建**新归档 |
| `-x` | **解开**归档 |
| `-t` | 查看包内文件列表，不解压 |
| `-r` | 向已有归档**追加**文件 |
| `-u` | 仅追加比包内更新的文件 |
| `-v` | 显示处理过程 |
| `-f` | **指定归档文件名**，必须紧跟文件名（如 `-f a.tar`） |
| `-z` | 使用 gzip 压缩 / 解压（`.gz`） |
| `-j` | 使用 bzip2（`.bz2`） |
| `-J` | 使用 xz（`.xz`） |
| `-C` | 切换到指定目录再操作（解压时常用，决定解压位置） |
| `--exclude` | 打包时排除指定文件，如 `--exclude='*.log'` |
| `-p` | 解压时保留原始权限 |

## zip / unzip（与 Windows 互通常用）

```bash
zip archive.zip file1 file2         # 打包文件
zip -r archive.zip dir/             # 递归打包目录
zip -e secret.zip file.txt          # 加密压缩（提示输入密码）

unzip archive.zip                   # 解压到当前目录
unzip archive.zip -d /tmp/          # 解压到指定目录
unzip -l archive.zip                # 仅查看内容
```

## gzip / bzip2 / xz（单文件压缩）

```bash
gzip file.txt                       # 压缩，生成 file.txt.gz，原文件被替换
gunzip file.txt.gz                  # 解压
gzip -k file.txt                    # 保留原文件

bzip2 file.txt                      # -> file.txt.bz2
bunzip2 file.txt.bz2

xz file.txt                         # -> file.txt.xz
unxz file.txt.xz
```

> 这三者都只压缩单文件，多文件场景请配合 `tar` 使用。

# 文本编辑和查找

## 重定向与追加

```bash
echo "hello" > a.txt                # 覆盖写入
echo "world" >> a.txt               # 追加写入
cat a.txt b.txt > c.txt             # 合并文件
command > out.log 2>&1              # 同时重定向标准输出和错误
command > /dev/null 2>&1            # 丢弃所有输出
```

## vi / vim 编辑器

vim 三种主要模式：**普通模式**（默认）、**插入模式**、**命令模式**。

```bash
vim file.txt                        # 打开文件，未存在则新建
```

模式切换：

| 操作 | 说明 |
| --- | --- |
| `i` | 在光标前进入插入模式 |
| `a` | 在光标后进入插入模式 |
| `o` | 在下方新开一行并进入插入模式 |
| `Esc` | 返回普通模式 |
| `:` | 进入命令模式 |

普通模式常用：

| 按键 | 作用 |
| --- | --- |
| `h j k l` | 左 下 上 右 |
| `gg` / `G` | 跳到文件开头 / 末尾 |
| `0` / `$` | 跳到行首 / 行尾 |
| `w` / `b` | 下一个 / 上一个单词 |
| `dd` | 删除当前行 |
| `yy` | 复制当前行 |
| `p` | 在下一行粘贴 |
| `u` | 撤销 |
| `Ctrl + r` | 重做 |
| `/keyword` | 向下搜索，`n` 下一个，`N` 上一个 |

命令模式常用：

| 命令 | 作用 |
| --- | --- |
| `:w` | 保存 |
| `:q` | 退出 |
| `:wq` 或 `ZZ` | 保存并退出 |
| `:q!` | 强制不保存退出 |
| `:set nu` | 显示行号 |
| `:set nonu` | 关闭行号 |
| `:%s/old/new/g` | 全文替换 old 为 new |
| `:10` | 跳转到第 10 行 |

## nano 编辑器

nano 是一款轻量、上手即用的终端编辑器，适合快速改配置文件。相比 vim 没有「模式」概念，输入即编辑，按底部提示的快捷键操作。

```bash
nano file.txt                       # 打开（不存在则新建）
nano +20 file.txt                   # 打开并跳到第 20 行
nano -w /etc/nginx/nginx.conf       # 关闭自动换行（编辑配置文件推荐）
nano -B file.txt                    # 保存时自动备份为 file.txt~
```

界面底部的 `^` 表示 `Ctrl`，`M-` 表示 `Alt`（或 `Esc`）。

常用快捷键：

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl + O` | 保存（Write Out），回车确认文件名 |
| `Ctrl + X` | 退出，未保存会询问 |
| `Ctrl + G` | 帮助 |
| `Ctrl + K` | 剪切当前行 |
| `Ctrl + U` | 粘贴 |
| `Ctrl + W` | 向下搜索 |
| `Alt + W` | 重复上一次搜索 |
| `Ctrl + \` | 查找并替换 |
| `Ctrl + _` | 跳转到指定行号（再输入行号） |
| `Alt + U` / `Alt + E` | 撤销 / 重做 |
| `Alt + #` | 显示行号（部分版本为 `Alt + N`） |
| `Ctrl + A` / `Ctrl + E` | 跳到行首 / 行尾 |
| `Ctrl + Y` / `Ctrl + V` | 上 / 下翻页 |

> 在 SSH 终端编辑系统配置时，如果只是顺手改几行，nano 比 vim 更省心；想要高效跳转、宏、批量操作，仍建议用 vim。

## grep 文本查找

```bash
grep "error" app.log                # 查找包含 error 的行
grep -i "error" app.log             # 忽略大小写
grep -n "error" app.log             # 显示行号
grep -v "error" app.log             # 反向匹配（不含 error 的行）
grep -r "TODO" src/                 # 递归搜索目录
grep -c "error" app.log             # 统计匹配行数
grep -A 3 "error" app.log           # 匹配行后 3 行
grep -B 3 "error" app.log           # 匹配行前 3 行
grep -C 3 "error" app.log           # 匹配行前后各 3 行
grep -E "error|warn" app.log        # 扩展正则，多关键字
grep --include="*.java" -r "main" . # 仅搜索 .java 文件
```

## find 文件查找

```bash
find /home -name "*.txt"            # 按名称查找
find . -iname "readme*"             # 忽略大小写
find . -type f                      # 仅文件
find . -type d                      # 仅目录
find . -size +10M                   # 大于 10MB 的文件
find . -size -1k                    # 小于 1KB 的文件
find . -mtime -7                    # 7 天内修改过的文件
find . -mtime +30                   # 30 天前修改过的文件
find . -user tom                    # 属于用户 tom
find . -name "*.sh" -exec chmod +x {} \;   # 找到并执行命令
```

## sed 流式编辑

```bash
sed 's/old/new/' file.txt           # 每行第一个 old 替换为 new（仅输出，不改文件）
sed 's/old/new/g' file.txt          # 每行全部替换
sed -i 's/old/new/g' file.txt       # 直接修改原文件
sed -n '5,10p' file.txt             # 打印第 5 到 10 行
sed '/^$/d' file.txt                # 删除空行
sed '2d' file.txt                   # 删除第 2 行
```

## awk 字段处理

```bash
awk '{print $1}' file.txt           # 打印每行的第 1 列（默认空白分隔）
awk -F: '{print $1}' /etc/passwd    # 用冒号作为分隔符
awk 'NR==2' file.txt                # 打印第 2 行
awk 'NR>1 && NR<5' file.txt         # 打印第 2 到 4 行
awk '$3>100 {print $1,$3}' data.txt # 第 3 列大于 100 的行，输出第 1、3 列
awk '{sum+=$1} END{print sum}' file.txt   # 第 1 列求和
```

## 排序与去重

```bash
sort file.txt                       # 按字典序升序
sort -r file.txt                    # 降序
sort -n file.txt                    # 按数值排序
sort -k2 file.txt                   # 按第 2 列排序
sort -u file.txt                    # 排序后去重
uniq file.txt                       # 去除相邻重复行（通常先 sort）
sort file.txt | uniq -c             # 统计每行出现次数
```

## 管道组合示例

```bash
# 查看占用 8080 端口的进程
netstat -tunlp | grep 8080

# 统计当前目录下 .java 文件数量
find . -name "*.java" | wc -l

# 找出日志中出现次数最多的 10 个 IP
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head -n 10

# 实时过滤日志中的错误
tail -f app.log | grep --color "ERROR"
```

# 进阶

## 用户与权限

### 用户管理

```bash
useradd tom                         # 创建用户
useradd -m -s /bin/bash tom         # 同时创建家目录并指定 shell
passwd tom                          # 修改用户密码
userdel tom                         # 删除用户（保留家目录）
userdel -r tom                      # 删除用户并清理家目录
usermod -aG docker tom              # 把 tom 加入 docker 附加组
groupadd dev                        # 创建用户组
groups tom                          # 查看 tom 所在的组
id tom                              # 查看 uid/gid/所属组
who                                 # 当前登录用户
whoami                              # 当前操作用户
su - tom                            # 切换到 tom（加载其环境）
sudo command                        # 以 root 权限执行命令
```

### 权限位

`ls -l` 输出示例：

```
-rwxr-xr-- 1 tom dev 1024 May 17 10:00 run.sh
```

第 1 位是文件类型：`-` 普通文件 / `d` 目录 / `l` 符号链接。
后 9 位分三组（owner、group、other），每组三位 `rwx`：

| 字符 | 数值 | 含义 |
| --- | --- | --- |
| `r` | 4 | 读 |
| `w` | 2 | 写 |
| `x` | 1 | 执行（目录则是「可进入」） |
| `-` | 0 | 无权限 |

### chmod 修改权限

```bash
chmod 755 run.sh                    # rwxr-xr-x（owner 全部，其他读+执行）
chmod 644 conf.yml                  # rw-r--r--（owner 读写，其他只读）
chmod 600 id_rsa                    # rw-------（仅 owner 读写，私钥常用）
chmod +x run.sh                     # 为所有人添加可执行权限
chmod u+x run.sh                    # 仅 owner 添加可执行
chmod g-w file                      # 移除 group 的写权限
chmod o=r file                      # other 仅保留读权限
chmod -R 755 dir/                   # 递归修改目录
```

### chown 修改归属

```bash
chown tom file.txt                  # 改变 owner
chown tom:dev file.txt              # 同时改 owner 和 group
chown -R tom:dev /opt/app           # 递归改变
chgrp dev file.txt                  # 仅改 group
```

## 进程管理

```bash
ps -ef                              # 查看所有进程（完整格式）
ps aux                              # 查看所有进程（含 CPU/内存占用）
ps -ef | grep java                  # 查找 java 相关进程
pgrep -l nginx                      # 按名称查 PID
pidof nginx                         # 直接获取 PID

top                                 # 实时进程监控（q 退出）
htop                                # 增强版（需安装，支持鼠标）
```

### 信号与终止

```bash
kill 1234                           # 发送默认 SIGTERM（15）
kill -9 1234                        # 强制终止 SIGKILL
kill -l                             # 查看所有信号
killall nginx                       # 按名称终止所有进程
pkill -f "java -jar app.jar"        # 按命令行模式匹配并终止
```

### 前台 / 后台

```bash
./run.sh &                          # 后台启动
jobs                                # 查看当前 shell 的后台任务
fg %1                               # 把 1 号任务调回前台
bg %1                               # 让 1 号任务在后台继续
Ctrl + Z                            # 当前前台任务挂起
Ctrl + C                            # 终止当前前台任务

nohup ./run.sh > out.log 2>&1 &     # 脱离终端后台运行（关闭 SSH 不退出）
disown -h %1                        # 将已运行任务从 shell 中脱离
```

## 网络与端口

### 网络配置查看

```bash
ip addr                             # 查看所有网卡（推荐）
ip a                                # 简写
ip route                            # 查看路由表
ifconfig                            # 旧命令，部分系统需安装 net-tools
hostname                            # 查看主机名
hostname -I                         # 查看本机 IP
cat /etc/resolv.conf                # 查看 DNS 配置
```

### 连接与端口

```bash
ss -tunlp                           # 查看所有监听端口（推荐替代 netstat）
ss -tunlp | grep 8080               # 查看 8080 占用
netstat -tunlp                      # 旧命令，含义同上
lsof -i:8080                        # 查看占用 8080 的进程
lsof -p 1234                        # 查看进程 1234 打开的所有文件
```

### 测试与抓取

```bash
ping baidu.com                      # 测试连通性（Ctrl+C 退出）
ping -c 4 baidu.com                 # 仅发 4 次
traceroute baidu.com                # 路由跟踪
telnet host 8080                    # 测试 TCP 端口连通性
nc -zv host 8080                    # 同上，更现代
curl https://example.com            # 发起 GET 请求
curl -I https://example.com         # 仅查看响应头
curl -X POST -d "k=v" url           # POST 表单
curl -o page.html url               # 保存到文件
wget https://example.com/file.zip   # 下载文件
wget -c url                         # 断点续传
```

## 系统服务（systemd）

```bash
systemctl start nginx               # 启动服务
systemctl stop nginx                # 停止服务
systemctl restart nginx             # 重启
systemctl reload nginx              # 重新加载配置（不中断）
systemctl status nginx              # 查看状态
systemctl enable nginx              # 开机自启
systemctl disable nginx             # 取消开机自启
systemctl is-active nginx           # 是否运行中
systemctl is-enabled nginx          # 是否已开机自启
systemctl list-units --type=service # 列出所有服务
systemctl daemon-reload             # 修改 .service 文件后重新加载
```

### journalctl 日志查看

```bash
journalctl -u nginx                 # 查看 nginx 服务日志
journalctl -u nginx -f              # 实时跟踪
journalctl -u nginx --since today   # 仅今日
journalctl -u nginx --since "1 hour ago"
journalctl -p err                   # 仅错误级别
journalctl --disk-usage             # 日志占用空间
```

## 磁盘与挂载

```bash
df -h                               # 查看各挂载点使用情况
df -hT                              # 同时显示文件系统类型
du -sh dir/                         # 查看目录总占用
du -sh *                            # 当前目录下每项占用
du -h --max-depth=1 /var            # 限制深度

lsblk                               # 树状显示块设备
fdisk -l                            # 查看分区表（root）
blkid                               # 查看设备 UUID 与文件系统类型
free -h                             # 查看内存使用情况
```

### 挂载与卸载

```bash
mount /dev/sdb1 /mnt/data           # 挂载分区到目录
mount -t nfs host:/share /mnt/nfs   # 挂载 NFS
umount /mnt/data                    # 卸载
umount -l /mnt/data                 # 懒卸载（占用时）
```

开机自动挂载：编辑 `/etc/fstab`，每行格式为：

```
UUID=xxxx  /mnt/data  ext4  defaults  0  2
```

## 软件包管理

### Debian / Ubuntu（apt）

```bash
apt update                          # 更新软件源索引
apt upgrade                         # 升级已装软件
apt install nginx                   # 安装
apt remove nginx                    # 卸载（保留配置）
apt purge nginx                     # 卸载并删除配置
apt search keyword                  # 搜索
apt show nginx                      # 查看详情
apt list --installed                # 已安装列表
dpkg -i pkg.deb                     # 安装本地 .deb 包
dpkg -l | grep nginx                # 已安装包查找
```

### RHEL / CentOS / Rocky（yum / dnf）

```bash
yum install nginx                   # 旧版 / CentOS 7
dnf install nginx                   # 新版 / CentOS 8+
dnf remove nginx
dnf update
dnf search keyword
dnf list installed
rpm -ivh pkg.rpm                    # 安装本地 .rpm
rpm -qa | grep nginx                # 已安装查找
rpm -ql nginx                       # 列出包内所有文件
```

## 软硬链接

```bash
ln source.txt hard.txt              # 硬链接：与源共用 inode
ln -s /opt/app/run.sh /usr/local/bin/run    # 软链接（符号链接）
ls -l /usr/local/bin/run            # 软链接显示为 -> 目标
readlink -f link                    # 查看链接最终指向
unlink link                         # 删除链接
```

| 区别 | 硬链接 | 软链接 |
| --- | --- | --- |
| 跨文件系统 | 不可 | 可 |
| 链接目录 | 不可 | 可 |
| 源被删除 | 仍可访问 | 失效（悬空） |
| inode | 相同 | 不同 |

## 环境变量与 PATH

```bash
echo $PATH                          # 查看 PATH
echo $HOME                          # 当前用户家目录
env                                 # 查看所有环境变量
export JAVA_HOME=/opt/jdk-17        # 临时设置（仅当前 shell）
export PATH=$JAVA_HOME/bin:$PATH    # 把 java 加入 PATH
unset JAVA_HOME                     # 删除变量
```

持久化（按需选择写入文件）：

| 文件 | 作用范围 |
| --- | --- |
| `/etc/profile` | 所有用户，登录时加载 |
| `/etc/environment` | 所有用户，纯键值对 |
| `~/.bash_profile` 或 `~/.profile` | 当前用户，登录时加载 |
| `~/.bashrc` | 当前用户，每次开新 bash 时加载 |
| `~/.zshrc` | zsh 对应文件 |

```bash
source ~/.bashrc                    # 让修改立即生效
. ~/.bashrc                         # 等价写法
```
## 防火墙

### firewalld（RHEL / CentOS / Fedora）

```bash
systemctl start firewalld             # 启动
systemctl enable firewalld            # 开机自启
firewall-cmd --state                  # 查看运行状态
firewall-cmd --reload                 # 重载规则（不中断连接）
```

#### 区域（zone）概念

firewalld 使用区域来定义不同信任级别的网络环境：

| 区域 | 说明 |
| --- | --- |
| `public` | 默认区域，仅允许 SSH/DHCP/ping，适合公网 |
| `trusted` | 信任所有流量 |
| `block` | 拒绝所有入站并返回明确拒绝 |
| `drop` | 静默丢弃所有入站（类似黑洞） |
| `home` / `work` / `internal` | 信任度递增，允许更多服务 |

```bash
firewall-cmd --get-default-zone       # 查看默认区域
firewall-cmd --get-active-zones       # 查看当前生效的区域与网卡绑定
firewall-cmd --set-default-zone=public
```

#### 开放端口与服务

```bash
firewall-cmd --permanent --add-service=http       # 永久放行 HTTP
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8080/tcp      # 放行指定端口
firewall-cmd --permanent --add-port=10000-10010/tcp  # 放行端口范围
firewall-cmd --reload
```

```bash
firewall-cmd --permanent --remove-service=http    # 移除服务
firewall-cmd --permanent --remove-port=8080/tcp   # 移除端口
firewall-cmd --reload
```

> `--permanent` 表示写入配置文件，必须配合 `--reload` 才立即生效；不加 `--permanent` 则仅当前生效，重启后丢失。

#### 查看规则

```bash
firewall-cmd --list-all               # 查看默认区域全部配置
firewall-cmd --zone=public --list-all # 查看指定区域
firewall-cmd --list-services          # 已放行的服务
firewall-cmd --list-ports             # 已放行的端口
```

### ufw（Ubuntu / Debian 简化版）

```bash
ufw enable                            # 启用防火墙
ufw disable                           # 关闭
ufw status verbose                    # 查看详细状态
ufw default deny incoming             # 默认拒绝入站
ufw default allow outgoing            # 默认允许出站
```

#### 规则管理

```bash
ufw allow 22/tcp                      # 放行 SSH
ufw allow 80/tcp                      # 放行 HTTP
ufw allow 443/tcp                     # 放行 HTTPS
ufw allow 8080/tcp                    # 放行自定义端口
ufw allow from 192.168.1.0/24         # 放行整个网段
ufw allow from 192.168.1.50 to any port 3306  # 仅允许指定 IP 访问 MySQL
```

```bash
ufw delete allow 80/tcp               # 删除规则
ufw deny 3306/tcp                     # 显式拒绝端口
ufw reset                             # 重置所有规则（谨慎）
```

#### 按应用名放行

```bash
ufw app list                          # 查看可用的应用配置
ufw allow 'Nginx Full'                # 同时放行 80 和 443
ufw allow 'OpenSSH'
```

> 应用配置文件位于 `/etc/ufw/applications.d/`，可自定义。

### iptables（底层通用）

iptables 是 Linux 内核 netfilter 框架的用户态工具，firewalld 和 ufw 底层都依赖它。

#### 四表五链

**四表**：

| 表名 | 作用 |
| --- | --- |
| `filter` | 过滤（默认最常用），决定放行 / 丢弃 |
| `nat` | 网络地址转换（端口映射、源/目的 NAT） |
| `mangle` | 修改数据包头部（如 TTL、TOS） |
| `raw` | 连接追踪豁免 |

**五链**（数据包流经的关键节点）：

| 链名 | 说明 |
| --- | --- |
| `PREROUTING` | 进入本机前（路由判断之前） |
| `INPUT` | 发往本机进程 |
| `FORWARD` | 经过本机转发（网关/路由器场景） |
| `OUTPUT` | 本机进程发出 |
| `POSTROUTING` | 离开本机前（路由判断之后） |

#### 常用命令

```bash
iptables -L -n -v                     # 列出所有规则（-n 数字显示，-v 详细）
iptables -L INPUT -n -v               # 仅查看 INPUT 链
iptables -F                           # 清空所有规则（谨慎）
iptables -X                           # 删除用户自定义链
```

#### 增删规则

```bash
# 允许已建立和相关的连接（通常放第一条）
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 放行本地回环
iptables -A INPUT -i lo -j ACCEPT

# 放行指定端口
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# 放行指定 IP
iptables -A INPUT -s 192.168.1.50 -j ACCEPT

# 拒绝其余入站
iptables -A INPUT -j DROP
```

```bash
# 删除指定规则（先查看编号）
iptables -L INPUT --line-numbers
iptables -D INPUT 3                   # 删除 INPUT 链第 3 条规则
```

| 参数 | 含义 |
| --- | --- |
| `-A` | 追加到链末尾（Append） |
| `-I` | 插入到链开头（Insert），如 `-I INPUT 1` |
| `-D` | 删除（Delete） |
| `-p` | 协议：`tcp` / `udp` / `icmp` / `all` |
| `--dport` | 目标端口 |
| `--sport` | 源端口 |
| `-s` | 源地址 |
| `-d` | 目标地址 |
| `-i` | 入站网卡 |
| `-o` | 出站网卡 |
| `-j` | 跳转目标：`ACCEPT` / `DROP` / `REJECT` / `LOG` |

> `DROP` 是静默丢弃，`REJECT` 会返回拒绝响应（对外更友好，对内暴露信息稍多）。

#### 保存与恢复

iptables 规则默认重启后丢失，需持久化：

```bash
# Debian / Ubuntu
iptables-save > /etc/iptables/rules.v4
ip6tables-save > /etc/iptables/rules.v6

# CentOS / RHEL
iptables-save > /etc/sysconfig/iptables
```

```bash
# 恢复
iptables-restore < /etc/iptables/rules.v4
```

## 定时任务

### crontab（周期任务）

```bash
crontab -e                          # 编辑当前用户任务
crontab -l                          # 查看
crontab -r                          # 删除（谨慎）
```

格式：`分 时 日 月 周  命令`

```cron
*  *  *  *  *   command       # 每分钟执行
0  3  *  *  *   /opt/backup.sh    # 每天 3:00
*/5 *  *  *  *   command      # 每 5 分钟
0  9  *  *  1-5 command       # 工作日 9 点
0  0  1  *  *   command       # 每月 1 号
```

### at（一次性任务）

```bash
echo "/opt/run.sh" | at 22:00       # 今晚 22:00 执行
at now + 5 minutes                  # 5 分钟后
atq                                 # 查看任务队列
atrm 3                              # 删除编号 3 的任务
```

## Shell 脚本基础

### 第一个脚本

```bash
#!/bin/bash
echo "Hello, $1"
```

```bash
chmod +x hello.sh
./hello.sh world                    # 输出 Hello, world
```

### 变量

```bash
name="tom"                          # 等号两边不能有空格
echo $name
echo "${name}_log"                  # 拼接时建议用花括号

# 特殊变量
$0      # 脚本名
$1..$9  # 第 N 个参数
$#      # 参数个数
$@      # 所有参数（逐个）
$*      # 所有参数（整体）
$?      # 上条命令退出码（0 表示成功）
$$      # 当前进程 PID
```

### 判断

```bash
if [ "$1" = "start" ]; then
    echo "starting..."
elif [ -f /tmp/lock ]; then
    echo "locked"
else
    echo "unknown"
fi
```

常用测试：

| 表达式 | 含义 |
| --- | --- |
| `-f file` | 是普通文件 |
| `-d dir` | 是目录 |
| `-e path` | 存在 |
| `-r/-w/-x` | 可读 / 可写 / 可执行 |
| `-z str` | 字符串为空 |
| `-n str` | 字符串非空 |
| `=` `!=` | 字符串相等 / 不等 |
| `-eq -ne -lt -le -gt -ge` | 数值比较 |

### 循环

```bash
# for
for i in 1 2 3; do
    echo $i
done

for f in *.log; do
    echo "处理 $f"
done

for i in {1..5}; do echo $i; done

# while
i=0
while [ $i -lt 3 ]; do
    echo $i
    i=$((i + 1))
done
```

### 函数

```bash
greet() {
    local name=$1
    echo "Hello, $name"
    return 0
}

greet "tom"
echo "退出码: $?"
```

## 常用快捷键与技巧

| 快捷键 | 作用 |
| --- | --- |
| `Tab` | 命令 / 路径补全 |
| `Ctrl + R` | 历史命令搜索 |
| `Ctrl + A` / `Ctrl + E` | 移到行首 / 行尾 |
| `Ctrl + U` / `Ctrl + K` | 删除光标前 / 后所有内容 |
| `Ctrl + W` | 删除前一个单词 |
| `Ctrl + L` | 清屏（等价于 `clear`） |
| `Ctrl + C` | 中断当前命令 |
| `Ctrl + D` | 退出当前 shell（或结束输入） |
| `Ctrl + Z` | 挂起当前任务 |
| `!!` | 重复上一条命令 |
| `!ssh` | 重复最近以 `ssh` 开头的命令 |
| `history` | 查看历史命令 |
| `!100` | 执行历史中第 100 条命令 |

## 系统信息一览

```bash
uname -a                            # 内核及架构
cat /etc/os-release                 # 发行版信息
lsb_release -a                      # 发行版（部分系统需安装）
uptime                              # 启动时长 + 负载
date                                # 当前时间
cal                                 # 日历
who -b                              # 上次启动时间
last                                # 登录历史
dmesg | tail                        # 内核日志（排查硬件问题）
```








