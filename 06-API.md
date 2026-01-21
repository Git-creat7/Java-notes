# API

**应用程序编程接口**  
API就是别人写好的东西，我们不需要自己编写，直接使用即可
例如：
	`Random  r  = new Random();`  
	`Scanner sc = new Scanner();`   

- Java API：JDK中提供的各种功能的Java类

## System
`public static void exit(int status) 终止当前运行的Java虚拟机`
`public static long currentTimeMillis() 返回当前系统的时间（毫秒）`
`public static void arraycopy(数据源数组,起始索引,目的地数组,起始索引,拷贝个数) 数组拷贝 （地址值）`

## Runtime
**Runtime表示当前虚拟机的运行环境**  
`public static		Runtime getRuntime() 当前系统的运行环境对象`  
`public void 	exit(int status)	停止虚拟机`  
`public int 	availableProcessors()	获取CPU线程数`  
`public long 	maxMemory()	 JVM能从系统中获取总内存大小byte`  
`public long	totalMemory()JVM已经从系统中获取总内存大小byte`  
`public long 	freeMemory() JVM剩余内存大小byte`
`public Process exec(String command)	运行cmd命令`

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

### 克隆clone
对象克隆：把A对象的属性值完全拷贝给B对象，也叫对象拷贝，对象复制

#### 第一种克隆方式（浅克隆）
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




![深克隆](image/06-2.png)





