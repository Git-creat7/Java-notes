+++
date = '2026-04-10'
draft = false
title = 'Maven'
tags = []
categories = ["JavaWeb"]
+++

> 本文更新于 2026-04-10

- 用于管理和构建Java项目的工具
- 拥有**本地仓库，中央仓库，远程仓库（私服）**
# * 生命周期
Maven 的工作是有固定逻辑顺序的
**只需要执行一个命令，它会自动执行之前的所有步骤**：（前提：同一生命周期）

- **clean**：清理旧的编译文件（删掉 `target` 目录）
    
- **compile**：编译源代码
    
- **test**：运行单元测试
    
- **package**：打包（生成可执行的 Jar 包）
    
- **install**：把打好的包安装到**本地仓库**，让其他项目也能引用它



---

# 坐标
在 Maven 中，**坐标（Coordinates）** 是用来唯一标识一个 Jar 包（插件或项目）的地址
## 坐标的核心组成（GAV）

一个最基本的坐标由三个核心部分组成，简称 **GAV**：

1. **`groupId` (团体/组织 ID)**：
    
    - **含义**：定义当前项目隶属的实际项目或组织。
        
    - **命名习惯**：通常是公司域名的倒写。例如：`com.google`、`org.apache`、`com.alibaba`。
        
2. **`artifactId` (项目 ID)**：
    
    - **含义**：该组织下的某个具体模块或项目的名称。
        
    - **命名习惯**：通常是项目名。例如：`spring-boot-starter-web`、`mysql-connector-java`。
        
3. **`version` (版本)**：
    
    - **含义**：当前项目的版本号。
        
    - **常见格式**：`1.0.0-RELEASE`（正式版）或 `2.1.5-SNAPSHOT`（开发快照版）
## 在`pom.xml`中的样子
当你去 **Maven 中央仓库** 搜到一个依赖时，它会给你这样一段坐标代码，你只需把它复制到 `dependencies` 标签里：
```XML
	<dependency>
	    <groupId>org.mybatis</groupId>
	    <artifactId>mybatis</artifactId>
	    <version>3.5.13</version>
	</dependency>
```
## 坐标与目录结构的逻辑顺序

坐标不仅仅是几个字母，它直接决定了 Jar 包在**本地仓库**中的**物理存放路径**。

如果本地仓库路径是 `D:\maven_repo`，那么上面 MyBatis 的 Jar 包会被存放在： 
`D:\maven_repo \ org \ mybatis \ mybatis \ 3.5.13 \ mybatis-3.5.13.jar`

- **`groupId`**：中的点（`.`）会被转换成文件夹斜杠（`\`）。
    
- **`artifactId`**：是下一级文件夹。
    
- **`version`**：是再下一级文件夹。


---
# 依赖配置
在 Maven 项目中，**依赖配置（Dependency Configuration）** 是通过 `pom.xml` 文件来声明项目运行所需的外部库

## 依赖传递与排除 (Exclusions)

这是 Maven 解决复用性的核心逻辑：如果引入了 A，而 A 依赖了 B，Maven 会自动把 B 也下载下来。

**问题**：如果 A 引入的 B 版本太旧，导致项目报错怎么办？ 
**解决**：使用 `<exclusions>` 手动切断传递

```XML
<dependency>
    <groupId>com.example</groupId>
    <artifactId>library-a</artifactId>
    <version>1.0.0</version>
    
    <exclusions>
        <exclusion>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-log4j12</artifactId>
        </exclusion>
    </exclusions>
