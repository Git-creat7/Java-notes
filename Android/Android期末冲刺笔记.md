# Android移动应用开发 期末考试冲刺笔记
> 基于5份实验报告 + 9份作业题目 的完整分析
> 教师：王治国 | 班级：移动软件24-03班

---

## 📊 知识点频率统计

### 🔴 高频出现（≥3次）
| 知识点 | 出现位置 | 频率 |
|--------|---------|------|
| **ListView + BaseAdapter** | 实验1, 实验3, Test-1 | 5次 |
| **RecyclerView + Adapter** | 实验5, Test-3 | 4次 |
| **Intent 数据传递 (putExtra/getExtra)** | 实验2, Test-4, Test-5 | 5次 |
| **startActivityForResult + onActivityResult** | 实验2, Test-5 | 4次 |
| **SQLiteOpenHelper CRUD** | 实验3, Test-9 | 4次 |
| **SharedPreferences** | 实验3, 实验5 | 3次 |
| **Toast** | 实验1, Test-2 | 3次 |
| **AlertDialog** | Test-4, 实验3 | 3次 |
| **Activity生命周期** | 实验2, Test-5, Test-7 | 3次 |
| **Fragment 动态/静态加载** | 实验2, Test-7 | 3次 |

### 🟡 中频出现（2次）
| 知识点 | 出现位置 |
|--------|---------|
| **Service + onBind/onStartCommand** | 实验4, Test-8 |
| **BroadcastReceiver** | 实验4, Test-8 |
| **JSON解析 (JSONObject)** | 实验5, Test-6 |
| **HttpURLConnection POST/GET** | 实验5, Test-6 |
| **MediaStore 内容提供者** | 实验4 |
| **ContentObserver** | Test-7 |
| **Handler 线程通信** | 实验5 |
| **File 存储** | 实验3 |
| **样式/主题/国际化** | 实验1 |
| **WebView** | 实验5 |

### 🟢 低频出现（1次）
| 知识点 | 出现位置 |
|--------|---------|
| **布局 XML 基础** | 实验1 |
| **Button onClick** | Test-2 |
| **EditText getText** | Test-2 |
| **Navigation 组件** | 实验5 |
| **Material Design** | 实验5 |

---

## 🎯 教师出题偏好分析

### 核心特征：
1. **代码填空题** 是绝对主流 —— 给出不完整代码，编号留空，按空给分
2. **每题标注分值**，总分通常 10-20 分
3. **偏爱考查"套路代码"** —— 即固定写法、模板化代码
4. **Adapter 必考** —— 不管是 ListView 还是 RecyclerView，至少出一个
5. **Intent 传参必考** —— Activity 跳转 + 数据传递
6. **数据库必考** —— SQLiteOpenHelper 创建/升级/查询
7. **四大组件** 全部覆盖：Activity, Service, BroadcastReceiver, ContentProvider
8. **有答案的题目** 可能直接改编为考试题（教师出题风格一致）

### 最可能的题型分布（总分100分预估）：
- 选择题/填空题：20分（基础概念）
- 代码填空题：50分（Adapter、Intent、Dialog、数据库）
- 简答题：10分（生命周期、组件区别）
- 综合编程题：20分（完整功能实现）

---

## 📖 第一阶段：必背知识点

### 1. ListView + BaseAdapter 模板（必背 ★★★★★）
**可能出题形式**：代码填空（4-5空，每空2-4分）

```java
class MyAdapter extends BaseAdapter {
    private List<Student> mData;     // 数据源
    private Context mContext;         // 上下文

    public MyAdapter(Context context, List<Student> data) {
        this.mContext = context;
        this.mData = data;
    }

    @Override
    public int getCount() {
        return mData.size();          // 【必填】返回数据总数
    }

    @Override
    public Object getItem(int position) {
        return mData.get(position);   // 【必填】返回当前位置数据
    }

    @Override
    public long getItemId(int position) {
        return position;              // 【必填】返回item id
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            // 【必填】加载布局
            convertView = LayoutInflater.from(mContext)
                .inflate(R.layout.item_layout, parent, false);
            holder = new ViewHolder();
            holder.tv1 = convertView.findViewById(R.id.tv1);
            holder.tv2 = convertView.findViewById(R.id.tv2);
            convertView.setTag(holder);  // 【必填】保存holder
        } else {
            holder = (ViewHolder) convertView.getTag(); // 【必填】取出holder
        }
        // 绑定数据
        Student s = mData.get(position);
        holder.tv1.setText(s.getName());
        holder.tv2.setText(s.getStatus());
        return convertView;
    }

    static class ViewHolder {  // 【必填】内部类
        TextView tv1, tv2;
    }
}

// 设置适配器
listView.setAdapter(new MyAdapter(this, dataList)); // 【必填】
```

