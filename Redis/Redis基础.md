+++
date = '2026-07-18'
draft = false
title = '基础'
tags = []
categories = ["Redis"]
+++

> 本文更新于 2026-07-18

# Redis

- **SQL** (Structured Query Language)：关系型数据库，有固定表结构、支持事务与复杂查询
- **NoSQL**：非关系型数据库，结构灵活，偏缓存、高并发、海量读写

| 对比项 | MySQL（关系型） | Redis（NoSQL） |
| --- | --- | --- |
| 数据模型 | 表、行、列 | 键值 + 多种数据结构 |
| 存储 | 磁盘为主 | 内存为主，可持久化 |
| 查询 | SQL | 命令（Command） |
| 事务 | 完整 ACID | 弱事务（MULTI/EXEC，无回滚） |
| 典型场景 | 业务数据持久化 | 缓存、会话、排行榜、分布式锁、消息队列 |

**Redis 是什么**：开源的内存键值数据库，支持 String、Hash、List、Set、ZSet 等结构，读写极快，常作缓存中间件。

默认端口：`6379`

```bash
# 连接
redis-cli
redis-cli -h 127.0.0.1 -p 6379 -a 密码

# 常用信息
ping          # 返回 PONG
info          # 服务器信息
select 0      # 切换库（默认 0~15）
flushdb       # 清空当前库
flushall      # 清空所有库（慎用）
```

---

# Command

## 通用

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `KEYS pattern` | 按模式查 key（生产慎用） | `KEYS user:*` |
| `EXISTS key` | key 是否存在，返回 0/1 | `EXISTS name` |
| `TYPE key` | 查看类型 | `TYPE name` |
| `DEL key [key...]` | 删除 | `DEL name age` |
| `UNLINK key` | 异步删除（大 key 更安全） | `UNLINK bigkey` |
| `EXPIRE key seconds` | 设置过期秒数 | `EXPIRE token 3600` |
| `PEXPIRE key ms` | 过期毫秒数 | `PEXPIRE token 1000` |
| `TTL key` | 剩余生存时间（秒） | `TTL token` |
| `-1` / `-2` | 永不过期 / key 不存在 | — |
| `PERSIST key` | 移除过期时间 | `PERSIST token` |
| `RENAME old new` | 重命名 | `RENAME a b` |
| `RANDOMKEY` | 随机返回一个 key | `RANDOMKEY` |
| `DBSIZE` | 当前库 key 数量 | `DBSIZE` |

> 生产环境不要用 `KEYS *`，会阻塞；用 `SCAN` 游标迭代。

```bash
SCAN 0 MATCH user:* COUNT 100
```

---

## String类型

最基础类型，value 可以是字符串、数字、JSON 等。单个 value 最大 512MB。

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `SET key value` | 设置 | `SET name tom` |
| `GET key` | 获取 | `GET name` |
| `SETNX key value` | 不存在才设置（分布式锁常用） | `SETNX lock 1` |
| `SETEX key sec value` | 设置并指定过期秒数 | `SETEX code 60 1234` |
| `SET key value EX sec` | 同上（推荐写法） | `SET code 1234 EX 60` |
| `SET key value NX EX sec` | 不存在 + 过期（锁） | `SET lock uuid NX EX 10` |
| `MSET k1 v1 k2 v2` | 批量设置 | `MSET a 1 b 2` |
| `MGET k1 k2` | 批量获取 | `MGET a b` |
| `INCR key` | 自增 1 | `INCR count` |
| `INCRBY key n` | 自增 n | `INCRBY count 10` |
| `DECR / DECRBY` | 自减 | `DECR stock` |
| `APPEND key val` | 追加字符串 | `APPEND name !` |
| `STRLEN key` | 长度 | `STRLEN name` |
| `GETRANGE key start end` | 截取子串 | `GETRANGE name 0 2` |
| `GETSET key value` | 设新值并返回旧值 | `GETSET name jerry` |

**常见场景**

- 缓存对象：`SET user:1 '{"id":1,"name":"tom"}'`
- 验证码：`SETEX sms:138xxxx 300 654321`
- 计数器 / 点赞 / 库存：`INCR`、`DECR`
- 分布式锁：`SET lock uuid NX EX 30`

---

## Key的层级格式

约定用 `:` 分层，提高可读性，方便按业务隔离与排查。

```text
项目:业务模块:对象:id[:属性]
```