</dependency>
```

## 常见配置逻辑顺

1. **确定需求**：比如需要连接 MySQL。
    
2. **查找坐标**：在 [MVNrepository](https://mvnrepository.com/) 搜索 `mysql-connector-java`
    
3. **粘贴配置**：将代码放入 `pom.xml`
    
4. **刷新 Maven**：在 IDEA 中点击刷新图标
    
5. **检查冲突**：在 IDEA 右侧 Maven 面板查看 `Dependencies` 树，确认没有红色的冲突标识
>[!WARNING] 警告
>- 如果依赖配置变更了，必须要刷新/重新加载
>

---
# 单元测试
**单元测试 (Unit Testing)** 是指对软件中的最小可测试单元（在 Java 中通常是一个**类**或一个**方法**）进行检查和验证
![](Maven-1.png)
## 为什么要写单元测试？

- **快速反馈**：改完代码秒知对错，不用等启动整个项目或手动点浏览器。
    
- **防止回滚**：当你重构（修改）旧代码时，单元测试能确保你没有改坏原本正常的功能。
    
- **文档作用**：好的测试代码本身就是最好的“功能说明书”。
>[!NOTE]
>- 测试代码与应用程序代码分开,便于维护
>- 可以自动生成测试报告(通过:绿色，失败:红色)
>- 一个测试方法执行失败，不会影响其它测试方法
## JUnit
### 测试类要求
| **维度**   | **要求标准**          | **说明**                                        |
| -------- | ----------------- | --------------------------------------------- |
| **存放路径** | `src/test/java`   | 必须与业务代码（`src/main/java`）分开存放。                 |
| **包名结构** | 与被测类包名一致          | 例如被测类在 `com.demo.service`，测试类也应在此包下。          |
| **类名规范** | 以 `Test` 结尾       | 例如：`UserServiceTest.java`（Surefire 插件默认识别规则）。 |
| **依赖配置** | `scope` 设为 `test` | 确保测试相关的 Jar 包（如 JUnit）不会被打包到生产环境。             |
### 断言`assert`
- **本质**：测试逻辑的“裁判”。它对比 **预期值 (Expected)** 与 **实际值 (Actual)**
    
- **逻辑流**：`执行业务逻辑 -> 获取结果 -> 调用断言方法 -> 判定测试通过/失败`

```Java
	@Test  
	public void testGenderWithAssert(){  
	    UserService userService = new UserService();  
	    String gender = userService.getGenderByIdCard("100000200010011011");  
	    Assertions.assertEquals("男", gender,"性别获取逻辑有问题");
	    //会检测与结果是否一致
	}
```
>[!PROBLEM]
>测试代码中，通常会极力避免手动写 `try-catch`

| **断言方法**                          | **说明**          | **适用场景**                  |
| --------------------------------- | --------------- | ------------------------- |
| **`assertEquals(exp, act)`**      | 判断两个值是否相等       | 验证计算结果、字符串内容、对象相等。        |
| **`assertNotEquals(exp, act)`**   | 判断两个值是否**不**相等  | 验证更新后的值确实变了。              |
| **`assertTrue(condition)`**       | 判断条件是否为 `true`  | 验证布尔逻辑（如：`canAfford` 方法）。 |
| **`assertFalse(condition)`**      | 判断条件是否为 `false` | 验证否定逻辑（如：用户是否未登录）。        |
| **`assertNull(obj)`**             | 判断对象是否为空        | 验证查询不到数据时的返回。             |
| **`assertNotNull(obj)`**          | 判断对象是否不为空       | 验证对象是否成功创建或查询到。           |
| **`assertArrayEquals(exp, act)`** | 判断两个数组是否相等      | 验证列表排序或批量处理后的数组。          |
```Java
	@Test  
	public void testGenderWithAssert2(){  
	    UserService userService = new UserService();  
	    String gender = userService.getGenderByIdCard("100000200010011011"); 
	    
		//当异常发生的时候 测试能否抛出正确的异常
	    Assertions.assertThrows(IllegalArgumentException.class,()->  
	            userService.getGenderByIdCard(null));  
	}
```
#### 组合断言
当一个测试方法里有多个断言时：
- **普通逻辑**：第一个断言挂了，后面都不跑了。
    
- **assertAll 逻辑**：所有断言都会跑完，最后统一输出哪些挂了。
```Java
	// 笔记示例：
	assertAll("用户信息校验",
	    () -> assertEquals("男", gender),
	    () -> assertEquals(36, age)
	);
