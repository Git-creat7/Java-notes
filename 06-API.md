# API

**应用程序编程接口**  
API就是别人写好的东西，我们不需要自己编写，直接使用即可
例如：
	`Random  r  = new Random();`  
	`Scanner sc = new Scanner();`   

- Java API：JDK中提供的各种功能的Java类

---

## System
`public static void exit(int status) 终止当前运行的Java虚拟机`
`public static long currentTimeMillis() 返回当前系统的时间（毫秒）`
`public static void arraycopy(数据源数组,起始索引,目的地数组,起始索引,拷贝个数) 数组拷贝 （地址值）`

---

## Runtime
**Runtime表示当前虚拟机的运行环境**  
`public static		Runtime getRuntime() 当前系统的运行环境对象`  
`public void 	exit(int status)	停止虚拟机`  
`public int 	availableProcessors()	获取CPU线程数`  
`public long 	maxMemory()	 JVM能从系统中获取总内存大小byte`  
`public long	totalMemory()JVM已经从系统中获取总内存大小byte`  
`public long 	freeMemory() JVM剩余内存大小byte`
`public Process exec(String command)	运行cmd命令`

---

## Object
`public boolean		equals(Objects obj) 比较地址值`  
`public String 		toString() 返回对象的字符串表示形式`  
`protected object clone(int a) 对象克隆`

```Java
		String s = "abc";
        StringBuilder sb = new StringBuilder("abc");
        System.out.println(s.equals(sb));//false
        
        *String中的equals方法会先判断参数是否为字符串*
        *是字符串再比较内部属性*
        
        System.out.println(sb.equals(s));//false
        *StringBuilder仅比较地址值*
        
        (String)
        public boolean equals(Object anObject) {
            if (this == anObject) {
                return true;
            }
            return (anObject instanceof String aString)
                    && (!COMPACT_STRINGS || this.coder == aString.coder)
                    && StringLatin1.equals(value, aString.value);
    	}
        
        (StringBuilder{Object的方法})
        public boolean equals(Object obj) {
        	return (this == obj);
    	}
```

---

### 克隆clone
对象克隆：把A对象的属性值完全拷贝给B对象，也叫对象拷贝，对象复制

#### 第一种克隆方式（浅克隆）
- **不管对象内部的属性是基本数据类型还是引用数据类型，都完全拷贝过来**
- Cloneable
- 如果一个接口里面没有抽象方法，表示当前的接口是一个可标记接口，现在Cloneable表示一旦实现了那么当前的对象就可以被克隆
- 如果没有实现，当前类的对象就不能克隆

```Java
public static void main(String[] args) throws CloneNotSupportedException {
        Student s1 = new Student("zhangsan",18);
        Object s2 = (Student)s1.clone();
        System.out.println(s1);//@23fc625e
        System.out.println(s2);//@3f99bd52
        System.out.println(s1 == s2);//false
}

	@Override（写在JavaBean中）
    protected Object clone() throws CloneNotSupportedException {
        return super.clone();
}

	/*	1.重写Object中的clone方法
		2.让JavaBean类实现Cloneable接口
		3.创建原对象调用clone	*/
```

![浅克隆](image/06-1.png)

>[!NOTE]
>浅克隆（引用数据类型）用的是相同的地址值，当其中一个对象修改该引用类型字段的内容时
>另一个对象也会受到影响，可能导致数据不一致的问题。

#### 第二种克隆方式（深克隆）
- 基本数据类型拷贝过来
- 字符串复用
- 引用数据类型会重新创建新的


![深克隆](image/06-2.png)
>[!NOTE]
>基本数据类型 ： 直接克隆对象
>引用数据类型 ： 创建一个新的对象
>注：String 深克隆时用串池地址（原地址），只有在改变后才会创建新String对象，因为String本身不可变
>**此时的data记录新数据的地址值**

![深克隆与浅克隆](image/06-3.png)

---

## Objects
`public static boolean equals(Object a,Object b)`**先做非空判断**，比较两个对象

