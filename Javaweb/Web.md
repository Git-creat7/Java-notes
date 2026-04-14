+++
date = '2026-04-11'
draft = false
title = 'Web'
tags = []
categories = ["JavaWeb"]
+++

> 本文更新于 2026-04-11

# SpringBootWeb基础
```Java
/*  
* 请求处理类  
* */  
@RestController  
public class HelloController {  
    /*  
    * 响应返回值  
    * */    @RequestMapping("/Hello")  
    public String Hello(String name){  
        System.out.println("name:"+name);  
        return "Hello" + name + "~";  
    }  
}
```

# [HTTP协议](基础#HTTP)
概念:`Hyper Text Transfer Protocol`，超文本传输协议，规定了浏览器和服务器之间数据传输的规则

- **特点:**
	1. 基于TCP协议：面向连接，安全
	2. 基于请求-响应模型的：一次请求对应一次响应
	3. HTTP协议是**无状态**的协议：对于事务处理没有记忆能力。每次请求-响应都是独立的。
	- 
	- 缺点:多次请求间不能共享数据。
	- 优点:速度快

## 请求协议
### 请求数据格式
![](Web-1.png)
####  请求行 (Request Line)

包含三个核心信息：

- **请求方法**：`GET`、`POST`、`PUT`、`DELETE` 等。
    
- **资源路径**：例如 `/api/v1/users`。
    
- **协议版本**：通常是 `HTTP/1.1` 或 `HTTP/2`。
    

> 示例：`POST /login HTTP/1.1`

#### 请求头 (Request Headers)

用键值对（`Key: Value`）的形式告知服务器客户端的环境、权限以及**数据格式**。常见头信息：

- **`Host`**: 服务器域名。
    
- **`User-Agent`**: 客户端浏览器或系统信息。
    
- **`Content-Type`**: **最重要的字段**，告诉服务器请求体里装的是什么格式的数据（如 JSON 或表单）。
    
- **`Authorization`**: 携带 Token 进行登录校验。
    

#### 空行 (Empty Line)

必须存在的一行空行，用于分隔“报头”和“数据体”。

#### 请求体 (Request Body)

真正传输的数据。注意：`GET` 请求通常没有请求体（参数放在 URL 后），而 `POST`、`PUT` 请求通常将数据放在这里。

---

## 请求数据获取
```Java
@RestController  
public class RequestController {  
    @RequestMapping("/request")  
    public String request(HttpServletRequest request) {  
        //获取请求方式  
        String method = request.getMethod();  
        System.out.println("请求方式:" + method);  
        //获取请求url地址  
        String url = request.getRequestURL().toString();
        //http://localhost:8080/request  
        
        System.out.println("请求url地址:" + url);  
        String uri = request.getRequestURI();//request  
        System.out.println("请求uri地址:" + uri);  
  
        //获取请求协议  
        String protocol = request.getProtocol();  
        System.out.println("请求协议:" + protocol);  
        //获取请求参数 - name        
        String name = request.getParameter("name");  
        String age = request.getParameter("age");  
        System.out.println("请求参数name:" + name + ",age:" + age);  
  
        //获取请求头 - Accept        
        String accept = request.getHeader("Accept");  
        System.out.println("请求头Accept:" + accept);  
          
        return "OKK";  
    }  
}
```

- **URL (Uniform Resource Locator)**：资源的**路径**。它像家庭住址：`http://localhost:8080/request`。
    
- **URI (Uniform Resource Identifier)**：资源的**身份证**。它只关心资源本身：`/request`。
> **面试题：** 所有的 URL 都是 URI，但不是所有的 URI 都是 URL

---

## 响应协议
### 响应数据格式
![](Web-2.png)
#### 响应行 
协议版本 + 状态码 + 状态描述
- 例如：`HTTP/1.1 200 OK` 或 `HTTP/1.1 404 Not Found`。    
#### 响应头
服务器告知客户端的数据元信息。
- **`Content-Type`**: **最关键**。告知浏览器数据格式（如 `application/json` 或 `text/html`）。

- **`Set-Cookie`**: 服务器给客户端种下的“小饼干”。

#### **空行**
分隔头部与内容。
#### 响应体
真正传回给前端的数据（HTML、JSON、图片字节流等）

| HTTP 状态码           | 含义说明                                             |
| ------------------ | ------------------------------------------------ |
| `1xx`              | 响应中 - 临时状态码，表示请求已经接收，告诉客户端应该继续请求或者如果它已经完成则忽略它。   |
| `2xx`              | 成功 - 表示请求已经被成功接收，处理已完成。                          |
| `3xx`              | 重定向 - 重定向到其他地方；让客户端再发起一次请求以完成整个处理。               |
| `4xx`              | 客户端错误 - 处理发生错误，责任在客户端。如：请求了不存在的资源、客户端未被授权、禁止访问等。 |
| `5xx`              | 服务器错误 - 处理发生错误，责任在服务端。如：程序抛出异常等。                 |
最常见状态码：

