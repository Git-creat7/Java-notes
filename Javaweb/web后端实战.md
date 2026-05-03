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

|**特性**|**POST**|**PUT**|
|---|---|---|
|**语义**|**创建 (Create)**：用于创建子资源。|**更新/替换 (Update/Replace)**：用于更新或替换指定资源。|
|**资源标识**|资源 ID 通常由**服务器**生成。|资源 ID 通常由**客户端**指定。|
|**对应 SQL**|类似于 `INSERT`。|类似于 `UPDATE` (全量) 或 `REPLACE INTO`。|
|**幂等性**|**不幂等**。|**幂等**。|

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

如果命名完全不规则（比如数据库叫 `d_n`，实体类叫 `deptName`），或者需要处理复杂的关联查询，就需要手动定义映射规则。

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

| **维度**      | **ResultMap (Join)** | **分开查询 (Service组装)** |
| ----------- | -------------------- | -------------------- |
| **开发效率**    | 高 (MyBatis 自动化)      | 中 (需要写 Java 逻辑)      |
| **SQL 复杂度** | 高 (涉及多表关联)           | 低 (全是单表操作)           |
| **传输压力**    | 较大 (存在冗余字段)          | 小 (按需取数据)            |
| **缓存灵活性**   | 差                    | 好                    |

```XML
<!--自定义结果集-->  
<resultMap id="empResultMap" type="asia.creat.pojo.Emp">  
    <id column="id" property="id" />  
    <result column="username" property="username" />  
    <result column="name" property="name" />  
    <result column="gender" property="gender" />  
    <result column="phone" property="phone" />  
    <result column="job" property="job" />  
    <result column="salary" property="salary" />  
    <result column="image" property="image" />  
    <result column="entry_date" property="entryDate" />  
    <result column="dept_id" property="deptId" />  
    <result column="create_time" property="createTime" />  
    <result column="update_time" property="updateTime" />  
    <!--封装exprList-->  
    <collection property="exprList" ofType="asia.creat.pojo.EmpExpr">  
        <id column="ee_Id" property="id"/>  
        <result column="ee_company" property="company"/>  
        <result column="ee_job" property="job"/>  
        <result column="ee_begin" property="begin"/>  
        <result column="ee_end" property="end"/>  
        <result column="ee_emp_id" property="empId"/>  
    </collection>
</resultMap>
```
---
# Nginx
```nginx
server{
	listen 90;
	# 省略......
	# ......
	location ^~ /api/{
		# 只要URL 是以 /api/ 开头的请求
		rewrite ^~/api/(.*)$ /$1 break;
		proxy_pass http://localhost:8080; # 代理转发
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
```Java
@Component  
public  class AliyunOSSOperator {  
    @Autowired  
    private AliyunOSSProperties aliyunOSSProperties;  
	
	
	public String upload(byte[] content, String originalFilename) throws ClientException {
	    String endpoint = aliyunOSSProperties.getEndpoint();  
	    String bucketName = aliyunOSSProperties.getBucketName();  
	    String region = aliyunOSSProperties.getRegion();
	    
	    ......
    }
}
```
```Java
@Data  
@Component  
@ConfigurationProperties(prefix = "aliyun.oss")  
public class AliyunOSSProperties {  
    private String endpoint;  
    private String bucketName;  
    private String region;  
}
```

---
# 全局异常处理器

无论程序在哪里抛出了异常，都能被这个处理器统一拦截，并返回一个优雅、格式统一的错误信息给前端或客户端
## 注解
- **`@RestControllerAdvice`**：标记这是一个增强版的控制器，专门处理全局层面的逻辑`(@ControllerAdvice + @ResponseBody)`。
    
- **`@ExceptionHandler`**：指定具体的异常类型，当这种异常发生时，执行对应的方法。
## 核心流程：

1. **异常发生**：Controller 或 Service 层抛出一个异常（如 `UserNotFoundException`）。
    
2. **自动捕获**：Spring 发现该异常未被内部 `try-catch`，于是将其向上抛给全局处理器。
    
3. **匹配处理**：处理器根据异常类型找到对应的处理方法。
    
4. **返回结果**：处理器将异常包装成一个通用的 `Result` 对象（包含错误码、错误消息），转换成 JSON 返回。
```Java
@RestControllerAdvice // = @ControllerAdvice + @ResponseBody
public class GlobalExceptionHandler {

