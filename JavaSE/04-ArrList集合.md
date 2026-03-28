# 集合
**类似于vector**  
>[!NOTE]
>集合的每个位置存储的是地址值
## ArrayList

### 成员方法（增删改查）
- `boolean add(E e)` 添加元素，返回值表示是否添加成功
一般直接用`list.add(E e)`，因为只要添加就会返回**true**

- `boolean add(E e)` 删除指定元素，返回值代表是否删除成功
优先删除索引小的元素

- `E remove(int index` 删除指定索引的元素，返回被删除的元素

- `E set(int index,E e)` 修改指定索引下的元素，返回原来的元素

- `E get(int index)` 获取指定索引的元素

- `int size()` 集合的长度

---

#### 基本数据类型对应的包装类
- byte ---> Byte
- short ---> Short
- **char ---> Character**
- **int --- > Integer**
- long ---> Long
- float ---> Float
- double ---> Double
- boolean ---> Boolean

---