**关键空位记忆口诀**：
- getCount → size, getItem → get(position), getItemId → position
- inflate → mContext, convertView == null → setTag, else → getTag
- ViewHolder → static class

### 2. RecyclerView + Adapter 模板（必背 ★★★★★）
**可能出题形式**：代码填空（5-6空，每空2-4分）

```java
class RvAdapter extends RecyclerView.Adapter<RvAdapter.MyHolder> {

    @NonNull @Override
    public MyHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // 【必填】加载布局，创建ViewHolder
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_layout, parent, false);
        return new MyHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull MyHolder holder, int position) {
        // 【必填】绑定数据
        Item item = dataList.get(position);
        holder.tv1.setText(item.getName());
        holder.tv2.setText(item.getInfo());
    }

    @Override
    public int getItemCount() {
        // 【必填】返回数量
        return dataList == null ? 0 : dataList.size();
    }

    class MyHolder extends RecyclerView.ViewHolder {
        TextView tv1, tv2;  // 【必填】声明控件变量

        public MyHolder(@NonNull View itemView) {
            super(itemView);
            // 【必填】findViewById
            tv1 = itemView.findViewById(R.id.tv1);
            tv2 = itemView.findViewById(R.id.tv2);
        }
    }
}

// 设置适配器（3行固定写法）
RecyclerView rv = findViewById(R.id.rv1);
rv.setLayoutManager(new LinearLayoutManager(this));  // 【必填】
rv.setAdapter(new RvAdapter(dataList));              // 【必填】
```

**ListView vs RecyclerView 区别**：
| | ListView | RecyclerView |
|---|---|---|
| 适配器基类 | BaseAdapter | RecyclerView.Adapter |
| ViewHolder | 手动优化 | 强制使用 |
| 布局管理器 | 不需要 | 必须 setLayoutManager |
| getView | 需要重写 | 改为 onCreateViewHolder + onBindViewHolder |

### 3. Intent 数据传递（必背 ★★★★★）
**可能出题形式**：代码填空 / 简答

**A → B 传递数据：**
```java
// ActivityA 中
Intent intent = new Intent(ActivityA.this, ActivityB.class);
intent.putExtra("key_name", value);   // 存入数据
startActivity(intent);
```

**B 接收数据：**
```java
// ActivityB 中
Intent intent = getIntent();
String data = intent.getStringExtra("key_name"); // 取出数据
```

**A → B → A 带回数据（startActivityForResult）：**
```java
// ActivityA：发起跳转
startActivityForResult(intent, REQUEST_CODE);  // REQUEST_CODE是自定义int常量

// ActivityA：接收返回
@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == REQUEST_CODE && resultCode == RESULT_OK) {
        String phone = data.getStringExtra("phone");
    }
}

// ActivityB：返回数据
Intent intent = new Intent();
intent.putExtra("phone", phoneNumber);
setResult(RESULT_OK, intent);
finish();  // 关闭当前页面，返回上一页
```

### 4. SQLiteOpenHelper + 数据库操作（必背 ★★★★）
**可能出题形式**：代码填空 / 编程题

```java
// ① 创建 Helper
public class MyHelper extends SQLiteOpenHelper {
    public MyHelper(Context context) {
        super(context, "mydb.db", null, 1);  // 数据库名，版本号
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        // 【必背】建表SQL
        String sql = "CREATE TABLE user(_id INTEGER PRIMARY KEY AUTOINCREMENT,"
                   + "name TEXT, password TEXT)";
        db.execSQL(sql);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // 【必背】升级时添加列，保留原数据
        String sql = "ALTER TABLE user ADD COLUMN state TEXT";
        db.execSQL(sql);
    }
}

// ② 创建实例
MyHelper helper = new MyHelper(this);

// ③ 获取数据库
SQLiteDatabase db = helper.getWritableDatabase();  // 可写
SQLiteDatabase db = helper.getReadableDatabase();  // 只读

// ④ 增删改查
// 增
ContentValues values = new ContentValues();
values.put("name", name);
values.put("password", pwd);
db.insert("user", null, values);

// 查
Cursor cursor = db.query("user", null, "name=? AND password=?",
                         new String[]{name, pwd}, null, null, null);
if (cursor.moveToFirst()) { /* 验证成功 */ }

// 改
ContentValues values = new ContentValues();
values.put("name", newName);
db.update("user", values, "name=?", new String[]{oldName});

// 删
db.delete("user", "name=?", new String[]{name});

// ⑤ 关闭
cursor.close();
db.close();
```

