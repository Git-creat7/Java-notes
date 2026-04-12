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
| **响应头字段**          | **含义说明**                                         |
| `Content-Type`     | 表示该响应内容的类型，例如`text/html`, `application/json`。    |
| `Content-Length`   | 表示该响应内容的长度（字节数）。                                 |
| `Content-Encoding` | 表示该响应压缩算法，例如`gzip`。                              |
| `Cache-Control`    | 指示客户端应如何缓存，例如`max-age=300`表示可以最多缓存 300 秒。        |
| `Set-Cookie`       | 告诉浏览器为当前页面所在的域设置 cookie。                         |