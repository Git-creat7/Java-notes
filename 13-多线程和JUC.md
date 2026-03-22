+++
date = '2026-03-22'
draft = false
title = '13-多线程和JUC'
tags = []
categories = []
+++

> 本文更新于 2026-03-22

# 多线程
>1.**进程 (Process)**：运行中的程序（比如 IDEA、Chrome、QQ）。它是操作系统资源分配的最小单位。
  >  
>2.**线程 (Thread)**：进程中的一个“执行路径”。一个进程可以包含多个线程（比如 Chrome 里一个线程下载文件，一个线程渲染网页）。

## 并发和并行
| **维度**   | **并发 (Concurrency)** | **并行 (Parallelism)** |
| -------- | -------------------- | -------------------- |
| **核心特点** | 任务**交替**执行           | 任务**同时**执行           |
| **资源需求** | 单核 CPU 即可实现          | 必须**多核 CPU**         |
| **目的**   | 提高 CPU 利用率，解决“阻塞”    | 提高计算速度，缩短处理时间        |
| **关系**   | 并发不一定是并行             | 并行一定是并发的一种形式         |
![](13-多线程和JUC-1.png)
## 实现方式

### 继承`Thread`类
```Java
public class MyThread extends Thread {
    @Override
    public void run() {
        for (int i = 0; i < 100; i++) {
            System.out.println(getName() + " 在运行: " + i);
        }
    }
}
	// 启动：new MyThread().start();
	优点:代码简单，直接 `this` 就能获取线程名。
	缺点：Java 是单继承，继承了 Thread 就不能继承别的类了。
```
## 实现`Runnable`接口
```Java
public class MyRun implements Runnable {
    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + " 执行中");
    }
}
	// 启动：new Thread(new MyRun()).start();
	优点：扩展性强，可以实现接口的同时继承别的类；适合多个线程处理同一个资源。
```
## 实现`Callable`接口
```Java
public class MyCallable implements Callable<Integer> {
    @Override
    public Integer call() throws Exception {
        return 100 + 200; // 返回计算结果
    }
}
	// 启动需配合 FutureTask
	特点：可以获取线程执行后的结果，还能抛出异常。
	
```
## 成员方法
| **方法名**                    | **说明**          | **备注**                    |
| -------------------------- | --------------- | ------------------------- |
| **`setName(String name)`** | 设置线程名称          | 默认是 `Thread-0,Thread-1` 等 |
| **`getName()`**            | 获取线程名称          | 建议在构造时就起好名字               |
| **`getPriority()`**        | 获取线程优先级         | 范围 1-10，默认 5              |
| **`setPriority(int p)`**   | 设置线程优先级         | 优先级越高，抢到 CPU 时间片的**概率**越大 |
| **`currentThread()`**      | **静态方法**，获取当前线程 | 哪条线程执行这行代码，就返回谁           |









### 状态控制方法

这些方法直接影响线程的运行节奏，是多线程编程的核心。
#### ① `sleep(long ms)`：线程休眠

- **类型**：静态方法。
    
- **作用**：让当前线程进入“阻塞状态”指定的时间。
    
- **特点**：**不释放锁**（如果你拿着钥匙睡觉，别人依然进不来）。
    
- **应用**：在拼图游戏中，如果想制作一个“倒计时”或“动画间隔”，就用它。
    
#### ② `yield()`：线程让步

- **类型**：静态方法。
    
- **作用**：暗示 CPU 当前线程愿意让出执行权。
    
- **特点**：线程从“运行”回到“就绪”状态。CPU 可能会再次选中它，也可能选中别人。这是一种**谦让**，不是强制停止。
    
#### ③ `join()`：线程插队

- **类型**：成员方法。
    
- **作用**：在 A 线程中调用 `B.join()`，意味着 A 必须等 B 执行完，A 才能继续。
    
- **类比**：你在排队买饭，突然一个 VIP（B 线程）插到了你前面，你必须等他买完。
