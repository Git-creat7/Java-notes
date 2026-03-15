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
>