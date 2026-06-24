# 📱 Android 移动应用开发 · 期末突击复习指南

> 基于实验作业题目整理，涵盖所有代码大题题型
> 时间：2026年6月

---

## 📋 总览：9大题型分布

| 题号 | 考点 | 分值 |
| :--: | :--- | :--: |
| 1 | **ListView + BaseAdapter** | 20分 |
| 2 | **EditText + Toast + List初始化** | 20分 |
| 3 | **RecyclerView** | 20分 |
| 4 | **AlertDialog + Activity跳转(传数据)** | 20分 |
| 5 | **Activity跳转(回传数据 / startActivityForResult)** | 20分 |
| 6 | **HTTP请求 + JSON解析** | 20分 |
| 7 | **ContentObserver + Fragment** | 15分 |
| 8 | **Service + BroadcastReceiver** | 20分 |
| 9 | **SQLite数据库操作** | 20分 |

---

## 🔥 题1：ListView + BaseAdapter（20分）

**考试套路**：给一个空壳 adapter，让你填空（getCount/getItem/getItemId/getView）

### 三个固定方法（各2分）

```java
public int getCount() {
    return mData.size();            // 返回数据条目数
}

public Object getItem(int position) {
    return mData.get(position);     // 返回该位置的数据对象
}

public long getItemId(int position) {
    return position;                // 直接返回 position
}
```

### ⭐ getView — ViewHolder 模式（10分）

```java
public View getView(int position, View convertView, ViewGroup parent) {
    ViewHolder h;
    if (convertView == null) {
        // 1. 加载布局
        convertView = LayoutInflater.from(mContext)
            .inflate(R.layout.stu_item, parent, false);
        // 2. 创建 ViewHolder，find 控件
        h = new ViewHolder();
        h.tv1 = convertView.findViewById(R.id.tv1);
        h.tv2 = convertView.findViewById(R.id.tv2);
        // 3. 存入 Tag
        convertView.setTag(h);
    } else {
        // 复用：直接取出 ViewHolder
        h = (ViewHolder) convertView.getTag();
    }
    // 4. 设置数据
    Student s = mData.get(position);
    h.tv1.setText(s.getName());
    h.tv2.setText(s.getStatus());
    return convertView;
}

// 内部类
static class ViewHolder {
    TextView tv1, tv2;
}
```

### ListView 设置适配器（4分）

```java
lv1.setAdapter(new StuAdapter(this, stus));
```

> **💡 记忆口诀**：getCount = size，getItem = get(position)，getItemId = position
> getView = inflate → find → setTag → 复用取Tag → 设数据

---

## 🔥 题2：EditText + Toast + 数据初始化（20分）

### 按钮点击 + Toast（10分）

```java
public void show(View view) {
    String input = ((EditText) findViewById(R.id.et1))
        .getText().toString().trim();
    Toast.makeText(this, input, Toast.LENGTH_SHORT).show();
}
```

> **⭐ 关键点**：Button 的 `android:onClick="show"` 指定方法 → 方法签名固定 `public void 方法名(View view)`
> 取 EditText 文本三件套：`getText()` → `toString()` → `trim()`

### List 初始化数据（10分）

```java
private void initDatas() {
    stus = new ArrayList<>();
    for (int i = 1; i <= 10; i++) {
        stus.add(new Student("S" + i, "学生" + i));
    }
}
```

---

## 🔥 🔥 题3：RecyclerView（20分）⭐ 最高频

### 完整适配器模板

```java
class RvAdapter extends RecyclerView.Adapter<RvAdapter.MyHolder> {
    private List<Stu> dataList;

    public RvAdapter(List<Stu> dataList) {
        this.dataList = dataList;
    }

    @NonNull
    @Override
    public MyHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // ⭐ inflate 布局（4分）
        View view = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.stu_item, parent, false);
        return new MyHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull MyHolder holder, int position) {
        // ⭐ 绑定数据（4分）
        Stu stu = dataList.get(position);
        holder.tv1.setText(stu.getName());
        holder.tv2.setText(stu.getInfo());
    }

    @Override
    public int getItemCount() {
        // ⭐ 返回数量，注意判空（2分）
        return dataList == null ? 0 : dataList.size();
    }

    // ⭐ ViewHolder 内部类（2分 + 2分）
    class MyHolder extends RecyclerView.ViewHolder {
        TextView tv1, tv2;                       // 声明控件

        public MyHolder(@NonNull View itemView) {
            super(itemView);
            tv1 = itemView.findViewById(R.id.tv1);  // find 控件
            tv2 = itemView.findViewById(R.id.tv2);
        }
    }
}
```

