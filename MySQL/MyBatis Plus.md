+++
date = '2026-05-21'
draft = false
title = 'MyBatis Plus'
tags = []
categories = ["MySQL"]
+++

> 本文更新于 2026-05-21

# 简介
**MyBatis Plus**（简称 MP）是基于 MyBatis 的**增强工具**，秉承“**只做增强不做改变**”的原则，在原 MyBatis 的基础上提供了大量开箱即用的 CRUD 能力。

特性：
- **无侵入**：只做增强不做改变，引入它不会对现有工程产生影响。
- **内置通用 Mapper**：少量配置即可实现单表大部分 CRUD 操作。
- **内置代码生成器**：可一键生成 Entity、Mapper、Service、Controller。
- **内置分页插件**：基于 MyBatis 物理分页，开发者无需关心具体方言。
- **支持 Lambda**：通过 Lambda 表达式编写查询条件，告别字段名硬编码。
- **支持主键自动生成**：支持 4 种主键策略，可自由配置。

---

# 入门使用
## 引入依赖
基于 SpringBoot 3.x 工程，使用 `mybatis-plus-spring-boot3-starter`：
```XML
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-spring-boot3-starter</artifactId>
    <version>3.5.7</version>
</dependency>
```
SpringBoot 2.x 工程使用 `mybatis-plus-boot-starter`。

> [!WARNING] 注意
> MP 的 starter 已经包含了 mybatis 和 mybatis-spring，**无需重复引入**，否则可能产生版本冲突。

## 基础配置
`application.yml`：
```yaml
spring:
  datasource:
    driver-class-name: com.mysql.cj.jdbc.Driver
    url: jdbc:mysql://localhost:3306/mp_db?useSSL=false&serverTimezone=UTC
    username: root
    password: 123456

mybatis-plus:
  configuration:
    # 开启 SQL 日志，便于调试
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
  global-config:
    db-config:
      # 全局主键策略
      id-type: auto
      # 全局逻辑删除字段
      logic-delete-field: deleted
      logic-delete-value: 1
      logic-not-delete-value: 0
  # XML 映射文件位置（如果需要写自定义 SQL）
  mapper-locations: classpath*:/mapper/**/*.xml
  type-aliases-package: org.example.pojo
```

## 快速上手
**实体类**：
```Java
@Data
public class User {
    private Long id;
    private String username;
    private String password;
    private String name;
    private Integer age;
}
```

**Mapper 接口**：继承 `BaseMapper<T>` 即可获得 CRUD 能力，无需写任何 SQL。
```Java
@Mapper
public interface UserMapper extends BaseMapper<User> {
}
```

**测试**：
```Java
@Autowired
private UserMapper userMapper;

@Test
public void testSelectAll() {
    List<User> users = userMapper.selectList(null); // null 表示无条件
    users.forEach(System.out::println);
}
```

---

# 常用注解
MP 通过实体类上的注解，建立 Java 对象与数据库表的映射关系。

## @TableName
指定实体类对应的**表名**。如果实体类名和表名一致（忽略大小写、驼峰转下划线），可省略。
```Java
@TableName("tb_user") // 表名为 tb_user
public class User { ... }
```

## @TableId
标注**主键字段**，并指定主键生成策略。
```Java
@TableId(value = "id", type = IdType.AUTO)
private Long id;
```

| **IdType** | **说明** |
| --- | --- |
| `AUTO` | 数据库 ID 自增（依赖数据库自增列） |
| `NONE` | 未设置主键策略（跟随全局配置） |
| `INPUT` | 由用户手动输入 |
| `ASSIGN_ID` | **默认值**。雪花算法生成 Long 类型 ID |
| `ASSIGN_UUID` | 分配 UUID（字段类型为 String） |

## @TableField
标注**普通字段**的特殊行为。

```Java
@TableField("user_name")           // 指定列名
private String username;

@TableField(exist = false)         // 该字段不是表中的列，仅业务使用
private String tempInfo;

@TableField(select = false)        // 查询时不返回该字段（如密码）
private String password;

@TableField(fill = FieldFill.INSERT)         // 插入时自动填充
private LocalDateTime createTime;

@TableField(fill = FieldFill.INSERT_UPDATE)  // 插入和更新时自动填充
private LocalDateTime updateTime;
```