`public static boolean isNull(Object obj)`判断对象是否为null，null->true

`public static boolean nonNull(Object obj)`判断对象是否为null，与isNull的结果相反 

```Java
import java.util.Objects;  
public class TestDemo {  
    public static void main(String[] args) throws CloneNotSupportedException {  
       Student s1 = null;  
       var s2 = new Student("zhangsan",23);  
       boolean res = Objects.equals(s1,s2);  
       System.out.println(res);  
       //方法的底层会判断n1 ?= null，如果为null，直接返回false  
       //如果s1不为null，那么就利用s1再次调用equals方法  
       //此时s1是Student类型，所以最终还是会调用Student中的equals方法  
       //未重写->比较地址值  重写->比较属性值  
    }  
}
```

---

## BigInteger和BigDecimal
#### BigInteger的构造方法
`public BigInteger(int num,Random rnd)`获取随机大整数，范围:[0~2的num次方-1]

`public BigInteger(String val)` 获取指定的大整数  

`public BigInteger(String val,int radix)`获取指定进制的大整数

`public static BigInteger valueOf(long val)`静态方法获取BigInteger的对象，内部有优化(-1~16,1~16)

>[!NOTE]
>对象一旦创建，内部的数据不能发生改变
```Java
BigInteger bd1 = new BigInteger.valueOf(1);
BigInteger bd2 = new BigInteger.valueOf(2);
BigInteger res  = bd1.add(bd2);//产生一个新对象
//res = 3;
```
![BigInteger](image/06-4.png)
##### BigInteger的成员方法
![成员方法](image/06-5.png)

---

#### BigDemical
**常用方法**
- 表示的数字不大(没有超出double) -> 使用静态方法
`public static BigDecimal valueOf(double val)`
- 表示的数字比较大(超出double) -> 使用构造方法
`BigDecimal bd = new BigDecimal(String val)`
>[!NOTE]
>如果传递的是[0,10]之间的数，那么方法会返回已经创建好的对象（不会new）

![常用方法](image/06-6.png)

> [!NOTE]
> 注：divide除法方法必须除尽，否则会报错

| 舍入模式    | 说明                      |
| :------ | :---------------------- |
| UP      | 远离**0方向**舍入的舍入模式(<- ->) |
| DOWN    | 靠近**0方向**舍入的舍入模式(-> <-) |
| CEILING | 向**正无穷大**方向舍入（ -> ）     |
| FLOOR   | 向**负无穷大**方向舍入 ( <- )    |
| HALF_UP | **四舍五入**                |

---

## 正则表达式（regex）
![regex](image/06-7.png)
![regex](image/06-8.png)


- `(?i)abcd`会忽略abcd的大小写
- `a(?i)bcd`会忽略bcd的大小写
- `a((?i)b)cd`会忽略b的大小写

---

## Date时间类
```Java
	//简单时间类
	Date d1 = new Date();//获取当前时间
	Date d2 = new Date(0L)//获取初始时间+0ms后的时间Thu Jan 01 08:00:00 CST 1970
	d2.getTime().sout;//0
	Date d3 = new Date(1000L)//获取初始时间+1000ms后的时间Thu Jan 01 08:00:01 CST 1970
	d3.getTime().sout;//1000
```
#### SimpleDateFormat类
- format格式化：把时间转换成指定格式
- parse解析：把字符串表示的时间变成Date对象
##### 构造方法
- ==`public SimpleDateFormat()`  使用默认格式==
```Java
	SimpleDateFormat sdf = new  SimpleDateFormat();  
	Date  date = new Date(0L);
	String str = sdf.format(date);  
	System.out.println(str);
	
	默认格式：1970/1/1 08:00 
```
- ==`public SimpleDateFormat(String Pattern)` 使用指定格式==
```Java
	SimpleDateFormat sdf = new  SimpleDateFormat("yyyy年MM月dd日 HH:mm:ss EEEE"); 
	Date  date = new Date(0L);  
	String str = sdf.format(date);  
	System.out.println(str);
	
	指定格式：1970年01月01日 08:00:00 星期四
```

