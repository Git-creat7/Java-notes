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

### 手动结果映射`@Results @Result`
```Java
@Mapper  
public interface DeptMapper{  
    @Results({  
            @Result(column = "create_time", property = "createTime"),  
            @Result(column = "update_time", property = "updateTime")  
    })  
    @Select("SELECT id, name, create_time, update_time FROM dept ORDER BY update_time DESC")  
    List<Dept> findAll();  
}
```
---

### 起别名
在写 SQL 语句时，利用 SQL 的 `AS` 关键字，手动将数据库字段名改成和实体类属性名一致。
- **优点：** 简单直接。
    
- **缺点：** 如果字段很多，SQL 语句会变得非常臃肿，且每个查询都要写一遍。
```Mysql
	SELECT 
	    id, name, 
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
---
# Nginx
```nginx
server{
	listen 90;
	# 省略......
	location ^~ /api/{
		# 只要URL 是以 /api/ 开头的请求
		rewrite ^~/api/(.*)$ /$1 break;
		proxy_pass http://localhost:8080; #代理转发
	}
}
```
---
# Controller 接收前端参数
## HttpServletRequest
```Java
	/*  
	* 基于HttpServetRequest接收前端请求参数，删除部门数据  
	* */  
	@DeleteMapping("/depts")  
	public Result deleteById(HttpServletRequest request){  
	    String idStr = request.getParameter("id");  
	    int id = Integer.parseInt(idStr);  
	    System.out.println("根据ID删除部门:"+id);  
	    return Result.success();  
	}
```
---
## @RequestParam
```Java
	@DeleteMapping("/depts")  
	public Result deleteById(@RequestParam("id") Integer deptId){  
	    System.out.println("根据ID删除部门:"+deptId);  
	    return Result.success();  
	}
```
- **`@DeleteMapping("/depts")`**: 指定该方法处理发送到 `/depts` 路径的 **DELETE** 类型请求。
	    
- **`@RequestParam("id")`**:
    
    - **❗明确映射**：**强制要求**前端必须传递一个名为 `id` 的参数，否则报错
	    - 默认Request 为 true，设为false 则不传递不会报错
        
    - **自动转换**：Spring 会自动将前端传来的字符串（如 `"1"`）转换为 Java 的 `Integer` 类型。如果前端传了非数字字符，Spring 会直接抛出 `400 Bad Request` 错误，无需你手动编写 `Integer.parseInt`。
        
- **`Integer deptId`**: 这里的变量名可以叫 `deptId`，因为在注解中明确指定了匹配前端的 `id` 字段
### 省略@RequestParam
**如果请求参数名与形参变量名相同，直接定义方法形参即可接收**
但是此时的形参只能为**前端请求参数名**
```Java
@DeleteMapping("/depts")  
public Result deleteById(Integer id){  
    System.out.println("根据ID删除部门:"+id);  
    return Result.success();  
}
```
---
## @RequestBody
当请求进入后端时，`@RequestBody` 会告诉 Spring：“不要去 URL 路径或查询参数里找数据，去请求体（HTTP Body）里找。把那段 JSON 字符串拿出来，转换成我定义的这个 Java 对象。”
```Java
Controller:
	@PostMapping("/depts")  
	public Result add(@RequestBody Dept dept){ //将json数据封装到对象  
	    System.out.println("新增部门"+dept);  
	    deptService.add(dept);
	    return Result.success();  
	}
	
Service:
	@Override  
	public void add(Dept dept) {  
	    dept.setCreateTime(LocalDateTime.now());  
	    dept.setUpdateTime(LocalDateTime.now());  
	    deptMapper.add(dept);  
	}
	
Mapper:
	@Insert("INSERT INTO dept (name,create_time,update_time)VALUES (#{name},#{creatTime},#{updateTime})")  
	❗❗❗注意：VALUES后用的是属性名(驼峰命名)而不是字段名(下划线)❗❗❗
	
	void add(Dept dept);
```
### 使用前提
- **请求方式**：通常用于 `POST`、`PUT` 或 `PATCH`。`GET` 请求没有请求体，所以不能使用
    
- **Content-Type**：前端发送请求时，Header 中必须包含 `Content-Type: application/json`。否则后端会报 `415 Unsupported Media Type` 错误
    
- **属性匹配**：JSON 中的键名（Key）必须与 Java 实体类中的属性名完全一致，且实体类必须提供 **Setter 方法**

---
## @PathVariable
REST 风格提倡“URL 代表资源”。例如，你想访问 ID 为 5 的部门，URL 应该是 `.../depts/5`，而不是传统的 `.../depts?id=5`。这里的 `5` 就是一个路径变量
要让 `@PathVariable` 生效，需要两个步骤的配合：

1. **在路径中使用占位符**：用 `{变量名}` 标注。
    
2. **在参数前加注解**：将占位符的值映射到 Java 变量。
```Java
@GetMapping("/depts/{id}")  
public Result getInfo(@PathVariable Integer id){  
	❗❗❗ 如果占位符名称 {id} 和方法参数名 id 一致，可以直接映射❗❗❗
    System.out.println("根据ID查询部门："+ id);  
    return Result.success();  
}
```