> [!NOTE] 命名规则
> MP 默认将**驼峰命名**自动转换为**下划线命名**：`createTime` → `create_time`。如果数据库列名遵循该规则，无需 `@TableField` 显式指定。

---

# BaseMapper 核心方法
继承 `BaseMapper<T>` 后即可调用以下方法，**无需写任何 SQL**。

## 插入
```Java
int insert(T entity);  // 返回受影响行数；自增主键会回写到 entity.id
```

## 删除
```Java
int deleteById(Serializable id);                       // 根据主键删
int deleteByMap(Map<String, Object> columnMap);        // 根据 Map 条件删
int delete(Wrapper<T> wrapper);                        // 根据条件构造器删
int deleteBatchIds(Collection<? extends Serializable> ids); // 批量删
```

## 修改
```Java
int updateById(T entity);                  // 根据主键更新（非空字段才会更新）
int update(T entity, Wrapper<T> wrapper);  // 根据条件更新
```

## 查询
```Java
T selectById(Serializable id);                          // 根据主键查
List<T> selectBatchIds(Collection<? extends Serializable> ids);  // 批量查
List<T> selectByMap(Map<String, Object> columnMap);     // Map 条件查
List<T> selectList(Wrapper<T> wrapper);                 // 条件查（多条）
T selectOne(Wrapper<T> wrapper);                        // 条件查（一条）
Long selectCount(Wrapper<T> wrapper);                   // 计数
IPage<T> selectPage(IPage<T> page, Wrapper<T> wrapper); // 分页查
```

---

# 条件构造器 Wrapper
Wrapper 是 MP 的**核心特性**，用于构造灵活的 WHERE 条件。

## 类继承体系
- `Wrapper`（顶层抽象）
  - `AbstractWrapper`
    - `QueryWrapper`：查询条件 + 指定列
    - `UpdateWrapper`：更新条件 + set 子句
  - `AbstractLambdaWrapper`（**推荐**，避免硬编码字段名）
    - `LambdaQueryWrapper`
    - `LambdaUpdateWrapper`

## 常用条件方法
| **方法** | **说明** | **示例 SQL** |
| --- | --- | --- |
| `eq` | 等于 = | `name = 'Tom'` |
| `ne` | 不等于 != | `age != 18` |
| `gt` / `ge` | 大于 / 大于等于 | `age > 18` |
| `lt` / `le` | 小于 / 小于等于 | `age < 18` |
| `between` | between A and B | `age between 18 and 30` |
| `like` / `notLike` | 模糊查询 | `name like '%T%'` |
| `likeLeft` / `likeRight` | 左/右模糊 | `name like '%T'` |
| `isNull` / `isNotNull` | 判空 | `name is null` |
| `in` / `notIn` | 包含 | `id in (1,2,3)` |
| `orderByAsc` / `orderByDesc` | 排序 | `order by age desc` |
| `groupBy` | 分组 | `group by dept_id` |
| `having` | 分组过滤 | `having sum(age) > 100` |
| `or` / `and` | 拼接 | — |
| `select` | 指定查询列 | `select id, name` |
| `last` | 拼接 SQL 末尾（**慎用，有注入风险**） | `limit 10` |

## QueryWrapper 示例
查询：年龄在 18-30 之间，姓名包含 "张"，按年龄降序排列。
```Java
QueryWrapper<User> wrapper = new QueryWrapper<>();
wrapper.between("age", 18, 30)
       .like("name", "张")
       .orderByDesc("age");
List<User> users = userMapper.selectList(wrapper);
```

## LambdaQueryWrapper（推荐）
使用方法引用代替字符串字段名，**编译期检查**，重构友好。
```Java
LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.between(User::getAge, 18, 30)
       .like(User::getName, "张")
       .orderByDesc(User::getAge);
List<User> users = userMapper.selectList(wrapper);
```

或使用链式构造器 `Wrappers`：
```Java
List<User> users = userMapper.selectList(
    Wrappers.<User>lambdaQuery()
        .between(User::getAge, 18, 30)
        .like(User::getName, "张")
        .orderByDesc(User::getAge)
);
```

## 条件判断 condition 参数
所有条件方法都有重载版本，第一个参数为 `boolean condition`。当 condition 为 `false` 时，**该条件不会被拼接**，省去手写 `if` 判空。
```Java
String name = "张";
Integer minAge = null;

LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.like(StringUtils.hasText(name), User::getName, name)  // name 非空才拼接
       .ge(minAge != null, User::getAge, minAge);              // minAge 非 null 才拼接
```

