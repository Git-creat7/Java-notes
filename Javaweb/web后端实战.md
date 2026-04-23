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
# 各种注解
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
### 指定默认值
使用defaultValue设置默认值
```Java
	/*  
	* 分页查询  
	* */  
	@GetMapping  
	public Result page(@RequestParam(defaultValue = "1") Integer page, Integer pageSize){  
	    log.info("分页查询{},{}",page,pageSize);  
	    PageResult<Emp> pageResult = empService.page(page, pageSize);  
	    return Result.success(pageResult);  
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

>[!NOTE]
>在URL中可以携带多个路径参数 如 "/depts/1/0"

---
## @DateTimeFormat
`@DateTimeFormat` 是一个非常实用的注解，主要用于 **格式化请求参数**（也就是从前端传到后端的日期字符串）
### 在实体类中使用（处理搜索条件）
```Java
@Data
public class EmpQueryDTO {
    private String name;
    
    // 接收类似 "2024-01-01" 的字符串
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate beginDate;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate endDate;
}
```
### 直接在 Controller 参数中使用
```Java
@GetMapping  
	public Result pageByCondition(String name, Integer gender,  
		  @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate begin,  
		  @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate end,  
		...
		...
		return Result.success(result);  
	}
```
>[!NOTE]
>如果是普通 GET 请求的参数，用 `@DateTimeFormat`；如果是 `@RequestBody` 接收的 JSON 数据，用 `@JsonFormat`

---
## @Options
`@Options` 注解主要用于在使用 **注解开发**（即直接在 Mapper 接口方法上写 `@Insert` 或 `@Update`）时，配置一些额外的开关和属性。最常见的用法是 **获取自增主键**
```Java
	@Options(useGeneratedKeys = true,keyProperty = "id")
	//获取到生成的主键  
	@Insert("...插入语句...")  
	void insertEmp(Emp emp);
```
- **`useGeneratedKeys = true`**：告诉 MyBatis 使用数据库生成的自增主键
    
- **`keyProperty = "id"`**：告诉 MyBatis 把拿到的主键值，设置到 `emp` 对象的哪个属性中
执行后的效果：
```Java
	empService.insertEmp(emp); 
	System.out.println(emp.getId()); // 这里就能打印出数据库生成的那个新 ID 了
```


除了获取主键，`@Options` 还可以配置以下内容：

|**属性**|**作用**|
|---|---|
|**`timeout`**|设置这条 SQL 执行的超时时间（单位：秒）|
|**`flushCache`**|设置为 `true` 时，只要语句被调用，就会清空一级和二级缓存|
|**`useCache`**|是否将该查询结果放入二级缓存（默认为 true）|
|**`statementType`**|设置 SQL 执行方式（默认为 `PREPARED`，即预编译）|
### XML形式的等价写法
```Java
	<insert id="insert" useGeneratedKeys="true" keyProperty="id">
	    insert into emp(...) values(...)
	</insert>
```

---

## 将多个参数提取到实体类
- **代码整洁**：方法参数由 10 个变成 1 个。
    
- **高复用性**：这个实体类可以在 Controller、Service、Mapper 之间直接传递。
    
- **自动封装**：Spring MVC 会自动根据请求参数的名称（Query Params）与实体类的属性名进行匹配并赋值
```Java
@Data  
public class EmpQueryParam {  
    private Integer page = 1;  
    private Integer pageSize = 10;  
    private String name;  
    private Integer gender;  
    @DateTimeFormat(pattern = "yyyy-MM-dd")  
    private String begin;  
    @DateTimeFormat(pattern = "yyyy-MM-dd")  
    private String end;  
}
```
### 注意事项
- **不要加 `@RequestBody`**：`@RequestBody` 是用来解析 POST 请求里的 JSON 体的。对于 GET 请求的 URL 参数映射到对象，**直接写参数**即可。
    
- **默认值处理**：在实体类中直接为 `page` 和 `pageSize` 赋初值，可以省去 Controller 里的 `@RequestParam(defaultValue = "...")`。
    
- **日期处理**：记得给日期属性加上 `@DateTimeFormat`，否则当前端传 `2026-05-20` 时，后端会因为无法转换为 `LocalDate` 而报错。

---
## 路径抽取 
- **修改前**：每个方法（如查询、删除、新增）都要在注解里写 `@GetMapping("/depts")` 或 `@DeleteMapping("/depts/{id}")`
    
- **修改后**：在 `public class DeptController` 顶部添加 **`@RequestMapping("/depts")`**。这样下方的方法注解就可以简化，例如：
    
    - 查询全部简写为：`@GetMapping`
        
    - 根据 ID 查询简写为：`@GetMapping("/{id}")`
```Java
@RequestMapping("/depts") //指定请求路径前缀  
@RestController
public class DeptController {  
    @Autowired  
    private DeptService deptService;  
	  
