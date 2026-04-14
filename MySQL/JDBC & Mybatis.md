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

---
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

---
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

---

## Resultset 结果集对象
`ResultSet`（结果集）是 JDBC 中用于存储和操作数据库查询结果的对象。它类似于一张**虚拟的临时表**，维持着一个指向当前数据行的光标（Cursor）

###  工作原理：光标机制 (The Cursor)

当你执行 `executeQuery()` 后，返回的 `ResultSet` 对象初始状态下，光标指向第一行数据的**上方**（即“Before First”位置）

* **`next()` 方法**：将光标下移一行。
* **返回值**：如果下一行有数据，返回 `true`；如果已经到达末尾，返回 `false`。
* **常用遍历模式**：
```java
    while (rs.next()) {
        // 处理当前行的数据
        rs.getXxx(参数);
    }
```

---

### 获取数据的方法 (Getter Methods)

`ResultSet` 提供了丰富的 `getXXX` 方法来获取不同类型的数据，通常支持两种定位方式：

| 获取方式      | 示例                     | 优缺点                         |
| :-------- | :--------------------- | :-------------------------- |
| **通过列索引** | `rs.getString(1)`      | 性能略高，但代码可读性差，且依赖 SQL 字段顺序。  |
| **通过列标签** | `rs.getInt("user_id")` | **推荐方式**。可读性强，不依赖 SQL 字段顺序。 |

**常用类型映射：**
* `getString()` -> `String` (VARCHAR, TEXT)
* `getInt()` -> `int` (INT)
* `getDouble()` -> `double` (DOUBLE, DECIMAL)
* `getTimestamp()` -> `java.sql.Timestamp` (DATETIME)
* `getObject()` -> 通用类型，通常用于处理动态查询。
>[!NOTE] 注意
>JDBC 的列索引是从 **1** 开始的（1-based），而 Java 数组和集合是从 **0** 开始的（0-based）。如果在循环里混用了，会导致 `SQLException: Column Index out of range`

```Java
	Connection conn = DriverManager.getConnection(url,username,password);  
	
	String sql = "SELECT * FROM users";  
	try (conn; Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {  
	    while (rs.next()){  
	        String user = rs.getString("username");  
	        String passwd = rs.getString("password");  
	        String date = rs.getString("created_at");  
	        System.out.println(user + " " + passwd + " " + date);  
	    }  
	}
```

---

## PreparedStatement 预编译语句对象
`PreparedStatement` 继承自 `Statement` 接口，是 JDBC 中最常用的 SQL 执行对象。它代表一条**预编译**的 SQL 语句，能够有效提高性能并彻底杜绝 SQL 注入风险
### 优势
相比于普通的 `Statement`，`PreparedStatement` 具有三大核心优势：

1.  **防止 SQL 注入**：通过参数化查询，将 SQL 逻辑与数据分离，使恶意代码无法改变 SQL 结构。

2.  **性能优化**：数据库会对预编译后的 SQL 进行缓存（执行计划）。后续执行相同结构的 SQL（仅参数不同）时，无需重新解析。

3.  **代码可读性**：使用占位符 `?` 代替繁琐的字符串拼接，代码更加整洁。

### 使用步骤 

使用 `PreparedStatement` 遵循以下固定流程：

1.  **编写带占位符的 SQL**：使用 `?` 作为参数位置。
2.  **预编译 SQL**：通过 `Connection` 对象获取 `PreparedStatement` 实例。
3.  **设置参数**：调用 `setXXX()` 方法为每个 `?` 赋值（注意：索引从 **1** 开始）。
4.  **执行 SQL**：调用 `executeQuery()` 或 `executeUpdate()`（注意：执行时**不需要**再传入 SQL 字符串）。

**代码示例：**
```java
	String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
	try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
	    // 1. 设置参数（索引从 1 开始）
	    pstmt.setString(1, "admin");
	    pstmt.setString(2, "123456");
	    
	    // 2. 执行查询
	    try (ResultSet rs = pstmt.executeQuery()) {
	        while (rs.next()) {
	            // 处理结果
	        }
	    }
	}
```