**记忆技巧**：
- 创建表 → CREATE TABLE (onCreate)
- 加列不丢数据 → ALTER TABLE ADD COLUMN (onUpgrade)
- 增 → insert(table, null, ContentValues)
- 查 → query → Cursor → moveToFirst
- 改 → update(table, ContentValues, whereClause, whereArgs)
- 删 → delete(table, whereClause, whereArgs)

### 5. AlertDialog（必背 ★★★★）
**可能出题形式**：代码填空（5空，每空2分）

```java
new AlertDialog.Builder(this)
    .setTitle("标题")                          // 填空1
    .setMessage("确定要退出吗？")               // 填空2
    .setPositiveButton("确定", new DialogInterface.OnClickListener() {
        @Override
        public void onClick(DialogInterface dialog, int which) {
            finish();  // 填空3：退出应用
        }
    })
    .setNegativeButton("取消", null)           // 填空4
    .create()    // 或者写成 .show()
    .show();     // 填空5：显示对话框
```

### 6. Service + BroadcastReceiver（必背 ★★★★）
**可能出题形式**：代码填空

```java
// Service 端
public class MyService extends Service {
    public class MyBinder extends Binder {
        // 返回Service实例，供Activity调用
    }

    @Override
    public IBinder onBind(Intent intent) {
        return new MyBinder();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        return super.onStartCommand(intent, flags, startId);
    }

    public void play() {
        // 发送广播
        Intent intent = new Intent("com.example.MY_ACTION");  // action字符串
        intent.putExtra("key", "zzuli");
        sendBroadcast(intent);  // 【必填】发送广播
    }
}

// Activity 端：启动和绑定服务
Intent serviceIntent = new Intent(this, MyService.class);
startService(serviceIntent);  // 启动服务
// 或
bindService(serviceIntent, connection, Context.BIND_AUTO_CREATE); // 绑定服务

// 通过 Binder 调用服务方法
MyService.MyBinder binder = (MyService.MyBinder) service;
binder.play();  // 需要通过ServiceConnection获取
```

```java
// BroadcastReceiver 端
class MyReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        String data = intent.getStringExtra("key"); // 【必填】接收数据
        tv1.setText(data);
    }
}

// 注册接收者（动态注册）
MyReceiver receiver = new MyReceiver();
IntentFilter filter = new IntentFilter("com.example.MY_ACTION");
registerReceiver(receiver, filter);

// 记得在 onDestroy 中注销
@Override
protected void onDestroy() {
    unregisterReceiver(receiver);  // 【必填】取消注册
    super.onDestroy();
}
```

### 7. Toast（必背 ★★★）
```java
Toast.makeText(this, "显示内容", Toast.LENGTH_SHORT).show();
//     上下文      文本内容          显示时长
```

### 8. ContentObserver（必背 ★★★）
```java
// 注册
ContentObserver observer = new ContentObserver(new Handler()) {
    @Override
    public void onChange(boolean selfChange, Uri uri) {
        // 数据变化时查询并更新UI
        Cursor cursor = getContentResolver().query(uri, null, null, null, null);
        // ... 处理cursor
    }
};
getContentResolver().registerContentObserver(
    Uri.parse("content://cn.zzuli.mycp"), true, observer);

// 取消注册（在 onDestroy 中）
getContentResolver().unregisterContentObserver(observer);
```

### 9. Fragment 动态加载（必背 ★★★）
```java
getSupportFragmentManager()
    .beginTransaction()
    .replace(R.id.fcv, new MyFragment())  // fcv是FragmentContainerView的id
    .commit();
```