```

---
### 注解`Annotation`
#### 生命周期钩子
| **注解**            | **执行时机**          | **强制要求**        | **典型用途**               |
| ----------------- | ----------------- | --------------- | ---------------------- |
| **`@BeforeAll`**  | 所有测试开始前，**只执行一次** | 必须是 `static` 方法 | 初始化数据库连接池、启动 Redis 容器。 |
| **`@BeforeEach`** | **每个**测试方法执行前都跑一次 | 普通方法            | 重置对象状态、准备 Mock 数据。     |
| **`@AfterEach`**  | **每个**测试方法执行后都跑一次 | 普通方法            | 清理临时文件、撤销数据库更改。        |
| **`@AfterAll`**   | 所有测试结束后，**只执行一次** | 必须是 `static` 方法 | 关闭数据库连接、释放系统资源。        |

**执行顺序逻辑：** `@BeforeAll` $\rightarrow$ (`@BeforeEach` $\rightarrow$ `@Test` $\rightarrow$ `@AfterEach`) $\times$ N次 $\rightarrow$ `@AfterAll`
```bash
	before All
	before each
	after each
	before each
	男
	after each
	before each
	26
	after each
	before each
	after each
	after All
	
	进程已结束，退出代码为 0
```
#### 核心测试与显示
- **`@Test`**：最基础的标签，告诉 Maven 这是一个标准的单元测试。
    
- **`@DisplayName("描述内容")`**：
    
    - **作用**：在 IDEA 的运行面板或测试报告中，显示中文或易读的描述，而不是枯燥的方法名。
        
    - **复用性**：让非技术人员（或一个月后的你）一眼看懂这个测试在测什么

#### 参数化测试
**`@ParameterizedTest`**

- **作用**：声明这个方法是一个“参数化测试”，它会多次运行，每次注入不同的值。
    
- **逻辑**：它必须配合“数据源”注解使用。
    

**`@ValueSource`**

- **作用**：最简单的**数据源**，提供一组基本类型的值（如 Strings, Ints）
- 身份证性别测试：
- ```Java
	@ParameterizedTest
	@ValueSource(strings = 
					{"100000200010011021",
					"100000200010011032",
					"100000200010011051"
				})
	@DisplayName("验证多个男性身份证的识别")
	public void testGenderWithAssert2(String idCard){//strings传入idCard
	    UserService userService = new UserService();  
	    String gender = userService.getGenderByIdCard(idCard);  
	    Assertions.assertEquals("男",gender);  
	}
   ```
#### 总结
| **注解分类** | **注解名称**                   | **记忆关键词**       |
| -------- | -------------------------- | --------------- |
| **控制流**  | `@Before...` / `@After...` | **时机控制**（前置/后置） |
| **基础**   | `@Test`                    | **入场券**（标记测试）   |
| **美化**   | `@DisplayName`             | **别名**（中文描述）    |
| **高级**   | `@ParameterizedTest`       | **分身术**（一法多测）   |
| **数据源**  | `@ValueSource`             | **数据池**（提供参数）   |
>[!WARNING]
>- **静态限制**：记住 `@BeforeAll` 和 `@AfterAll` 必须加 `static` 关键字，因为它们在类实例创建之前就要运行。
>
>- **依赖冲突**：如果你在 `pom.xml` 里用的是 JUnit 4，这些注解（来自 `org.junit.jupiter` 包）是无法识别的。
>
>- **不要混用**：通常一个方法要么标 `@Test`，要么标 `@ParameterizedTest`，不要两个都标。

---

### 规范
在企业开发规范中，这种写法被称为 **“测试环境准备（Test Fixture Setup）”**
```Java
	private UserService userService;  
	@BeforeEach  
	public void setUp(){  
	    userService = new UserService();  
	}