| 字母    | 描述 (Description)   | 示例 (Output)    | 备注 (Note)                 |
| ----- | ------------------ | -------------- | ------------------------- |
| **G** | 年代标志 (Era)         | AD (公元)        | 通常用于历史日期                  |
| **y** | 年 (Year)           | 2026; 26       | `yy` 是两位年，`yyyy` 是四位年     |
| **u** | 纪元年 (Year)         | 2026           | 在 `java.time` 中比 `y` 更严谨  |
| **M** | **月份 (Month)**     | 07; Jul; July  | **大写**；`MM` 为数字，`MMM` 为缩写 |
| **L** | 独立月份 (Month)       | 7; July        | 常用于特定语言环境的格式化             |
| **d** | **月中天数 (Day)**     | 10; 05         | **小写**；该月中的第几天            |
| **D** | 年中天数 (Day)         | 189            | 该年中的第几天 (1-366)           |
| **E** | 星期 (Day in week)   | Tue; Tuesday   | 星期几的文本描述                  |
| **e** | 星期数字 (Day of week) | 2              | 1 (周一) 到 7 (周日)           |
| **a** | 上下午标记 (AM/PM)      | PM             | 上午或下午                     |
| **H** | **24小时制小时**        | 0-23           | **大写**；常用于服务器日志           |
| **h** | **12小时制小时**        | 1-12           | **小写**；需配合 `a` 使用         |
| **m** | **分钟 (Minute)**    | 30             | **小写**；不要和月份 `M` 搞混       |
| **s** | **秒 (Second)**     | 55             | 秒数                        |
| **S** | 毫秒 (Fraction)      | 978            | 毫秒或纳秒的零头                  |
| **n** | 纳秒 (Nano)          | 500000         | 仅限 Java 8+ 的 `java.time`  |
| **z** | 时区 (Time Zone)     | CST; PST       | 通用时区名称                    |
| **Z** | 时区偏移 (Offset)      | +0800          | RFC 822 格式                |
| **X** | ISO 8601 时区        | Z; +08; +08:00 | 现代 API 推荐使用的时区格式          |

##### 常用方法
- ==`public final String format(Date date)` 格式化（日期对象 -> 字符串)==
- ==`public Date parse(String source)` 解析（字符串 -> 日期对象）==
 
#### Calendar类
- Calendar代表了系统当前时间的日历对象，可以单独修改、获取事件中的年月日
- Calendar是一个抽象类，不能直接创建对象，需要通过一个静态方法获取到子类对象
![[image/06-10.png]]

##### get/set/add方法
```Java
	Calandar c = Calandar.getInstance();
	c.get(Calandar.YEAR);
	c.set(Calandar.YEAR,11)//实际为12月
	c.add(Calandar.YEAR,1)//实际为次年1月
```

| 数字  | 常量名                          | 含义  | 注意事项                  |
| :-- | :--------------------------- | :-- | :-------------------- |
| 1   | Calendar.YEAR                | 年   | -                     |
| 2   | Calendar.MONTH               | 月   | 从 0 开始。0表示1月，11表示12月。 |
| 5   | Calendar.DATE / DAY_OF_MONTH | 日   | 两个常量效果一样。             |
| 10  | Calendar.HOUR                | 小时  | 12小时制。                |
| 11  | Calendar.HOUR_OF_DAY         | 小时  | 24小时制。                |
| 12  | Calendar.MINUTE              | 分钟  | -                     |
| 13  | Calendar.SECOND              | 秒   | -                     |
| 7   | Calendar.DAY_OF_WEEK         | 星期  | 周日是1，周一是2，周六是7。       |

