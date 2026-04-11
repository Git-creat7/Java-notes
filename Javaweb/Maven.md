+++
date = '2026-04-10'
draft = false
title = 'Maven'
tags = []
categories = ["JavaWeb"]
+++

> 本文更新于 2026-04-10

- 用于管理和构建Java项目的工具
- 拥有本地仓库，中央仓库，远程仓库（私服）
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
### 断言`assert`与注解
