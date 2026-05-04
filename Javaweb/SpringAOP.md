+++
date = '2026-05-03'
draft = false
title = 'SpringAOP'
tags = []
categories = ["JavaWeb"]
+++

> 本文更新于 2026-05-03

---
**AOP（Aspect Oriented Programming，面向切面编程）**
![场景：计算程序运行耗时](img/SpringAOP-1.png)
AOP是一种思想，SpringAOP把设个思想实现了
AOP 的核心思想是：将那些与业务无关，却为业务模块所共同调用的逻辑（如日志、事务、权限、缓存）封装起来，形成一个“切面”。

-  **应用场景**：记录系统的操作日志，**事务管理，权限控制**
 
# 基础
```Java
@Slf4j  
@Component  
@Aspect //AOP类  
public class RecordTimeAspect {  
  
    //切入点表达式：execution(访问修饰符? 返回值类型 包名.类名.方法名(参数列表))  
    @Around("execution(* com.itheima.service.impl.*.*(..))")  
    public Object recordTime(ProceedingJoinPoint pjp) throws Throwable {  
        //记录方法运行开始时间  
        long begin = System.currentTimeMillis();  
        //执行目标方法 返回值可能不一样，用Object接收  
        Object result = pjp.proceed();  
  
        //记录方法运行结束时间  
        long end = System.currentTimeMillis();  
        //计算方法运行时间  获取方法签名  
        log.info("{} 方法运行时间: {}ms", pjp.getSignature(), end - begin);  
        //List com.itheima.service.impl.DeptServiceImpl.list() 方法运行时间: 3ms
        return result;  
    }
}

❗注意在启动类加上ComponentScan❗
@SpringBootApplication  
@ComponentScan({"com.itheima", "aop"})  
public class SpringbootAopQuickstartApplication {...}
```
## 核心概念

- **切面 (Aspect)**：横切关注点的模块化（比如一个日志类）
	- 描述通知与切入点的对应关系
	- 通知+切入点
    
- **连接点 (Join Point)**：程序执行过程中的某个点，在 Spring 中通常指**方法执行**
	- **可以被AOP控制的方法**(暗含方法执行时的相关信息)
    
- **切入点 (Pointcut)**：定义**哪些方法**需要被拦截（比如：所有以 `save` 开头的方法）
	- 就是实际被控制的方法
	- `@Around(...)`就是切入点表达式
    
- **通知 (Advice)**：拦截后要**执行的操作**（比如：在方法开始前记录时间）
	- 指那些重复的逻辑，也就是**共性功能**(最终体现为一个方法)
- **目标对象**：

| 概念       | **连接点 (Join Point)**         | **切入点 (Pointcut)**  |
| -------- | ---------------------------- | ------------------- |
| **定义**   | 一个具体的执行点（所有方法）               | 匹配连接点的断言（筛选规则）      |
| **数量**   | 很多（每一个方法都是）                  | 较少（你定义的规则）          |
| **关系**   | **是被筛选的对象**                  | **是筛选工具**           |
| **在代码中** | 表现为 `JoinPoint` 对象，用于获取运行时信息 | 表现为 `@Pointcut` 表达式 |
| **理解**   | 可选择的对象                       | 选择后的对象              |
### 执行流程：动态代理
Spring AOP 的执行流程可以看作是一个典型的**职责链模式**与**动态代理**的结合。当一个请求调用被 AOP 增强的方法时，它会经历从代理对象到拦截器链，再到目标方法的完整循环。
我们可以将整个流程拆解为 **启动阶段**、**调用阶段** 和 **收尾阶段**。
![](img/SpringAOP-2.png)

#### 启动阶段：织入

在 Spring 容器启动并初始化 Bean 的过程中，AOP 已经开始工作了：

1. **扫描切面**：Spring 会解析所有标注了 `@Aspect` 的类。
    
2. **匹配筛选**：利用 **Pointcut（切入点）** 表达式，在所有的 Bean 中寻找匹配的方法。
    
3. **创建代理**：一旦发现匹配，Spring 不会把原始的 Bean 放入容器，而是利用 **JDK 动态代理** 或 **CGLIB** 创建一个**代理对象（Proxy）**。
    
4. **构建拦截器链**：将匹配到的各种通知（`@Before`、`@Around` 等）根据优先级排序，封装成一个 **MethodInterceptor（方法拦截器）** 链。
    

---

#### 调用阶段：横切逻辑的执行

当外部代码调用代理对象的方法时，流程正式进入动态执行阶段：

##### 第一步：进入代理对象

调用者以为自己在调用原始方法，实际上进入了代理对象的 `invoke()` 或 `intercept()` 方法。

##### 第二步：获取拦截器链

代理对象会获取针对该方法的所有拦截器（Advices）。这些拦截器形成了一个链条。

##### 第三步：环绕执行（核心）

Spring 采用的是**递归**的方式来执行这个链条。

- **前置处理**：首先执行 `@Before` 通知或 `@Around` 的前半部分代码。
    
- **链式传递**：如果当前拦截器执行完，会调用 `mi.proceed()` 触发下一个拦截器。
    