---
### LocalDateTime
** /* **
## 包装类
- 基本数据类型所对应的对象
### Integer
##### Integer缓存
- Java的Integer类内部实现了一个静态缓存池，用于存储特定范围内的整数值对应的Integer对象。
- 默认情况下，这个范围时-128至127。当通过Integer.valueOf(int)方法创建一个在这个范围内的整数对象时，并不会每次都生成新的对象实例，而是**复用缓存中的现有对象**，会直接从内存中取出，不需要新建一个对象。
- 目的：节约内存

##### JDK5以后
- 自动装箱、自动拆箱
- 直接赋值获取对象
- 计算时不需要new，不需要调用方法，直接赋值即可
```Java
	Integer i1 = 10;
	Integer i2 = 20;
	Integer i3 = i1 + i2;//底层：先拆箱 -> 计算 -> 再装箱赋值给i3
```

##### Integer成员方法
![[06-11.png]]



---
## Arrays
![[06-12.png]]
##### Arrays.binarySearch()
- 查找的元素存在，就返回真实的索引
- 查找的元素不存在，就返回( -插入点 - 1 )
```Java
	int[] a =  {1,2,3,4,5,6,7,8,9,10};
	Arrays.binarySearch(arr,10);//9
	Arrays.binarySearch(arr,100)//-11
```

---

##### Arrrays.copyOf()
- if(新数组len < 老数组len) 会部分拷贝
- if(新数组len = 老数组len) 会完全拷贝
- if(新数组len > 老数组len) 会补上默认初始值(int[] 补0)
```Java
	int[] a =  {1,2,3,4,5,6,7,8,9,10};
	int[] newa = Arrays.copyOf(a);
```

---

#### Arrrays.copyOfRange()
- 包左不包右（左闭右开）
```Java
	int[] a =  {1,2,3,4,5,6,7,8,9,10};
	int[] newa = Arrays.copyOfRange(a,0,9);
	//1 2 3 4 5 6 7 8 9
```

---
#### Arrays.fill()
```Java
	int[] a =  {1,2,3,4,5,6,7,8,9,10};	
	Arrays.fill(a,100);//100 100 100 ...
```

---
#### Arrays.sort()
- 对基本类型快速排序
```Java
	Arrays.sort(a);//升序
```
###### 重载
- 只能对引用数据类型排序
- o1：表示在无序序列中，遍历得到的每一个元素
- o2：表示有序序列中的元素
- 返回值
	- 负数：表示当前要插入的元素是小的，放在前面
	- 正数：表示当前要插入的元素是大的，放在后面
	- 0    ：一样大，放在后面
```Java
	Integer[] a =  {2,7,5,4,5,6,7,8,9,31};  
Arrays.sort(a,newComparator<Integer>() {  
	@Override  
	public int compare(Integer o1, Integer o2) {  
		return o1-o2;  
	}  
});
```
## Lambda表达式
- ( )对应方法的形参
- -> 固定格式
- { } 对应方法体
- ```Java
	Integer[] a =  {2,7,5,4,5,6,7,8,9,31};  
Arrays.sort(a,(Integer o1, Integer o2) -> {  
		return o1-o2;  
	}  
);
```
>[!NOTE]
>lambda 表达式可以用来简化匿名内部类的书写（不是所有）
>lambda 表达式只能简化函数式接口的匿名内部类写法
>
>函数式接口：
>- **有且仅有一个抽象方法的接口**，接口上方可以加@FunctionalInterface的注解

```Java
	Integer[] a =  {2,7,5,4,5,6,7,8,9,31};  
Arrays.sort(a,(Integer o1, Integer o2) -> {  
		return o1-o2;  
	}  
);

```
---
```Java
package MyTestDemo2;  
public class TestDemo{  
    public static void main(String[] args){  
        method(()->{  
            System.out.println("lambda:");  
            System.out.println("swimming");  
        });  
    }  
    public static void method(swim s){  
        s.swimming();  
    }  
}  
@FunctionalInterface
interface swim{  
    public void swimming();  
}
```
##### 可推导，可省略
```Java
	Integer[] a =  {2,7,5,4,5,6,7,8,9,31};  
	Arrays.sort(a,(o1,o2) -> o1-o2);//升序
	Arrays.sort(a,(o1,o2) -> o2-o1);//倒序
```