### 常用API
| **方法**                         | **功能描述**                     |
| ------------------------------ | ---------------------------- |
| **`setObject(int, Object)`**   | 最通用的赋值方法，自动映射 Java 类型到数据库类型。 |
| **`setInt / setString / ...`** | 强类型赋值，确保数据类型安全。              |
| **`setNull(int, int)`**        | 为数据库字段设置 NULL 值。             |
| **`addBatch()`**               | 将当前参数组加入批处理队列。               |
| **`clearParameters()`**        | 清除当前设置的所有参数，以便重用该对象。         |
### `*`批处理
```Java
	String sql = "INSERT INTO students (name, score) VALUES (?, ?)";
	try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
	    for (Student s : studentList) {
	        pstmt.setString(1, s.getName());
	        pstmt.setInt(2, s.getScore());
	        pstmt.addBatch(); // 添加到批处理
	    }
	    pstmt.executeBatch(); // 一次性发送所有数据
	}
```


>[!WARNING] 注意
>SQL语句中的占位符**只能给值/参数使用**，**不能给表名使用**

### 原理
`PreparedStatement` 不仅仅是 `Statement` 的子接口，它在数据库层面引入了**预编译（Prepare**机制。

#### 防注入原理：语义定型

这是 `PreparedStatement` 最核心的安全特性。

* **逻辑固定**：在预编译阶段，SQL 的逻辑结构（如 `SELECT...WHERE...AND`）已经确定并被数据库理解。

* **字面量处理**：随后传入的任何参数，无论包含什么特殊字符（如 `' OR '1'='1`），都会被数据库引擎强制视为一个**整体的字符串常量**，而不会被当作 SQL 指令的一部分。

* **类型检查**：`setXXX` 方法在 Java 端就进行了类型校验，不符合类型的参数无法通过编译。

#  数据库连接池
数据库连接池是程序启动时自动建立的一定数量的数据库连接，并将这些连接维持在一个“池”中。当应用程序需要访问数据库时，直接从池中借用，使用完毕后归还给池。


- **数据库连接池**是个容器，负责分配、管理数据库连接 (Connection)。

- 它允许应用程序重复使用一个现有的数据库连接，而不是再重新建立一个。

- 释放空闲时间超过最大空闲时间的连接，来避免因为没有释放连接而引起的数据库连接遗漏。

优势：

1. 资源重用
2. 提升系统响应速度
3. 避免数据库连接遗漏
---

## 为什么走连接池？
在不使用连接池的情况下，每次数据库操作都遵循“六步走”：
1. **加载驱动** (消耗 CPU)
2. **建立物理连接** (涉及 TCP 三次握手，最耗时，通常需 0.1s - 0.5s)
3. **身份验证** (安全开销)
4. **执行 SQL**
5. **结果返回**
6. **销毁连接** (TCP 四次挥手)

**弊端**：在高并发场景下，频繁创建/销毁连接会产生巨大的网络负载，甚至导致数据库因连接数过多而宕机

---

## 主流连接池对比

1. **HikariCP 追光者(推荐)**：
   * **特点**：目前性能最强的连接池，字节码精简，速度极快。
   * **地位**：Spring Boot 2.0+ 默认连接池。
1. **Druid 德鲁伊(阿里巴巴)**：
   * **特点**：功能最全面，自带 **SQL 监控**、防御 SQL 注入、统计信息等。
   * **地位**：国内 Java 开发者的首选，利于排查慢 SQL。
3. **C3P0 / DBCP**：
   * **特点**：较老，配置繁琐，性能在现代高并发环境下略显不足。

---
## 核心参数配置

在使用连接池（如 Druid 或 HikariCP）时，这些参数直接决定了系统的吞吐量：

| 参数名称 | 描述 | 建议 |
| :--- | :--- | :--- |
| **initialSize** | 初始连接数 | 建议与 `minIdle` 一致。 |
| **maxActive** | 最大活跃连接数 | 根据数据库承载能力设置（如 50-100）。 |
| **maxWait** | 获取连接的最大等待时间 | 设置过长会导致前端请求挂起，建议 2000ms 左右。 |
| **minIdle** | 最小空闲连接数 | 始终保持在池中的“保底”连接。 |
| **validationQuery** | 验证连接是否有效的 SQL | MySQL 常用 `SELECT 1`。 |

```Java
	// 1. 加载配置文件
	Properties props = new Properties();
	props.load(new FileInputStream("druid.properties"));
	
	// 2. 获取数据源 (DataSource)
	DataSource ds = DruidDataSourceFactory.createDataSource(props);
	
	// 3. 从池中获取连接
	try (Connection conn = ds.getConnection()) {
	    // 这里的 close() 只是把连接归还给池
	    System.out.println("获取到连接：" + conn);
	}
```