    // 处理自定义业务异常
    @ExceptionHandler(BusinessException.class)
    public Result handleBusinessException(BusinessException e) {
        return Result.error(e.getCode(), e.getMessage());
    }

    // 处理参数验证异常 (如 @Valid 校验失败)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result handleValidationException(MethodArgumentNotValidException e) {
        String msg = e.getBindingResult().getFieldError().getDefaultMessage();
        return Result.error(400, msg);
    }

    // 兜底：处理所有未知的运行异常
    @ExceptionHandler(Exception.class)
    public Result handleException(Exception e) {
        log.error("系统崩溃了，救命！", e); 
        return Result.error(500, "服务器开小差了，请稍后再试");
    }
    ---------------------
	@ExceptionHandler  
	public Result handleException(Exception e) {  
	    log.error("发生异常: ", e);  
	    return Result.error("服务器发生异常，请稍后再试");  
	}  
	@ExceptionHandler  
	public Result handleDuplicateKeyException(DuplicateKeyException e) {  
	    log.error("发生异常: ", e);  
	    String msg = e.getMessage();  
	    int i = msg.indexOf("Duplicate entry");  
	    String errMsg = msg.substring(i);  
	    String[] arr = errMsg.split(" ");  
	  
	    return Result.error("'" + arr[2] + "' 已存在，请检查数据");  
	}
}
```

---
# 会话技术

## Cookie
### 工作流程

Cookie 的本质是通过 HTTP 响应头和请求头在外部交换数据：

1. **设置阶段**：服务器在响应（Response）中加入 `Set-Cookie` 头部字段。
    
2. **存储阶段**：浏览器收到响应后，将 Cookie 内容保存在本地（内存或硬盘）。
    
3. **携带阶段**：下次请求同一个域名时，浏览器会自动在请求（Request）头中加入 `Cookie` 字段。
### 缺点

|**维度**|**缺点**|**说明**|
|---|---|---|
|**存储能力**|容量小|单个 Cookie 最大限制约为 **4KB**，不适合存大数据。|
|**用户控制**|可被禁用|用户可以在浏览器设置中完全禁止接收 Cookie，导致功能失效。|
|**安全性**|不安全|默认明文存储在客户端，极易受到 **XSS 攻击** 窃取或中间人篡改。|
|**访问限制**|跨域限制|受到同源策略限制，Cookie 无法在不同的一级域名间直接共享。|
|**网络性能**|占用带宽|每次 HTTP 请求都会自动携带相关 Cookie，增加了请求头体积，浪费流量。|
|**合规隐私**|隐私问题|常用于行为追踪，可能触犯 GDPR 等隐私法规，令用户反感。|
|**生命周期**|时效性|默认为会话级别（关闭浏览器即消失），除非开发者手动设置 `Max-Age`。|
|**物理限制**|无法跨设备|数据绑定在特定设备的特定浏览器上，无法实现手机/电脑端同步。|

### 典型场景与规避方案

- **敏感信息处理**：
    
    - **原则**：绝不在 Cookie 中存储密码、身份证号等敏感数据。
        
    - **方案**：仅存储加密后的 Token，并设置 `HttpOnly` 属性以防止 JS 脚本读取。
        
- **移动端开发**：
    
    - **痛点**：部分原生 App 内置浏览器或某些移动端环境对 Cookie 支持不佳。
        
    - **方案**：在移动端或前后端分离架构中，优先考虑使用 **JWT (JSON Web Token)** 并通过自定义 Header 传输。
        
- **分布式/集群环境**：
    
    - **痛点**：多台服务器之间无法直接共享保存在各自内存或浏览器关联的传统 Session。
        
    - **方案**：采用 **分布式会话**（如 `Spring Session + Redis`），将状态数据统一托管在外部缓存中。

---

## Session

### 工作原理

Session 的核心在于服务器与浏览器之间的一个“约定”。

1. **创建：** 当用户第一次访问服务器时，服务器会为该用户创建一个唯一的 **HttpSession** 对象，并生成一个唯一的 ID（通常称为 `JSESSIONID`）。
    
2. **传递：** 服务器通过 HTTP 响应头，将这个 `JSESSIONID` 以 **Cookie** 的形式发送给浏览器。
    
3. **识别：** 当浏览器再次请求该服务器时，会自动在请求头中携带这个 `JSESSIONID`。
    
4. **检索：** 服务器根据收到的 ID，在内存中找到对应的 Session 对象
### 生命周期
- **开始：** 用户第一次调用 `request.getSession()` 时。
    
- **超时：** 为了节省服务器内存，Session 不会永久存在。如果用户在一段时间内（默认通常是 30 分钟）没有任何操作，Session 会自动销毁。
### 缺点
| **维度**   | 优势                                              | 劣势                                                        |
| -------- | ----------------------------------------------- | --------------------------------------------------------- |
| **开发难度** | **简单易用**：Java 原生支持，直接调用 `getAttribute` 即可，逻辑清晰。 | **依赖 Cookie**：如果客户端禁用了 Cookie，Session 就会失效（需额外处理 URL 重写）。 |
| **数据安全** | **安全性高**：敏感数据留在服务器，客户端只拿一个加密 ID，不容易被篡改。         | **会话劫持**：如果 ID 被窃取，攻击者可以完全冒充用户身份（需 HTTPS 配合）。             |
| **性能表现** | **读写极快**：数据就在本地内存中，无需网络开销，适合单机小型应用。             | **内存消耗**：用户多了会占满服务器内存。用户关浏览器不点退出，数据会白白占用内存直到超时。           |
| **架构扩展** | **无需额外中间件**：单机部署时非常方便，不需要安装 Redis 等数据库。         | **分布式困境**：多台服务器环境下，Session 不共享，会导致用户登录状态频繁丢失。             |
|**数据类型**|**灵活**：可以存储复杂的 Java 对象，不需要像 Token 那样进行频繁的序列化转换。|**存储限制**：不能存太大的东西（如大列表、大图片），否则严重拖慢服务器性能。|
### 对比Cookie
|**特性**|**Cookie**|**Session**|
|---|---|---|
|**存储位置**|客户端（浏览器）|服务器端|
|**安全性**|较低（易被伪造或窃取）|较高（敏感数据不发送给客户端）|
|**存储容量**|较小（通常单个 4KB）|较大（取决于服务器内存）|
|**数据类型**|只能存储字符串|可以存储任意 Java 对象|
|**性能影响**|几乎不占用服务器资源|占用服务器内存，用户多时压力大|

---

## ⭐Token令牌（主流）
### 工作原理

**1. 签发：** 当用户通过用户名和密码登录成功后，服务器会根据用户信息（如用户 ID）和一段只有服务器知道的“秘钥”，生成一个加密的字符串（即 Token）。

**2. 传输：** 服务器将这个 Token 作为响应体的一部分发送给浏览器。与 Session 不同，服务器此时**不会**在自己的内存或数据库中保存这个 Token。

**3. 存储：** 浏览器接收到 Token 后，通常将其存储在 `localStorage`、`sessionStorage` 或 `Cookie` 中。

**4. 携带：** 当浏览器后续请求受保护的资源（如获取订单列表）时，会手动将 Token 放入 HTTP 请求头中（通常放在 `Authorization: Bearer <Token>` 字段）。

**5. 校验：** 服务器接收到请求后，不再去查找数据库或内存，而是直接使用存储在服务器本地的“秘钥”对该 Token 进行解密和签名校验。

**6. 提取：** 如果校验通过，服务器就认为该请求是合法的，并直接从 Token 内部解密出用户信息（如该用户是“张三”），从而完成业务处理。

### JWT组成
#### Header（头部）—— “说明书”
这部分用于描述 JWT 的元数据，告诉服务器如何处理这个令牌。

- **内容：** 通常包含令牌的类型（`typ`: "JWT"）和所使用的加密算法（`alg`: 如 "HS256" 或 "RS256"）。
    
- **编码：** 使用 **Base64URL** 算法进行编码。
```Java
	{ "alg": "HS256", "typ": "JWT" }