```

---
# 依赖范围 
| **范围 (Scope)**     | **编译 (main)** | **测试 (test)** | **运行 (runtime)** | **打包** | **典型例子**               |
| ------------------ | ------------- | ------------- | ---------------- | ------ | ---------------------- |
| **`compile`** (默认) | ✅             | ✅             | ✅                | ✅      | Spring 核心库、Log4j       |
| **`test`**         | ❌             | ✅             | ❌                | ❌      | **JUnit 5**、Mockito    |
| **`provided`**     | ✅             | ✅             | ❌                | ❌      | **Servlet API**、Lombok |
| **`runtime`**      | ❌             | ✅             | ✅                | ✅      | **JDBC 驱动实现**          |
| **`system`**       | ✅             | ✅             | ✅                | ✅      | 本地磁盘上的 Jar 包，**迁移报错**  |
## 详细范围
### compile（编译范围）

- **逻辑**：如果不写 `<scope>`，默认就是这个。
    
- **特性**：全能型。你在写代码、跑测试、部署上线时都需要它。
    
- **复用性**：它具有**传递性**（如果你依赖 A，A 依赖 B，那么你的项目也会获得 B）。
    

### 🔹 test（测试范围）

- **逻辑**：只在 `src/test/java` 下的代码中有效。
    
- **为什么要用**：像 JUnit 这种工具，上线运行代码时根本不需要。
    
- **规范**：**必须**给所有测试框架加上 `test` 范围，防止线上包由于包含测试类而变得臃肿。
    

### 🔹 provided（已提供范围）

- **逻辑**：编译时我需要它，但**打包时请不要带上它**。
    
- **典型场景**：
    
    - **Servlet API**：你的代码需要它来编译，但你最终要把项目部署到 Tomcat。Tomcat 已经自带了 Servlet 的 Jar 包，如果你的包里也带一个，就会产生版本冲突。
        
    - **Lombok**：编译时生成 Getter/Setter，编译完后就不再需要了。
        

### 🔹 runtime（运行时范围）

- **逻辑**：写代码（编译）时不需要，但程序跑起来（运行）时必须有。
    
- **典型场景**：**数据库驱动（如 MySQL Connector）**。
    
    - 我们在代码里通常使用 JDK 自带的 `java.sql.Connection`（接口），不需要直接调用 MySQL 的具体实现类。只有在程序运行时，Maven 才会加载驱动包来建立真实连接。
# BOM
**BOM** 的全称是 **Bill of Materials**（物料清单）

简单来说，BOM 是一个特殊的 `pom.xml` 文件，它的核心逻辑不是为了提供代码，而是为了**统一管理依赖的版本号**

## 使用BOM
在 `pom.xml` 中导入 BOM
```XML
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>3.2.0</version>
            <type>pom</type>
            <scope>import</scope> </dependency>
    </dependencies>
</dependencyManagement>
```
引入具体依赖（不写版本号）
```XML
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
</dependencies>
```


|**维度**|**传统方式**|**使用 BOM**|
|---|---|---|
|**版本控制**|每个模块各自维护，易冲突|全局统一，一处修改全线更新|
|**配置量**|每个 `<dependency>` 都要写版本|只在顶层写一次，子模块极简|
|**复用性**|差，需要反复确认版本号|极强，确保所有组件完美兼容|
|**稳定性**|容易出现 Jar 包版本不匹配|官方认证的“全家桶”组合，最稳定|

---
# 分模块设计与开发
```Java
algorithm-oj (父工程，打包方式为 pom)
├── pom.xml (总控制台)
├── oj-common (通用工具模块，如 ThreadLocal 工具类、Result 返回类)
├── oj-model (实体类模块，POJO、DTO、VO)
├── oj-service (业务逻辑模块)
└── oj-web (入口模块，包含 Controller、启动类和配置文件)
```
## 父工程与子模块

### 父工程 (Parent POM)

父工程不写任何业务代码，只负责**聚合管理**和**依赖版本控制**。

- **打包方式**：必须设置为 `<packaging>pom</packaging>`。
    
- **聚合管理**：使用 `<modules>` 标签列出所有子模块。
    
- **版本管理**：使用 `<dependencyManagement>` 声明依赖，这样子模块引用时就无需写版本号，确保全项目版本统一。
    

### 子模块 (Child Module)

子模块专注于特定功能，并在 POM 中声明其父工程。

- **继承**：使用 `<parent>` 标签指向父工程。
    
- **依赖**：如果模块 A 需要用到模块 B 的功能，只需在 A 的 POM 中加入 B 的坐标

|**优势**|**说明**|
|---|---|
|**高复用性**|`oj-common` 或 `oj-model` 可以被其他项目（如管理后台、移动端 API）直接引用。|
|**职责清晰**|开发人员可以只关注自己负责的层级（如只开发 Service 层），减少代码冲突。|
|**构建灵活**|可以单独对某个模块进行编译、打包或测试，而不需要每次都跑全量任务。|
|**依赖解耦**|例如 `oj-model` 只需要基础的 Lombok 依赖，不需要引入 Web 相关的 Tomcat 或 Spring MVC 依赖。|

---
# 继承与聚合
## 继承
在 Maven 分模块开发中，**继承（Inheritance）** 是为了消除配置重复、统一管理项目资源的核心机制。它类似于 Java 类之间的继承：子工程可以继承父工程中定义的配置、依赖和插件
### 核心配置实现
#### 父工程

父工程通常不含逻辑代码，其 `pom.xml` 是整个项目的“指挥中心”。
```XML
<groupId>com.creat</groupId>
<artifactId>algorithm-oj</artifactId>
<version>1.0-SNAPSHOT</version>
<!-- 1. 打包方式必须是 pom -->
<packaging>pom</packaging>