### 10. JSON 解析（必背 ★★★）
```java
// 解析 JSON 字符串
List<Article> parseArticle(String strJson) {
    List<Article> list = new ArrayList<>();
    try {
        JSONObject root = new JSONObject(strJson);
        int errorCode = root.getInt("errorCode");
        if (errorCode == 0) {
            JSONArray dataArray = root.getJSONArray("data");
            for (int i = 0; i < dataArray.length(); i++) {
                JSONObject obj = dataArray.getJSONObject(i);
                Article article = new Article();
                article.setDesc(obj.getString("desc"));
                article.setId(obj.getInt("id"));
                article.setTitle(obj.getString("title"));
                article.setUrl(obj.getString("url"));
                list.add(article);
            }
        }
    } catch (JSONException e) {
        e.printStackTrace();
    }
    return list;
}
```

### 11. SharedPreferences 读写（必背 ★★★）
```java
// 保存
SharedPreferences sp = getSharedPreferences("config", MODE_PRIVATE);
sp.edit().putString("username", username)
         .putString("password", password)
         .apply();  // 或 .commit()

// 读取
SharedPreferences sp = getSharedPreferences("config", MODE_PRIVATE);
String username = sp.getString("username", "");  // 第二个参数是默认值
String password = sp.getString("password", "");
```

### 12. HttpURLConnection POST 请求（必背 ★★★）
```java
String httpPost(String url, String name, String pwd) {
    try {
        URL u = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setDoInput(true);
        // 拼接参数
        String params = "username=" + URLEncoder.encode(name, "UTF-8")
                      + "&password=" + URLEncoder.encode(pwd, "UTF-8");
        // 写出参数
        OutputStream os = conn.getOutputStream();
        os.write(params.getBytes());
        os.close();
        // 读取返回
        InputStream is = conn.getInputStream();
        // InputStream → String（用BufferedReader读取）
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        reader.close();
        return sb.toString();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

// 注意：网络请求必须在子线程中执行！
new Thread(new Runnable() {
    @Override
    public void run() {
        String result = httpPost(url, name, pwd);
        // 更新UI必须在主线程，使用 Handler 或 runOnUiThread
    }
}).start();
```

---

## 📖 第二阶段：常考简答题

### Q1: Activity的生命周期有哪些方法？
**答案**：onCreate → onStart → onResume → (运行中) → onPause → onStop → onDestroy
- 从不可见回到前台：onRestart → onStart → onResume
- **关键**：onCreate 只调用一次初始化，onResume 获得焦点，onPause 失去焦点

### Q2: ListView 与 RecyclerView 的区别？
**答案**：
- RecyclerView 强制使用 ViewHolder 模式，性能更好
- RecyclerView 需要设置 LayoutManager（LinearLayoutManager/GridLayoutManager）
- RecyclerView 解耦了布局、动画、item分隔
- ListView 用 BaseAdapter，RecyclerView 用 RecyclerView.Adapter

### Q3: SharedPreferences 与 File 存储的区别？
**答案**：
- SharedPreferences：键值对存储，适合小量配置数据（自动生成XML文件）
- File：流式读写，适合大量文本/二进制数据，需要手动管理文件路径
- SP 更简单但安全性低，File 更灵活但代码多

### Q4: Service 的两种启动方式及区别？
**答案**：
- **startService**：启动后独立运行，不受启动者生命周期影响
- **bindService**：绑定后与启动者生命周期关联，启动者销毁则Service解绑
- startService 用于后台任务（如播放音乐），bindService 用于组件间通信

### Q5: BroadcastReceiver 的两种注册方式？
**答案**：
- **静态注册（AndroidManifest.xml）**：应用未启动也能接收
- **动态注册（registerReceiver）**：必须在代码中注册，组件销毁时必须 unregisterReceiver

### Q6: SQLiteOpenHelper onCreate 和 onUpgrade 分别在什么时候调用？
**答案**：
- **onCreate**：数据库文件不存在时（首次创建）调用
- **onUpgrade**：数据库版本号增加时调用（用于升级表结构）

---

## 📖 第三阶段：代码题模板速记

### 模板1：Adapter 填空全模板
```
getCount()       → return xxx.size();
getItem(i)       → return xxx.get(i);
getItemId(i)     → return i;
getView(...)     → inflate + ViewHolder(setTag/getTag) + 绑定数据
onCreateViewHolder → inflate + return new ViewHolder(view)
onBindViewHolder   → holder.tv.setText(data.get(position).getXxx())
onCreateViewHolder中的findViewById → tv = itemView.findViewById(R.id.tv)
```