```
####  Payload（有效载荷）—— “货物”

这是 JWT 的核心部分，包含了实际要传递的用户信息（Claims）。

- **标准字段：** 如签发人（`iss`）、过期时间（`exp`）、用户 ID（`sub`）等。
    
- **自定义字段：** 你可以放入用户的角色、权限、姓名等（例如：`"role": "admin"`）。
    
- **编码：** 同样使用 **Base64URL** 编码。
    
- **注意：** 这里的内容只是编码，并不是加密。**绝对不要在此处存放密码或敏感信息**，因为任何人拿到 Token 都能通过解码看到里面的内容。
```Java
	{ 
		"sub": "ZhangSan", 
		"role": "Java-Dev", 
		"exp": 1746144000 
	}
```
#### Signature（签名）—— “防伪封条”

这是保证安全的关键。它用于验证 Token 在传输过程中是否被篡改。

- **生成原理：** 服务器将编码后的 `Header` 和 `Payload` 用点拼接起来，再加上一个只有服务器知道的**密钥（Secret）**，按照 Header 中指定的算法进行哈希计算。
    
- **作用：** 如果有人修改了 Payload 里的用户权限（比如把 `user` 改成 `admin`），由于他没有服务器的密钥，生成的签名就会和原来的不匹配。服务器校验失败，该 Token 立即失效。
```Secret
	a-string-secret-at-least-256-bits-long
