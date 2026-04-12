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