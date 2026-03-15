# 异常
```mewmaid
Throwable（所有异常/错误的根类）
|
├─ Error（系统级致命错误，程序无法恢复）
│  ├─ OutOfMemoryError（内存溢出，如创建超大对象/无限集合）
│  └─ StackOverflowError（栈溢出，如无限递归调用）
│
└─ Exception（程序可处理的异常）运行时异常+编译时异常
   |
   ├─ RuntimeException（运行时异常/非检查型，编译器不强制捕获）
   |  |
   │  ├─ NullPointerException（空指针，调用null对象的方法/属性）
   │  ├─ IndexOutOfBoundsException（下标越界，如数组/集合下标超出范围）
   │  ├─ ClassCastException（类型转换异常，如String强转Integer）
   │  ├─ IllegalArgumentException（参数非法，如传入不符合规则的参数）
   │  └─ ArithmeticException（算术异常，如整数除以0）
   │
   |
   └─ CheckedException（检查型异常，编译器强制捕获/声明抛出）
	  |
      ├─ IOException（IO操作异常）
      │  └─ FileNotFoundException（文件未找到，如读取不存在的文件）
      ├─ SQLException（数据库操作异常，如SQL语法错误/连接失败）
      └─ InterruptedException（线程中断异常，如休眠线程被打断）
```