### 模板2：Intent 填空速记
```
跳转: Intent(this, B.class) → putExtra("k", v) → startActivity(intent)
接收: getIntent() → getStringExtra("k")
返回: setResult(RESULT_OK, intent) → finish()
接收返回: onActivityResult → data.getStringExtra("k")
```

### 模板3：Dialog 填空速记
```
setTitle → setMessage → setPositiveButton → setNegativeButton → show()/create()
确定按钮回调 → finish()
```

### 模板4：数据库填空速记
```
建库: super(context, "name.db", null, version)
建表: db.execSQL("CREATE TABLE t(_id INTEGER PRIMARY KEY AUTOINCREMENT, ...)")
加列: db.execSQL("ALTER TABLE t ADD COLUMN col TYPE")
查询: db.query(table, columns, where, whereArgs, null, null, null)
插入: db.insert(table, null, ContentValues)
```

### 模板5：Service/Broadcast 填空速记
```
绑定时返回: return new MyBinder()
发广播: sendBroadcast(new Intent("action_string").putExtra("k", v))
收广播: intent.getStringExtra("k")
注册: registerReceiver(receiver, new IntentFilter("action"))
注销: unregisterReceiver(receiver)
```

---

## 📖 第四阶段：考试前30分钟必看

### ⚠️ 最容易失分的坑

1. **ListView 忘记 setTag/getTag** → ViewHolder 失效
2. **RecyclerView 忘记 setLayoutManager** → 不显示数据
3. **Intent 的 KEY 字符串前后不一致** → 接收不到数据
4. **startActivityForResult 与 startActivity 混用** → 无法接收返回数据
5. **网络请求在主线程执行** → 会报 NetworkOnMainThreadException
6. **Cursor 没有 moveToFirst() 就直接读** → 数据读取失败
7. **BroadcastReceiver 动态注册后没有 unregister** → 内存泄漏
8. **putExtra 用的 key 和 getStringExtra 用的 key 不一致** → null
9. **Adapter 的 getCount 返回 0** → 列表不显示
10. **inflate(item_layout, parent, false) 第三个参数写成 true** → 报错

### ✅ 快速检查清单
- [ ] Adapter 四件套：getCount, getItem, getItemId, getView
- [ ] ViewHolder 三件套：findViewById, setTag, getTag
- [ ] RecyclerView 五件套：onCreateViewHolder, onBindViewHolder, getItemCount, MyHolder(构造+findViewById), setLayoutManager
- [ ] Intent 三件套：new Intent, putExtra, startActivity
- [ ] Dialog 五件套：setTitle, setMessage, setPositiveButton, setNegativeButton, show
- [ ] SQLite 三件套：helper = new MyHelper, db = helper.getWritableDatabase(), cursor.close + db.close
- [ ] Service 三件套：onBind(return binder), onStartCommand, sendBroadcast
- [ ] Broadcast 三件套：registerReceiver, onReceive, unregisterReceiver

### 📝 答题策略
1. 先看分值分配，高分空位优先做
2. Adapter 类题目最快拿分——纯套路，背模板直接填
3. Intent 类题目注意 key 字符串要跟上下文一致
4. 如果不会写完整代码，至少要写出方法调用（如 `.show()`, `.setAdapter()`）
5. 注意题目中给出的 id（如 et1, tv1, btn 等），findViewById 时用对
6. 注意 import 不需要写（Java 填空一般不考 import）

---

## 📖 第五阶段：模拟考试

### 一、代码填空题（共60分）

**第1题（16分）** ListView Adapter
知识点：ListView + BaseAdapter + ViewHolder

```java
class StuAdapter extends BaseAdapter {
    private List<Student> mData;
    private Context mContext;

    @Override
    public int getCount() {
        return __①__;  // (2分)
    }

    @Override
    public Object getItem(int position) {
        return __②__;  // (2分)
    }

    @Override
    public long getItemId(int position) {
        return __③__;  // (2分)
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(mContext)
                .inflate(R.layout.stu_item, parent, __④__);  // (2分)
            holder = new ViewHolder();
            holder.tv1 = convertView.findViewById(R.id.tv1);
            holder.tv2 = convertView.findViewById(R.id.tv2);
            __⑤__;  // (2分) setTag
        } else {
            holder = (ViewHolder) __⑥__;  // (2分) getTag
        }
        Student s = mData.get(__⑦__);  // (2分) position
        holder.tv1.setText(s.getName());
        holder.tv2.setText(s.getStatus());
        return __⑧__;  // (2分) convertView
    }

    static class ViewHolder {
        TextView tv1, tv2;
    }
}
```