<!-- 2. 使用 dependencyManagement 声明依赖（不实际引入） -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-dependencies</artifactId>
            <version>3.0.0</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### 子工程

子工程通过 `<parent>` 标签建立继承关系。
```XML
<parent>
    <groupId>com.creat</groupId>
    <artifactId>algorithm-oj</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>

<artifactId>oj-service</artifactId>

<dependencies>
    <!-- 引用父工程声明过的依赖，无需写版本号 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

|**特性**|**dependencies**|**dependencyManagement**|
|---|---|---|
|**作用**|**直接引入**依赖。|**声明**依赖版本，不实际引入。|
|**继承表现**|子工程**自动继承**，强制拥有。|子工程**按需引用**，不引用则没有。|
|**最佳实践**|用于所有模块都需要的依赖（如 Lombok）。|用于各模块可选的依赖（如 MySQL 驱动、Redis）。|


在 Maven 项目中，`<packaging>` 标签定义了项目的**打包方式**。这不仅决定了项目最终生成什么格式的文件，还决定了 Maven 构建生命周期的执行行为

|**维度**|**POM**|**JAR**|**WAR**|
|---|---|---|---|
|**产出物**|无（仅 pom 配置）|`.jar` 文件|`.war` 文件|
|**包含内容**|配置信息、子模块列表|字节码、配置文件|字节码、配置文件、静态资源、第三方库|
|**运行方式**|无法直接运行|`java -jar` 或被引用|部署在外部容器（Tomcat等）|
|**主要功能**|依赖管理与聚合|封装模块、类库、微服务|传统 Java Web 应用发布|
|**项目层级**|通常作为 **顶级父工程**|通常作为 **功能子模块**|通常作为 **Web 展现层模块**|
### 自定义属性
```XML
//父工程
<properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    
    <!-- 自定义版本号变量 -->
    <mybatis.version>3.5.11</mybatis.version>
    <lombok.version>1.18.24</lombok.version>
    <mysql.version>8.0.31</mysql.version>
</properties>

//引用属性（在依赖配置中）
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>${mybatis.version}</version>
</dependency>
```
## 聚合
```XML
<!--聚合工程-->  
<modules>  
    <module>../tlias-pojo</module>  
    <module>../tlias-utils</module>  
    <module>../tlias-web-managerment</module>  
</modules>
```
### 聚合的智能：反应堆

当你触发聚合构建时，Maven 会启动一个叫 **Reactor（反应堆）** 的机制。它有两个超能力：

1. **自动排序**：它会分析模块间的依赖关系。比如 `tlias-web-managerment` 依赖 `tlias-utils`，那么它会确保先构建 `tlias-utils`，再构建`tlias-web-managerment`，绝不会发生“找不到依赖”的错误。
    
2. **构建状态统计**：它会输出一个漂亮的表格，告诉你哪些模块成功了，整个过程花了多少时间。

|**维度**|**聚合 (Aggregation)**|**继承 (Inheritance)**|
|---|---|---|
|**关系方向**|**父知子**：父 POM 知道有哪些子模块。|**子知父**：子 POM 知道谁是自己的父工程。|
|**配置位置**|在父 POM 中配置 `<modules>`。|在子 POM 中配置 `<parent>`。|
|**核心目的**|**方便构建**（一键打包、清理）。|**减少配置**（共享依赖、版本控制）。|
|**物理路径**|父工程通常在子工程的**上一层**。|子工程通过 `<relativePath>` 寻找父 POM。|

---
# 私服
- 私服在架构中处于中间层
- 当项目需要某个依赖时，寻找路径如下：
	- **本地仓库** → **私服** → **远程中央仓库**