### RecyclerView 设置适配器（6分）

```java
RecyclerView rv1 = findViewById(R.id.rv1);
rv1.setLayoutManager(new LinearLayoutManager(this));   // ★ 必须设置 LayoutManager！
RvAdapter adapter = new RvAdapter(stuList);
rv1.setAdapter(adapter);
```

> **⚠️ 和 ListView 的关键区别**：
>
> | 对比项 | ListView | RecyclerView |
> | :----- | :------- | :----------- |
> | ViewHolder | 自己写内部类（可选的） | **必须**继承 RecyclerView.ViewHolder |
> | 创建 View | getView 统一处理 | 拆成 onCreateViewHolder + onBindViewHolder |
> | 布局管理 | 默认纵向 | **必须** setLayoutManager |
> | 复用机制 | convertView 参数 | 自动通过 ViewHolder 复用 |

---

## 🔥 题4：AlertDialog + Activity 跳转（20分）

### 返回键弹窗（10分）

```java
@Override
public void onBackPressed() {
    new AlertDialog.Builder(this)
        .setTitle("提示")                              // 1. 标题
        .setMessage("确定要退出吗？")                    // 2. 消息
        .setPositiveButton("确定", (dialog, which) -> {  // 3. 确认按钮
            finish();                                   // 4. 关闭 Activity
        })
        .setNegativeButton("取消", null)                // 取消按钮
        .show();                                        // 5. 显示
}
```

> 填空对应：① setTitle ② setMessage ③ setPositiveButton ④ finish() ⑤ show()

### Activity 传数据（10分）

```java
// === A 发送端 ===
EditText et1 = findViewById(R.id.et1);
String content = et1.getText().toString().trim();
Intent intent = new Intent(ActivityA.this, ActivityB.class);
intent.putExtra("input_data", content);
startActivity(intent);

// === B 接收端 ===
TextView tv1 = findViewById(R.id.tv1);
Intent intent = getIntent();
if (intent != null) {
    String receivedData = intent.getStringExtra("input_data");
    tv1.setText(receivedData);
}
```

> **⭐ 四步法**：A 端 `putExtra` 放数据 → `startActivity` → B 端 `getIntent()` 取 Intent → `getStringExtra(key)` 读数据

---

## 🔥 🔥 题5：Activity 跳转 + 返回数据（20分）⭐ 套路固定

### 核心流程

```
ActivityA                         ActivityB
   |                                 |
   |-- startActivityForResult() ---->|  ← ① A 启动 B，带 requestCode
   |                                 |   B 填写数据
   |<-- onActivityResult() ---------|  ← ② B 用 setResult + finish 返回
```

### 完整代码

```java
// === ActivityA ===
public class ActivityA extends AppCompatActivity {
    private TextView tv1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_a);
        tv1 = findViewById(R.id.tv1);           // ⭐ findViewById
    }

    // 点击按钮，启动B等待结果
    public void getPhone(View view) {
        Intent intent = new Intent(ActivityA.this, ActivityB.class);
        startActivityForResult(intent, 100);    // ⭐ requestCode = 100
    }

    // 接收B返回的结果
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        // ⭐ 三重判断：requestCode + resultCode + data != null
        if (requestCode == 100 && resultCode == RESULT_OK && data != null) {
            String phone = data.getStringExtra("phone");
            tv1.setText(phone);
        }
    }
}

// === ActivityB ===
public class ActivityB extends AppCompatActivity {
    private EditText et1;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_b);
        et1 = findViewById(R.id.et1);           // ⭐ findViewById
    }

    // 点击按钮，返回数据
    public void retPhone(View view) {
        String phone = et1.getText().toString().trim();
        Intent intent = new Intent();           // ⭐ 注意：无参构造！
        intent.putExtra("phone", phone);
        setResult(RESULT_OK, intent);           // ⭐ 设置结果
        finish();                                // ⭐ 关闭自己
    }
}
```

> **💡 记忆口诀**：
> - A: `startActivityForResult(intent, code)` → 重写 `onActivityResult` 接收
> - B: `new Intent()` 无参 → `setResult(RESULT_OK, intent)` → `finish()`
> - `onActivityResult` 中**三重判断**：requestCode、resultCode、data非空

---

## 🔥 题6：HTTP POST + JSON 解析（20分）

### POST 请求（10分）

