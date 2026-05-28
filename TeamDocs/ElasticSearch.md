+++
date = '2026-05-28'
draft = false
title = 'ElasticSearch'
tags = []
categories = ["TeamDocs"]
+++

> 本文更新于 2026-05-28

# 核心概念

> ES 就是一个**分布式搜索引擎**，擅长全文检索和近实时分析。可以把 MySQL 类比迁移过来理解。

| MySQL / 关系型数据库 | ElasticSearch |
|-------------------|--------------|
| 数据库（Database）    | 索引（Index）   |
| 表（Table）         | 类型（Type，7.x 后已废弃，一个 Index 只有一个 Type） |
| 行（Row）           | 文档（Document）|
| 列（Column）        | 字段（Field）   |
| 主键（PK）           | _id           |
| Schema            | Mapping       |
| SQL               | DSL（JSON 格式查询语句）|

- **Index**：文档的集合，类似于数据库
- **Document**：JSON 格式的数据单元，每条文档有唯一 `_id`
- **Mapping**：定义字段名称和类型的元数据，类似表结构
- **倒排索引**：ES 全文检索的核心——不是通过文档找关键词，而是通过关键词找文档
- **分片（Shard）**：索引可以被拆分成多个分片，分布在不同节点上，实现水平扩展
- **副本（Replica）**：分片的复制，提供高可用和负载均衡

> **⚠️ "type" 有两个含义，容易混淆：**
> 1. **概念层的 Type**（已废弃）：上表中对应 MySQL "表"的那层，7.x 后一个 Index 只保留 `_doc` 一种 Type。
> 2. **Mapping 中的 `"type"` 属性**：声明字段的**数据类型**（如 `text`、`keyword`、`float`），等同于 MySQL 中的 `VARCHAR`、`INT` 等，**没有废弃，是必须的**。

## 倒排索引原理

传统正排索引：文档 → 关键词（遍历扫描，慢）

倒排索引：关键词 → 文档ID列表（直接定位，快）

```
词条      文档ID列表
"Java" → [1, 3, 5]
"笔记" → [1, 2]
```

ES 对文档内容进行**分词**，把每个词条建立倒排索引，搜索时直接通过词条定位文档。

---

# 安装与启动

## Docker 部署

```bash
docker run -d \
  --name es \
  -p 9200:9200 \
  -p 9300:9300 \
  -e "discovery.type=single-node" \
  -e "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
  -v es-data:/usr/share/elasticsearch/data \
  -v es-plugins:/usr/share/elasticsearch/plugins \
  elasticsearch:8.12.0
```

| 端口   | 用途          |
|------|-------------|
| 9200 | HTTP REST API |
| 9300 | 节点间通信（TCP）  |

## 验证启动

```bash
curl http://localhost:9200
```

返回 JSON 包含集群名称、版本等信息即启动成功。

## 安装 IK 分词器

中文分词必须安装 IK 插件：

```bash
# 进入容器
docker exec -it es bash

# 安装插件
cd /usr/share/elasticsearch
bin/elasticsearch-plugin install https://github.com/inmedias/ik/releases/对应版本.zip

# 退出重启
exit
docker restart es
```

---

# 分词器

分词器（Analyzer）决定文本如何被拆分成词条，直接影响搜索效果。

## 内置分词器

| 分词器               | 说明           | 示例：`"Hello World"` |
|-------------------|--------------|----------------------|
| `standard`        | 默认分词器，按单词边界切分 | `hello`, `world`     |
| `simple`          | 按非字母切分，转小写   | `hello`, `world`     |
| `whitespace`      | 按空格切分，不转小写   | `Hello`, `World`     |
| `keyword`         | 不分词，整体作为一个词条 | `Hello World`        |

## IK 分词器

中文分词器，提供两种模式：

| 模式            | 说明         | 示例：`"中华人民共和国"`                                                 |
| ------------- | ---------- | -------------------------------------------------------------- |
| `ik_smart`    | 粗粒度切分，速度优先 | `中华人民共和国`                                                      |
| `ik_max_word` | 细粒度切分，覆盖优先 | `中华人民共和国`, `中华人民`, `中华`, `华人`, `人民共和国`, `人民`, `共和国`, `共和`, `国` |

**测试分词效果：**

```json
GET /_analyze
{
  "analyzer": "ik_max_word",
  "text": "中华人民共和国"
}
```

> 搜索时用 `ik_max_word`（多词条提高召回率），索引时用 `ik_smart`（减少冗余词条节省空间）。

---

# 索引操作

## 创建索引

