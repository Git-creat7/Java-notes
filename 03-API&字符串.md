# API
**应用程序编程接口**  
API就是别人写好的东西，我们不需要自己编写，直接使用即可
例如：
	`Random  r  = new Random();`  
	`Scanner sc = new Scanner();`   
- Java API：JDK中提供的各种功能的Java类

# 字符串
## String
**字符串在内存中存储的是地址**  

### 创建String对象的两种方式
１．直接赋值
	`String name = "MyString"`  
2.使用new关键字构造

```Java
	//空参构造
	String s1 = new String(); 		// 空
	
	//传递一个字符串，根据传递的字符串内容再创建一个新的字符串对象
	String s2 = new String("abc"); 	//abc
	
	//*传递一个字符数组，根据一个字符数组的内容，创建一个新的字符串
	char[] ch = {'a','b','c','d'};
	String s3 = new String(ch);		//abcd
	
	//*传递一个字节数组，根据一个字节数组的内容，创建一个新的字符串
	byte[] bytes = {97,98,99,100}; //传递ASCII码
	String s4 = new String(bytes);  //abcd
	
```

---

### 字符串的比较
​	先了解"=="比较的是什么，在~~基本数据类型~~中"=="比较的是具体的**数据值**，但是在~~引用数据类型~~中，"=="比的是**地址值**，所以在字符串的比较中不能用 "=="。
```Java
	String s1 = "abc";
	String s2 = "abc";
	sout(s1 == s2);  // true
	
	String s1 = new String("abc");//记录堆里面的地址值
	String s2 = "abc";			  //记录串池中的地址值
	sout(s1 == s2); // false
```
#### equals 与 equalsIgnoreCase
- boolean equals 方法：**完全一样结果才是true**

- boolean equalsIgnoreCase方法：**忽略大小写的比较**  
	<u>（忽略大小写只能是英文状态下的）</u>  
	`	boolean bool = s1.equals(s2)`
```Java
		Scanner sc = new Scanner(System.in);
		String str1 = sc.next(); //abc
		String str2 = "abc";	//赋值
		Souy(str1 == str2) //false
```
> [!NOTE]
>
> 两者不一样，键盘录入得到的字符串其实是new出来的，两者的地址值不一样，因此一定要用equals比较字符串  

---

### 遍历字符串
 - `public charAt(int index)`   根据索引返回字符
 - `public int length()` 	   返回此字符串的长度 


- `String substring(int beginindex, int endlindex)`  截取字符串  
> [!NOTE]
> 包头不包尾，包左不包右 ，对原字符拆没影响
> 重构：`String substring (int beginindex)`  截取到末尾  
---

### 替换字符串
 - `String replace(旧值，新值)` 替换
## StringBulider
- **提高字符串的操作效率**  
### StringBuilder 常用方法
- `public StringBulider()` 
创建一个空白可变的字符串对象，不含有任何内容  

> [!NOTE]
>*StringBuilder 是 Java 已经写好的类*
>*Java在底层对他做了一些特殊处理*
>*打印对象不是**地址值**而是**属性值***


----------------

- `public StringBuilder append(任意类型)`
添加数据，返回对象本身

- `public StringBuilder reverse()` 
反转容器中的内容  

- `public int length()`
返回长度（字符出现的个数）

- `public String toString()`
  通过toString()就可以实现把 StringBuilder 转化为 String

~~**以下是对于StringBuilder 和 toString的演示**~~

```java
		// 此时并不是字符串
    	StringBuilder sb = new StringBuilder("abc");

        sb.append("111");
        sb.append("222");

        //再将 StringBuilder 变回字符串
        String str = sb.toString();
        System.out.println(str);
```

> [!TIP]
>**补充** 链式编程：当我们在调用一个方法的时候，不需要用变量接收他的结果，可以继续调用其他方法。
>
>例如：`int len getString().substring(1).replace("A","Q").length()`

---
## StringJoiner
- StringJoiner 跟 StringBuilder 一样，也可以看成是一个容器，创建之后里边的内容是可变的。
- 作用：提高字符串的操作效率，而且代码编写特别简介，但是目前市场很少有人用  
- **JDK8才出现**

### StringJoiner  的构造方法
- `public StringJoiner(间隔符号)`  创建一个StringJoiner对象,指定拼接时的**间隔符号**  
- `public StringJoiner(间隔符号,开始符号,结束符号)` 创建一个StringJoiner对象，指定拼接时的**间隔符号,开始符号,结束符号**  

### StringJoiner 的成员方法
- `public StringJoiner add(添加的内容)` 添加数据，并返回数据本身
- `public int length()` 返回长度（字符出现的个数）
- `public String toString()` 返回一个字符串（该字符串就是拼接之后的效果）  

---

## 字符串原理

1.字符串存储的原理
	- 直接赋值会复用字符串常量池中的
	- new 出来的不会复用，而是开辟一个新的空间  

2.==号比较的到底是什么？
	- 基本数据类型 **比较数据值**
	- 引用数据类型 **比较地址值**

3.字符串拼接的底层原理

```Java
    public class Test2 {
        public static void main(String[] args) {
             String ss = "abc"; // 记录串池中的地址值
            String s = "a" + "b" + "c"; //拼接时没有变量,会复用串池中的字符串
           
            System.out.println(s); //abc
        }
    }
```

> [!NOTE]
> 拼接的时候没有变量，都是字符串
> 触发字符串的优化机制
> 在编译的时候就已经是最终结果了。
>
> 在编译的时候，就会将"a"+"b"+"c" 拼接为 "abc"...

```java
public class Test2 {
    public static void main(String[] args) {
        String s1 = "a";
        String s2 = s1 + "b"; 
        String s3 = s2 + "c";
        System.out.println(s3);
    }
}
```
> [!NOTE]
> 相当于先创建了一个new StringBuilder 对象
> 做完一系列操作后在使用 toString 转化为字符串
> new StringBuilder().append(s1).qppend("b").toString();
```Java
    public class Test2 {
        public static void main(String[] args) {
            String s1 = "a";
            String s2 = "b"; 
            String s3 = "c";
            String s4 = s1 + s2 + s3 ; //创建了四个SB对象
            System.out.println(s3);
        }
    }
```
>[!NOTE]
>JDK8 之前：每次以上的字符串相加都会创建两个SB对象
>JDK8 及之后，编译器会对连续的字符串拼接操作进行优化，通过一个StringBuilder完成所有拼接，并预先计算和分配合适的容量，从而减少对象创建和数组扩容的开销。

**总结：**

- **如果没有变量参与，都是字符串直接相加，编译之后就是拼接的结果，会复用字符串池**

- **如果有变量参与，每一行拼接的代码，都会在内存中创建新的字符串，浪费内存**  

4.StringBuilder 提高效率原理图

- 所有要拼接的内容都会往StringBuilder中放，不会创建很多无用空间，节约内存

5.StringBuilder 源码分析
- 默认创建一个长度为16的字节数组
- 添加的内容长度小于16，直接存
- 添加的内容大于16 会扩容（原来的容量*2+2）
- 如果扩容后还不够，以实际长度为准

---

 ## 补充内容
 `startsWith("String") 或 startsWith("String",begin,end)`检测字符串（范围）开头