| 示例 | 含义 |
| --- | --- |
| `login:token:1001` | 用户 1001 的登录 token |
| `cache:user:1001` | 用户 1001 的缓存 |
| `order:detail:20260718001` | 订单详情 |
| `sms:code:13800138000` | 手机验证码 |
| `lock:order:create:1001` | 下单锁 |

```bash
SET cache:user:1001 '{"id":1001,"name":"tom"}' EX 3600
GET cache:user:1001
KEYS cache:user:*      # 开发用；生产用 SCAN
```

---

## Hash类型

类似 Java 的 `Map<String, String>`，适合存对象字段，可单独改某一个 field。

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `HSET key field value` | 设置字段 | `HSET user:1 name tom` |
| `HGET key field` | 获取字段 | `HGET user:1 name` |
| `HMSET key f1 v1 f2 v2` | 批量设置（旧写法） | `HMSET user:1 age 18 city bj` |
| `HSET key f1 v1 f2 v2` | 批量设置（新） | `HSET user:1 age 18 city bj` |
| `HMGET key f1 f2` | 批量获取 | `HMGET user:1 name age` |
| `HGETALL key` | 获取全部 | `HGETALL user:1` |
| `HKEYS key` | 所有 field | `HKEYS user:1` |
| `HVALS key` | 所有 value | `HVALS user:1` |
| `HEXISTS key field` | 字段是否存在 | `HEXISTS user:1 name` |
| `HDEL key field [field...]` | 删字段 | `HDEL user:1 city` |
| `HLEN key` | 字段个数 | `HLEN user:1` |
| `HINCRBY key field n` | 字段数值增减 | `HINCRBY user:1 age 1` |

**String 存 JSON vs Hash**

| 方式 | 优点 | 缺点 |
| --- | --- | --- |
| String + JSON | 简单，一次读写 | 改一个字段要整读整写 |
| Hash | 可 partial update | 嵌套对象不方便 |

```bash
HSET user:1001 id 1001 name tom age 18
HGET user:1001 name
HINCRBY user:1001 age 1
HGETALL user:1001
```

**场景**：用户信息、商品详情、购物车（field=商品id，value=数量）

---

## List类型

双向链表，可当队列 / 栈。元素可重复，按下标访问两端快、中间慢。

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `LPUSH key v1 v2` | 左插入 | `LPUSH list a b` |
| `RPUSH key v1 v2` | 右插入 | `RPUSH list c d` |
| `LPOP key` | 左弹出 | `LPOP list` |
| `RPOP key` | 右弹出 | `RPOP list` |
| `LRANGE key start stop` | 范围查看（含两端） | `LRANGE list 0 -1` |
| `LINDEX key index` | 按下标取 | `LINDEX list 0` |
| `LLEN key` | 长度 | `LLEN list` |
| `LSET key index value` | 修改指定下标 | `LSET list 0 x` |
| `LREM key count value` | 删除 count 个 value | `LREM list 1 a` |
| `LTRIM key start stop` | 只保留区间 | `LTRIM list 0 99` |
| `BLPOP key timeout` | 阻塞左弹 | `BLPOP queue 5` |
| `BRPOP key timeout` | 阻塞右弹 | `BRPOP queue 5` |

**队列 / 栈**

```bash
# 队列：左进右出 或 右进左出
LPUSH queue task1
RPOP queue

# 栈：左进左出
LPUSH stack a
LPOP stack

# 最新消息列表（只保留 100 条）
LPUSH msg:1 "hello"
LTRIM msg:1 0 99
LRANGE msg:1 0 -1
```

**场景**：消息队列、最新动态、粉丝列表分页（简单场景）

---

## Set类型

无序、不重复，类似 Java `HashSet`。适合交集、并集、差集。

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `SADD key m1 m2` | 添加 | `SADD tags java redis` |
| `SREM key m1` | 删除 | `SREM tags java` |
| `SMEMBERS key` | 全部成员 | `SMEMBERS tags` |
| `SISMEMBER key m` | 是否成员 | `SISMEMBER tags redis` |
| `SCARD key` | 成员数 | `SCARD tags` |
| `SRANDMEMBER key [n]` | 随机取 n 个（不删） | `SRANDMEMBER tags 2` |
| `SPOP key [n]` | 随机弹出 | `SPOP tags` |
| `SINTER k1 k2` | 交集 | `SINTER user:1:follow user:2:follow` |
| `SUNION k1 k2` | 并集 | `SUNION a b` |
| `SDIFF k1 k2` | 差集（在 k1 不在 k2） | `SDIFF a b` |
| `SINTERSTORE dest k1 k2` | 交集写入 dest | `SINTERSTORE r a b` |
| `SMOVE source dest member` | 移动成员 | `SMOVE a b x` |

