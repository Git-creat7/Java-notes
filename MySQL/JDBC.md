+++
date = '2026-04-05'
draft = false
title = 'JDBC'
tags = []
categories = ["MySQL"]
+++

> 本文更新于 2026-04-05

# API
## DriverManager 驱动管理类

1. **注册驱动**：让 `DriverManager` 知道当前有哪些可用的数据库驱动（如 MySQL, Oracle, PostgreSQL）。 
2. **建立连接**：根据传入的 URL、用户名和密码，找到匹配的驱动并返回一个 `Connection` 对象。

```Java
	"jdbc:mysql://127.0.0.1:3306/school_db?useSSL=false&serverTimezone=UTC&characterEncoding=UTF-8"
```

* **`//127.0.0.1:3306/`**：指定数据库服务器的地址和监听端口（默认 3306）。
* **`school_db`**：要连接的具体数据库模式（Schema）名称。
* **`useSSL=false`**：关闭 SSL 加密连接（开发环境下常用，减少性能开销）。
* **`serverTimezone=UTC`**：指定服务器时区。若不设置，在某些 MySQL 版本中可能会抛出时区错误。
* **`characterEncoding=UTF-8`**：强制使用 UTF-8 编码，防止中文乱码。
```Java
	// 1. 注册驱动 (JDBC 4.0 以后这一步可以省略)
	Class.forName("com.mysql.cj.jdbc.Driver"); 
	
	// 2. 通过 DriverManager 获取连接
	String url = "jdbc:mysql://localhost:3306/test_db";
	Connection conn = DriverManager.getConnection(url, "root", "password");
```
## Connection
`Connection` 接口是 JDBC API 的核心，代表与特定数据库的**物理会话（Session）**。所有的 SQL 语句都在此连接的上下文中执行。

### 核心方法
| 方法                                 | 功能描述                               |
| :--------------------------------- | :--------------------------------- |
| **`createStatement()`**            | 创建一个基本的 `Statement` 对象，用于执行静态 SQL。 |
| **`prepareStatement(String sql)`** | 创建一个预编译的语句对象，支持参数化查询（防注入）。         |
| **`setAutoCommit(boolean)`**       | 设置是否自动提交事务。默认为 `true`。             |
| **`commit()` / `rollback()`**      | 手动提交或回滚当前事务中的所有更改。                 |
| **`close()`**                      | 释放该连接占用的数据库和 JDBC 资源。              |
| **`isClosed()`**                   | 检查连接是否已关闭或失效。                      |
### JDBC的事务处理
```Java
	Connection conn = null;
	try {
	    conn = DriverManager.getConnection(url, user, pass);
	    // 1. 关闭自动提交，开启事务
	    conn.setAutoCommit(false);
	
	    // 2. 执行 SQL A (扣钱)
	    // 3. 执行 SQL B (加钱)
	
	    // 4. 业务全部成功，手动提交
	    conn.commit();
	} catch (Exception e) {
	    // 5. 一旦出异常，全部回滚
	    if (conn != null) {
	        try {
	            conn.rollback();
	        } catch (SQLException ex) {
	            ex.printStackTrace();
	        }
	    }
	} finally {
	    // 6. 记得关闭连接
	    if (conn != null) conn.close();
	}
```
## Statement
`Statement` 是 JDBC 中最基础的执行对象，用于执行静态 SQL 语句。
```Java
	// 1. 通过连接创建一个邮差
	Statement stmt = conn.createStatement();
	
	// 2. 让邮差去送信（执行 SQL）
	String sql = "UPDATE user SET name = '张三' WHERE id = 1";
	int rows = stmt.executeUpdate(sql); // 返回受影响的行数
	
	// 3. 如果是查询，会带回一个结果集
	ResultSet rs = stmt.executeQuery("SELECT * FROM user");
```

| **特性**     | **executeUpdate()**           | **executeQuery()**                      |
| ---------- | ----------------------------- | --------------------------------------- |
| **SQL 类型** | `INSERT, UPDATE, DELETE, DDL` | `SELECT`                                |
| **返回类型**   | `int` (行数)                    | `ResultSet` (数据集合)                      |
| **典型场景**   | 转账、注册、修改密码、删帖                 | 查余额、搜商品、看个人资料                           |
| **为空时**    | 返回 `0`                        | 返回一个空的 `ResultSet`（`rs.next()` 为 false） |
## Resultset