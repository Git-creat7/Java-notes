# TeamDocs 后端源码吃透笔记

> 整理日期：2026-09-08  
> 源码目录：`F:\CodeProject\TeamDocs`  
> Git 基线：`89057635d476a0d4e124dbdfeb97e448eb467d69`；以本次读取的工作区代码为准。  
> 证据范围：后端 Java、Mapper XML、SQL、Lua、POM、启动和部署配置；前端只用于确认 API 调用和文件访问方式。没有读取已有项目 Markdown 来推导项目功能。  
> 阅读定位：面向 Java 后端实习面试。正文讲已经实现的行为；局限和改进方向单独指出，不能把建议说成已实现能力。个人负责范围、用户量、QPS、优化幅度无法由源码证明，本文不代填。

## 补充：面试考核要求

> 本节是补充的通用面试准备要求。第 1 节起为 TeamDocs 源码分析。

### 一、Java 基础考核指标

- **集合**：被问到 `HashMap` 时，能够徒手画出底层数据结构，完整讲出 `put` 流程、扩容机制和哈希冲突解决方案，并对比 `HashMap`、`Hashtable`、`ConcurrentHashMap`。
- **JVM**：掌握 JVM 内存模型、堆栈区别和 GC 算法。
- **多线程与并发**：掌握线程生命周期、`synchronized` 与 `Lock`、锁升级过程、`volatile` 底层原理和 AQS 核心框架。
- **集合对比**：讲清楚三者并发安全上的差异。

### 二、数据库考核指标

- **索引原理**：讲明白 B+ 树索引为什么适配 MySQL。
- **慢查询优化**：给出完整的优化方案，覆盖索引、SQL 改写和表结构调整等维度。
- **存储引擎与事务**：掌握 InnoDB 引擎核心特性、事务隔离级别和锁机制，包括间隙锁、临键锁。
- **SQL 调优**：掌握 SQL 调优实战。
- **复制与读写分离**：掌握主从复制与读写分离的底层原理。

### 三、框架和中间件考核指标

- **Spring**：讲清 IoC 容器中 Bean 的完整生命周期，以及 AOP 动态代理的两种实现方式。
- **Spring Boot / Spring Cloud**：掌握核心组件。
- **Redis 高可用**：讲清哨兵、集群如何实现高可用。
- **Redis 缓存问题**：完整说明缓存穿透、击穿、雪崩的解决方案。
- **Redis 基础与应用**：掌握常用数据结构、持久化机制和业务落地场景。
- **消息队列**：Kafka、RocketMQ 重点掌握消息不丢失的保障机制。

### 四、项目实战考核指标

项目需要经得住连环追问，以下内容应能连贯讲清：

1. 业务背景。
2. 技术选型理由。
3. 数据库表设计。
4. 项目遇到的最难问题。
5. 排查过程。
6. 最终解决方案。

**优化成果**：尽量做数字化呈现。

- **优化示例一**：例如通过线程加缓存优化接口，QPS 从 100 提升至 500。
- **优化示例二**：索引优化后，接口查询耗时从 2 秒压缩至 100 毫秒。

> **项目选题提醒**：苍穹外卖这类烂大街项目在金九银十基本等于“我没什么项目可聊”。尽量掌握技术亮点更强的项目，如云商城、短链接系统等。

---

## 1. 项目是什么

TeamDocs 是以“空间”为协作和权限边界的团队文件管理应用。用户注册、登录，创建空间并添加成员，在空间内管理文件夹、上传和预览文档、打标签、搜索、评论、查看动态及使用回收站。

后端是一个 Spring Boot 单体应用。MySQL 存业务元数据，MinIO 存文件内容，Redis 存空间缓存、限流计数、最近浏览及 Token 撤销状态。源码没有在线共同编辑文档正文的接口；这里的协作主要体现为共享文件、角色权限、标签、评论和操作动态。

### 1.1 总体架构

~~~mermaid
flowchart LR
    Browser["浏览器 / Vue"] -->|"HTTP /api"| Proxy["Nginx 或开发 Vite 代理"]
    Proxy -->|"去掉 /api 前缀"| API["Spring Boot :8080"]
    subgraph Backend["同一个后端进程"]
        API --> Security["Spring Security / JWT Filter"]
        Security --> Controller["7 个 REST Controller"]
        Controller --> Services["Service 业务层"]
        Aspects["角色 AOP / 操作日志 AOP"] -.-> Services
        Services --> Mapper["MyBatis-Plus / Mapper XML"]
        Services --> Cache["Redis 相关服务"]
        Services --> Storage["FileStorageService"]
        Services --> Recent["异步记录最近浏览"]
    end
    Mapper --> MySQL[("MySQL")]
    Cache --> Redis[("Redis")]
    Recent --> Redis
    Storage --> MinIO[("MinIO")]
    Browser -->|"签名 URL 获取文件"| MinIO
~~~

图中的各个 Service 是同一应用内的 Spring Bean，不是独立微服务。Compose 中多个容器是应用和依赖的部署划分。

### 1.2 技术栈

| 技术 | 源码用途 | 证据 |
|---|---|---|
| Java 17、Spring Boot 3.5.14 | Web 应用和自动配置 | `teamdocs-backend/pom.xml` |
| Spring Security、JJWT 0.12.x、BCrypt | 认证、JWT、密码散列 | `SecurityConfig`、`JWTUtils` |
| MyBatis-Plus 3.5.9 | CRUD、逻辑删除、分页 | POM、实体、`MpConfig` |
| MySQL | 九张业务表、JOIN、全文检索 | `sql/*.sql`、Mapper XML |
| Spring Data Redis | String、ZSet、Lua | `CacheClient`、Redis 相关 Service |
| MinIO SDK 8.6.0 | 文件上传、删除、预签名 URL | `MinioFileStorageServiceImpl` |
| Spring AOP | 方法级空间权限、操作日志 | `SpaceRoleAspect`、`OperationLogAspect` |
| Spring Async | 最近浏览写入 | `@EnableAsync`、`@Async` |
| Bean Validation | 请求参数约束 | DTO、Controller `@Validated` |
| Actuator | 健康检查 | `application.yaml` |

## 2. 后端代码地图

Java 根包是 `teamdocs-backend/src/main/java/asia/creat`。