## UpdateWrapper 示例
更新：将年龄大于 60 岁的用户密码全部置为 "expired"。
```Java
LambdaUpdateWrapper<User> wrapper = new LambdaUpdateWrapper<>();
wrapper.gt(User::getAge, 60)
       .set(User::getPassword, "expired");
userMapper.update(null, wrapper);
```

> [!NOTE] update 第一个参数
> 如果实体对象 `entity` 不为 null，MP 会同时更新实体中的非空字段；通常我们只需要 wrapper 的 set，传 null 即可。

---

# Service 层封装
MP 同样提供了 Service 层的封装，进一步减少模板代码。

## IService 接口
| **常用方法** | **说明** |
| --- | --- |
| `save(T)` / `saveBatch(Collection)` | 保存、批量保存 |
| `saveOrUpdate(T)` | 主键存在则更新，否则插入 |
| `removeById` / `removeByIds` / `remove(Wrapper)` | 删除 |
| `updateById(T)` / `update(Wrapper)` | 修改 |
| `getById(id)` / `getOne(Wrapper)` | 查询单条 |
| `list()` / `list(Wrapper)` | 查询多条 |
| `count(Wrapper)` | 统计 |
| `page(IPage, Wrapper)` | 分页 |
| `lambdaQuery()` / `lambdaUpdate()` | 链式构造器，**最常用** |

## 标准用法
**Service 接口**：继承 `IService<T>`。
```Java
public interface UserService extends IService<User> {
}
```
**Service 实现类**：继承 `ServiceImpl<Mapper, T>`。
```Java
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
}
```
**调用**：
```Java
@Autowired
private UserService userService;

// 链式查询
List<User> list = userService.lambdaQuery()
    .like(User::getName, "张")
    .ge(User::getAge, 18)
    .list();

// 链式更新
userService.lambdaUpdate()
    .gt(User::getAge, 60)
    .set(User::getPassword, "expired")
    .update();
```

> [!NOTE] Service vs Mapper
> 相比 Mapper，Service 提供**更友好的方法名**（如 `save` 替代 `insert`）和**链式 API**。简单业务推荐直接用 Service，复杂联表查询仍需在 Mapper 写 XML。

---

# 分页插件
MP 的分页基于**插件机制**实现，需要先注册分页拦截器。

## 配置分页插件
```Java
@Configuration
public class MybatisPlusConfig {

    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor() {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // 添加分页插件，指定数据库类型
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));
        return interceptor;
    }
}
```

## 使用分页
```Java
// 第 1 页，每页 10 条
Page<User> page = new Page<>(1, 10);

LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
wrapper.like(User::getName, "张");

userMapper.selectPage(page, wrapper);

// 获取分页结果
long total = page.getTotal();           // 总记录数
long pages = page.getPages();           // 总页数
List<User> records = page.getRecords(); // 当前页数据
long current = page.getCurrent();       // 当前页码
long size = page.getSize();             // 每页条数
```

底层会自动追加 `LIMIT ?, ?` 并执行 `COUNT(*)` 查询，无需手写。

---

# 自定义 SQL
当业务过于复杂（多表 JOIN、子查询）时，仍可使用 MyBatis 原生方式编写 SQL，并配合 Wrapper 复用条件。

**Mapper 接口**：
```Java
public interface UserMapper extends BaseMapper<User> {
    List<User> selectByDept(@Param(Constants.WRAPPER) Wrapper<User> wrapper,
                            @Param("deptId") Long deptId);
}
```
**XML**：使用 `${ew.customSqlSegment}` 插入 Wrapper 生成的 SQL 片段。
```XML
<select id="selectByDept" resultType="org.example.pojo.User">
    SELECT u.* FROM user u
    LEFT JOIN dept d ON u.dept_id = d.id
    WHERE d.id = #{deptId}
    AND ${ew.customSqlSegment}
</select>
```

---

# 逻辑删除
**逻辑删除**指数据库表中以一个标志位（如 `deleted` 字段）表示删除状态，而非物理删除行。

