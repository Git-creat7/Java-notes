+++
date = '2026-03-28'
draft = false
title = 'SQLs'
tags = []
categories = ["MySQL"]
+++

> 本文更新于 2026-03-28

# 通用语法及分类
## 基础书写规则

- **分号结束**：每条 SQL 语句通常以分号 `;` 结尾（虽然某些单条执行环境不强制，但在脚本中是必需的）。
    
- **不区分大小写**：SQL 关键字（如 `SELECT`, `FROM`）不区分大小写，但为了代码可读性，习惯上**关键字大写**，表名和列名小写。
    
    - _推荐写法：_ `SELECT name FROM users;`
        
- **空格与缩进**：SQL 对空格和换行不敏感。合理的缩进能显著提高代码的可读性。
    
- **注释规范**：
    
    - 单行注释：`-- 注释内容` 或 `# 注释内容`（仅限 MySQL）。
        
    - 多行注释：`/* 注释内容 */`。

|**缩写**|**全称**|**操作对象**|**常用动词**|**场景示例**|
|---|---|---|---|---|
|**DDL**|Definition|表结构/数据库|`CREATE`, `DROP`|“建个名为‘用户’的表”|
|**DML**|Manipulation|行记录|`INSERT`, `UPDATE`|“把小明的年龄改成18”|
|**DQL**|Query|数据结果集|`SELECT`|“找出所有北京的用户”|
|**DCL**|Control|权限/安全|`GRANT`, `REVOKE`|“允许小李查看工资表”|

# DDL

## CREATE（创建）

- 用于建立新的数据库对象。
```SQL
-- 创建一个名为 users 的表
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT, -- 主键，自动增长
    username VARCHAR(50) NOT NULL,      -- 不允许为空
    email VARCHAR(100) UNIQUE,          -- 唯一约束
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP -- 默认值
);
```

## ALTER（修改）

- 用于修改现有的表结构，例如增加新列、更改数据类型或重命名。
```SQL
-- 在 users 表中增加一行“手机号”
ALTER TABLE users ADD phone_number VARCHAR(20);

-- 修改字段类型
ALTER TABLE users MODIFY COLUMN username VARCHAR(100);

-- 删除某一列
ALTER TABLE users DROP COLUMN email;
```

## DROP（删除）

- 将整个对象从数据库中彻底抹去。
```SQL
-- 删除整个 users 表（结构和数据全部消失）
DROP TABLE users;

-- 删除整个数据库
DROP DATABASE my_app;
```

## TRUNCATE（清空）

- 用于删除表中的**所有**数据，但保留表结构。

- **与 DELETE 的区别**：`DELETE` 是一行行删，速度慢；`TRUNCATE` 是直接销毁表并重建一个空的，速度极快且不记录逐行日志。

```SQL
TRUNCATE TABLE users;
```
## 数值类型
| **类型**            | **占用字节** | **取值范围 (有符号)**   | **常见应用场景**               |
| ----------------- | -------- | ---------------- | ------------------------ |
| **TINYINT**       | 1 Byte   | -128 ~ 127       | 枚举状态（0:禁用, 1:激活）、布尔模拟、年龄 |
| **SMALLINT**      | 2 Bytes  | -32,768 ~ 32,767 | 较小的计数、邮编、年份              |
| **MEDIUMINT**     | 3 Bytes  | -838万 ~ 838万     | 中等规模的 ID 或统计             |
| **INT / INTEGER** | 4 Bytes  | -21亿 ~ 21亿       | **最常用**，普通表的主键 ID、订单量    |
| **BIGINT**        | 8 Bytes  | 很大 (10的18次方级)    | 全球级 ID（雪花算法）、毫秒级时间戳、大型流水 |

