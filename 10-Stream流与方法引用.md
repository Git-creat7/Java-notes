# Stream流的思想和获取Stream流
- **比喻：** Stream 是流水线，不存数据
- **作用：** 结合Lambda表达式，简化集合、数组操作

| 类型         | 获取Stream流              |
| ---------- | ---------------------- |
| List       | `.stream()`            |
| Map        | `.entrySet().stream()` |
| 数组         | `Arrays.stream(数组)`    |
| Set        | `.stream()`            |
| 零散数据（同种类型） | `Stream.of(数据)`        |

```Java
	//List-------------------------//
	ArrayList<String> list = new ArrayList<>();  
	Collections.addAll(list, "Java", "Python", "C++", "JavaScript", "Ruby");  
	list.stream()  
	    .filter(s -> s.length() > 4)  
	    .forEach(System.out::println);  
	    
	//Map--------------------------//
	HashMap<String, Integer> map = new HashMap<>();  
	map.put("aaa", 111);  
	map.put("bbb", 222);  
	map.put("ccc", 333);  
	  
	map.entrySet().stream()  
	        .filter(e -> e.getValue() == 333)  
	        .forEach(e -> System.out.println(e.getKey() + " = " + e.getValue()));  
	        
	map.keySet().stream()  
        .filter(k -> map.get(k) == 333)  
        .forEach(k -> System.out.println(k + " = " + map.get(k)));  
              
	//数组---------------------------//
	int[] arr = {1,2,3,4,5,6,7,8,9,10};  
	Arrays.stream(arr)  
	        .filter(n-> n==1)  
	        .forEach(System.out::println);
	        
	//零散数据-----------------------//
	Stream.of(1,2,3,4,5,6,7,8,9,10)  
        .filter(n-> n==1)  
        .forEach(System.out::println);
```
**`Stream.of`的注意事项**
- **数组必须是引用数据类型！！！**
```Java
String[] sArr = {"a", "b"};
Stream.of(sArr); // 得到流 [a, b]，长度 2

int[] iArr = {1, 2};
Stream.of(iArr); // 得到流 [[1, 2]]，长度 1！它把整个数组当成了一个元素
```

## 中间方法和终结方法

### 中间方法
-  返回值**还是 Stream**（可以继续 `.filter()`、`.map()` 下去）

| **常用方法**       |  **功能**  | **备注**                                                                                |
| -------------- | :------: | ------------------------------------------------------------------------------------- |
| **`filter`**   |    过滤    | 接收 `Predicate`，返回 true 的留下。<u>修改Stream中的数据，不会影响原来的数据</u>                              |
| **`map`**      |   类型转换   | 把一种对象换成另一种（如把 `Student` 转成 `String` 姓名）`.map(s -> Integer.parseInt(s.split("-")[1]))` |
| **`distinct`** |    去重    | 依赖对象的 `hashCode` 和 `equals`                                                           |
| **`limit(n)`** | 截取前 n 个` | 获取前几个元素（短路）                                                                           |
| **`skip(n)`**  | 跳过前 n 个  | 经常和 `limit` 组合做**分页**                                                                 |
| **`sorted`**   |    排序    | 自然排序或传 `Comparator`                                                                   |
| **`concat`**   |    合并    | 将a和b两个流合并成一个集 合。`Stream.concat(list1.stram(),list2.stream())`                         |


### 终结方法
- 返回值**不是 Stream**（变成 `void`、`long`、`List`、`Optional` 等），一旦调用，流彻底关闭

| **常用方法**      | **功能**    | **备注**                             |                                                                   |
| ------------- | --------- | ---------------------------------- | ----------------------------------------------------------------- |
| **`forEach`** | 遍历        | 打印或消费数据                            | `.forEach()`                                                      |
| **`count`**   | 统计个数      | 返回 `long`                          | `.count`                                                          |
| **`collect`** | **收集**转集合 | **最重要！** 把流转回 `List`, `Set`, `Map` | `.collect(Collectors.toList())`<br>`.collect(Collectors.toSet())` |
| **`toArray`** | **收集**转数组 | 收集流中的数据，放到数组中                      | `.toArray(n -> String[n])`<br>`.toArray(String[]::new)`           |
| `reduce`      | 聚合        | 把所有数据累加/合成一个结果                     |                                                                   |
| `anyMatch`    | 匹配        | 只要有一个满足条件就返回 true                  |                                                                   |
|               |           |                                    |                                                                   |
#### collect收集到Map中
```Java
	/*
		toMap()：参数一表示键的生成规则
				 参数二表示值的生成规则
		
		Function：泛型一表示流中每一个数据的类型
				  泛型二表示Map集合中 键/值 的数据类型
				  
		apply形参：依次表示流里面的每一个数据
			 方法体：生成 键/值 的代码
			 返回值：已经生成的 键/值
	*/
	例：数据格式为 name - gender - age
	Map<String, Integer> map = 
		list.stream()
			.filter(s -> "男".equals(s.spilt("-")[1]))
			.collect(Collectors.toMap(new Function<流的类型,键的类型>(){
					@Override
					public String apply(String s){
						return s.split("-")[0];//name
						//return null;
					}
				},new Function<流的类型,值的类型>(){
						@Override
						public Integer apply(String s){
							return Integer.parseInt(s.split("-")[2]);//age
							//return null;
						}
					}));
	//----------lambda-----------//				
	Map<String, Integer> map = list.stream()  
        .filter(s -> "男".equals(s.split("-")[1]))  
        .collect(Collectors.toMap(s->s.split("-")[0],
					s-> Integer.parseInt(s.split("-")[2])));  
	