    @RequestMapping(value = "/depts",method = RequestMethod.GET)  
    @GetMapping  
    //指定请求方式  
    public Result list(){...}  
	  
    @PostMapping  
    public Result add(@RequestBody Dept dept){...}  
	  
    @DeleteMapping  
    public Result deleteById(Integer id){...}  
	  
    @GetMapping("/{id}")  --> 即为 "/depts/{id}"
    public Result getInfo(@PathVariable Integer id){...}  
	  
	  
    @PutMapping  
    public Result update(@RequestBody Dept dept){...}  
}
```
---
# 日志Logback
- **JUL (java.util.logging)**：Java 原生日志框架，虽然配置简单但灵活性和性能较差
    
- **Log4j**：早期非常流行的第三方日志框架，配置灵活
    
- **Logback**：由 Log4j 作者开发的升级版，性能更优，也是目前 Spring Boot 默认集成的日志实现
    
- **Slf4j (Simple Logging Facade for Java)**：重点强调的“**简单日志门面**”，它不是真正的日志实现，而是一套标准接口，允许你在不修改代码的情况下切换底层的日志框架（如从 Log4j 切换到 Logback）
---
```Java
	//logger 来自 SLF4j包
	private  static final Logger log =
	 org.slf4j.LoggerFactory.getLogger(LogTest.class);
```
**可替换为注解：@Slf4j**
## 日志级别

| **日志级别**  | **说明**                            | **记录方式**           |
| --------- | --------------------------------- | ------------------ |
| **trace** | 追踪，记录程序运行轨迹，使用很少                  | `log.trace("...")` |
| **debug** | 调试，记录调试过程中的信息，实际应用中通常视为最低级别       | `log.debug("...")` |
| **info**  | 记录一般信息，描述运行关键事件（如网络连接、IO 操作），使用较多 | `log.info("...")`  |
| **warn**  | 警告信息，记录潜在有害情况，使用较多                | `log.warn("...")`  |
| **error** | 错误信息，使用较多                         | `log.error("...")` |
- 只有**大于等于**设定级别的日志才会被输出。
- 如果将 `root` 级别设为 **`info`**，那么 `trace` 和 `debug` 级别的日志将**不会**被记录或显示
```XML
	<root level="info">
		<appender-ref ref="STDOUT" />
		<appender-ref ref="FILE" />
	</root>
```

---
# PageHelper分页查询
## 原理
PageHelper 利用了 MyBatis 的 **拦截器（Interceptor）** 机制。它的工作流程如下：

1. **拦截**：当你调用 Mapper 方法前，PageHelper 会拦截到即将执行的 SQL
    
2. **解析**：自动检测你当前使用的数据库类型（MySQL, Oracle, MariaDB 等）
    
3. **改写**：根据你设置的页码（pageNum）和每页数量（pageSize），动态地在原始 SQL 后面拼接分页子句
    
4. **自动 Count**：它还会额外执行一条 `SELECT COUNT(0)` 来获取总记录数，方便前端显示总页数
	
5. **❗SQL语句结尾不能加分号；**(PageHelper会追加limit语句)
6. ❗**PageHelper仅仅能对紧跟在其后的第一个查询语句进行分页处理**
## 使用
原始Service层
```Java
	@Override  
	public PageResult<Emp> page(Integer page, Integer pageSize) {  
	    Long total = empMapper.count();  
	    List<Emp> rows = empMapper.page((page -1)*pageSize, pageSize);  
	    return new PageResult<Emp>(total,rows);  
	}
