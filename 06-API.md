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
![BigInteger](06-4.png)
##### BigInteger的成员方法
![成员方法](06-5.png)

---

#### BigDemical
**常用方法**
- 表示的数字不大(没有超出double) -> 使用静态方法
`public static BigDecimal valueOf(double val)`
- 表示的数字比较大(超出double) -> 使用构造方法
`BigDecimal bd = new BigDecimal(String val)`
>[!NOTE]
>如果传递的是[0,10]之间的数，那么方法会返回已经创建好的对象（不会new）

![常用方法](06-6.png)

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

### 正则表达式（regex）
- {begin,end} -->左开右闭
- \\\\d -->对应数字