| 目录 | 职责 | 阅读重点 |
|---|---|---|
| `controller` | 绑定请求参数和登录用户，调用 Service，包装 Result | 接口如何进入业务 |
| `service/impl` | 权限后的业务规则、数据访问编排、补偿和事务 | 项目最应投入时间的部分 |
| `mapper` | MyBatis-Plus BaseMapper 和自定义查询接口 | 方法如何对应 SQL |
| `resources/asia/creat/mapper` | JOIN、回收站、搜索、动态查询 | 真正的 SQL 条件和排序 |
| `entity` | 表映射、ID、逻辑删除 | 哪些删除会变成 UPDATE |
| `dto` / `vo` | 输入校验 / 返回结构 | 请求和响应不能混为一谈 |
| `filter` / `security` | JWT、LoginUser、空间 ThreadLocal | 用户身份从哪里来 |
| `anno` / `aspect` | 权限和日志声明与执行 | 注解为什么会生效 |
| `helper` | 资源归属检查、日志资源名称查询 | 业务复用的规则 |
| `utils` / `config` | Redis/JWT 封装、Spring 配置 | 缓存异常和基础设施参数 |

第一次跟代码时，用这条线路：`DocumentController.uploadDocument → DocumentServiceImpl.upload → FileStorageService.upload / documentMapper.insert`，再回头补过滤器和 AOP。

## 3. 启动与一次请求的完整过程

### 3.1 启动

`TeamdocsBackendApplication` 先通过 Dotenv 读取环境文件，允许文件不存在；将读取项写到系统属性，再执行 `SpringApplication.run`。它启用了 `@EnableAsync`，排除了默认用户服务自动配置。

`application.yaml` 定义后端端口 8080、MySQL/Redis/MinIO/JWT 配置，Mapper XML 位置、下划线转驼峰以及上传大小。不要从本地配置文件摘抄密码或密钥到简历、笔记中。

关键配置：

| 项目 | 当前值 |
|---|---|
| JWT 有效期 | `604800000` ms，即七天 |
| multipart 单文件上限 | 100 MB |
| multipart 请求上限 | 105 MB |
| 分页默认值 | 第 1 页，每页 20 条 |
| 分页最大数量 | DTO 和分页插件均为 100 |
| 健康检查 | `/actuator/health`，不展示组件详情 |

### 3.2 身份、业务权限与业务执行

~~~mermaid
sequenceDiagram
    participant Client as 客户端
    participant Filter as JwtAuthenticationFilter
    participant Redis as Redis
    participant Controller as Controller
    participant Role as SpaceRoleAspect
    participant DB as MySQL
    participant Service as 业务 Service
    Client->>Filter: Bearer JWT
    Filter->>Filter: 验签、过期、jti、userId、username
    Filter->>Redis: 查 jti 撤销标记和用户失效水位
    Filter->>Filter: 将 LoginUser 放入 SecurityContext
    Filter->>Controller: 通过 Security 认证
    Controller->>Role: 调用带 RequireSpaceRole 的 Service
    Role->>DB: 查有效空间与当前成员角色
    Role->>Role: 校验角色，设置 SpaceContext
    Role->>Service: proceed
    Service->>Service: 校验资源属于该空间、资源创建者等
    Service->>DB: 执行业务 SQL
    Service-->>Role: 返回或抛异常
    Role->>Role: finally remove ThreadLocal
    Controller-->>Client: Result
~~~

这里有三种不同检查：

1. **认证**：Token 是否有效，用户是谁。
2. **空间角色**：用户是不是这个空间的成员，角色是否允许执行该方法。
3. **资源权限**：文档/文件夹/标签是否属于当前空间；MEMBER 是否为资源创建者。

前端隐藏按钮无法替代后端这些检查。

### 3.3 统一响应和异常

`Result` 的业务成功码是 1，失败码是 0，不是 HTTP 状态码。

~~~json
{"code":1,"msg":"success","data":null}
~~~

普通业务异常由 `GlobalExceptionHandler` 返回 `Result.error`，没有额外设置 HTTP 4xx；JWT 认证失败由 `RestAuthenticationEntryPoint` 显式返回 HTTP 401 和失败 JSON。因此处理业务失败和处理 401 是两条路径。

`PageQuery` 的 `current` 默认 1、`size` 默认 20，用 `@Min`、`@Max` 校验。`MpConfig` 注册 MySQL 分页插件，`maxLimit=100`。`PageResult.from` 提取 `records,total,current,size,pages`。

## 4. 数据模型和索引

### 4.1 逻辑关系图