```
使用后
```Java
@Override  
	public PageResult<Emp> page(Integer page, Integer pageSize) {  
	    //设置分页参数PageHelper  
	    PageHelper.startPage(page, pageSize);  
	    //执行查询  
	    List<Emp> emp = empMapper.list(page, pageSize);  
	    //解析查询结果并封装数据  
	    Page<Emp> p = (Page<Emp>) emp;  //多态的实现
	    return new PageResult<Emp>(p.getTotal(), p.getResult());  
	}
```
![644](web后端实战-1.png)

---
# Spring[事务管理](/MySQL/事务)
Spring 事务的本质是利用 **AOP（面向切面编程）**。当你给一个方法加上事务注解时，Spring 会为该类创建一个代理对象。

- **开启**：在方法执行前，代理对象关闭自动提交，开启事务。
    
- **提交**：如果方法正常执行完毕，代理对象提交事务。
    
- **回滚**：如果方法执行过程中抛出异常，代理对象捕获异常并回滚数据。
## @Transactional
这是开发中最常用的方式，通过注解直接管理事务，代码零侵入
```Java
@Service
public class EmpServiceImpl implements EmpService {
    @Autowired
    private EmpMapper empMapper;
    @Autowired
    private DeptMapper deptMapper;

    @Transactional // 开启事务
    @Override
    public void deleteDept(Integer id) {
        // 1. 删除部门
        deptMapper.deleteById(id);
        
        // 模拟异常：一旦报错，上面的删除操作也会撤销
        // int i = 1/0; 
        
        // 2. 删除该部门下的所有员工
        empMapper.deleteByDeptId(id);
    }
}
```

| **属性**            | **描述**                                                               |
| ----------------- | -------------------------------------------------------------------- |
| **`rollbackFor`** | 指定哪些异常触发回滚。默认只回滚 `RuntimeException`。建议设置为 `Exception.class` 以涵盖所有异常。 |
| **`propagation`** | **事务传播行为**：定义当一个事务方法调用另一个事务方法时，事务如何传递。                               |
| **`readOnly`**    | 是否为只读事务。查询操作建议设为 `true`，可以优化数据库性能。                                   |
### rollbackFor
```Java
	@Transactional//默认出现运行时异常RuntimeException才会回滚
	@Transactional(rollbackFor = {Exception.class})//指定所有异常都会回滚
```
### propagation

| 属性值              | 含义                                 |
| ---------------- | ---------------------------------- |
| **REQUIRED**     | **【默认值】需要事务，有则加入，无则创建新事务**         |
| **REQUIRES_NEW** | **需要新事务，无论有无，总是创建新事务**             |
| SUPPORTS         | 支持事务，有则加入，无则在无事务状态中运行              |
| NOT_SUPPORTED    | 不支持事务，在无事务状态下运行；如果当前存在已有事务，则挂起当前事务 |
| MANDATORY        | 必须有事务，否则抛异常                        |
| NEVER            | 必须没事务，否则抛异常                        |

### readOnly
```Java
@Transactional(readOnly = true)
public User getUserById(Long id) {
    return userRepository.findById(id);
}
```

- **作用**：告诉数据库这是一个只读事务。
    
- **好处**：数据库可以针对只读操作进行优化（例如在 MySQL 中不分配回滚段），提高查询效率

|**维度**|**说明**|
|---|---|
|**它能防止修改吗？**|**不一定**。这取决于数据库和驱动。虽然 Hibernate 会跳过脏检查，但如果你在只读事务中强行执行原生 SQL 的 `UPDATE`，某些数据库可能仍然允许执行（虽然这会导致语义混乱）。|
|**主从架构（Read/Write Splitting）**|这是 `readOnly` 的**关键应用场景**。通过 AOP 拦截 `readOnly=true` 的方法，可以将请求路由到从库（Read Node），而将其他的路由到主库。|
|**性能损耗**|虽然它能优化内存，但开启事务本身也是有开销的（获取连接、上下文切换）。对于极其简单的单条查询，有时不加 `@Transactional` 反而更快。|

---

## 失效场景
1. **非 public 方法**：`@Transactional` 只能用于 `public` 方法。
    
2. **方法内部调用**：同一个类中，A 方法调用 B 方法，即使 B 加了注解也不会生效（因为绕过了 AOP 代理）。
    
3. **异常被捕获**：如果你在代码里 `try...catch` 了异常且没有抛出，Spring 无法感知到报错，就不会回滚。
    
4. **数据库不支持**：比如 MySQL 的 MyISAM 引擎不支持事务，必须使用 **InnoDB**。

---
## ⭐Tips
- **加在 Service 层**：不要加在 Controller 层，确保业务逻辑的完整性。
    
- **显式指定回滚范围**：推荐使用 `@Transactional(rollbackFor = Exception.class)`。
    
- **保持方法短小**：事务会占用数据库连接，尽量不要在事务方法中进行远程接口调用或耗时操作，防止连接池耗尽
>[!TIP]
>`@Transactional` 可以加在**方法上、类上、接口**上
> ※ 推荐加在方法上 ※


---
# 文件上传
# MultipartFile
`MultipartFile` 是处理文件上传的核心接口。它代表了 HTML 表单中 `multipart/form-data` 类型的文件内容。
```Java
	@PostMapping("/upload")  
	public Result upload(String name, Integer age, MultipartFile file){  
	    log.info("接收参数：{},{},{}",name,age,file);  
	    return Result.success();  
	}
