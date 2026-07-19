+++
date = '2026-07-18'
draft = false
title = 'Redis缓存'
tags = []
categories = ["Redis"]
+++

> 本文更新于 2026-07-18

# 缓存

临时存放热点数据，加快读取。**MySQL 是权威数据源，Redis 是加速层。**

```text
读：先 Redis → miss 再 MySQL → 回写 Redis
写：改 MySQL → 删对应缓存 key
```

---

# Cache-Aside（旁路缓存）

## 读

```text
1. GET cache:user:{id}
2. 命中 → JSON 转对象 → 返回
3. miss → 查 DB
4. DB 无 → 抛业务异常
5. DB 有 → 写入 Redis（建议带 TTL）→ 返回
```

## 写

| 操作 | DB | Redis |
| --- | --- | --- |
| 增 | INSERT | 可不写，等第一次读再缓存 |
| 改 / 删 | UPDATE / DELETE | **delete** `cache:user:{id}` |

---

# getById 示例

`StringRedisTemplate` + Hutool `JSONUtil`：

```java
private static final String CACHE_USER_KEY = "cache:user:";

@Override
public User getById(Long id) {
    String key = CACHE_USER_KEY + id;
    String userJson = stringRedisTemplate.opsForValue().get(key);
    if (userJson != null) {
        return JSONUtil.toBean(userJson, User.class);
    }
    User user = userMapper.selectById(id);
    if (user == null) {
        throw new BusinessException("用户不存在");
    }
    stringRedisTemplate.opsForValue().set(key, JSONUtil.toJsonStr(user), Duration.ofMinutes(30));
    return user;
}
```

```java
// update / delete 成功后
stringRedisTemplate.delete(CACHE_USER_KEY + id);
```

---

# 分层

| 层 | 职责 |
| --- | --- |
| Service | 返回 `User` 或抛 `BusinessException`，**不**返回 `Result` |
| Controller | `Result.success(data)` |
| 全局异常 | `Result.error(msg)` |

---