```
>[!WARNING]
>如果要收集到Map集合当中，**<u>键不能重复</u>**


# 方法引用

> **方法引用前提：**
> 
> 1. **接口对路**：必须是函数式接口。
>     
> 2. **坑位对齐**：参数、返回值必须和接口方法一模一样。
>     
> 3. **现成逻辑**：逻辑已存在(被引用方法满足当前需求),且 Lambda 内部**只有**这一行调用。

| **类型**       | **格式**      | **例子 (Lambda -> 方法引用)**                                          |
| ------------ | ----------- | ---------------------------------------------------------------- |
| **静态方法引用**   | `类名::静态方法`  | `s -> Integer.parseInt(s)` $\rightarrow$ `Integer::parseInt`     |
| **实例方法引用**   | `对象名::成员方法` | `s -> System.out.println(s)` $\rightarrow$ `System.out::println` |
| **特定类型实例方法** | `类名::成员方法`  | `(s1, s2) -> s1.compareTo(s2)` $\rightarrow$ `String::compareTo` |
| **构造方法引用**   | `类名::new`   | `name -> new Student(name)` $\rightarrow$ `Student::new`         |
## 引用成员方法的多种情况
- **其他类：** `其它类对象::方法名`
- **本类：** `this::方法名` 
- **父类：** `super::方法名`
>[!WARNING]
> 当**本类,父类**的引用处为静态方法时，不可用this/super，应当先创建本类对象
```Java
public class Daily {  
    public static void main(String[] args) {  
        ArrayList<String> list = new ArrayList();  
        Collections.addAll(list, "张三", "李四", "王五", "张六一", "孙而七");  
        
	    //当方法在本类中，方法为static，创建本类对象
        list.stream().filter(new Daily()::stringJudge)  
                .forEach(System.out::println);      
    }  
	public boolean stringJudge(String s) {...} 
}
 ```
```Java
class Parent {  
    public boolean stringJudge(String s) {  
        return s.startsWith("张");  
    }  
}  
  
class Daily extends Parent {  
    @Override  
    public boolean stringJudge(String s) {  
        return s.startsWith("张") && s.length() == 3;  
    }  
  
    public void test(List<String> list) {  
        // 调子类重写后的方法  
	    list.stream().filter(this::stringJudge)
		    .forEach(System.out::println);  
  
        // 强制调父类版本  
	    list.stream().filter(super::stringJudge)
		    .forEach(System.out::println);  
    }  
}
```

## 构造方法的引用
```Java

	ArrayList<String> list = new ArrayList();  
	Collections.addAll(list, "张三,13", "李四,46", "王五,15");  
	List<Student> list1 = 
		list.stream()  
			//这里必须在Student中新建一个构造方法
			.map(Student::new)  
			.collect(Collectors.toList());
    /*在Student中
	*    public Student(String s){  
	*	    this.name = s.split(",")[0];  
	*	    this.age = Integer.parseInt(s.split(",")[1]);
	*	 }
    */
```
## 其他调用方式

### 类名引用成员方法 `类名::成员方法`
>**独有的规则**
>
>被引用方法的形参，需要跟抽象方法的第二个形参到最后一个形参保持一致，返回值需要保持一致 

>**抽象方法形参的详解：**
>**第一个参数：** 
>	表示被引用方法的调用者，决定了可以引用那些类中的方法
>	在`Stream`流当中，第一个参数一般都表示流里面的每一个数据
>	假设流里面的数据是字符串，那么使用这种方式进行方法引用，只能引用`String`这个类中的方法
>
>**第二个参数到最后一个参数：**
>	跟被引用方法的形参保持一致，<u>如果没有第二个参数，说明被引用的方法需要时无参的成员方法</u>

**例子：`String::substring(int beginIndex)`**

- 这个方法括号里只有 **1 个** 参数。
    
- 但它是一个成员方法，需要 **1 个** 调用者。
    
- 所以这个方法引用，要求 Lambda 必须提供 **2 个** 参数：
    
    - 第一个参数：必须是 `String`（调用者）。
        
    - 第二个参数：必须是 `int`（对应 `beginIndex`）。
        
- **Lambda 原型**：`(String s, int i) -> s.substring(i)`

**总结：** “类名::成员方法”之所以看起来参数少了一个，是因为第一个参数被拿去“点”那个方法了。

```Java
	ArrayList<String> list = new ArrayList();  
	Collections.addAll(list, "aaa", "bbb", "ccc", "ddd");  
	list.stream()  
			//拿着流里面的每一个数据，去调用String类中的方法
	        .map(String::toUpperCase) //s -> s.toUpperCase()
	        .forEach(System.out::println);
```

### 引用数组的构造方法 `数据类型[]::new`
```Java
	Integer[] array = list.stream()
		.toArray(Integer[]::new);//v -> new Integer[v]
```
>[!IMPORTANT]
>数组的类型，需要跟流中数据一致

## 常犯错误

**Stream 中的参数分配法则：** 流里的数据总得有个去处。

1. 要么当**参数**：喂给静态方法或构造器（如 `Student::new`）。
    
2. 要么当**主人**：自己调用成员方法（如 `Student::getName`）。
    
**报错的原因**：通常是因为你既提供了一个主人（`new Student()`），又想让流里的数据当参数，结果方法不收参数，数据就“没地方放”了。