## 配置
**全局配置**（`application.yml`）：
```yaml
mybatis-plus:
  global-config:
    db-config:
      logic-delete-field: deleted   # 逻辑删除字段名
      logic-delete-value: 1         # 删除时的值
      logic-not-delete-value: 0     # 未删除的值
```
**或在字段上注解**：
```Java
@TableLogic
private Integer deleted;
```

## 行为变化
配置后，MP 会**自动改写 SQL**：
- `deleteById(1)` → `UPDATE user SET deleted = 1 WHERE id = 1 AND deleted = 0`
- `selectById(1)` → `SELECT ... FROM user WHERE id = 1 AND deleted = 0`
- `selectList(...)` → 自动追加 `AND deleted = 0`

> [!WARNING] 注意
> 自定义 SQL **不会自动追加** `AND deleted = 0`，需要在 XML 中手动加上。

---

# 自动填充
针对 `createTime`、`updateTime`、`createBy` 等需要在插入/更新时自动赋值的字段。

## 实体类标注
```Java
@TableField(fill = FieldFill.INSERT)
private LocalDateTime createTime;

@TableField(fill = FieldFill.INSERT_UPDATE)
private LocalDateTime updateTime;
```

| **FieldFill** | **触发时机** |
| --- | --- |
| `DEFAULT` | 不填充 |
| `INSERT` | 插入时填充 |
| `UPDATE` | 更新时填充 |
| `INSERT_UPDATE` | 插入和更新时都填充 |

## 实现 MetaObjectHandler
```Java
@Component
public class MyMetaObjectHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createTime", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
    }
}
```

---

# 乐观锁
通过版本号 `version` 实现并发更新冲突检测。

## 配置插件
```Java
interceptor.addInnerInterceptor(new OptimisticLockerInnerInterceptor());
```

## 实体类标注
```Java
@Version
private Integer version;
```

## 行为
执行 `updateById` 时，SQL 会变为：
```sql
UPDATE user SET ..., version = version + 1
WHERE id = ? AND version = ?
```
若返回受影响行数为 0，说明数据已被其他线程修改，本次更新失败，可由业务层重试。

---

# 主键策略对比
| **策略** | **数据库要求** | **优点** | **缺点** |
| --- | --- | --- | --- |
| `AUTO` | 自增列 | 简单、有序 | 分库分表困难，迁移麻烦 |
| `ASSIGN_ID`（雪花） | Long 类型即可 | 分布式友好、有序 | 占用 8 字节，时钟回拨可能重复 |
| `ASSIGN_UUID` | String(32) | 完全去中心化 | 无序，B+Tree 索引性能差 |
| `INPUT` | 任意 | 完全可控 | 业务自行保证唯一 |

> [!NOTE] 选型建议
> - **单体小项目**：用 `AUTO`，简单够用。
> - **分布式/微服务**：用 `ASSIGN_ID`（雪花算法），全局唯一且有序。
> - **避免使用 `ASSIGN_UUID`** 作为 InnoDB 主键，会显著降低聚簇索引插入性能。

---

# 常见问题
## 问：MP 如何在不写 SQL 的情况下完成 CRUD？
**回答：** MP 在启动时扫描所有继承了 `BaseMapper<T>` 的接口，通过 `T` 的泛型类型获取实体 Class，结合 `@TableName`、`@TableId` 等注解解析出表结构（表名、主键、字段映射）。然后在内部通过**反射 + 模板**为每个 Mapper 动态注册 `MappedStatement`，相当于在运行期为每个接口方法生成了对应的 SQL。所以本质上仍是 MyBatis，只是 SQL 由 MP 在启动期帮我们“预制”好。

## 问：`#{}` 防注入，那 Wrapper 拼接条件安全吗？
**回答：** 安全。Wrapper 内部所有的值都通过参数占位符（`#{}`）传递给 PreparedStatement，不是字符串拼接。但需注意 `last()` 和 `apply()` 是直接拼接 SQL 的，**用户输入禁止直接传入**，否则同样有注入风险。

## 问：LambdaQueryWrapper 相比 QueryWrapper 有什么优势？
**回答：** 主要是**消除字段名硬编码**。`QueryWrapper` 的字段名是字符串，重命名时编译器无法发现错误；而 `LambdaQueryWrapper` 使用 `User::getName` 方法引用，编译期校验，IDE 重构能同步修改。代价是性能略低（需要解析 Lambda），但可忽略。