```java
String httpPost(String url, String name, String pwd) {
    try {
        URL u = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) u.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);          // 允许输出（发送数据）
        conn.setDoInput(true);           // 允许输入（接收数据）

        // 拼接参数
        String params = "username=" + URLEncoder.encode(name, "UTF-8")
                      + "&password=" + URLEncoder.encode(pwd, "UTF-8");

        // 发送数据
        OutputStream os = conn.getOutputStream();
        os.write(params.getBytes("UTF-8"));
        os.close();

        // 接收响应
        InputStream is = conn.getInputStream();
        BufferedReader reader = new BufferedReader(
            new InputStreamReader(is, "UTF-8"));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
        reader.close();
        conn.disconnect();
        return sb.toString();
    } catch (Exception e) {
        e.printStackTrace();
    }
    return null;
}

// ⭐ 调用方式：必须放在子线程！
new Thread() {
    public void run() {
        String str = httpPost(url, name, pwd);
        // ...处理结果（注意：不能在子线程更新UI）...
    }
}.start();
```

> **⚠️ 网络请求不能在主线程执行**，必须 `new Thread(){...}.start()`

### JSON 解析（10分）

```java
// JSON 结构：{"data":[{...},{...}], "errorCode":0, "errorMsg":""}

List<Article> parseArticle(String strJson) {
    List<Article> list = new ArrayList<>();
    try {
        JSONObject root = new JSONObject(strJson);
        int errorCode = root.getInt("errorCode");
        if (errorCode == 0) {                         // ← 先判断错误码
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

> **JSON 解析三步曲**：`new JSONObject(字符串)` → `getJSONArray("数组名")` → 遍历 `getJSONObject(i)` 取值

---

## 🔥 题7：ContentObserver + Fragment（15分）

### ContentObserver（10分）

```java
public class MainActivity extends AppCompatActivity {
    private TextView tv1;
    private ContentResolver resolver;
    private MyObserver observer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        // ⭐ (5分) 注册观察者
        tv1 = findViewById(R.id.tv1);
        resolver = getContentResolver();
        observer = new MyObserver(new Handler());
        resolver.registerContentObserver(
            Uri.parse("content://cn.zzuli.mycp"),
            true,
            observer
        );
    }

    @Override
    protected void onDestroy() {
        // ⭐ (2分) 注销观察者
        resolver.unregisterContentObserver(observer);
        super.onDestroy();
    }

    // ⭐ (8分) 观察者类
    class MyObserver extends ContentObserver {
        public MyObserver(Handler handler) {
            super(handler);
        }

        @Override
        public void onChange(boolean selfChange, Uri uri) {
            // 查询数据
            Cursor cursor = resolver.query(
                Uri.parse("content://cn.zzuli.mycp"),
                null, null, null, null
            );
            if (cursor != null && cursor.moveToFirst()) {
                StringBuilder sb = new StringBuilder();
                do {
                    int id = cursor.getInt(cursor.getColumnIndex("_id"));
                    String name = cursor.getString(cursor.getColumnIndex("name"));
                    int age = cursor.getInt(cursor.getColumnIndex("age"));
                    sb.append("id:").append(id)
                      .append(", name:").append(name)
                      .append(", age:").append(age).append("\n");
                } while (cursor.moveToNext());
                cursor.close();
                tv1.setText(sb.toString());
            }
        }
    }
}
```

> **Cursor 操作套路**：`moveToFirst()` 判空 → `do...while(moveToNext())` 遍历 → `getColumnIndex("列名")` 取列 → `close()` 关闭

### 动态加载 Fragment（5分）

```java
getSupportFragmentManager()
    .beginTransaction()
    .replace(R.id.fcv, new MyFragment())
    .commit();
```

---

## 🔥 题8：Service + BroadcastReceiver（20分）

### Service 代码

```java
public class MyService extends Service {

    public class MyBinder extends Binder {
        public MyService getService() {
            return MyService.this;  // ⭐ 返回 Service 实例
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return new MyBinder();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        play();                         // ⭐ 启动时直接播放
        return super.onStartCommand(intent, flags, startId);
    }

    public void play() {
        // ⭐ (3分) 发送广播
        Intent intent = new Intent("com.example.PLAY_ACTION");
        intent.putExtra("key", "zzuli");
        sendBroadcast(intent);
    }
}
```

### Activity 中调用

```java
// ⭐ (3分) 启动服务
Intent serviceIntent = new Intent(ActivityA.this, MyService.class);
startService(serviceIntent);

// ⭐ (10分) 调用 play 方法
// 最简方案：onStartCommand 中已调用 play()，startService 就够了
// 如需从 Activity 直接调用：
bindService(serviceIntent, new ServiceConnection() {
    public void onServiceConnected(ComponentName name, IBinder service) {
        MyService.MyBinder binder = (MyService.MyBinder) service;
        binder.getService().play();
    }
    public void onServiceDisconnected(ComponentName name) {}
}, Context.BIND_AUTO_CREATE);

// ⭐ (4分) 广播接收者
class MyReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        String data = intent.getStringExtra("key");
        tv1.setText(data);
    }
}

