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