| 状态码   | 英文描述                    | 解释                |
| ----- | ----------------------- | ----------------- |
| `200` | `OK`                    | 请求成功，服务器正常处理并返回资源 |
| `404` | `Not Found`             | 请求的资源不存在          |
| `500` | `Internal Server Error` | 服务器内部错误，无法完成请求    |
字段解释：

| **响应头字段**          | **含义说明**                                         |
|------------------|-----------------|
| `Content-Type`     | 表示该响应内容的类型，例如`text/html`, `application/json`。    |
| `Content-Length`   | 表示该响应内容的长度（字节数）。                                 |
| `Content-Encoding` | 表示该响应压缩算法，例如`gzip`。                              |
| `Cache-Control`    | 指示客户端应如何缓存，例如`max-age=300`表示可以最多缓存 300 秒。        |
| `Set-Cookie`       | 告诉浏览器为当前页面所在的域设置 cookie。                         |
### 响应数据设置
```Java
@RestController  
public class ResponseController {  
    @RequestMapping("/response")  
    public void response(HttpServletResponse response) throws IOException {  
        //设置响应状态码  
        response.setStatus(401);  
        //设置响应头  
        response.setHeader("name","itcast");  
        //设置响应体  
        response.getWriter().write("<h1>Hello Response</h1>");  
        //  
    }  
    /*  
    * 方法二  
    * 基于ResponseEntity构建响应对象  
    * */    @RequestMapping("/response2")  
    public ResponseEntity<String> response2(){  
        return ResponseEntity  
                .status(401)  
                .header("name","javaweb")  
                .body("<h1>Hello ResponseEntity</h1>");  
    }  
}
```

# 案例
```Java
//UserController
/*  
 * 用户信息Controller  
 * */@RestController  
public class UserController {  
    @RequestMapping("/list")  
    public List<User> list() throws FileNotFoundException {  
        //加载并读取user.txt  
        InputStream in = this.getClass().getClassLoader().getResourceAsStream("user.txt");  
        ArrayList<String> lines = IoUtil.readLines  
                (in, StandardCharsets.UTF_8, new ArrayList<>());  
        //解析用户信息，封装为User对象，list集合  
        List<User> userList = lines.stream().map(line -> {  
            String[] parts = line.split(",");  
            Integer id = Integer.parseInt(parts[0]);  
            String username = parts[1];  
            String password = parts[2];  
            String name = parts[3];  
            Integer age = Integer.parseInt(parts[4]);  
            LocalDateTime updateTime = LocalDateTime.parse(parts[5], DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));  
            return new User(id, username, password, name, age, updateTime);  
        }).toList();  
  
        //返回数据json  
        return userList;  
    }  
}

//User
@Data  
@NoArgsConstructor  //  
@AllArgsConstructor //全参  
public class User {  
    private Integer id;  
    private String username;  
    private String password;  
    private String name;  
    private Integer age;  
    private LocalDateTime updateTime;  
  
}
```

>1.静态资源文件存放位置
>
>- resources/static
>
>2.@ResponseBody 注解的作用
>
>- 将 controller 方法的返回值直接写入 HTTP 响应体
>- 如果是对象或集合，会先转为 json，再响应
>- @RestController = @Controller + @ResponseBody

# 分层解耦
**耦合:** 衡量软件中各个层/各个模块的依赖关联程度。

**内聚:** 软件中各个功能模块内部的功能联系。