---

---

# MyBatis
## `#{}`：预编译占位符（最常用、最安全）

这是 MyBatis 的默认推荐方式。

- **底层原理**：它是基于 JDBC 的 `PreparedStatement` 实现的。MyBatis 会先将 SQL 语句中的 `#{}` 替换为 `?`，发送给数据库进行预编译，然后再将参数值设置进去。
    
- **特点**：
    
    - **安全性高**：自动处理 SQL 注入风险。
        
    - **自动转义**：如果传入的是字符串，它会自动加上单引号 `' '`。
        
- **示例**：
```Mysql
-- 输入参数 name = "Zhang"
SELECT * FROM user WHERE username = #{name}
-- 解析后的 SQL：SELECT * FROM user WHERE username = ?
-- 执行时：SELECT * FROM user WHERE username = 'Zhang'
```


| **特性**    | **#{}**                 | **${}**           |
| --------- | ----------------------- | ----------------- |
| **处理方式**  | 预编译 (PreparedStatement) | 字符串替换 (Statement) |
| **场景**    | 参数值传递                   | 表名、字段名动态设置时使用     |
| **安全性**   | **高**，防止 SQL 注入         | **低**，有 SQL 注入风险  |
| **性能**    | 高（预编译可重用执行计划）           | 低（每次都需要重新解析 SQL）  |
| **自动加引号** | 是                       | 否                 |
这些场景通常是 **“参数不是作为值，而是作为 SQL 的语法组成部分”** 时：

1. **动态表名**：`SELECT * FROM ${tableName}`
    
2. **动态列名**：`SELECT ${columnName} FROM user`
    
3. **动态排序**：`ORDER BY ${orderColumn} ${sortType}`（比如让用户点击表头按不同字段排序）
### 问：“为什么 `#{}` 能防止 SQL 注入，而 `${}` 不能？”

**回答：** “因为 `#{}` 采用了 JDBC 的 **预编译 (PreparedStatement)** 机制。在这种机制下，SQL 的结构在参数传入前就已经确定并发送给数据库解析了。参数被视为单纯的‘值’，即使参数里包含 `OR 1=1` 这样的指令，也只会被当作一段普通的文本处理，不会改变 SQL 的逻辑语义。 而 `${}` 只是简单的 **字符串拼接**，参数会直接参与 SQL 语句的解析和编译，从而可能改变 SQL 的执行意图，导致注入风险。”

## 增删改查


### 插入INSERT
```Java
Mapper接口：

	@Insert("INSERT INTO user(username,password,name,age) VALUES(#{username},#{password},#{name},#{age})")  
	public void insert(User user);//插入用户信息
	
Spring测试：

	@Test  
	public void testInsert(){  
    User user = new User(null,"jjj","666888","鸡鸡鸡",18);  
    userMapper.insert(user);//调用UserMapper接口中的insert方法，插入用户信息  
	}
```

### 删除DELETE
```Java
Mapper接口：

	@Delete("DELETE FROM user WHERE id = #{id}")  
	public void deleteById(Integer id);
	
Spring测试：

	@Autowired  
	private UserMapper userMapper;//注入UserMapper接口的代理对象
	@Test  
	public void testDeleteById(){  
	    userMapper.deleteById(5);  
	}
```

### 修改UPDATE
```Java
Mapper接口：

	@Update("UPDATE user set username = #{username},password = #{password},name = #{name},age = #{age} WHERE id = #{id}")  
	public void update(User user);
	
Spring测试：

	public void testUpdate(){  
    User user = new User(1,"zhouyu","8989","周瑜",19);  
    userMapper.update(user);//调用UserMapper接口中的update方法，更新用户信息  
	}
```