- **目标执行**：当链条走到尽头，最后才会真正通过反射执行**目标方法（Target Method）**。
    

---

#### 收尾阶段：响应与异常回溯

目标方法执行完毕后，执行权会沿着拦截器链**原路返回**：

1. **返回通知 (`@AfterReturning`)**：如果目标方法正常结束，执行此逻辑。
    
2. **异常通知 (`@AfterThrowing`)**：如果目标方法抛出异常，执行此逻辑。
    
3. **后置通知 (`@After`)**：无论是否发生异常，都会执行。
    
4. **结果返回**：最后，代理对象将最终结果（或异常）返回给调用者。

---

## 通知类型
### 前置通知 (`@Before`)

- **执行时机**：在目标方法执行**之前**
    
- **典型用途**：权限校验、登录检查、参数预处理
    
- **注意**：除非抛出异常，否则它不能阻止目标方法的执行
    

### 返回后通知 (`@AfterReturning`)

- **执行时机**：在目标方法**正常执行完成后**
    
- **典型用途**：记录业务日志、对返回值进行加工
    
- **特权**：可以访问到方法的返回值（通过 `returning` 属性绑定）
    

### 异常后通知 (`@AfterThrowing`)

- **执行时机**：在目标方法**抛出异常后**
    
- **典型用途**：异常监控（告警）、事务回滚、记录错误日志。
    
- **特权**：可以获取到抛出的异常对象（通过 `throwing` 属性绑定）
    

### 后置通知 (`@After`)

- **执行时机**：在目标方法执行**之后**，无论成功还是失败（类似 `finally`）
    
- **典型用途**：释放资源（如关闭流、释放数据库连接）
    

### 环绕通知 (`@Around`) —— **功能最强**

- **执行时机**：包裹了整个目标方法，在方法调用前后都可以运行自定义逻辑
    
- **典型用途**：性能统计（计时）、缓存逻辑（如果缓存有数据，直接返回，不调用目标方法）
    
- **核心**：必须手动调用 `proceed()` 方法，目标方法才会执行

| **通知类型**  | **注解**            | **执行时机**           | **能否访问返回值/异常**  | **能否阻止目标方法执行**         | **典型应用场景**          |
| --------- | ----------------- | ------------------ | --------------- | ---------------------- | ------------------- |
| **前置通知**  | `@Before`         | 目标方法执行**前**        | 否               | 只有抛出异常时可以              | 权限校验、登录检查、参数过滤      |
| **返回后通知** | `@AfterReturning` | 目标方法**正常完成**后      | **是** (可获取返回值)  | 否                      | 业务日志记录、数据加工         |
| **异常后通知** | `@AfterThrowing`  | 目标方法**抛出异常**后      | **是** (可获取异常对象) | 否                      | 事务回滚、异常监控告警         |
| **后置通知**  | `@After`          | 目标方法执行**后** (无论成败) | 否               | 否                      | 释放资源 (类似 `finally`) |
| **环绕通知**  | `@Around`         | **环绕**整个方法执行过程     | **是** (完全控制返回值) | **是** (手动控制 `proceed`) | 性能监控、缓存控制、幂等校验      |


>[!NOTE]
>`@Around`环绕通知**需要**自己调用 `Proceeding]oinPoint.proceed()`来让原始方法执行
>其他通知**不需要**考虑目标方法执行

```Java
	//前置通知 - 在目标方法运行之前运行  
	@Before("execution(* com.itheima.service.impl.*.*(..))")  
	public void before(){  
	    log.info("前置通知");  
	}  
	  
	//环绕通知 - 在目标方法运行之前和之后都运行  
	@Around("execution(* com.itheima.service.impl.*.*(..))")  
	public Object around(ProceedingJoinPoint pjp) throws Throwable {  
	    log.info("环绕通知-前");  
	  
	    Object result = pjp.proceed();  
	  
	    log.info("环绕通知-后");  
	    return result;  
	}  
	//后置通知 - 在目标方法运行之后运行  
	@After("execution(* com.itheima.service.impl.*.*(..))")  
	public void after(){  
	    log.info("后置通知");  
	}  
	  

两者互排斥-------------
|	//返回后通知 - 目标方法运行之后运行，出现异常不会运行  
|	@AfterReturning("execution(* com.itheima.service.impl.*.*(..))")  
|	public Object afterReturning(ProceedingJoinPoint pjp) throws Throwable {  
|	    log.info("返回后通知");  
|	    return pjp.proceed();  
|	}  
|	  
|	//异常后通知 - 只有目标方法抛出异常时执行  
|	@AfterThrowing("execution(* com.itheima.service.impl.*.*(..))")  
|	public void afterThrowing() {  
|	    log.info("异常后通知");  
|	}
----------------------
未出现异常：
/*  
    环绕通知-前  
    前置通知  
    list()方法运行时间: 927ms  
    返回后通知  
    后置通知    
    环绕通知-后  
*/
出现异常：
/*
    环绕通知-前  
    前置通知    
    异常后通知  
	后置通知  
*/
```
### @PointCut
- 该注解的作用是将公共的切点表达式抽取出来，需要用到时引用该切点表达式即可
```Java
	@Pointcut("execution(* com.itheima.service.impl.*.*(..))")  
	private void pt1(){}  
	public void pt2(){}  //可以在别的AOP类使用
	
	//前置通知 - 在目标方法运行之前运行  
	@Before("pt1()")  
	public void before(){  
	    log.info("前置通知");  
	}
```
## 通知顺序
当有多个切面的切入点都匹配到了目标方法，自目标方法运行时，多个通知方法都会被执行
执行顺序:
- 不同切面类中，默认按照切面类的**类名字母排序**
	- 目标方法前的通知方法：字母排名靠前的先执行
	- 目标方法后的通知方法:：字母排名靠前的后执行