```

| **方法**                      | **说明**                        |
| --------------------------- | ----------------------------- |
| **`getName()`**             | 获取表单中文件参数的名称（如上面例子中的 "file"）。 |
| **`getOriginalFilename()`** | 获取客户端文件系统的原始文件名。              |
| `getContentType()`          | 获取内容类型（如 `image/png`）。        |
| `isEmpty()`                 | 判断文件是否为空（没有内容或未选择文件）。         |
| `getSize()`                 | 返回文件大小（单位：字节）。                |
| `getBytes()`                | 以字节数组形式读取文件内容。                |
| `getInputStream()`          | 获取输入流，用于流式读取（适合大文件处理）。        |
| `transferTo(File dest)`     | **最常用**：将上传的文件直接保存到目标文件。      |
## 问题及注意事项
- **多文件上传**： 如果你需要一次上传多个文件，将参数改为数组或列表即可： `public String upload(@RequestParam("files") MultipartFile[] files)`
    
- **文件名冲突**： 直接使用 `getOriginalFilename()` 可能导致重名覆盖。建议使用 **UUID** 或 **时间戳** 重命名文件。
    
- **临时存储**： `MultipartFile` 在处理时会产生临时文件（存储在操作系统的 `tmp` 目录）。一旦请求处理完成，这些临时文件会被自动删除。
    
- **安全性**： 务必校验文件后缀名和文件头（Magic Number），防止用户上传恶意的 `.exe` 或 `.sh` 脚本文件。

## 存储在本地
```Java
	@PostMapping("/upload")  
	public Result upload(String name, Integer age, MultipartFile file) throws IOException {  
	    log.info("接收参数：{},{},{}",name,age,file);  
	    //原始文件名  
	    String fof = file.getOriginalFilename();  
	    //新文件名  
	    String extension = fof.substring(fof.lastIndexOf("."));  
	    String newName = UUID.randomUUID() + extension;  
	    //保存文件  
	    file.transferTo(new File("F:/images/"+ newName));  
	    return Result.success();  
	}
```
Spring中默认上传文件最大大小为1MB，超过大小需要在配置文件中配置
```YML
# 文件上传
Spring:
	servlet:  
	  multipart:  
	    # 最大单个文件大小  
	    max-file-size: 10MB  
	    # 最大请求大小（包含所有文件和表单数据）  
	    max-request-size: 100MB
```
# OSS
```Java
@Value("${aliyun.oss.endpoint}")  
private String endpoint;  
@Value("${aliyun.oss.bucketName}")  
private String bucketName;  
@Value("${aliyun.oss.region}")  
private String region;
```

```YML
# 阿里云 OSS配置  
aliyun:  
  oss:  
    endpoint: https://oss-cn-beijing.aliyuncs.com  
    bucketName: creat-spring-oss  
    region: cn-beijing
```
## 批量注入值@ConfigurationProperties