**标准答案**：
① mData.size()
② mData.get(position)
③ position
④ false
⑤ convertView.setTag(holder)
⑥ convertView.getTag()
⑦ position
⑧ convertView

**评分点**：每空2分，方法名或变量名拼错扣1分，逻辑错误全扣。
**易失分**：④容易填成 true（会报错）；⑤⑥字母大小写

---

**第2题（14分）** Activity跳转与回传
知识点：Intent + startActivityForResult + onActivityResult

```java
// ActivityA 点击按钮跳转到 ActivityB 获取联系人电话
public void getPhone(View view) {
    Intent intent = __①__;  // (3分)
    __②__;  // (3分) startActivityForResult
}

@Override
protected void onActivityResult(int requestCode, int resultCode, Intent data) {
    super.onActivityResult(requestCode, resultCode, data);
    if (requestCode == 100 && resultCode == RESULT_OK) {
        String phone = __③__;  // (2分) getStringExtra
        tv1.setText(phone);
    }
}
```

```java
// ActivityB 返回数据
public void retPhone(View view) {
    String phone = et1.getText().toString().trim();
    Intent intent = new Intent();
    __④__;  // (3分) putExtra
    __⑤__;  // (3分) setResult
    __⑥__;  // (2分) finish
}
```

**标准答案**：
① new Intent(ActivityA.this, ActivityB.class)
② startActivityForResult(intent, 100)
③ data.getStringExtra("phone")
④ intent.putExtra("phone", phone)
⑤ setResult(RESULT_OK, intent)
⑥ finish()

**评分点**：①③④⑤各3分，②⑥各2分。类名、key字符串不一致扣1分。
**易失分**：①类名写成 ActivityB.this 而不是 ActivityA.this；③的 key 跟④不一致

---

**第3题（16分）** SQLite 数据库
知识点：SQLiteOpenHelper + CRUD

```java
public class MyHelper extends SQLiteOpenHelper {
    public MyHelper(Context context) {
        super(context, __①__, null, 1);  // (2分) 数据库名
    }

    @Override
    public void onCreate(SQLiteDatabase db) {
        String sql = __②__;  // (4分) CREATE TABLE
        db.execSQL(sql);
    }

    @Override
    public void onUpgrade(SQLiteDatabase db, int old, int newVer) {
        db.execSQL("__③__");  // (4分) ALTER TABLE ADD COLUMN
    }
}

// 登录验证
public void login(View v) {
    String name = et_name.getText().toString();
    String pwd = et_pwd.getText().toString();
    MyHelper helper = new MyHelper(this);
    SQLiteDatabase db = helper.__④__;  // (2分) getWritableDatabase
    Cursor cursor = db.__⑤__("user", null, "name=? AND password=?", __⑥__, null, null, null);  // (2+2分)
    if (cursor.moveToFirst()) {
        Toast.makeText(this, "登录成功", Toast.LENGTH_SHORT).show();
    }
    cursor.close();
    db.close();
}
```

**标准答案**：
① "user.db"
② "CREATE TABLE user(_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, password TEXT)"
③ ALTER TABLE user ADD COLUMN state TEXT
④ getWritableDatabase()
⑤ query
⑥ new String[]{name, pwd}

---

**第4题（14分）** RecyclerView
知识点：RecyclerView.Adapter + ViewHolder + LayoutManager

```java
class RvAdapter extends RecyclerView.Adapter<RvAdapter.MyHolder> {
    private List<Article> list;

    @NonNull @Override
    public MyHolder __①__(@NonNull ViewGroup parent, int viewType) {  // (2分)
        View v = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_article, parent, false);
        return new MyHolder(v);
    }

    @Override
    public void __②__(@NonNull MyHolder holder, int position) {  // (2分)
        Article article = list.get(position);
        holder.tvTitle.setText(article.getTitle());
    }

    @Override
    public int __③__() {  // (2分)
        return list.size();
    }

    class MyHolder extends RecyclerView.ViewHolder {
        TextView tvTitle;
        public MyHolder(View itemView) {
            super(itemView);
            __④__ = itemView.findViewById(R.id.tvTitle);  // (2分)
        }
    }
}

// Activity 中设置
RecyclerView rv = findViewById(R.id.rv1);
rv.setLayoutManager(__⑤__);  // (3分)
rv.__⑥__(new RvAdapter(articleList));  // (3分)
```

