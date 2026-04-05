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
5.  **行 (Row)**：最终的数据记录。