~~~mermaid
erDiagram
    USER ||--o{ SPACE : owns
    USER ||--o{ SPACE_MEMBER : joins
    SPACE ||--o{ SPACE_MEMBER : includes
    SPACE ||--o{ FOLDER : contains
    SPACE ||--o{ DOCUMENT : contains
    SPACE ||--o{ TAG : defines
    FOLDER o|--o{ FOLDER : parent
    FOLDER o|--o{ DOCUMENT : directory
    DOCUMENT ||--o{ DOCUMENT_TAG : has
    TAG ||--o{ DOCUMENT_TAG : labels
    DOCUMENT ||--o{ COMMENT : receives
    USER ||--o{ COMMENT : writes
    COMMENT o|--o{ COMMENT : reply
    USER ||--o{ OPERATION_LOG : triggers
    SPACE o|--o{ OPERATION_LOG : scopes
~~~

这是逻辑关系图。DDL 没有声明 FOREIGN KEY；根目录用 0 表示，不对应 folder 的真实行；评论 reply_to_id 可以为空，操作日志 space_id 也可以为空。

### 4.2 九张表

| 表 | 关键字段 | 业务含义 |
|---|---|---|
| `user` | username、password、nickname、email、avatar、status | password 是 BCrypt 散列；username 区分大小写且唯一；email 唯一 |
| `space` | name、description、owner_id、deleted | 空间、所有者和软删除状态 |
| `space_member` | space_id、user_id、role | 一个用户在不同空间可有不同角色 |
| `folder` | space_id、parent_id、name、created_by | 邻接表表示目录树，0 是根目录 |
| `document` | space_id、folder_id、name、file_type、file_size、file_path、description、upload_by、deleted | 元数据；file_path 是 MinIO 对象 key |
| `tag` | space_id、name | 标签属于空间 |
| `document_tag` | document_id、tag_id | 文档和标签多对多 |
| `comment` | document_id、user_id、content、reply_to_id、deleted | 评论及回复引用 |
| `operation_log` | user_id、space_id、operation_name、resource_type/id/name、success、error_message、duration_ms | 操作快照和结果 |

所有表使用自增 ID。初始化脚本包含 DROP TABLE，不能把它当成线上升级脚本执行。

### 4.3 索引与真实查询

| 索引 | 对应查询或约束 |
|---|---|
| `space_member UNIQUE(space_id,user_id)` | 防重复成员；AOP 按空间与用户查角色 |
| `space_member idx_user(user_id)` | 查询用户加入的空间 |
| `folder(space_id,parent_id)` | 查直接子文件夹、BFS 遍历 |
| `document(space_id,folder_id,deleted,updated_at,id)` | 目录内未删除文档分页、排序 |
| `document(space_id,deleted,updated_at,id)` | 空间回收站列表 |
| `tag UNIQUE(space_id,name)` | 空间内标签名唯一 |
| `document_tag UNIQUE(document_id,tag_id)` | 防止重复打同一个标签 |
| `document_tag(tag_id,document_id)` | 按标签查文档 |
| `comment(document_id,created_at,id)` | 文档评论正序分页 |
| `operation_log(user_id,created_at)`、`(space_id,created_at)`、`(resource_type,resource_id)` | 对应用户、空间和资源维度；当前动态 SQL 还使用 id 倒序，不能直接声称无排序开销 |
| `FULLTEXT ft_name(name)`、`ft_description(description)` | ngram 全文搜索 |

上述索引存在于 DDL；具体 SQL 是否命中、扫描多少行、是否 filesort，需要目标数据库的 EXPLAIN 才能确认。源码和注释不能证明性能指标。

### 4.4 删除语义

| 对象 | 删除方式 | 结果 |
|---|---|---|
| 空间 | 实体 `@TableLogic` | `deleted=1`；没有级联清空成员、文档和 MinIO |
| 文档 | 实体 `@TableLogic` | 普通删除进回收站 |
| 文件夹 | 无逻辑删除注解 | 物理删除；其中的文档先软删除 |
| 标签和标签关联 | 无逻辑删除注解 | 物理删除 |
| 评论 | 手动 `deleted=1` | 保留行和回复关系；列表隐藏正文 |

## 5. 登录、退出、改密和用户资料

### 5.1 注册和登录

`UserController.register/login` 先做 IP 限流，随后调用 `UserServiceImpl`。

注册：查用户名是否存在 → BCrypt encode → insert user。数据库 username 唯一索引是并发情况下的最终约束，“先查再插”本身不能保证并发唯一。

登录：查用户 → BCrypt matches → 检查 status → 生成 claims → 返回 `LoginResultVO(token,user)`。用户资料由 `UserProfileVO` 映射，不含密码。JWT 包含 userId、username、随机 UUID jti、iat、exp；签名 key 来自配置。

### 5.2 Security Filter 的细节

- Security 放行 POST 登录/注册及 health 路径，其余要求 authenticated。
- Filter 的 `shouldNotFilter` 跳过登录、注册和精确 health 路径。
- 没有 Authorization 头：继续 FilterChain，由后续 Security 拦截未认证请求。
- 格式不是 Bearer 或内容空：直接认证失败。
- Token 有效：读取 Redis 撤销状态，构造无权限列表的 `UsernamePasswordAuthenticationToken`，principal 是 `LoginUser`。
- 解析或撤销校验异常：清空 SecurityContext，返回 401。
- `FilterRegistrationBean` 关闭该 Component Filter 的 Servlet 自动注册，避免同时在 Servlet 链和 Security 链重复执行。

### 5.3 单 Token 退出与账号级失效

~~~mermaid
flowchart TD
    Logout["POST /user/logout"] --> Parse["解析当前 JWT 的 jti 与 exp"]
    Parse --> Revoke["Redis 写 revoked:jti\nTTL = exp - 当前时间"]
    Password["PUT /user/password"] --> Check["校验旧密码和新旧不同"]
    Check --> Update["数据库更新新 BCrypt hash"]
    Update --> Watermark["Redis 写 user-invalid-before:userId\n值 = 当前毫秒时间，TTL = 7天"]
    Watermark -->|"写入失败"| Rollback["尝试把密码 hash 更新回原值"]
    Revoke --> Next["后续受保护请求"]
    Watermark --> Next
    Next --> Reject["检查 jti 或 iat 小于水位，拒绝旧会话"]
~~~

“无状态 Session”不等于系统完全不保存登录状态：项目保存撤销信息，每次受保护请求依赖 Redis。单 token 撤销 key 到 token 到期时自然失效；用户水位到旧 token 最长有效期后也可过期。

改密方法没有数据库事务注解，Redis 失败时的恢复是再次执行 UPDATE 的补偿。并发改密、恢复失败及数据库/Redis之间的中断窗口不能描述为已获得分布式原子性。

JWT iat 按 JWT NumericDate 表达，代码以毫秒水位比较；同一秒改密后立即重新登录的边界值得验证。源码测试没有据此证明“所有时间边界均正确”。

### 5.4 资料与头像

nickname/email 未传时不更新，空白会转为 null；邮箱有格式/长度校验和重复检查。头像验证非空、2 MB 上限，允许 JPEG/PNG/GIF/WEBP 的 Content-Type。

头像 key 为 `avatar/{userId}/{uuid}{ext}`，上传到公共桶。新头像数据库写失败时删除新对象；成功后尝试删除旧头像，旧对象删除失败只写日志。Content-Type 检查依赖上传声明，代码没有文件内容嗅探或病毒扫描。

## 6. 空间权限：这个项目的核心横切逻辑

### 6.1 两层授权

`@RequireSpaceRole` 默认允许 OWNER、ADMIN、MEMBER。`SpaceRoleAspect` 反射读取方法和参数注解，从 `@SpaceId` 参数取空间 ID、从参数类型取 LoginUser，再查空间和成员表。

方法声明允许的角色通过后，把 SpaceMember 写到 `SpaceContext` 的 ThreadLocal；结束时 finally 调用 remove。这样 Service 可重复使用同一次角色检查结果，也避免线程池复用请求线程时遗留上一个用户的成员信息。

`ResourcePermissionHelper.checkOwnerOrCreator` 的规则是：仅 MEMBER 需要满足 creatorId=currentUserId，OWNER/ADMIN 可以操作空间内其他人的资源。

### 6.2 权限矩阵

| 操作 | OWNER | ADMIN | MEMBER | 源码额外规则 |
|---|---|---|---|---|
| 查看空间、目录、文档、标签、评论 | 允许 | 允许 | 允许 | 资源须属于当前空间 |
| 上传文档、创建目录、发表评论 | 允许 | 允许 | 允许 | 当前用户成为资源创建者 |
| 文档重命名/移动/删除/恢复/purge | 任意 | 任意 | 自己上传 | Helper 检查 uploadBy |
| 文件夹重命名/移动/删除 | 任意 | 任意 | 自己创建 | Helper 检查 createdBy |
| 文档增删标签 | 任意 | 任意 | 自己上传 | 标签也必须属于该空间 |
| 删除评论 | 任意 | 任意 | 自己发表 | Helper 检查 userId |
| 创建/改名/删除标签 | 允许 | 允许 | 拒绝 | 方法显式声明 OWNER/ADMIN |
| 修改空间信息 | 允许 | 允许 | 拒绝 | 方法注解 |
| 添加成员 | 允许 | 允许 | 拒绝 | 不能直接添加 OWNER；代码允许 ADMIN 添加 ADMIN |
| 移除成员 | 允许 | 部分允许 | 拒绝 | OWNER 不可移除；ADMIN 不能移除 ADMIN |
| 修改成员角色 | 允许 | 拒绝 | 拒绝 | 不能改自己、不能设 OWNER |
| 删除空间 | 允许 | 拒绝 | 拒绝 | 空间逻辑删除 |

`SpaceServiceImpl.getSpaceById/listMembers` 使用手动成员检查，不经过该 AOP；`listMySpaces`、最近浏览、动态通过 SQL 限制用户可见范围。

需要理解一个边界：MEMBER 删除自己创建的文件夹后，代码会级联处理整个子树内的文档，没有逐个检查子树内每份文档的上传者。因此不能把矩阵概括成“MEMBER 的所有操作绝不会影响他人的文件”。

## 7. 空间与文件夹

### 7.1 创建、查询和缓存

`createSpace` 用 `@Transactional` 保证插入 space 和 OWNER 的 space_member 同时成功。`listMySpaces` 用一个 SQL JOIN 成员关系，并通过相关子查询返回成员数、未删除文档数和 myRole；它减少应用层多次请求，不代表数据库内部只有一次简单扫描。

空间详情 `getSpaceById` 先查 Redis：

~~~mermaid
flowchart TD
    Request["getSpaceById"] --> Read["读取 teamdocs:space:id"]
    Read -->|"值为 NULL"| Missing["空间不存在"]
    Read -->|"JSON 命中"| Deserialize["反序列化 Space"]
    Read -->|"未命中或 Redis 读取失败"| DB["MySQL 查询未删除空间"]
    DB -->|"不存在"| NullCache["缓存 NULL 60秒"]
    NullCache --> Missing
    DB -->|"存在"| Cache["缓存 30分钟 + 0至300秒随机值"]
    Deserialize --> Member["MySQL 检查是否为成员"]
    Cache --> Member
    Member -->|"通过"| Response["返回空间"]
    Member -->|"失败"| Forbidden["业务异常"]
~~~

缓存值是共享空间信息，权限判断不缓存。更新/删除空间先改 MySQL，再删缓存。空值缓存降低反复查询不存在资源的成本，随机 TTL 分散集中失效；没有互斥锁或逻辑过期来防止热点 key 重建并发。

### 7.2 文件夹树、移动、删除

`FolderServiceImpl` 使用 parent_id 邻接表，根目录是 0。创建/移动时检查非根父目录存在且属于当前空间。

移动步骤：检查被移动目录 → 检查创建者权限 → 检查目标目录 → 拒绝自身 → BFS 收集所有子孙 ID → 拒绝目标属于自己的子孙 → 更新 parent_id。

BFS 使用 `Queue<Long> queue = new LinkedList<>()` 和 `ArrayList<Long>`。每弹出一个目录就查询一次直接子目录，目录数较多会产生多次 SQL；代码没有一次加载整棵树或递归 CTE，也没有 visited 集合。

删除步骤：检查目标和创建者 → BFS 收集包含自身的所有目录 ID → 批量逻辑删除这些目录中的 document → 物理删除 folder。该方法有数据库事务；MinIO 文件保留，文档可以从回收站恢复。

## 8. 文档生命周期与对象存储

### 8.1 上传全链路

入口：`POST /spaces/{spaceId}/documents/upload`，multipart 参数 `file`、`folderId`（默认 0）。

~~~mermaid
sequenceDiagram
    participant Client as 客户端
    participant Service as DocumentServiceImpl
    participant Store as MinioFileStorageServiceImpl
    participant MinIO as 私有桶
    participant DB as MySQL document
    participant Log as OperationLogAspect
    Client->>Service: 经 JWT、空间角色检查后 upload
    Service->>Service: 检查文件名、目录归属
    Service->>Service: 生成 space/id/yyyy-MM/uuid.ext
    Service->>Store: upload(file, PRIVATE, key)
    Store->>MinIO: putObject，传 InputStream
    MinIO-->>Service: 上传完成
    Service->>DB: insert 文档元数据
    alt SQL 失败或插入行数不是1
        Service->>MinIO: delete 新对象作补偿
        Service-->>Client: 抛异常
    else 插入成功
        Service-->>Log: 返回文档 ID，日志取 result 作为资源 ID
        Service-->>Client: Controller 返回 success，无文档 ID 数据
    end
~~~

元数据保存空间、目录、原名、对象 key、大小、MIME、上传者。扩展名来自原文件名最后一个点；UUID 用来隔离重名对象。显示名变更不会移动或改名 MinIO 对象，移动文档只改 folder_id。

这里的上传通过 Spring Boot 接收，再由 MinIO SDK 上传；不是前端直传，也没有业务级分片上传、秒传或断点续传接口。100 MB 限制来自 multipart 配置，`upload` 方法本身没有单独检查文件内容类型和 file.isEmpty。

补偿覆盖“对象成功后，SQL 执行抛 RuntimeException/插入失败”。如果补偿删除也失败，只记录错误并把清理异常作为 suppressed exception。进程在两个资源操作之间退出仍可能产生孤儿对象。

### 8.2 元数据列表与详情

`listByFolder` 校验目录属于空间，然后按 space_id + folder_id 分页，`updated_at DESC,id DESC` 排序。MyBatis-Plus 自动过滤 deleted。

`getDocumentDetail` 查有效文档并校验空间 → 查 document_tag → 批量查 Tag → 复制字段到 DocumentDetailVO → 沿 parent_id 反向查目录构建 folderPath → 异步记录最近浏览。

路径构建每层查询一次，遇到不存在目录就截断；循环没有 visited 检查，依赖目录树保持无环。详情 VO 没有 filePath，部分列表直接返回 Document 实体，其中包含 filePath。

### 8.3 下载与预览

`downloadDocument` 和 `previewDocument` 都先验证文档未删除且属于当前空间，再生成私有桶 URL，记录最近浏览。

| 接口 | 返回 | Content-Disposition |
|---|---|---|
| `/{documentId}/download` | URL 字符串 | attachment |
| `/{documentId}/preview` | documentId/name/fileType/fileSize/url | inline |

文件名使用 UTF-8 URL 编码放入 `filename*`。私有 URL 有效期为 1 小时，头像公共 URL 直接拼接。后端的两个 MinioClient 分别使用内部 endpoint 和浏览器可达的 publicEndpoint，签名从一开始就按外部端点生成。

私有桶鉴权发生在生成 URL 时；拿到 URL 的访问者在有效期内可以直接访问 MinIO。退出账号或被移出空间不会自动撤销已经发出的签名 URL，这是当前访问模型的边界。

### 8.4 回收站状态

~~~mermaid
stateDiagram-v2
    [*] --> Normal: 上传成功
    Normal --> Trash: 删除文档 / 删除所在目录
    Trash --> Normal: 恢复，deleted=0
    Trash --> Removed: purge
    Removed --> [*]
    note right of Normal
        document.deleted=0
        MinIO 对象存在
    end note
    note right of Trash
        document.deleted=1
        MinIO 对象保留
    end note
    note right of Removed
        清理对象、标签关系、document
    end note
~~~

恢复必须通过 XML 查询 deleted=1 的文档，因为普通 selectById 已过滤软删除。检查空间、创建者后，未指定目录就尝试原目录；原目录失效则回根目录并返回 `originalFolderDeleted=true`；指定目标目录则检查有效性。XML 更新 deleted=0 和 folder_id。

彻底删除 `purgeDocument` 顺序为：MinIO 删除 → document_tag 删除 → document 物理删除；仅允许操作回收站文档。它有 `@Transactional`，但对象删除不受数据库事务保护；SQL 最后失败时 MySQL 回滚，MinIO 文件仍已删除。当前方法没有清理 comment 表。

## 9. 标签、搜索和评论

### 9.1 标签

标签 CRUD：创建/重命名/删除需 OWNER 或 ADMIN，名称唯一性由 `UNIQUE(space_id,name)` 保证。删除标签使用事务，先删除关联再删标签。

给文档增删标签要同时检查 document.spaceId 和 tag.spaceId，并检查 MEMBER 是否为上传者。重复打标由 `UNIQUE(document_id,tag_id)` 拒绝，当前未专门处理成幂等成功响应。

批量文档标签查询最多 200 个传入 ID；XML JOIN document 过滤空间与 deleted。Java 用 LinkedHashMap 为每个请求 ID 初始化空列表，再填充返回记录。所以越权/不存在 ID 不会返回标签数据，但仍可能以空列表出现在 map 中。

### 9.2 搜索

`searchDocuments` 拒绝空白关键词，trim 后传入 XML；查询只覆盖当前空间的有效文档。

~~~sql
MATCH(d.name) AGAINST(#{keyword} IN BOOLEAN MODE)
OR MATCH(d.description) AGAINST(#{keyword} IN BOOLEAN MODE)
OR t.name LIKE CONCAT('%', #{keyword}, '%')
~~~

这段是 XML 中的实际匹配条件。名称和描述分别建 ngram FULLTEXT；标签仍是包含式 LIKE。LEFT JOIN 多个标签可能让一份文档出现多次，所以 SELECT DISTINCT；结果按更新时间和 ID，而不是相关性分数排序。

Service 的 `page.setOptimizeCountSql(false)` 保留原查询的 DISTINCT/JOIN 语义来计算总数。全文索引 SQL 关闭停用词，Compose 设置 ngram-token-size=2；两者都影响搜索行为。代码没有提取 PDF/Word 正文来索引，description 字段虽然可搜索，当前文档上传入口也没有接收描述并写入它。

### 9.3 评论与回复

`AddCommentDTO` 限制正文非空、最多 1000 字符，replyToId 非空时必须为正。Service 验证文档归属；回复目标须存在、属于同一文档、未删除，再 strip 正文保存。

删除评论检查其属于当前文档和操作者权限，更新 deleted=1。查询 XML 没有过滤删除行，而是 `CASE WHEN deleted=1 THEN NULL ELSE content END`，保留 ID、时间、用户和回复引用。数据返回是正序分页的平面列表，不是后端递归组装的评论树。

## 10. Redis：要能讲出 key、类型、TTL 和故障策略

### 10.1 使用清单

| key 前缀/形式 | 类型 | TTL/限制 | 代码入口 |
|---|---|---|---|
| `teamdocs:space:{id}` | JSON String 或 NULL 标记 | 正常30分钟+随机0~300秒；空值60秒 | SpaceServiceImpl |
| `teamdocs:rate:login:{ip}` | String 计数器 | 60秒，10次通过，第11次拒绝 | UserController、RateLimitServiceImpl |
| `teamdocs:rate:register:{ip}` | String 计数器 | 60秒，5次通过，第6次拒绝 | 同上 |
| `teamdocs:user:recent:{userId}` | ZSet | 最多保留20条；整 key 30天 | RecentDocumentServiceImpl |
| `teamdocs:auth:revoked:{jti}` | String "1" | Token 剩余有效期 | TokenRevocationServiceImpl |
| `teamdocs:auth:user-invalid-before:{userId}` | String 毫秒时间 | 7天 | 同上 |

### 10.2 固定窗口限流

Lua 核心就是 INCR；只有计数首次为1才 EXPIRE；返回计数。单脚本避免“加1成功但设置过期前程序中断”这种两个命令之间的窗口。过期时间从首个请求开始，不会每次续期；这不是滑动窗口。

`RateLimitServiceImpl` 在 Java 中比较计数是否大于阈值，Redis 出错/返回 null 时放行。key 的 IP 来自 `request.getRemoteAddr()`，Nginx 虽设置 X-Forwarded-For，但当前应用配置未显式设置 forwarded headers 策略；代理部署下是否得到真实客户端 IP，要在部署环境确认。

### 10.3 最近浏览 ZSet

`@Async recordRecentDocument`：

1. member=文档 ID，score=当前毫秒时间；再次浏览会更新同一 member 分数。
2. 给整个 key 续期 30 天。
3. `removeRange(0,-21)` 删除按升序排列中超出最新20个之外的旧成员。

这三步不是一个 Redis Lua 事务，短暂并发顺序不能称为严格原子。异步记录通过另一个 Spring Bean 调用，可以生效；用户 ID 显式传入，不依赖异步线程继承 SecurityContext 或 SpaceContext。

读取：倒序取前20个 ID/score → MySQL JOIN space 和 space_member 校验当前访问权 → 按 Redis 原顺序装配结果 → 将不可见/不存在 ID 从 ZSet 移除。MySQL IN 查询不会保证 Redis 顺序，所以 Java 建 map 后再次按原 ID 列表组装是必要的。

### 10.4 故障策略

普通 `CacheClient` 吞异常并记录日志：读取 String 失败返回 null，ZSet 读取失败返回空集合；写入和删除失败不打断业务。限流失败也放行。

Token 撤销相关 Redis 操作直接捕获并转成异常；Filter 拒绝该请求，返回401。因此“缓存支持降级”不能推出“Redis 完全宕机时业务仍能正常使用”，受保护请求还依赖认证 Redis 检查。

## 11. AOP 日志与数据库事务

### 11.1 日志如何收集信息

`OperationLogAspect` 的 `@Order(1)` 环绕带 `@OperationLog` 的方法。它从参数提取 LoginUser、SpaceId、OperationTarget，从 RequestContextHolder 获取请求方法和 URI。

resourceName 优先执行注解中的 SpEL，如 `#dto.name`、`#file.originalFilename`；没有表达式结果时，`OperationResourceNameResolver` 回查文档/目录/标签名称。名称在方法前获取，因此删除资源后仍可保留名称快照。上传额外设置 `resourceIdFromResult=true`，从 Service 返回的文档 ID 获取日志资源。

在 finally 中记录 success、errorMessage、durationMs 并保存，异常仍继续抛出。操作日志没有保存上传文件正文或完整请求参数。名称最多255字符，异常消息最多512字符。

### 11.2 REQUIRES_NEW 和日志展示

`OperationLogServiceImpl.saveLog` 开启独立事务。即使业务失败，也有机会保留失败日志；日志写失败只打印错误，原调用结果不被覆盖。这个动作是同步写库，没有 MQ 或异步日志队列。

动态只返回成功日志，JOIN 当前有效空间，按当前用户成员关系过滤；默认20、最大50，按日志ID倒序。数据库存失败日志不等于前端动态展示失败日志。

创建空间没有 SpaceId 参数、没有返回资源ID，当前日志可能有 resourceName，但 space_id/resource_id 为空；动态 JOIN space 无法展示这条创建空间日志。创建文件夹/标签没有返回资源ID，不能把它们说成所有日志都有完整资源定位。

### 11.3 实际事务清单

| 方法 | 数据库事务范围 | 外部资源边界 |
|---|---|---|
| `SpaceServiceImpl.createSpace` | space + owner member | 无跨存储事务 |
| `FolderServiceImpl.deleteFolder` | document软删 + folder物理删 | MinIO 保留 |
| `TagServiceImpl.deleteTag` | document_tag + tag | 无外部对象操作 |
| `DocumentServiceImpl.purgeDocument` | 关系和document删除 | MinIO 删除无法回滚 |
| `OperationLogServiceImpl.saveLog` | REQUIRES_NEW | 同步独立日志写库 |
| `UserServiceImpl.changePassword` | 无事务注解，手动补偿 | DB 和 Redis 非原子 |
| `DocumentServiceImpl.upload` | 无事务注解，单次插入和对象补偿 | DB 和 MinIO 非原子 |

权限切面没有显式 Order，事务 advice 默认顺序也不是在本项目中显式规定的。本文不把权限切面与事务开启的相对顺序画成可靠的固定保证；确需依赖时应检查实际代理链。

## 12. 接口速查：读源码时的入口

下列路径是后端路径；浏览器通过代理时通常要加 `/api`。

| 模块 | HTTP 和路径 | Service 方法 |
|---|---|---|
| 用户 | POST /user/register、/login | register / login |
| 用户 | GET /user/info；PUT /user/profile、/password；POST /user/avatar、/logout | getProfile / updateProfile / changePassword / updateAvatar / revoke |
| 最近浏览 | GET /user/recent-documents | getRecentDocuments |
| 空间 | POST /space；GET /space/list；GET/PUT/DELETE /space/{id} | createSpace / listMySpaces / getSpaceById / updateSpace / deleteSpace |
| 成员 | POST/GET /space/{id}/members；DELETE/PUT /space/{id}/members/{userId} | addMember / listMembers / removeMember / updateMemberRole |
| 目录 | POST/GET /spaces/{s}/folders；PUT/DELETE /spaces/{s}/folders/{f}；PUT /.../{f}/move | FolderService |
| 文档 | POST /spaces/{s}/documents/upload；GET /spaces/{s}/documents | upload / listByFolder |
| 文档 | GET/DELETE /spaces/{s}/documents/{d} | getDocumentDetail / deleteDocument |
| 文档 | PUT /.../{d}/rename、/move；GET /.../{d}/download、/preview | 对应文档方法 |
| 回收站 | GET /spaces/{s}/documents/trash；PUT /.../{d}/restore；DELETE /.../{d}/purge | listTrashedDocuments / restoreDocument / purgeDocument |
| 搜索 | GET /spaces/{s}/documents/search?keyword=... | searchDocuments |
| 标签 | POST/GET /spaces/{s}/tags；PUT/DELETE /spaces/{s}/tags/{t} | createTag / getTags / renameTag / deleteTag |
| 打标 | POST/DELETE /spaces/{s}/documents/{d}/tags/{t} | addTagToDocument / removeTagFromDocument |
| 标签查询 | GET /spaces/{s}/documents/{d}/tags；GET /spaces/{s}/documents/tags?documentIds=... | listTagsByDocument / listTagsByDocuments |
| 标签筛选 | GET /spaces/{s}/tags/{t}/documents | listDocumentsByTag |
| 评论 | POST/GET /spaces/{s}/documents/{d}/comments；DELETE /.../comments/{c} | CommentService |
| 动态 | GET /activities?spaceId=...&limit=... | listRecentActivities |

请求细节：文档/目录重命名 body 是 newName；标签重命名的 newName 是 query 参数。恢复目标目录允许不传；搜索、目录文档、回收站、按标签文档、评论使用 PageQuery。

## 13. 部署和排错

### 13.1 部署关系

~~~mermaid
flowchart TB
    Nginx["frontend Nginx :80"] -->|"API 代理"| Boot["backend :8080"]
    Nginx -->|"静态资源 / SPA fallback"| Dist["Vue dist"]
    Boot --> MySQL[("mysql :3306")]
    Boot --> Redis[("redis :6379")]
    Boot --> MinIO[("minio :9000")]
    Init["minio-init 一次性任务"] -->|"创建公私桶，公共桶允许匿名下载"| MinIO
    Boot -.-> BH["/actuator/health"]
    Nginx -.-> FH["/healthz"]
~~~

开发 Compose 含 MySQL、Redis、MinIO、minio-init、backend；前端可通过 Vite 5173运行。生产 Compose 额外包含 frontend；后端等 MySQL/Redis healthy 和桶初始化完成，前端等后端 healthy。

后端 Dockerfile 用 Maven+Java17 构建，在 Java17 JRE Alpine 中以非root用户运行；构建命令跳过测试。生产数据卷为 external，部署脚本按 commit 打 tag、校验配置、构建、启动并等待健康。

### 13.2 需要配置什么

数据库：DB_HOST/PORT/NAME/USERNAME/PASSWORD；Redis：REDIS_HOST/PORT/PASSWORD；JWT_SECRET；MinIO内部与公共端点、region、access/secret key、公私桶名称。生产 Compose 还需要镜像、卷名和对外端口变量。

`MINIO_ENDPOINT` 是后端可达地址，`MINIO_PUBLIC_ENDPOINT` 是浏览器可达地址，两者混淆会造成“后端上传成功，浏览器打不开签名URL”。Nginx 在 API 代理处移除 /api 前缀。它限制请求体105m，放宽上传超时，关闭请求缓冲。

### 13.3 按症状查代码

| 症状 | 排查顺序 |
|---|---|
| 请求全是401 | Authorization格式 → JWT key/exp → jti和iat → Redis连接和撤销状态 |
| 登录被限流 | getRemoteAddr实际值 → 对应rate key和TTL → 是否共享代理IP |
| 空间提示无权限 | space.deleted → space_member行 → role →资源spaceId/creator |
| 上传成功但列表没文件 | MinIO上传和document插入日志 →spaceId/folderId →deleted过滤 |
| 下载/预览打不开 | 签名URL是否过期 →publicEndpoint可达性 →CORS/浏览器错误 →对象key与bucket |
| 搜索无结果 | SQL全文索引是否存在 →ngram/停用词设置 →搜索的是名称/描述/标签还是正文 |
| 回收站恢复到根目录 | 原folder已物理删除，查看originalFolderDeleted |
| 最近浏览缺失 | 异步记录是否完成 →Redis故障 →文档/空间是否删除 →成员是否移除 |
| 动态没显示操作 | 是否有OperationLog →保存是否成功 →success/space_id/resource_id →动态SQL过滤 |

## 14. 当前边界：面试不要说过头

| 可以由代码证明 | 不能据此声称 |
|---|---|
| 有空值缓存、随机TTL | 已解决热点缓存重建并发、强一致缓存 |
| Redis Lua窗口计数 | 实现了滑动窗口或全局精确风控 |
| JWT撤销和用户失效水位 | Redis宕机时所有功能仍完全可用 |
| MinIO失败补偿 | MySQL和MinIO跨资源原子提交 |
| 数据库事务及日志独立事务 | 所有外部副作用都能回滚 |
| 目录移动前防环检查 | 并发交叉移动不会产生环；源码没有锁/版本控制保障 |
| 应用层空间权限与唯一索引 | 数据库外键约束完善或并发修改已全面覆盖 |
| 文件预览和共享 | 实时协同编辑、文件正文检索、版本历史 |
| Docker Compose部署 | 已拆微服务、生产集群高可用、压测指标达到某数值 |

值得理解的现有局限还包括：purge未清理评论；空间软删后底层记录和对象保留；缓存删除失败可能留下旧空间信息；异步记录没有项目自定义线程池/持久重试；已签发的1小时对象URL在应用撤权后仍可能使用至过期。这些是理解取舍的材料，不是要求现在全部改造。

## 15. 面试表达：从代码推导

### 15.1 约三分钟的介绍结构

先讲业务：围绕空间协作管理文档，角色有OWNER/ADMIN/MEMBER。再讲架构：Spring Boot分层单体，MySQL元数据、MinIO文件、Redis辅助状态。接着选两个自己确实掌握的实现展开，例如空间角色AOP、上传补偿、回收站、最近浏览和全文搜索。最后说明已验证的场景和当前边界。

可以用作项目层面介绍的内容：

> TeamDocs是一个团队文档管理项目，以空间隔离成员和资源。后端用Spring Security自定义JWT过滤器认证，空间角色通过方法注解和AOP统一检查，普通成员修改资源时再验证创建者。文件上传经过后端写入MinIO私有桶，MySQL保存元数据，数据库写失败时尝试删除新对象。普通删除采用逻辑删除保留文件，恢复支持原目录失效时回退根目录。Redis用于空间缓存、窗口限流、最近浏览ZSet和Token撤销；文档名与描述使用MySQL ngram全文索引，操作日志由AOP单独写库。

其中“我负责...”必须按你的真实参与范围另加，不能从这个模板推断你负责整个系统。

### 15.2 高频追问和回答要点

| 追问 | 应答要点 | 回到哪里 |
|---|---|---|
| JWT怎么退出？ | jti黑名单；剩余TTL；每次鉴权检查 | TokenRevocationServiceImpl |
| 改密怎么踢掉其它会话？ | 用户invalid-before水位；iat比较；Redis失败手动恢复hash | UserServiceImpl |
| 为什么角色不放JWT？ | 当前实现从成员表按空间查询，同一用户不同空间角色不同 | SpaceRoleAspect |
| ThreadLocal为什么清理？ | 请求线程复用；防串用户和对象滞留；finally remove | SpaceContext、SpaceRoleAspect |
| 上传怎么避免重名和脏数据？ | UUID对象key；SQL失败删除对象；仍有进程中断窗口 | DocumentServiceImpl.upload |
| 为什么不直接存文件到MySQL？ | 实现选择元数据与二进制分开；签名URL让客户端下载 | MinioFileStorageServiceImpl |
| 删除和恢复怎么关联？ | deleted位；MinIO保留；目录不存在回根 | restoreDocument |
| 为什么最近浏览回MySQL？ | Redis只存ID和时间；当前权限和资源有效性由DB确认 | RecentDocumentServiceImpl |
| Redis坏了怎么办？ | 普通缓存降级；限流放行；认证撤销检查拒绝 | CacheClient/RateLimit/TokenRevocation |
| 搜索是不是文件内容搜索？ | 只name、description、tag；未解析文件正文 | DocumentMapper.xml |
| SQL为什么DISTINCT？ | 多标签JOIN去重；关闭count优化保持总数语义 | searchDocuments |
| 日志为什么REQUIRES_NEW？ | 业务失败仍留痕；写日志失败不覆盖业务结果 | OperationLogServiceImpl |
| 文件夹树怎么防环？ | BFS查子孙，拒绝移向自身/子孙；并发移动仍需考虑 | FolderServiceImpl |
| 哪些地方用了集合？ | BFS的Queue/ArrayList；最近浏览HashMap；批量标签LinkedHashMap | 各Service实现 |

答题顺序：**业务问题 → 实现类/方法 → 操作顺序 → 为什么这样做 → 当前限制**。不要用一般八股替代实际项目流程。

## 16. 对照源码的学习任务

1. **画请求链路**：打开SecurityConfig、JwtAuthenticationFilter、DocumentController和SpaceRoleAspect，解释LoginUser从哪里来。
2. **画数据图**：对照九张表，解释space_member、document_tag为什么是关联表，根目录和deleted怎样表示。
3. **跟上传和下载**：从Controller到MinIO和documentMapper，逐个说明失败分支，区分后端上传与浏览器下载。
4. **跟回收站**：模拟删除目录、恢复文档、彻底删除，写出各表和对象是否还存在。
5. **列Redis键**：不看资料写出类型、TTL、读写入口、失败策略，再对照RedisConstants。
6. **跟搜索SQL**：说明WHERE、JOIN、DISTINCT、ORDER BY、分页count的作用。
7. **跟日志**：选上传和删除两个方法，说明resourceId/name怎样得到、失败日志保存在哪里。
8. **口述一遍**：用上节问题自测；答不出时回到具体方法，不重新从第一页读整本笔记。

建议亲自验证的业务场景：不同角色操作同一文档；跨空间传错ID；上传失败补偿；删除目录后的恢复；退出/改密后旧JWT；重复打标；被移出空间后的最近浏览；多标签搜索分页。验证结果要记录真实输入和输出，不能把测试设想写成已验证结论。

## 17. 源码导航

以下路径相对 `F:\CodeProject\TeamDocs`。

| 主题 | 源码 |
|---|---|
| 启动与依赖 | `teamdocs-backend/pom.xml`；`src/main/java/asia/creat/TeamdocsBackendApplication.java`；`src/main/resources/application.yaml` |
| 用户链路 | `controller/UserController.java`；`service/impl/UserServiceImpl.java` |
| 鉴权 | `config/SecurityConfig.java`；`filter/JwtAuthenticationFilter.java`；`security/RestAuthenticationEntryPoint.java`；`utils/JWTUtils.java` |
| 撤销 | `service/impl/TokenRevocationServiceImpl.java` |
| 空间权限 | `anno/RequireSpaceRole.java`；`anno/SpaceId.java`；`aspect/SpaceRoleAspect.java`；`security/SpaceContext.java`；`helper/ResourcePermissionHelper.java` |
| 空间/目录/文档 | `service/impl/SpaceServiceImpl.java`；`FolderServiceImpl.java`；`DocumentServiceImpl.java` |
| 标签/评论 | `service/impl/TagServiceImpl.java`；`CommentServiceImpl.java` |
| Redis | `utils/RedisConstants.java`；`utils/CacheClient.java`；`service/impl/RateLimitServiceImpl.java`；`RecentDocumentServiceImpl.java` |
| MinIO | `config/MinioConfig.java`；`service/FileStorageService.java`；`service/impl/MinioFileStorageServiceImpl.java` |
| 日志 | `aspect/OperationLogAspect.java`；`helper/OperationResourceNameResolver.java`；`service/impl/OperationLogServiceImpl.java` |
| SQL | `sql/*.sql`；`teamdocs-backend/src/main/resources/asia/creat/mapper/*.xml` |
| 部署 | `docker-compose.dev.yml`；`docker-compose.prod.yml`；两端Dockerfile；`teamdocs-frontend/nginx.conf`；`scripts/deploy.sh` |

表中省略前缀的Java路径均以 `teamdocs-backend/src/main/java/asia/creat/` 为起点。

关键方法可直接跳转到源码：

- [JWT过滤器](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/filter/JwtAuthenticationFilter.java:29)、[空间角色切面](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/aspect/SpaceRoleAspect.java:30)、[操作日志切面](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/aspect/OperationLogAspect.java:35)
- [文档上传](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/DocumentServiceImpl.java:68)、[文档详情](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/DocumentServiceImpl.java:178)、[下载/预览](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/DocumentServiceImpl.java:215)、[恢复](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/DocumentServiceImpl.java:261)、[彻底删除](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/DocumentServiceImpl.java:301)、[搜索](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/DocumentServiceImpl.java:332)
- [空间缓存和成员逻辑](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/SpaceServiceImpl.java:60)、[目录删除](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/FolderServiceImpl.java:89)、[最近浏览](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/RecentDocumentServiceImpl.java:37)、[Token撤销](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/service/impl/TokenRevocationServiceImpl.java:38)
- [文档控制器](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/controller/DocumentController.java:19)、[安全配置](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/config/SecurityConfig.java:30)、[Redis常量](F:/CodeProject/TeamDocs/teamdocs-backend/src/main/java/asia/creat/utils/RedisConstants.java:5)

### 17.1 已有测试的覆盖地图

仓库现有测试主要是 Mockito/单元级边界验证，适合用来反向阅读代码：

| 测试类 | 已覆盖的典型边界 |
|---|---|
| `JwtAuthenticationFilterTest` | 有效 Token、缺失/格式错误请求头、撤销 Token、用户会话失效、Redis 检查失败 |
| `SpaceRoleAspectTest` | 角色允许、角色拒绝、非成员、ThreadLocal 清理 |
| `DocumentServiceImplTest` | 上传元数据、对象补偿、跨空间目录、恢复回根目录、下载/预览最近浏览、purge 顺序 |
| `FolderServiceImplTest` | 删除目录时子树和文档限定在当前空间 |
| `CommentServiceImplTest` | 回复目标校验、正文清理、作者/管理员删除权限、跨文档拒绝 |
| `RecentDocumentServiceImplTest` | ZSet 写入与20条裁剪、恢复 Redis 顺序、移除无权文档 |
| `RateLimitServiceImplTest` | 首次/达到/超过阈值、Redis 空值或异常时放行 |
| `TokenRevocationServiceImplTest` | jti TTL、Redis 异常、用户失效水位比较 |
| `UserServiceImplTest` | 登录、改密及补偿、资料/邮箱、头像上传与清理 |

这些测试没有替代真实 MySQL `EXPLAIN`、MinIO/Redis 集成环境、并发移动或线上性能验证；不要把测试类名当成全部场景都已通过的证明。

## 18. 验证说明

本笔记基于源码静态分析，不以注释中的意图代替实际分支。未读取已有项目Markdown，未修改后端业务代码，未执行数据库初始化或真实业务写入。仓库已有的单元测试可以继续用于理解边界，但Mock测试不能证明MySQL索引效果、MinIO可达性、并发安全或线上性能。