**标准答案**：
① onCreateViewHolder
② onBindViewHolder
③ getItemCount
④ tvTitle
⑤ new LinearLayoutManager(this)
⑥ setAdapter

---

### 二、简答题（共20分）

**第5题（8分）**：简述 Activity 生命周期中 onCreate、onStart、onResume、onPause、onStop、onDestroy 的调用顺序（从启动到退出）。
**答案**：
启动时：onCreate → onStart → onResume
按Home键：onPause → onStop
重新打开：onRestart → onStart → onResume
按返回键退出：onPause → onStop → onDestroy
**评分点**：顺序正确给6分，提到onRestart再加2分。

**第6题（6分）**：对比 SharedPreferences 和 SQLite 数据库的适用场景。
**答案**：
- SharedPreferences：适合少量配置数据（如用户名、设置项），键值对存储，操作简单
- SQLite：适合大量结构化数据（如通讯录），支持复杂查询，需要写SQL

**第7题（6分）**：简述 Service 中 startService 和 bindService 的区别。
**答案**：
- startService：Service独立运行，不随启动者销毁而停止
- bindService：Service与启动者绑定，启动者销毁则Service解绑；可通过Binder通信

---

### 三、综合题（共20分）

**第8题（20分）**：实现以下功能：
1. 使用 HttpURLConnection 发送POST请求到指定URL（4分）
2. 携带参数 username 和 password（4分）
3. 解析返回的JSON（格式：{"errorCode":0,"data":{"token":"xxx"}}）（6分）
4. 如果 errorCode==0 则跳转到 MainActivity（3分）
5. 否则用 Toast 显示错误信息（3分）

**标准答案**：
```java
new Thread(new Runnable() {
    @Override
    public void run() {
        try {
            URL url = new URL("https://example.com/api/login");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            // 参数
            String body = "username=" + URLEncoder.encode(name,"UTF-8")
                        + "&password=" + URLEncoder.encode(pwd,"UTF-8");
            OutputStream os = conn.getOutputStream();
            os.write(body.getBytes());
            os.close();
            // 读返回
            BufferedReader reader = new BufferedReader(
                new InputStreamReader(conn.getInputStream()));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) sb.append(line);
            reader.close();
            // 解析JSON
            final String result = sb.toString();
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        JSONObject root = new JSONObject(result);
                        if (root.getInt("errorCode") == 0) {
                            startActivity(new Intent(LoginActivity.this, MainActivity.class));
                        } else {
                            Toast.makeText(LoginActivity.this, "登录失败", Toast.LENGTH_SHORT).show();
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}).start();
```

**评分点**：
- 子线程执行网络请求 (4分)
- POST方法设置、参数写出正确 (4分)
- JSON解析正确 (6分)
- 条件分支处理 (3分)
- UI更新在主线程 (3分)

**易失分**：
- 没有在子线程执行 → -4分
- URLEncoder未导入 → -2分
- JSONObject解析未try-catch → -2分
- 更新UI未用runOnUiThread → -3分

---

## 📊 考前30秒记忆卡片

```
ListView:  size → get(position) → position → inflate(false) → setTag → getTag → convertView
Recycler:  onCreateVH → onBindVH → getItemCount → VH(findVById) → LayoutManager → setAdapter
Intent:    new Intent → putExtra → startActivity / startActivityForResult
Result:    onActivityResult → getStringExtra → setResult(RESULT_OK) → finish
Dialog:    setTitle → setMessage → setPositive → setNegative → show → finish()
SQLite:    super("name.db") → execSQL(CREATE TABLE) → getWritable → query → cursor.moveToFirst
Service:   onBind(return binder) → onStartCommand → sendBroadcast → startService
Broadcast: IntentFilter → registerReceiver → onReceive(getStringExtra) → unregisterReceiver
Toast:     Toast.makeText(this, msg, LENGTH_SHORT).show()
SP:        getSharedPreferences("name",MODE) → getString("key","default") → edit().putString().apply()
JSON:      new JSONObject(str) → getInt/getString → getJSONArray → getJSONObject
Fragment:  getSupportFragmentManager().beginTransaction().replace(id,new F()).commit()
Thread:    new Thread(){run(){...}}.start()
UIThread:  runOnUiThread(new Runnable(){run(){...}})
```
