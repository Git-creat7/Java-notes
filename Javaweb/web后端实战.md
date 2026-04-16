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


