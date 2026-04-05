+++
date = '2026-04-05'
draft = false
title = 'InnoDB引擎'
tags = []
categories = ["MySQL"]
+++

> 本文更新于 2026-04-05

InnoDB 是 MySQL 的默认事务型引擎，也是目前最常用、最强大的存储引擎。它被设计用来处理大量的短期事务，具有高性能和高可用性。

# 核心特性

InnoDB 的强大源于其四大核心支柱：

* **事务支持 (ACID)**：
	
    - 支持事务的原子性、一致性、隔离性和持久性。通过 **Redo Log**（重做日志）保证持久性，通过 **Undo Log**（回滚日志）保证原子性。
    
* **行级锁 (Row-level Locking)**：
	
    - 不同于 MyISAM 的表级锁，InnoDB 支持行锁，极大提高了多用户并发操作的性能。
    
* **外键约束 (Foreign Key)**：
	
	- 它是 MySQL 中唯一支持外键的内置存储引擎，能够维护数据的参照完整性。
	
* **MVCC (多版本并发控制)**：
	
    - 通过 Read View 和 Undo Log 实现非阻塞读。在“可重复读”隔离级别下，读操作不会加锁，从而提升了并发查询效率。

---
# 逻辑存储结构

InnoDB 将所有数据逻辑地存放在一个名为 **Tablespace**（表空间）的地方，其结构从大到小依次为：

1.  **表空间 (Tablespace)**：包含系统表空间（ibdata1）或独立表空间（.ibd）。
2.  **段 (Segment)**：分为数据段（Leaf node segment）、索引段（Non-leaf node segment）等。
3.  **区 (Extent)**：固定大小为 1MB，由 64 个连续的页组成。
4.  **页 (Page)**：InnoDB 磁盘管理的最小单位，默认大小为 **16KB**。
5.  **行 (Row)**：InnoDB存储引擎数据是按行进行存放的

---
## MySQL InnoDB 架构演进与组成

InnoDB 存储引擎的架构设计主要分为两个部分：
	**内存结构 (In-Memory Structures)** 和 **磁盘结构 (On-Disk Structures)**。
	这种设计旨在平衡高性能（内存操作）与数据持久性（磁盘存储）。


### 内存结构 (In-Memory Structures)


内存池是 InnoDB 性能的核心，其主要组件包括：

* **Buffer Pool (缓冲池)**：
	
    * **核心作用**：缓存磁盘上的真实数据页和索引页。
	    * **机制**：读取数据时，若缓冲池有则直接返回；修改数据时，先修改缓冲池中的页（变为“脏页”），再通过 Checkpoint 机制异步刷入磁盘。
    - ![](InnoDB引擎-3.png)
* **Change Buffer (写缓冲区)**：
	
    * 针对**非唯一辅助索引**的优化。当插入或更新辅助索引且该页不在缓冲池时，先记录在 Change Buffer 中，等未来读取该页时再进行合并。
    * ![](InnoDB引擎-4.png)
    
* **Adaptive Hash Index (自适应哈希索引)**：
	
    * InnoDB 会监控表上的索引查询，如果观察到某些索引值被频繁访问，会自动建立哈希索引以加速查询（将 B+ 树查询变为 O(1) 查找）
    * ![](InnoDB引擎-5.png)
    
* **Log Buffer (日志缓冲区)**：
	
    * 用于保存准备写入磁盘的 **Redo Log** 数据。默认大小为 16MB，定期刷入磁盘以保证事务的持久性。
    
    - **意义：** 即使内存里的数据还没来得及写回磁盘就断电了，重启后也能通过磁盘上的 Redo Log 把数据恢复回来。
    - ![](InnoDB引擎-6.png)

---

### 磁盘结构 (On-Disk Structures)

磁盘结构确保了数据的物理存储和崩溃恢复能力： 

* **Tablespaces (表空间)**：
	
    * **System Tablespace (系统表空间)**：存储 InnoDB 数据字典、双写缓冲区等。
    * **File-Per-Table Tablespaces (独立表空间)**：每个表对应一个 `.ibd` 文件，存储该表的数据和索引。
    
* **Doublewrite Buffer (双写缓冲区)**：
	
    * 位于系统表空间的物理存储区。在将页写入数据文件前，先写入此处。用于防止在写入过程中发生断电导致的“页破碎”问题。
	
* **Redo Log (重做日志)**：
	
    * 记录对页的物理修改。当数据库宕机重启，会根据 Redo Log 将未落盘的脏页恢复。
	
* **Undo Logs (回滚日志)**：
	
    * 逻辑日志，记录事务变更前的样子。用于**事务回滚**和 **MVCC**（实现非阻塞读）。

---

### 核心后台线程

InnoDB 依靠多个后台线程来维持运行：

1.  **Master Thread**：负责将缓冲池数据异步刷新到磁盘，保持数据一致性。
2.  **IO Thread**：主要负责 AIO（异步IO）请求的回调处理（分为 Read, Write, Log, Insert Buffer 线程）。
3.  **Purge Thread**：事务提交后，负责回收已经不再需要的 Undo Log 页。
4.  **Page Cleaner Thread**：专门负责脏页的刷新工作，减轻 Master Thread 的负担。

---

### 架构设计的精髓：WAL (Write-Ahead Logging)

InnoDB 遵循 **日志先行策略**：
* 当数据发生变更时，先修改内存（Buffer Pool），并同步记录 Redo Log 到磁盘。
* 只要 Redo Log 落地，即使此时内存中的“脏页”还没来得及刷入磁盘，数据库发生崩溃也能通过日志恢复。
* 这种将“随机写磁盘”转变为“顺序写日志”的设计，是 InnoDB 高性能读写的基石。