**设计原则： 高内聚低耦合**
## 三层架构
| **层次名称**  | **对应英文**                    | **核心注解**          | **职责描述（通俗理解）**                         |
| --------- | --------------------------- | ----------------- | -------------------------------------- |
| **控制层**   | **Controller**              | `@RestController` | **门面**。负责接收请求、校验参数，并把结果响应给前端。它不负责处理业务。 |
| **业务逻辑层** | **Service**                 | `@Service`        | **大脑**。负责所有的计算、逻辑判断、事务管理。它是系统最核心的部分。   |
| **数据访问层** | **dao**(Data Access Object) | `@Repository`     | **搬运工**。负责与数据库打交道，进行增删改查（CRUD）。        |
### Controller
```Java
/*  
 * 用户信息Controller  
 * */@RestController  
public class UserController {  
    private UserService userService = new UserServiceImpl();  
    *多态的实现*
    @RequestMapping("/list")  
    public List<User> list() throws FileNotFoundException {  
        
        List<User> list = userService.findAll();  
        *多态的实现*
        
        return list;  
    }  
}
```
### Service
```Java
//接口
public interface UserService {  
    /*  
    *查询所有用户信息  
    * */   
    public List<User>  findAll();  
}

//实现类
//带impl就是一个实现类  
public class UserServiceImpl implements UserService {  
    private UserDao userDao = new UserDaoImpl();  
	*多态的实现*
    @Override  
    public List<User> findAll() {  
        List<String> lines = userDao.findAll();  
        *多态的实现*
        
        List<User> userList = lines.stream().map(line -> {  
            String[] parts = line.split(",");  
            Integer id = Integer.parseInt(parts[0]);  
            String username = parts[1];  
            String password = parts[2];  
            String name = parts[3];  
            Integer age = Integer.parseInt(parts[4]);  
            LocalDateTime updateTime = LocalDateTime.parse(parts[5], DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));  
            return new User(id, username, password, name, age, updateTime);  
        }).toList();  
        return userList;  
    }  
}
```

### Dao
```java
//接口
public interface UserDao {  
    /*  
    * 加载用户数据  
    * */    
    public List<String> findAll();  
}

//实现类
public class UserDaoImpl implements UserDao {  
    @Override  
    public List<String> findAll() {  
    
        InputStream in = this.getClass().getClassLoader().getResourceAsStream("user.txt");  
        
        ArrayList<String> lines = IoUtil.readLines  
                (in, StandardCharsets.UTF_8, new ArrayList<>());  
  
        return lines;  
    }  
  
}
```


![](Web-3.png)
![](Web-4.png)

## 控制反转（IOC）& 依赖注入（DI）& Bean对象
- 对象的创建控制权由程序自身转移到外部(容器)，这种思想称为控制反转
- 容器为应用程序提供运行时，所依赖的资源，称之为依赖注入
- IOC容器中创建、管理的对象，称之为Bean
![](Web-5.png)
![](Web-6.png)
### IOC详解
1. **如何将一个类交给 IOC 容器管理？**

- `@Component`（注意：是加在实现类上，而非接口上）

1. **如何从 IOC 容器中找到该类型的 bean，然后完成依赖注入？**

- `@Autowired`

@Component时声明bean的基础注解
其他三个是@Component的衍生注解

