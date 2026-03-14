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

- **中间方法：** 返回值**还是 Stream**（可以继续 `.filter()`、`.map()` 下去）

| **常用方法**       |  **功能**  | **备注**                                                   |
| -------------- | :------: | -------------------------------------------------------- |
| **`filter`**   |    过滤    | 接收 `Predicate`，返回 true 的留下。<u>修改Stream中的数据，不会影响原来的数据</u> |
| **`map`**      |   类型转换   | 把一种对象换成另一种（如把 `Student` 转成 `String` 姓名）                  |
| **`distinct`** |    去重    | 依赖对象的 `hashCode` 和 `equals`                              |
| **`limit(n)`** | 截取前 n 个` | 获取前几个元素（短路）                                              |
| **`skip(n)`**  | 跳过前 n 个  | 经常和 `limit` 组合做**分页**                                    |
| **`sorted`**   |    排序    | 自然排序或传 `Comparator`                                      |


- **终结方法**：返回值**不是 Stream**（变成 `void`、`long`、`List`、`Optional` 等），一旦调用，流彻底关闭

|**常用方法**|**功能**|**备注**|
|---|---|---|
|**`forEach`**|遍历|打印或消费数据|
|**`count`**|统计个数|返回 `long`|
|**`collect`**|**收集**|**最重要！** 把流转回 `List`, `Set`, `Map`|
|**`toArray`**|转数组|稍微有点生僻，通常用 `collect`|
|**`reduce`**|聚合|把所有数据累加/合成一个结果|
|**`anyMatch`**|匹配|只要有一个满足条件就返回 true|