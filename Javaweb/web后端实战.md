+++
date = '2026-04-16'
draft = false
title = 'web后端实战'
tags = []
categories = ["JavaWeb"]
+++

> 本文更新于 2026-04-16

# Restful
REST(REpresentational state Transfer)，表述性状态转换，它是一种软件架构风格。
❗它并不是一种标准或协议，而是一组设计原则，旨在让网络服务更加简洁、高效且易于扩展。
## 具体请求url

| **动作**   | **完整的 URL 示例**                     | **语义** |
| -------- | ---------------------------------- | ------ |
| **查询全部** | `GET localhost:8080/books`         | 查列表    |
| **查询单个** | `GET localhost:8080/books/{id}`    | 查详情    |
| **新增**   | `POST localhost:8080/books`        | 存入新数据  |
| **更新**   | `PUT localhost:8080/books/{id}`    | 覆盖旧数据  |
| **删除**   | `DELETE localhost:8080/books/{id}` | 移除数据   |

## 对应的注解
|**注解**|**对应的 HTTP 方法**|**REST 语义**|**典型应用场景**|
|---|---|---|---|
|**`@GetMapping`**|**GET**|**查**|获取列表、查看详情、条件搜索。|
|**`@PostMapping`**|**POST**|**增**|提交表单、上传文件、新增部门/员工。|
|**`@PutMapping`**|**PUT**|**改（整）**|修改整个对象的信息（如修改员工的所有资料）。|
|**`@PatchMapping`**|**PATCH**|**改（部）**|修改部分信息（如只修改状态、只重置密码）。|
|**`@DeleteMapping`**|**DELETE**|**删**|删除单个或批量删除资源。|

```Java
	@GetMapping("/depts")  
	//指定请求方式  
	public Result list(){  
	    System.out.println("查询全部部门数据");  
	    List<Dept> deptList =  deptService.findAll();  
	    return Result.success(deptList);  
	}
```


## 优点
- **轻量级:** 相比早期的 SOAP 协议，REST 传输的数据量更小。
    
- **易于理解:** 直接利用 HTTP 语义，开发者上手极快。
    
- **高兼容性:** 只要支持 HTTP 协议的平台（浏览器、移动端、IoT）都能轻松调用。
    
- **利于缓存:** 良好的 RESTful 设计可以充分利用 HTTP 缓存机制，提升性能。

---


# 数据封装
在 MyBatis 中，如果**实体类属性名**（比如 `deptName`）和**数据库字段名**（比如 `name`）对不上，MyBatis 找不到对应关系，封装出来的结果就会是 `null`

### 起别名
在写 SQL 语句时，利用 SQL 的 `AS` 关键字，手动将数据库字段名改成和实体类属性名一致。
- **优点：** 简单直接。
    
- **缺点：** 如果字段很多，SQL 语句会变得非常臃肿，且每个查询都要写一遍。
```Mysql
	SELECT 
	    id, 
	    dept_name AS deptName, -- 数据库是 dept_name，实体类是 deptName
	    create_time AS createTime 
	FROM dept;
```

---

### 开启驼峰命名自动转换 (最推荐)
这是目前最常用的方案。大部分开发规范中，数据库字段用下划线（`dept_name`），Java 属性用小驼峰（`deptName`）。

只需要在 Spring Boot 的配置文件 `application.yml`（或 `properties`）中开启一个开关，MyBatis 就会自动帮你转换。

- **配置文件设置：**
- ```YAML
	  mybatis:
	  configuration:
	    # 开启驼峰命名自动映射：a_column -> aColumn
	    map-underscore-to-camel-case: true
   ```
- **效果：** 开启后，`dept_name` 会自动映射到 `deptName`
---

### 使用 ResultMap (最强大、最灵活)

如果你的命名完全不规则（比如数据库叫 `d_n`，实体类叫 `deptName`），或者需要处理复杂的关联查询，就需要手动定义映射规则。

在 Mapper 的 XML 文件中定义 `<resultMap>`：
```XML
	<resultMap id="DeptResultMap" type="com.example.pojo.Dept">
	    <id column="id" property="id" />
	    <result column="name" property="deptName" />
	    <result column="c_time" property="createTime" />
	</resultMap>
	
	<select id="findAll" resultMap="DeptResultMap">
	    SELECT id, name, c_time FROM dept
	</select>
```