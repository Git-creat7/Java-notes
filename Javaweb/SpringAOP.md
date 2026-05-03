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

- **切面 (Aspect)**：横切关注点的模块化（比如一个日志类）
    
- **连接点 (Join Point)**：程序执行过程中的某个点，在 Spring 中通常指**方法执行**
    
- **切入点 (Pointcut)**：定义**哪些方法**需要被拦截（比如：所有以 `save` 开头的方法）
    
- **通知 (Advice)**：拦截后要**执行的操作**（比如：在方法开始前记录时间）

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