```
#### 总结外观
一个完整的 JWT 看起来像这样：
`eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.`
`eyJzdWIiOiJaaGFuZ3NhbiIsInJvbGUiOiJKYXZhLURldiIsImV4cCI6MTc0NjE0NDAwMH0.`
`MJSEga1Hm1wHRnaCKpjSzXcr7DpI3TlhDQoGcIWnXDA`

`xxxxx.yyyyy.zzzzz`
1. **红色部分 (xxxxx):** 头部，声明算法。
    
2. **蓝色部分 (yyyyy):** 负载，存放用户信息。
    
3. **绿色部分 (zzzzz):** 签名，由前两部分加盐哈希而成
### JWR生成/解析
```Java
private static final String SECRET = "基于base64的字符串（字节数必须大于32）";  
private static final SecretKey KEY = Keys.hmacShaKeyFor(SECRET.getBytes(StandardCharsets.UTF_8));
  
@Test  
public void testGenerateJwt() {  
    Map<String, Object> dataMap = new HashMap<>();  
    dataMap.put("userId", 1);  
    dataMap.put("username", "admin");  
  
    String token = Jwts.builder()  
            .claims(dataMap)  
            .expiration(new Date(System.currentTimeMillis() + 3600 * 1000))  
            .signWith(KEY)  
            .compact();  
  
    System.out.println(token);  
}  
  
