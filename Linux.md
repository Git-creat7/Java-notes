+++
date = '2026-05-17'
draft = false
title = 'Linux'
tags = []
categories = [""]
+++

> 本文更新于 2026-05-17


# 目录结构

Linux 采用树状目录结构，所有目录都从根目录 `/` 出发，不同于 Windows 的盘符（C:、D:）。

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

## mv 移动 / 重命名

```bash
mv old.txt new.txt                  # 同目录下相当于重命名
mv file.txt /tmp/                   # 移动到目标目录
mv file.txt /tmp/new.txt            # 移动并重命名
mv -i a.txt b.txt                   # 覆盖前提示
mv -f a.txt b.txt                   # 强制覆盖
mv -n a.txt b.txt                   # 已存在则不覆盖
mv dir1 dir2                        # 移动目录（不需要 -r）
```

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

| 参数 | 含义 |
| --- | --- |
| `-c` | 创建（create） |
| `-x` | 解开（extract） |
| `-t` | 查看内容（list） |
| `-v` | 显示过程（verbose） |
| `-f` | 指定文件名（file），必须紧跟文件名 |
| `-z` | 使用 gzip |
| `-j` | 使用 bzip2 |
| `-J` | 使用 xz |
| `-C` | 指定目标目录 |

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