```bash
SADD user:1:follow 10 20 30
SADD user:2:follow 20 30 40
SINTER user:1:follow user:2:follow   # 共同关注 → 20 30
SDIFF user:1:follow user:2:follow    # 1 关注但 2 没关注 → 10
```

**场景**：标签、点赞去重、共同好友、抽奖、黑名单

---

## Sorted类型

有序集合（ZSet）：成员唯一，每个成员带 **score**，按 score 排序。适合排行榜。

| 命令 | 说明 | 示例 |
| --- | --- | --- |
| `ZADD key score member` | 添加/更新 | `ZADD rank 100 tom` |
| `ZREM key member` | 删除 | `ZREM rank tom` |
| `ZSCORE key member` | 查分数 | `ZSCORE rank tom` |
| `ZINCRBY key n member` | 分数增减 | `ZINCRBY rank 10 tom` |
| `ZCARD key` | 成员数 | `ZCARD rank` |
| `ZRANK key member` | 升序排名（从 0） | `ZRANK rank tom` |
| `ZREVRANK key member` | 降序排名 | `ZREVRANK rank tom` |
| `ZRANGE key start stop [WITHSCORES]` | 升序区间 | `ZRANGE rank 0 9 WITHSCORES` |
| `ZREVRANGE key start stop [WITHSCORES]` | 降序区间 | `ZREVRANGE rank 0 9 WITHSCORES` |
| `ZRANGEBYSCORE key min max` | 按分数区间 | `ZRANGEBYSCORE rank 80 100` |
| `ZCOUNT key min max` | 分数区间人数 | `ZCOUNT rank 80 100` |
| `ZREMRANGEBYRANK key start stop` | 按排名删 | `ZREMRANGEBYRANK rank 0 0` |
| `ZREMRANGEBYSCORE key min max` | 按分数删 | `ZREMRANGEBYSCORE rank 0 10` |

```bash
ZADD rank:game 98.5 tom
ZADD rank:game 99.2 jerry
ZADD rank:game 97.0 spike
ZREVRANGE rank:game 0 2 WITHSCORES   # 前三名（高分在前）
ZINCRBY rank:game 1 tom              # tom +1 分
```

**场景**：排行榜、延时队列（score=时间戳）、带权重的好友列表

---

# Jedis

Java 连接 Redis 的客户端（底层 socket）。Spring 项目更常用 **Spring Data Redis + Lettuce**，但 Jedis 适合理解命令映射。

## 快速入门

**依赖（Maven）**

```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>5.1.0</version>
</dependency>
```

**基本使用**

```java
public class JedisDemo {
    public static void main(String[] args) {
        // host, port
        Jedis jedis = new Jedis("127.0.0.1", 6379);
        // jedis.auth("密码");

        jedis.set("name", "tom");
        System.out.println(jedis.get("name"));

        jedis.hset("user:1", "age", "18");
        System.out.println(jedis.hgetAll("user:1"));

        jedis.close(); // 用完关闭
    }
}
```

| Java 方法 | Redis 命令 |
| --- | --- |
| `jedis.set / get` | `SET / GET` |
| `jedis.hset / hget / hgetAll` | `HSET / HGET / HGETALL` |
| `jedis.lpush / lrange` | `LPUSH / LRANGE` |
| `jedis.sadd / smembers` | `SADD / SMEMBERS` |
| `jedis.zadd / zrevrange` | `ZADD / ZREVRANGE` |
| `jedis.expire / ttl` | `EXPIRE / TTL` |
| `jedis.del` | `DEL` |

> 每个命令方法名基本与 Redis 命令一致，便于对照学习。

## Jedis连接池

每次 `new Jedis` 都建连接开销大，生产用连接池。

```java
public class JedisPoolUtil {
    private static final JedisPool POOL;

    static {
        JedisPoolConfig config = new JedisPoolConfig();
        config.setMaxTotal(8);          // 最大连接
        config.setMaxIdle(8);           // 最大空闲
        config.setMinIdle(0);           // 最小空闲
        config.setTestOnBorrow(true);   // 借出时检测

        // host, port, timeout(ms)
        POOL = new JedisPool(config, "127.0.0.1", 6379, 2000);
        // 有密码：
        // POOL = new JedisPool(config, "127.0.0.1", 6379, 2000, "密码");
    }

    public static Jedis getJedis() {
        return POOL.getResource();
    }
}
```