@Test  
public void testParseJwt() {  
    String token = "JWT得到的Token";  
    Claims claims = Jwts.parser()  
            .verifyWith(KEY)  
            .build()  
            .parseSignedClaims(token)  
            .getPayload();  
    System.out.println(claims);  
}
```
---

## `Cookie,Session,Token`对比
| **维度**   | **Cookie**    | **Session**            | **Token (JWT)**       |
| -------- | ------------- | ---------------------- | --------------------- |
| **定义**   | 存储在浏览器端的一段文本。 | 服务器端的一种会话记录机制。         | 一段经过加密/签名的凭证字符串。      |
| **核心位置** | **客户端**       | **服务器**（内存/数据库/Redis）  | **客户端**（服务器不存储）       |
| **工作逻辑** | 浏览器自动携带。      | 依赖 Session ID 匹配服务器记录。 | 客户端手动放入 Header，服务器解密。 |
| **安全性**  | 较低，容易被拦截或伪造。  | 较高，敏感信息存在服务器。          | 高，有签名校验，防篡改。          |
| **扩展性**  | 无。            | 差，多台服务器需做数据同步。         | 极佳，天然支持跨服务器、跨域。       |
| **存储压力** | 无（存在用户本地）。    | 较大，用户多时会消耗大量服务器内存。     | 无（存在用户本地）。            |



![](web后端实战-2.png)



### 优点对比

| **维度**   | **Cookie (客户端存储)**                | **Session (服务端存储)**                 | **Token (无状态令牌/JWT)**                   |
| -------- | --------------------------------- | ----------------------------------- | --------------------------------------- |
| **最大优势** | **减轻服务器压力**：数据存用户本地，服务器不占内存。      | **数据最安全**：敏感信息不发给客户端，只在服务器内部。       | **极易水平扩展**：服务器不存任何数据，非常适合微服务/集群。        |
| **生命周期** | **持久性好**：可以设置长达数天的有效期，甚至关机后再开也存在。 | **控制力强**：服务器可以随时主动让某个特定用户下线。        | **性能均衡**：不需要查数据库或缓存，服务器解析 Token 即可校验身份。 |
| **开发难度** | **最简单**：浏览器原生支持，几乎不需要写代码逻辑。       | **非常简单**：成熟的框架（如 Spring）自动处理 ID 传递。 | **跨域支持完美**：不受浏览器跨域限制，App、小程序、H5 通用。     |
| **存储能力** | **随用随取**：适合存偏好设置（如主题颜色、语言）。       | **类型多样**：可以存复杂的 Java 对象（用户角色、权限列表）。 | **自包含**：Token 内部可以携带用户信息，减少后端查询次数。      |


---

# 过滤器Filter
## 核心作用

过滤器主要用于处理一些**通用性**的横切关注点：

- **权限校验**：检查请求头中是否携带有效的 JWT Token。
    
- **字符编码转换**：统一设置 `request` 和 `response` 的编码（如 UTF-8）。
    
- **日志记录**：统计接口的访问耗时、记录请求来源 IP。
    
- **敏感词过滤**：对用户提交的内容进行安全扫描。
## 工作原理：责任链模式

过滤器并不是独立存在的，它们通常组成一个**过滤器链 (FilterChain)**。

1. **执行前处理**：请求进入时，过滤器先执行 `doFilter` 方法中 `chain.doFilter()` 之前的代码。
    
2. **放行（传递）**：调用 `chain.doFilter(request, response)`。如果有下一个过滤器，就传给下一个；如果没有，就传给 Servlet（或 Controller）。
    
3. **执行后处理**：当核心业务处理完返回响应时，代码会回到 `chain.doFilter()` 之后，执行后续逻辑。
## 执行顺序

$$Filter \rightarrow Controller \rightarrow Service \rightarrow Mapper \rightarrow DB$$

$$\uparrow \quad \quad \quad \quad \quad \quad \quad \quad \quad \quad \quad \quad \quad \quad \downarrow$$

$$Filter(回程) \leftarrow Controller \leftarrow Service \leftarrow Mapper$$
```Java
		[浏览器请求]
		    │
		    ▼
		┌────── Filter (去程：校验Token、记录时间) ──────┐
		│   │                                       │
		│   ▼                                       │
		│ ┌──── Controller (解析请求、参数校验) ────┐ │
		│ │   │                                 │ │
		│ │   ▼                                 │ │
		│ │ ┌── Service (业务逻辑处理) ────────┐ │ │
		│ │ │   │                           │ │ │
		│ │ │   ▼                           │ │ │
		│ │ │ ┌ Mapper (SQL执行) ──┐        │ │ │
		│ │ │ │   │                │        │ │ │
		│ │ │ │   ▼                │        │ │ │
		│ │ │ │ [ 数据库 DB ] <────┘        │ │ │
		│ │ │ │   │ (返回结果)               │ │ │
		│ │ │ └────────────────────────────┘ │ │
		│ │ │   │                           │ │ │
		│ │ └── Service (业务结果组装) ────────┘ │ │
		│ │   │                                 │ │
		│ └──── Controller (封装结果对象) ─────────┘ │
		│   │                                       │
		└────── Filter (回程：清理ThreadLocal、日志打印) ┘
		    │
		    ▼
		[返回响应]
//-- 这种图强调了 Filter 是最外层，它包裹着所有的内部组件：--
		( ( ( ( [ 数据库 DB ] ) ) ) )
      ▲   ▲   ▲   ▲     ▲   ▼   ▼   ▼   ▼     ▼
      │   │   │   └─────┴───┘   │   │   │     │
      │   │   └──── Mapper ─────┘   │   │     │
      │   └─────── Service ─────────┘   │     │
      └────────── Controller ───────────┘     │
      └───────────── Filter ──────────────────┘
    [请求进入]                           [响应返回]