| **注解**            | **适用层级**            | **语义描述**                                                                                    |
| ----------------- | ------------------- | ------------------------------------------------------------------------------------------- |
| **`@Component`**  | 通用组件                | 不属于以下三类时，用此注解（如工具类、配置类）。                                                                    |
| **`@Controller`** | 标注在**控制层类** (Web)   | 负责处理 HTTP 请求，分发数据。                                                                          |
| **`@Service`**    | 标注在**业务逻辑层类**       | 负责核心业务逻辑处理、事务管理。                                                                            |
| **`@Repository`** | 标注在**数据访问层类** (Dao) | 负责数据库的增删改查，并能将原生数据库异常转为 Spring 异常。（由于与[mybatis](MySQL/JDBC%20&%20Mybatis.md#Mybatis)整合，用的少） |
|                   |                     |                                                                                             |
|                   |                     |                                                                                             |
>[!warning]
>❗：@RestController 注解内部已经包含 @Controller
>
>❗：声明bean的时候，可以通过注解的value属性指定bean的名字，如果没有指定，默认为类名首字母小写


![](Web-7.png)

### DI详解
#### 基于@Autowired进行依赖注入的常见方式
**①.属性注入**
- 这是最常见、最简洁的方式。直接在成员变量上加上 `@Autowired`。
- ```Java
	@RestController
	public class UserController {
		@Autowired
		private UserService userService; // 直接注入
	}
   ```
- **优点**：代码极其简洁，可读性好。
    
- **缺点**：
    
    - **不能使用 `final` 修饰变量**（因为变量必须在对象实例化后通过反射注入）。
        
    - **隐藏依赖关系**：外部不通过反射很难看到这个类到底依赖了谁。
        
    - **违背单一职责原则**：因为写起来太简单，容易导致一个类注入了过多的依赖。

---

**②.构造器注入**—Spring官方推荐
- 通过类的构造函数来完成注入。
- ```Java
	@Service //将当前类给IOC容器管理  
	public class UserServiceImpl implements UserService {  
	    private final UserDao userDao;  //可以是final
	    @Autowired  //可省略！
	    public UserServiceImpl(UserDao userDao) {  
	        this.userDao = userDao;  
	    }
    }
   ```
- **优点**：
    
    - **支持 `final` 关键字**：保证了依赖在对象创建后不可变，更加安全。
        
    - **完全初始化**：确保对象在被调用前，所有依赖都已就绪。
        
    - **易于测试**：在写单元测试时，可以直接通过 `new` 一个对象并传入 Mock 依赖，不需要启动整个 Spring 容器。
        
- **注意**：如果类中只有一个构造函数，Spring 4.3 以后可以省略 `@Autowired`
---
**③.Setter方法注入**
- 通过对应的 `setXxx` 方法来注入依赖。
- ```Java
	@RestController  
	public class UserController {  
	    private UserService userService;  
	      
	    @Autowired  
	    public void setUserService(UserService userService) {  
	        this.userService = userService;  
	    }
	}
   ```
- **优点**：允许依赖在之后被修改（灵活性高）。
    
- **缺点**：
    
    - 不能使用 `final`。
        
    - 对象在被使用时可能处于“未完全初始化”的状态（如果没调用 set 方法）
---

**对比：**

| **注入方式**      | **是否推荐** | **支持 final** | **优点**        | **缺点**          |
| ------------- | -------- | ------------ | ------------- | --------------- |
| **属性注入**      | 慎用       | 否            | 简单、快          | 依赖关系不透明，不方便单元测试 |
| **构造器注入**     | **强烈推荐** | **是**        | 安全、强制初始化、方便测试 | 代码略显冗长          |
| **Setter 注入** | 可选       | 否            | 灵活，可按需注入      | 无法保证对象完整性       |

---

#### 当出现多个相同类型的Bean就会报错，如何解决？
![](Web-8.png)
**①使用 @Primary**

如果你希望在大多数情况下都使用某个特定的实现类，可以在该类上加上 `@Primary` 注解。

- **效果**：当存在多个候选 Bean 时，Spring 会优先注入标注了 `@Primary` 的那一个
- ```JAVA
	@Primary
	@Service
	public class UserServiceImpl1 implements UserService { 
	    // ... 
	}
	
	@Service
	public class UserServiceImpl2 implements UserService { 
	    // ... 
	}
   ```
**②使用@Qualifier(指定具体的名称)**

如果你想在不同的地方注入不同的实现，可以配合 `@Autowired` 使用 `@Qualifier`，并指定 Bean 的名称。

- **注意**：Bean 的默认名称是**类名首字母小写**（如 `userServiceImpl1`），你也可以在注解中手动指定名称，如 `@Service("userService2")`。
- ```Java
	@RestController
	public class UserController {
	    @Autowired
	    @Qualifier("userServiceImpl1") // 明确告诉 Spring：我要这一个
	    private UserService userService;
	}
   ```
   
**③使用@Resource(直接按名称查找)**

`@Resource` 是 JDK 提供的注解（Spring 也支持）。
它与 `@Autowired` 的最大区别在于**查找顺序**：

- **`@Autowired`**：先按**类型**找，如果类型有多个，再按名称找。
    
- **`@Resource`**：先按**名称**找，如果名称找不到，再按类型找。
- ```Java
	@RestController
	public class UserController {
	    @Resource(name = "userServiceImpl2") // 直接通过名字“精准定位”
	    private UserService userService;
	}
   ```

| **解决方案**         | **核心原理**        | **适用场景**                       |
| ---------------- | --------------- | ------------------------------ |
| **`@Primary`**   | 权重优先            | 存在一个“绝对主流”的实现类时。               |
| **`@Qualifier`** | **类型** + 名称辅助   | 需要在不同类中灵活切换不同实现时。              |
| **`@Resource`**  | **名称**优先        | 想减少对 Spring 注解的依赖，或更倾向于按名字查找时。 |

---

### 问题
**问：“既然没有代码显式调用构造函数，Spring 是如何实现注入的？”**

- 这是通过 **IoC 容器** 的生命周期管理实现的。Spring 启动时会解析 **BeanDefinition**（Bean 的定义信息）。如果发现是构造器注入，Spring 会通过 **反射** 查找匹配的参数 Bean，并利用 `Constructor.newInstance()` 方法完成实例化。这种方式将对象的创建权交给了容器，实现了真正的控制反转。

---

**问：“如果你在代码里同时用了 `@Primary` 和 `@Qualifier`，谁会生效？”**
- “**`@Qualifier` 的优先级更高**。因为 `@Primary` 定义的是默认的首选 Bean，而 `@Qualifier` 是在注入点进行的‘精准指名’。这就好比食堂默认提供大米饭（Primary），但你明确跟打饭阿姨说你要面条（Qualifier），阿姨肯定会给你面条。”

---

# 附录
## [状态码大全](https://cloud.tencent.com/developer/article/2138076)