**使用**

```java
Jedis jedis = null;
try {
    jedis = JedisPoolUtil.getJedis();
    jedis.set("cache:user:1", "tom");
    System.out.println(jedis.get("cache:user:1"));
} finally {
    if (jedis != null) {
        jedis.close(); // 归还连接池，不是销毁
    }
}
```

| 配置项 | 含义 |
| --- | --- |
| `maxTotal` | 池中最大连接数 |
| `maxIdle` | 最大空闲连接 |
| `minIdle` | 最小空闲连接 |
| `maxWaitMillis` | 借连接最大等待时间 |
| `testOnBorrow` | 取出前是否 ping 检测 |

**注意**

1. `close()` 在池化场景是**归还**，必须在 `finally` 里调用
2. 不要把 `Jedis` 实例做成多线程共享变量
3. 连接超时、密码、数据库编号按环境配置，不要写死在业务代码里

---

# SpringDataRedis

Spring 官方对 Redis 的封装，基于 **Spring Data Redis**，默认客户端是 **Lettuce**（也可用 Jedis）。比手写 Jedis 更适合 Spring Boot 项目：自动配置、连接池、模板 API、与 Spring 容器集成。

| 对比 | Jedis | Spring Data Redis + Lettuce |
| --- | --- | --- |
| 使用方式 | 自己 `new` / 连接池 | 注入 `RedisTemplate` / `StringRedisTemplate` |
| 线程模型 | 同步，实例不宜共享 | Lettuce 基于 Netty，连接可共享 |
| 配置 | 代码写死或自管 | `application.yml` + 环境变量 |
| 序列化 | 多半自己管字符串 | 默认 JDK 序列化，需自定义 |

---

## 依赖

```xml
<!-- Redis 起步依赖（默认 Lettuce） -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

<!-- 连接池（配置 lettuce.pool 时需要） -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-pool2</artifactId>
</dependency>

<!-- 使用 GenericJackson2JsonRedisSerializer 时需要 Jackson -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-json</artifactId>
</dependency>

<!-- 测试 -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>
```

> 只有 `data-redis` **不会**带齐 Jackson。用 JSON 序列化器却漏加 `starter-json` 会报：  
> `ClassNotFoundException: com.fasterxml.jackson.databind.jsontype.TypeResolverBuilder`

---

## 配置 application.yml

```yaml
spring:
  data:
    redis:
      host: ${REDIS_HOST}          # 未设置环境变量时会原样当主机名 → 连不上
      port: 6379
      password: ${REDISCLI_AUTH}
      timeout: 3000ms
      lettuce:
        pool:
          max-active: 8
          max-idle: 8
          min-idle: 0
```

| 配置 | 说明 |
| --- | --- |
| `host` / `port` / `password` | 连接信息，建议用环境变量，勿提交仓库 |
| `timeout` | 命令超时 |
| `lettuce.pool.*` | 连接池；要生效需 `commons-pool2` |


---

## RedisTemplate 与 StringRedisTemplate

| | `RedisTemplate` | `StringRedisTemplate` |
| --- | --- | --- |
| key/value 类型 | 默认可为 Object | 都是 **String** |
| 默认序列化 | **JDK**（`JdkSerializationRedisSerializer`） | **String**（UTF-8） |
| Redis 里长什么样 | `\xac\xed\x00\x05...` 二进制 | 明文 `张三` |
| 是否要 Config | 要存对象/要可读时需自定义 | 字符串场景一般**不用** |
| 典型用法 | 缓存对象、Hash 等 | 验证码、token、简单 KV |

**API 与命令对应（两种 Template 类似）**

| Java                              | Redis                       |
| --------------------------------- | --------------------------- |
| `opsForValue().set/get`           | `SET` / `GET`               |
| `opsForHash().put/get/entries`    | `HSET` / `HGET` / `HGETALL` |
| `opsForList().leftPush/range`     | `LPUSH` / `LRANGE`          |
| `opsForSet().add/members`         | `SADD` / `SMEMBERS`         |
| `opsForZSet().add/reverseRange`   | `ZADD` / `ZREVRANGE`        |
| `expire` / `getExpire` / `delete` | `EXPIRE` / `TTL` / `DEL`    |

---

