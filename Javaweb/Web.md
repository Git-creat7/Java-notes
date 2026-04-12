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
#### ① 请求行 (Request Line)

包含三个核心信息：

- **请求方法**：`GET`、`POST`、`PUT`、`DELETE` 等。
    
- **资源路径**：例如 `/api/v1/users`。
    
- **协议版本**：通常是 `HTTP/1.1` 或 `HTTP/2`。
    

> 示例：`POST /login HTTP/1.1`

#### ② 请求头 (Request Headers)

用键值对（`Key: Value`）的形式告知服务器客户端的环境、权限以及**数据格式**。常见头信息：

- **`Host`**: 服务器域名。
    
- **`User-Agent`**: 客户端浏览器或系统信息。
    
- **`Content-Type`**: **最重要的字段**，告诉服务器请求体里装的是什么格式的数据（如 JSON 或表单）。
    
- **`Authorization`**: 携带 Token 进行登录校验。
    

#### ③ 空行 (Empty Line)

必须存在的一行空行，用于分隔“报头”和“数据体”。

#### ④ 请求体 (Request Body)

真正传输的数据。注意：`GET` 请求通常没有请求体（参数放在 URL 后），而 `POST`、`PUT` 请求通常将数据放在这里。

---

## 请求数据获取

## 响应协议