```
**去程：** `Client` $\rightarrow$ `Filter` $\rightarrow$ `Controller` $\rightarrow$ `Service` $\rightarrow$ `Mapper` $\rightarrow$ `DB`

**核心：** 数据库执行查询/更新

**回程：** `DB` $\rightarrow$ `Mapper` $\rightarrow$ `Service` $\rightarrow$ `Controller` $\rightarrow$ `Filter` $\rightarrow$ `Client`

## 过滤器链

### 工作原理

过滤器链将多个功能独立的“过滤器”组合在一起。每个过滤器只负责一个特定的逻辑（如：身份验证、日志记录、压缩数据等）。

- **顺序性**：请求会按照预定的顺序依次通过过滤器 $F_1, F_2, ..., F_n$。
    
- **双向处理**：请求在进入核心业务逻辑前会被处理一遍；当业务逻辑处理完成后，响应（Response）会以**相反的顺序**再次通过过滤器链。
    
- **中断机制**：任何一个过滤器都有权终止链条的传递（例如：发现用户未登录，直接拦截并返回错误，不再交给后面的过滤器或业务逻辑）。

|**角色**|**说明**|
|---|---|
|**Filter (过滤器)**|执行具体任务的组件。包含 `doFilter` 方法，用于编写逻辑并决定是否传给下一个过滤器。|
|**FilterChain (链条管理器)**|负责维持过滤器的顺序，并控制 `next()` 操作，确保流程向下推进。|
|**Target (目标资源)**|最终要访问的业务逻辑（如 API 接口、Servlet 或控制器）。|
### 应用场景
过滤器链常被形象地称为“洋葱模型”，每一层都是一个过滤器：

1. **安全校验**：检查用户 Token 是否有效，权限是否足够。
    
2. **日志记录**：记录请求的 URL、耗时、IP 地址等。
    
3. **编码转换**：统一设置字符集（如 UTF-8）。
    
4. **数据压缩**：检查浏览器是否支持 Gzip，对响应内容进行压缩。
    
5. **异常处理**：捕获后续流程中抛出的所有异常并统一返回友好格式。

```Java
public void doFilter(Request req, Response res, FilterChain chain) {
    // 1. 【前置处理】请求进入时的逻辑 (例如：检查登录)
    if (isValid(req)) {
        // 2. 【放行】传给下一个过滤器或目标资源
        chain.doFilter(req, res); 
        
        // 3. 【后置处理】响应返回时的逻辑 (例如：记录响应时长)
        logResponseTime(res);
    } else {
        // 拦截，不再向下传递
        res.write("Unauthorized");
    }
}
```


---
---页尾---

---

# 注意事项
## @PathVariable与@RequestParam

| **方式**    | 前端URL               | 后端请求                       | **什么时候用？**    |
| --------- | ------------------- | -------------------------- | ------------- |
| **精准定位**  | `/clazzs/5`         | `/{id}` + `@PathVariable`  | **删除单个 ID**   |
| **带清单操作** | `/clazzs?ids=1,2,3` | `(无路径)` + `@RequestParam`  | **批量删除**      |
| **路径串烧**  | `/clazzs/1,2,3`     | `/{ids}` + `@PathVariable` | 极少用，除非有特殊设计需求 |

---
## `xml`的更新语句

| **字段类型**         | **业务要求**        | **<if> 判定表达式**                       | **避坑指南**                                                         |
| ---------------- | --------------- | ------------------------------------ | ---------------------------------------------------------------- |
| **String**       | **必填** (非空且非空串) | `test="name != null and name != ''"` | 这样可以防止前端传个空字符串 `""` 导致数据库存入无意义数据。                                |
| **String**       | **允许置空**        | `test="address != null"`             | **注意：** 这样如果传 `""`，它会判定为非 null，从而把空串插入数据库。                       |
| **Integer / 数字** | **必填**          | `test="id != null"`                  | **绝对不要加** `and id != ''`！如果 id 为 0，MyBatis 可能会误判它等于空串，导致 0 存不进去。 |
| **Integer / 数字** | **允许置空**        | `test="degree != null"`              | 同上，只判断 null 即可。                                                  |

---

|**操作类型**|**字段类型**|**推荐写法**|**理由**|
|---|---|---|---|
|**SELECT** (搜索)|任何类型|`!= null and != ''`|**防前端传空搜索框**导致的“查无数据”。|
|**UPDATE** (更新)|**String**|`!= null and != ''`|过滤无效空串，保证数据严谨。|
|**UPDATE** (更新)|**Integer**|**`!= null`**|**最安全**，防止 `0` 值无法更新。|
|**INSERT** (插入)|任何类型|`!= null`|通常只为了防止 null 值覆盖数据库默认值。|