// 注册广播
MyReceiver receiver = new MyReceiver();
IntentFilter filter = new IntentFilter("com.example.PLAY_ACTION");
registerReceiver(receiver, filter);

// 注销广播（在 onDestroy 中）
unregisterReceiver(receiver);
```

---

## 🔥 🔥 题9：SQLite 数据库（20分）

### ① 创建数据库实例（2分）

```java
MyHelper helper = new MyHelper(this, "user.db", null, 1);
```

### ② 建表 — 写在 onCreate 中（4分）

```java
@Override
public void onCreate(SQLiteDatabase db) {
    String sql = "CREATE TABLE user("
               + "_id INTEGER PRIMARY KEY AUTOINCREMENT, "
               + "name TEXT, "
               + "password TEXT)";
    db.execSQL(sql);
}
```

### ③ 升级加列 — 写在 onUpgrade 中（4分）

```java
@Override
public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    String sql = "ALTER TABLE user ADD COLUMN state TEXT";
    db.execSQL(sql);
}
// 同时把创建 helper 的版本号从 1 改为 2，触发 onUpgrade
```

### ④ ⭐ 登录验证（10分）

```java
public void login(View v) {
    // 1. 获取输入
    String name = et_name.getText().toString().trim();
    String pwd = et_pwd.getText().toString().trim();

    // 2. 打开数据库
    MyHelper helper = new MyHelper(this, "user.db", null, 1);
    SQLiteDatabase db = helper.getWritableDatabase();

    // 3. 查询（用 ? 占位符防 SQL 注入）
    Cursor cursor = db.query("user", null,
        "name=? AND password=?",
        new String[]{name, pwd},
        null, null, null);

    // 4. 判断结果
    if (cursor.moveToFirst()) {
        Toast.makeText(this, "登录成功", Toast.LENGTH_SHORT).show();
    } else {
        Toast.makeText(this, "账号或密码错误", Toast.LENGTH_SHORT).show();
    }

    // 5. 关闭资源
    cursor.close();
    db.close();
}
```

> **⭐ db.query 参数签名**：
> `query(表名, 要查的列名(null=全部), where条件, 条件参数数组, groupBy, having, orderBy)`

---

## 🧠 高频考点速记

### 三方件 / 布局加载

```java
// LayoutInflater 加载布局（ListView 和 RecyclerView 通用）
LayoutInflater.from(context).inflate(R.layout.stu_item, parent, false);
```

### Intent 传递数据类型

| 方法 | 读取方法 |
| :--- | :------- |
| `putExtra("key", "string")` | `getStringExtra("key")` |
| `putExtra("key", 123)` | `getIntExtra("key", 0)` |
| `putExtra("key", true)` | `getBooleanExtra("key", false)` |

### 资源引用格式

- `R.id.xxx` — 控件 ID
- `R.layout.xxx` — 布局文件
- `R.string.xxx` — 字符串资源
- `R.drawable.xxx` — 图片资源

---

## 📝 考场 tips

1. **命名看题目**：`R.id.xxx`、`R.layout.xxx` 严格用题目给的名称
2. **判空是得分点**：`cursor != null`、`data != null`、`intent != null` 这些判断要写
3. **资源要释放**：`cursor.close()`、`db.close()`、`unregisterReceiver()`
4. **网络请求开线程**：`new Thread(){...}.start()`
5. **RecyclerView 要 LayoutManager**：`rv.setLayoutManager(new LinearLayoutManager(this))`
6. **导包别忘**：尤其 RecyclerView（`androidx.recyclerview.widget.*`）
7. **onActivityResult 三重判断**：requestCode + resultCode + data != null
8. **AlertDialog.Builder 最后要 show()**

---

## 🎯 考前优先级

| 优先级 | 内容 | 建议 |
| :----: | :--- | :--- |
| 🔥必背 | RecyclerView 适配器模板 | 完整手写一遍 |
| 🔥必背 | Activity 跳转（传数据和回传数据） | 两种都要会 |
| 🔥必背 | SQLite 建表 + 登录查询 | 背下 query 参数 |
| ⚡重点 | AlertDialog 五个填空位 | 对照题目背 |
| ⚡重点 | Service + Broadcast 流程 | 启动→发送→接收→注销 |
| 📖了解 | HTTP POST 请求模板 | 背框架，注意线程 |
| 📖了解 | JSON 解析三步曲 | Object→Array→遍历取值 |
| 📖了解 | ContentObserver 注册/注销/onChange | 理解流程即可 |