```json
PUT /products
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart"
      },
      "price": {
        "type": "float"
      },
      "category": {
        "type": "keyword"
      },
      "create_time": {
        "type": "date"
      },
      "description": {
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart"
      }
    }
  }
}
```

> 上面 mapping 中每字段里的 `"type": "text"` / `"type": "float"` 等，声明的是**字段数据类型**，和概念层的 Type 废弃无关。

## 常用字段类型

| 类型          | 说明                            |
|-------------|-------------------------------|
| `text`      | 全文检索字段，会分词                    |
| `keyword`   | 精确匹配字段，不分词，用于过滤、排序、聚合         |
| `integer`   | 整型                            |
| `float`     | 浮点型                           |
| `boolean`   | 布尔型                           |
| `date`      | 日期型                           |
| `object`    | 嵌套对象                          |
| `nested`    | 嵌套数组（独立查询每个元素）                |

> `text` vs `keyword`：`text` 分词后建倒排索引，适合全文搜索；`keyword` 不分词，适合精确过滤（如状态码、分类名）。

## 查看与删除

```json
// 查看索引映射
GET /products/_mapping

// 查看索引设置
GET /products/_settings

// 删除索引
DELETE /products
```

---

# 映射（Mapping）

Mapping 定义索引中文档的结构——有哪些字段、每个字段的类型、如何分词等，类似 MySQL 中定义表结构。

## 动态映射 vs 显式映射

| 方式     | 说明                                | 适用场景           |
|--------|-----------------------------------|----------------|
| 动态映射   | 插入文档时 ES 自动推断字段类型并创建 mapping       | 快速原型、日志等非严格场景  |
| 显式映射   | 创建索引时手动指定每个字段的类型和属性              | 生产环境，需要精确控制类型  |

**动态映射的问题**：ES 推断可能不准。例如插入 `"price": 100`，ES 会被推断为 `long`，后续插入 `"price": 99.9` 就会报类型冲突。生产中建议显式映射。

## 动态映射推断规则

ES 首次遇到未知字段时，根据值自动推断类型：

| JSON 值              | 推断的 ES 类型     |
|----------------------|---------------|
| `null`               | 不创建字段          |
| `true` / `false`     | `boolean`      |
| `123`                | `long`         |
| `1.23`               | `float`        |
| `"2026-01-01"`       | `date`（匹配日期格式时）|
| `"hello"`            | `text` + `keyword` 子字段 |
| `{ "k": "v" }`       | `object`       |
| `["a", "b"]`         | `text` + `keyword` 子字段 |

> 字符串默认同时生成 `text`（全文检索）和 `keyword`（精确匹配）子字段，可通过 `title.keyword` 访问。

## 动态映射控制

通过 `dynamic` 参数控制遇到新字段时的行为：

| 值        | 说明                            |
|-----------|-------------------------------|
| `true`    | 自动推断类型并添加新字段（默认）              |
| `false`   | 忽略新字段，文档可写入但新字段不被索引，无法搜索     |
| `"strict"`| 遇到新字段直接报错，文档写入失败             |

```json
PUT /products
{
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "title": { "type": "text" }
    }
  }
}
```

> `dynamic` 可以设在索引级别，也可以设在某个 `object` 字段内部，实现精细控制。

## 常用字段属性

Mapping 中每个字段除了 `type`，还可以配置多种属性：

| 属性               | 适用类型          | 说明                                  |
|------------------|---------------|-------------------------------------|
| `type`           | 所有            | 字段数据类型（必填）                          |
| `analyzer`       | `text`        | 索引时使用的分词器                           |
| `search_analyzer`| `text`        | 搜索时使用的分词器（不指定则用 `analyzer`）         |
| `index`          | 所有            | 是否建索引，`false` 则该字段不可搜索（默认 `true`）   |
| `store`          | 所有            | 是否独立存储原始值（默认 `false`，从 `_source` 取） |
| `doc_values`     | 除 `text` 外    | 是否启用列式存储，用于排序/聚合（默认 `true`）        |
| `format`         | `date`        | 日期格式，如 `"yyyy-MM-dd HH:mm:ss"`     |
| `copy_to`        | 所有            | 将字段值复制到另一个字段，用于组合搜索                 |
| `ignore_above`   | `keyword`     | 超过指定长度的字符串不索引（默认 256）              |

### index 示例

```json
"password": {
  "type": "keyword",
  "index": false
}
```

> `index: false` 的字段不能被搜索，但会存在于 `_source` 中可以获取。适合存储但不需要搜索的字段。

### copy_to 示例

将 `title` 和 `description` 的值合并到 `all` 字段，实现一键全文搜索：