## 切入点表达式
- **介绍**：描述切入点方法的一种表达式。
- **作用**：用来决定项目中的哪些方法需要加入通知
**常见形式**：
- `execution(...)`：根据方法的签名来匹配
- `@annotation(...)`：根据注解匹配
#### `execution` 
```Java
	`execution(访问修饰符? 返回类型 包名.类名.方法名(参数) 异常?)`
	//注：带 `?` 的表示可省略的部分
	1. 访问修饰符：可省略(public,protected)
	2. 报名.类名：可省略但不建议
    3. throws 异常：可省略(注意是方法上声明抛出的异常，不是实际抛出的异常)
```
##### 通配符 `*` (匹配单个占位)
**`*` 用于匹配一个任意类型的元素。它不能跨越包层级，也不能代表任意数量的参数**

- **在返回类型位置**：`*` 表示匹配任意返回类型（`void, String, int` 等）。
    
- **在包名位置**：`*` 表示匹配**一层**包名。
    
- **在方法名位置**：`*` 表示匹配方法名中连续的字符。
	- `dele*`：表示`dele`开头的方法
	- `*e`：表示以`e`结尾的方法
	
- **在参数列表位置**：`*`表示匹配**单个**任意形参

##### 通配符 `..`(匹配任意深度/数量)

`..` 更加强大，它专门用于处理**层级关系**或**参数列表**。

- **在包名位置**：匹配当前包及其**所有子包**（无限深度）。
    
- **在参数列表位置**：匹配**任意数量、任意类型**的参数（包括零个参数）。
>[!NOTE]
>另外，`execution`也可以**通过接口匹配实现类**
>而且，`execution`可以使用逻辑运算符(`||,&&,!`)

#### `@annotation`
`@annotation` 切入点表达式，用于匹配标识有特定注解的方法
**定义注解**
```Java
@Target(ElementType.METHOD) // 作用在方法上  
@Retention(RetentionPolicy.RUNTIME) // 运行时有效  
public @interface MyLog {  
    String value() default ""; // 可以定义一些参数  
}
```
**在业务方法使用**
```Java
@Service
public class UserService {
    @MyLog("添加用户") // 贴上标签
    public void addUser(String name) {
        System.out.println("执行业务逻辑...");
    }
}
```
**编写切面**
```Java
@Aspect
@Component
public class LogAspect {

    // 匹配所有贴了 @MyLog 注解的方法
    @Before("@annotation(com.creat.annotation.MyLog)")
    public void doBefore(JoinPoint joinPoint) {
        // 获取注解中的参数
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        MyLog annotation = signature.getMethod().getAnnotation(MyLog.class);
        
        System.out.println("日志描述：" + annotation.value());
    }
}
```
### 对比
|**维度**|**execution (基于路径)**|**@annotation (基于注解)**|
|---|---|---|
|**控制力度**|批量拦截（比如：所有 Service）|个体拦截（比如：特定几个方法）|
|**代码侵入**|**无侵入**（不需要改业务代码）|**有侵入**（需要手动贴注解）|
|**维护成本**|包名变动时需同步修改表达式|随代码移动，维护成本低|
|**适用场景**|事务管理、全局日志、监控|权限细控、特定缓存、幂等校验|

---
## 连接点

在Spring中用JoinPoint抽象了连接点，用它可以获得方法执行时的相关信息，如目标类名、方法名、方法参数等
- 对于 @Around 通知，获取连接点信息只能使用 ProceedingJoinPoint
- 对于其它四种通知，获取连接点信息只能使用 JoinPoint，它是 ProceedingJoinPoint 的父类型

连接点是程序执行过程中的一个**点**。在 Spring 中，这个点就是**方法的调用**。

- **每一个方法都是一个连接点**： `UserService` 里有 10 个方法，这 10 个方法都是潜在的连接点。
    
- **它是动态的**：只有当代码运行到那个方法时，连接点才真正“激活”

|**方法**|**说明**|**示例**|
|---|---|---|
|**`getArgs()`**|获取方法传入的**参数值**|拿到用户登录的账号、密码|
|**`getSignature()`**|获取**方法签名**|拿到方法名、所属类名、返回类型|
|**`getTarget()`**|获取**被代理的目标对象**|拿到原始的 `UserService` 实例|
|**`getThis()`**|获取**代理对象本身**|拿到 Spring 生成的那个代理实例|