### 查询SELECT
```Java
	@Select("SELECT * FROM user WHERE username = #{username} AND password = #{password}")  
	public User findByUsernameAndPassword(  
        @Param("username")String username,  
        @Param("password") String password);

```
**❗说明:**
**基于官方骨架创建的springboot项目中**，接口编译时会**保留方法形参名**，@Param注解可以省略(#{形参名})
#### @Param内部原理图解
1. **调用接口**：调用 `findByUsernameAndPassword("Zhang", "123")`。
    
2. **封装 Map**：MyBatis 内部会将这些参数封装成一个 `Map`。
    
    - **没有 `@Param`**：Map 为 `{arg0: "Zhang", arg1: "123"}`。
        
    - **有 `@Param`**：Map 为 `{username: "Zhang", password: "123"}`。
        
3. **SQL 填充**：执行时，MyBatis 从 Map 中根据 Key（即 `username`）取出 Value
#### 问：“MyBatis 的 `@Param` 注解有什么用？”

**回答：** “`@Param` 主要用于**多参数传递**的场景。由于 Java 字节码在编译后可能会丢失方法参数名，导致 MyBatis 无法将 SQL 中的占位符与方法参数对应。 通过 `@Param` 注解，我们可以显式地为参数命名，MyBatis 会将这些参数封装进一个 Map 中，从而在解析 SQL 语句时能够准确地通过 Key 找到对应的 Value。这增强了代码的可读性，并避免了多参数环境下参数找不到的异常。”

---
## XML映射配置
### 基本组成结构
```XML
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
  PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">

<mapper namespace="com.example.mapper.UserMapper">

    <select id="findById" resultType="com.example.pojo.User">
        SELECT * FROM user WHERE id = #{id}
    </select>

</mapper>
```
### 核心对应关系

为了让 Spring 容器能通过接口找到对应的 SQL，必须严格遵守以下约定：

1. **名称空间一致**：XML映射文件 的 `namespace` 属性必须是接口的**全路径名**。
    
2. **ID与方法名 一致**：XML映射文件中 SQL 标签的 `id` 属性必须与接口中的**方法名**完全一致。
	
3. **包名类名一致**： XML映射文件 的名称与`Mapper`接口名称一致，并且将XML映射文件和Mapper放在相同包下（同包同名）
	
4. **参数/结果一致**：`parameterType`（通常可省略）和 `resultType` 要与接口的入参和出参对应
	
```XML
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE mapper  
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"  
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">  
<mapper namespace="org.example.mapper.UserMapper">  
  
    <select id="findAll" resultType="org.example.pojo.User"> #往User封装  
        SELECT id,username,password,name,age FROM user  
    </select>  
</mapper>
相当于Mapper中的：@Select("SELECT id,username,password,name,age FROM user")
```

|**场景**|**推荐方式**|**原因**|
|---|---|---|
|简单的根据 ID 查询、删除|**注解**|快速、省事，不用在文件间跳来跳去。|
|复杂的关联查询（Join）|**XML**|注解难以处理复杂的 `resultMap` 嵌套映射。|
|动态搜索、批量插入|**XML**|动态标签（`<if>`, `<foreach>`）是 XML 的杀手锏。|
|SQL 语句经常需要优化|**XML**|修改 SQL 时不影响 Java 逻辑，更易于维护。|

### 辅助配置
```properties
	# 指定XML映射文件的位置  
	mybatis.mapper-locations=classpath:mapper/*.xml
```

# SpringBoot配置文件
## 配置格式
SpringBoot项目提供了多种属性配置方式(properties、yaml、yml)
## 核心语法规则（避坑指南）

YAML 的语法非常严苛，这些错误尤其会导致 Spring Boot 启动失败：

1. **大小写敏感**：`Name` 和 `name` 是不同的。
    
2. **使用缩进表示层级**：禁止使用 Tab 键，必须使用 **空格**（通常缩进 2 个空格）。
    
3. **冒号后必须有空格**：这是最容易忘的！`key: value` 冒号后面必须跟着一个空格。
    
4. **“#” 表示注释**：与 Java 里的 `//` 作用一样。

---
## YAML 的数据格式

###  纯量（普通键值对）
```yaml
server:
  port: 8080    # 注意冒号后的空格
  address: 127.0.0.1
```

### 对象（层级关系）

YAML 天然适合表达这种父子结构：
```yaml
student:
  name: ZhangKun
  age: 20
  major: SoftwareEngineering
```
### 数组 / 集合

使用 **短横线 `-`** 表示列表中的一个项：
```yaml
subjects:
  - Java
  - MyBatis
  - SpringBoot
```

>[!WARNING]
>在yml格式的配置文件中，如果配置项的值是以0开头的，值需要使用' '引起来，因为以0开头在yml中表示8进制的数据。





如果 `src/main/resources` 下同时存在 `application.properties` 和 `application.yml`：

- **Spring 会同时加载两个文件**。
    
- 如果有重复配置，**`.properties` 的优先级更高**（它会覆盖 `.yml` 的内容）。
    

> **建议**：项目中统一只用一种格式，避免逻辑混乱。