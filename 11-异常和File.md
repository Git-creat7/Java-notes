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
## 捕获异常`try-catch`
```Java
	int[] arr = {1,2,3};  
	try{  
		//程序创建异常，与catch（）中的异常对比，可捕获 -> 执行catch{..}
		//当catch{..}执行完毕，继续向下执行
	    System.out.println(arr[10]);     
	}catch (ArrayIndexOutOfBoundsException e){  
	    System.out.println("数组越界了");  
	}  
	System.out.println("执行！");
```
### 常见问题
#### 如果`try`中没有遇到问题，怎么办？

> 会把`try`中的所有代码全部执行完毕，**不会执行**`catch`中的代码
> 
> **注意：** 只有出现了异常，才会执行`catch`

#### 如果`try`中可能遇到多个问题，怎么办？

>写多个`catch`与之对应
>
>**注意：** 如果捕获多个异常，父类一定要写在下面
>
>JDK7以后，可以用`catch`捕获多个异常，中间用`|`隔开


#### 如果`try`中遇到的问题没有被捕获，怎么办？

><u>JVM虚拟机默认处理异常</u>，会停止程序

#### 如果`try`中遇到了问题，那么`try`下面的其他代码块还会执行吗？

>**不会执行** ，会直接跳转到对应的`catch`

### 常用方法
| **方法名**                   | **返回值**  | **作用**                                                           |
| ------------------------- | -------- | ---------------------------------------------------------------- |
| **`e.getMessage()`**      | `String` | **简报**：只告诉你最简单的错误原因（如 "By zero"）。                                |
| **`e.toString()`**        | `String` | **中报**：异常类型 + 错误原因（如 `java.lang.ArithmeticException: / by zero`） |
| **`e.printStackTrace()`** | `void`   | **详报**：在控制台打印完整的堆栈信息，**最常用**                                     |
## 抛出处理
| **关键字**      | **位置** | **作用** | **后面跟什么**       |
| ------------ | ------ | ------ | --------------- |
| **`throws`** | 方法声明处  | 向上抛    | **异常类名**（可以跟多个） |
| **`throw`**  | 方法体内   | 制造异常   | **异常对象**（只能跟一个） |
- 运行时异常不需要`throws`声明
## 自定义异常
- 定义异常类
- 写继承关系
- 空参构造
- 带参构造

| 类型    | 继承 `Exception`（检查型）         | 继承 `RuntimeException`（非检查型） |
| ----- | --------------------------- | --------------------------- |
| 强制要求  | 必须用 try-catch 捕获，或声明 throws | 无需强制捕获，按需处理                 |
| 适用场景  | 必须处理的严重业务异常（比如文件读写失败）       | 普通业务异常（比如余额不足、用户不存在）        |
| 代码复杂度 | 高（到处加 try-catch）            | 低（只在需要处理的地方捕获）              |

---
# File
## 常用方法
| **类别** | **方法名**             | **返回值**   | **核心功能**       | **备注**                         |
| ------ | ------------------- | --------- | -------------- | ------------------------------ |
| **获取** | `getName()`         | `String`  | 获取文件或文件夹名称     | 带后缀名（如 `a.txt`）                |
|        | `length()`          | `long`    | 获取文件大小，文件夹为`0` | 单位是**字节 (Byte)**，UTF-8一个汉字三个字节 |
|        | `lastModified()`    | `long`    | 最后修改时间         | 毫秒值，需转换日期                      |
| **路径** | `getPath()`         | `String`  | 获取构造时传入的路径     | 怎么 `new`的就给什么                  |
|        | `getAbsolutePath()` | `String`  | 获取**绝对路径**     | 从盘符开始的全路径                      |
| **判断** | `exists()`          | `boolean` | 路径是否存在         | **最常用**，防报错必备                  |
|        | `isFile()`          | `boolean` | 是否为文件          | 路径不存在则返回 false                 |
|        | `isDirectory()`     | `boolean` | 是否为文件夹         | 路径不存在则返回 false                 |
| **创建** | `createNewFile()`   | `boolean` | 创建新文件          | 文件夹不存在会创建失败                    |
|        | `mkdirs()`          | `boolean` | **递归**创建文件夹    | 建议永远用带 s 的这个                   |
| **删除** | `delete()`          | `boolean` | 删除文件/空文件夹      | **不走回收站**，直接消失                 |