```json
"all": {
  "type": "text",
  "analyzer": "ik_max_word"
},
"title": {
  "type": "text",
  "analyzer": "ik_max_word",
  "copy_to": "all"
},
"description": {
  "type": "text",
  "analyzer": "ik_max_word",
  "copy_to": "all"
}
```

搜索时对 `all` 字段检索即可同时匹配 `title` 和 `description`，效果类似 `multi_match` 但写法更简洁。

## 已有映射的修改限制

| 操作     | 是否允许 | 说明                          |
|--------|-----|-----------------------------|
| 新增字段   | ✅  | 往 mapping 中加新字段，不影响已有数据     |
| 修改字段类型 | ❌  | 已有字段类型不能改，例如 `text` → `keyword` 不行 |
| 删除字段   | ❌  | 不能删除 mapping 中的字段           |

**字段类型冲突的解决方案**：创建新索引 → 用 `_reindex` 迁移数据 → 删除旧索引 → 给旧索引名创建别名指向新索引。

```json
POST /_reindex
{
  "source": { "index": "products_old" },
  "dest": { "index": "products_new" }
}
```

---

# 文档操作

## 新增文档

```json
POST /products/_doc
{
  "title": "小米手机",
  "price": 2999.0,
  "category": "手机",
  "description": "性价比之王"
}
```

指定 ID：

```json
POST /products/_doc/1
{
  "title": "小米手机",
  "price": 2999.0
}
```

## 查询文档

```json
GET /products/_doc/1
```

## 修改文档

全量修改（覆盖）：

```json
PUT /products/_doc/1
{
  "title": "小米手机Pro",
  "price": 3999.0
}
```

局部修改：

```json
POST /products/_update/1
{
  "doc": {
    "price": 3499.0
  }
}
```

## 删除文档

```json
DELETE /products/_doc/1
```

## 批量操作

```json
POST /_bulk
{"index": {"_index": "products", "_id": "1"}}
{"title": "商品A", "price": 100}
{"index": {"_index": "products", "_id": "2"}}
{"title": "商品B", "price": 200}
{"delete": {"_index": "products", "_id": "3"}}
{"update": {"_index": "products", "_id": "1"}}
{"doc": {"price": 150}}
```

---

# 查询 DSL

## match 全文检索

对查询文本分词后去倒排索引匹配，最常用的全文搜索方式。

```json
GET /products/_search
{
  "query": {
    "match": {
      "title": "小米手机"
    }
  }
}
```

## term 精确匹配

不对查询文本分词，直接精确匹配，适合 `keyword` 类型字段。

```json
GET /products/_search
{
  "query": {
    "term": {
      "category": "手机"
    }
  }
}
```

> `term` 用于精确值查询，`match` 用于全文检索。**不要用 `term` 查 `text` 字段**，因为 `text` 字段存储的是分词后的词条。

## bool 复合查询

| 组合类型      | 说明              |
|-----------|-----------------|
| `must`    | 必须匹配，参与算分（AND）  |
| `should`  | 至少匹配一个，参与算分（OR） |
| `must_not`| 必须不匹配，不算分（NOT）  |
| `filter`  | 必须匹配，不算分，性能更好   |

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "title": "手机" } }
      ],
      "filter": [
        { "term": { "category": "手机" } },
        { "range": { "price": { "gte": 1000, "lte": 5000 } } }
      ]
    }
  }
}
```

> `filter` 不参与算分且结果可被缓存，性能优于 `must`。需要算分用 `must`，只做过滤用 `filter`。

## range 范围查询

```json
GET /products/_search
{
  "query": {
    "range": {
      "price": {
        "gte": 1000,
        "lte": 3000
      }
    }
  }
}
```

| 操作符  | 含义    |
|------|-------|
| `gt` | 大于    |
| `gte`| 大于等于  |
| `lt` | 小于    |
| `lte`| 小于等于  |

## match_all 查询全部

```json
GET /products/_search
{
  "query": {
    "match_all": {}
  }
}
```

## multi_match 多字段搜索

```json
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "小米",
      "fields": ["title", "description"]
    }
  }
}
```

---

# 排序与分页

## 排序

```json
GET /products/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "price": "asc" }
  ]
}
```

> `text` 字段不能直接排序，需使用 `keyword` 子字段：`title.keyword`。

## 分页

```json
GET /products/_search
{
  "query": { "match_all": {} },
  "from": 0,
  "size": 10
}
```

| 参数     | 含义     |
|--------|--------|
| `from` | 偏移量，从 0 开始 |
| `size` | 每页条数   |

> ES 默认限制 `from + size <= 10000`，深度分页需使用 `search_after` 或 `scroll` API。

---

# 高亮

搜索结果中对匹配关键词添加标签标记：

```json
GET /products/_search
{
  "query": {
    "match": { "title": "手机" }
  },
  "highlight": {
    "fields": {
      "title": {}
    },
    "pre_tags": ["<em>"],
    "post_tags": ["</em>"]
  }
}
```

返回结果中 `highlight.title` 会包含 `<em>手机</em>` 标记。

---

# 聚合分析

类似 SQL 的 `GROUP BY` 和聚合函数。

## 桶聚合（Bucket）

按字段值分组：

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "category_agg": {
      "terms": {
        "field": "category"
      }
    }
  }
}
```