## 序列化：为什么会出现 \xac\xed

默认 `RedisTemplate` 用 **JDK 序列化** 写 value（甚至 key）：

```text
\xac\xed\x00\x05 t \x00\x09 testValue
 │         │    │    └─ 内容 testValue
 │         │    └─ 字符串标记
 │         └─ 序列化版本
 └─ Java 序列化魔数
```

Java 里 `get` 能还原，但 redis-cli / 其他语言看到的是“乱码”。

| 序列化方式 | 适用 | Redis 中形态 |
| --- | --- | --- |
| JDK（默认） | 不推荐 | 二进制 |
| `StringRedisSerializer` | 纯字符串 | 明文 |
| `GenericJackson2JsonRedisSerializer` | 对象 + 可读 | JSON（常带 `@class` 类型信息） |

**注意：** 改序列化后，旧 key 可能读失败，需 `DEL` 旧数据再写入。

---

## 自定义 RedisConfig（JSON）

```java
@Configuration
public class RedisConfig {

    @Bean
    public RedisTemplate<String, Object> redisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory); // 连接仍走 yml，这里只改序列化

        GenericJackson2JsonRedisSerializer json = new GenericJackson2JsonRedisSerializer();

        // key / hash field 用字符串 → 可读、好运维
        template.setKeySerializer(RedisSerializer.string());
        template.setHashKeySerializer(RedisSerializer.string());
        // value / hash value 用 JSON → 可读 + 可存对象
        template.setValueSerializer(json);
        template.setHashValueSerializer(json);

        return template;
    }
}
```

| 代码 | 为什么 |
| --- | --- |
| `@Bean RedisTemplate` | 覆盖默认 JDK 序列化 |
| 注入 `RedisConnectionFactory` | 复用 Boot 自动配置的连接 |
| key 用 String | 避免 key 也变成二进制 |
| value 用 JSON | 缓存对象且客户端可读 |
| Hash 的 key/value 也设 | 否则 `opsForHash` 仍走默认 JDK |

---

## StringRedisTemplate 用法

Boot 自动提供 Bean，注入即可：

```java
@Resource
private StringRedisTemplate stringRedisTemplate;

@Test
void testString() {
    stringRedisTemplate.opsForValue().set("name", "张三");
    String name = stringRedisTemplate.opsForValue().get("name");
    System.out.println(name); // 张三，Redis 里也是明文
}
```

**存对象：自己转 JSON（推荐与 String 模板搭配）**

```java
@Resource
private StringRedisTemplate stringRedisTemplate;

private static final ObjectMapper mapper = new ObjectMapper();

@Test
void testUser() throws Exception {
    User user = new User("张三军", 20);
    String json = mapper.writeValueAsString(user);
    stringRedisTemplate.opsForValue().set("user:1", json);

    String jsonUser = stringRedisTemplate.opsForValue().get("user:1");
    User u = mapper.readValue(jsonUser, User.class);
    System.out.println(u);
}
```

| 方案 | 说明 |
| --- | --- |
| `StringRedisTemplate` + `ObjectMapper` | 自己控制 JSON，Redis 里是干净 JSON，无强制 `@class` |
| `RedisTemplate` + `GenericJackson2Json` | 框架自动序列化，可能带类型信息，取对象更省事 |

---

## @Resource 注入坑（字段名）

`@Resource` **默认按字段名**找 Bean，不是“变量名随便起”。

```java
// 错：字段名叫 redisTemplate → 命中 RedisConfig 里的 RedisTemplate Bean
@Resource
private StringRedisTemplate redisTemplate;
// BeanNotOfRequiredTypeException:
// expected StringRedisTemplate but was RedisTemplate

// 对：字段名与 Boot 默认 Bean 名一致
@Resource
private StringRedisTemplate stringRedisTemplate;

// 或显式指定名字
@Resource(name = "stringRedisTemplate")
private StringRedisTemplate redisTemplate;
```

| 注解 | 默认按什么注入 |
| --- | --- |
| `@Resource` | **名字**优先，再校验类型 |
| `@Autowired` | **类型**优先；多个同类型再靠名字 / `@Qualifier` |

容器中常见两个 Bean：

| Bean 名 | 类型 | 来源 |
| --- | --- | --- |
| `redisTemplate` | `RedisTemplate` | 你的 `RedisConfig` 或 Boot 默认 |
| `stringRedisTemplate` | `StringRedisTemplate` | Boot 自动配置 |

---