## 度量聚合（Metric）

计算统计值：

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "price_stats": {
      "stats": {
        "field": "price"
      }
    }
  }
}
```

返回 `count`、`min`、`max`、`avg`、`sum`。

## 嵌套聚合

先按分类分组，再计算每组均价：

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "category_agg": {
      "terms": { "field": "category" },
      "aggs": {
        "avg_price": {
          "avg": { "field": "price" }
        }
      }
    }
  }
}
```

---

# Java 客户端

## 依赖

```xml
<dependency>
    <groupId>co.elastic.clients</groupId>
    <artifactId>elasticsearch-java</artifactId>
    <version>8.12.0</version>
</dependency>
```

## 连接配置

```java
RestClient restClient = RestClient.builder(
    new HttpHost("localhost", 9200, "http")
).build();

ElasticsearchTransport transport = new RestClientTransport(
    restClient, new JacksonJsonpMapper()
);

ElasticsearchClient esClient = new ElasticsearchClient(transport);
```

Spring Boot 中可直接使用 `ElasticsearchRestTemplate` 或 `ElasticsearchRepository`。

## 常用操作示例

### 创建索引

```java
esClient.indices().create(c -> c
    .index("products")
    .mappings(m -> m
        .properties("title", p -> p.text(t -> t.analyzer("ik_max_word")))
        .properties("price", p -> p.float_())
    )
);
```

### 新增文档

```java
Product product = new Product("小米手机", 2999.0, "手机");
esClient.index(i -> i
    .index("products")
    .id("1")
    .document(product)
);
```

### 搜索文档

```java
SearchResponse<Product> response = esClient.search(s -> s
    .index("products")
    .query(q -> q
        .bool(b -> b
            .must(m -> m.match(mt -> mt.field("title").query("手机")))
            .filter(f -> f.range(r -> r.field("price").gte(JsonData.of(1000.0))))
        )
    )
    .from(0)
    .size(10)
    .highlight(h -> h.fields("title", f -> f))
, Product.class);

response.hits().hits().forEach(hit -> {
    System.out.println(hit.source());
    System.out.println(hit.highlight().get("title"));
});
```

---

# 与 MySQL 数据同步

ES 不支持事务，通常作为 MySQL 的搜索补充。需要保证数据一致性。

## 同步方案对比

| 方案             | 原理                    | 优点      | 缺点            |
|----------------|-----------------------|---------|---------------|
| 同步双写           | 业务代码中同时写 MySQL 和 ES    | 简单直接    | 侵入业务代码，一致性难保证  |
| 异步 MQ          | 写完 MySQL 后发 MQ 消息，消费者写 ES | 解耦，性能好  | 需引入 MQ，消息可能丢失  |
| Canal 监听 Binlog | 监听 MySQL binlog 变更写入 ES  | 零侵入业务代码 | 架构复杂，有延迟       |

## Canal 方案原理

```
MySQL → Binlog → Canal → 消息队列/RPC → ES
```

Canal 伪装成 MySQL 从节点，实时读取 binlog 中的变更事件（INSERT/UPDATE/DELETE），解析后写入 ES。

---

# 常见踩坑

1. **`text` 字段用 `term` 查不到数据**：`text` 字段存储的是分词后的词条，`term` 不分词去精确匹配必然失败。应对：用 `match` 查询或给 `text` 加 `.keyword` 子字段。
2. **中文搜索无结果**：默认分词器 `standard` 对中文按单字切分，效果很差。必须安装 IK 分词器并在 mapping 中指定。
3. **深度分页报错**：`from + size` 超过 10000 会报错。解决方案：修改 `index.max_result_window` 或使用 `search_after`。
4. **字段类型冲突**：同一个 Index 中同名字段类型必须一致。如果之前自动映射为 `text`，后续无法改为 `keyword`，需重建索引。
5. **内存占用过高**：ES 基于 JVM，建议将堆内存设置为物理内存的 50%，不超过 32GB（超过会关闭指针压缩）。
