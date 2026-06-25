# Android 移动应用开发 - 期末考试模拟试卷

**考试时长：120分钟 | 满分：180分**

---

## 第一题：ListView 数据展示（20分）

Activity布局内添加了一个ListView（id: `lv1`），用来显示学生列表 `stus`，请按要求完成代码。

### 要求：完成适配器，用来显示stus

```java
class StuAdapter extends BaseAdapter {
    
    @Override
    public int getCount() {
        // 空1（2分）
        
        
    }
    
    @Override
    public Object getItem(int position) {
        // 空2（2分）
        
        
    }
    
    @Override
    public long getItemId(int position) {
        // 空3（2分）
        
        
    }
    
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        // 空4：加载的布局名：stu_item，包含两个TextView，id分别为tv1和tv2
        // 使用ViewHolder优化（10分）
        
        
        
        
        
        
        
        
        
        
        
    }
}
```

### 请写出ListView设置适配器的代码（4分）

```java
// 空5


```

---

## 第二题：Toast 与数据初始化（20分）

### 题目1：完成show方法（10分）

Activity布局包含一个EditText（id: `et1`）和一个Button（id: `btn1`）。

点击按钮时，获取EditText的内容，并用Toast显示出来。

```java
public void show(View view) {
    // 完成此方法
    
    
    
    
}
```

### 题目2：完成initDatas方法（10分）

已知学生类 `Student(String id, String name, int age)`。

请完成 `initDatas()` 方法，向 `List<Student> stus` 中添加10条学生数据。

学号格式：S1, S2, ..., S10  
姓名格式：张三1, 张三2, ..., 张三10  
年龄：20

```java
private void initDatas() {
    // 完成此方法
    
    
    
    
    
}
```

---

## 第三题：RecyclerView 数据展示（20分）

Activity布局内添加了一个RecyclerView（id: `rv1`），用来显示学生列表 `stus`。

### 要求：完成适配器和ViewHolder

```java
class StuAdapter extends RecyclerView.Adapter<StuAdapter.ViewHolder> {
    
    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        // 空1：加载布局 stu_item（4分）
        
        
        
    }
    
    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        // 空2：绑定数据（4分）
        
        
        
    }
    
    @Override
    public int getItemCount() {
        // 空3（2分）
        
    }
    
    static class ViewHolder extends RecyclerView.ViewHolder {
        // 空4：声明两个TextView成员变量 tv1, tv2（2分）
        
        
        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            // 空5：findViewById初始化tv1和tv2（2分）
            
            
        }
    }
}
```

### 请写出RecyclerView设置适配器和LayoutManager的代码（6分）

```java
// 空6




```

---

## 第四题：AlertDialog 与 Intent 传参（20分）

### 题目1：完成AlertDialog代码（10分）

点击按钮弹出对话框，标题"退出"，消息"确定退出吗？"。

点击"确定"关闭当前Activity，点击"取消"关闭对话框。

```java
public void exit(View view) {
    AlertDialog.Builder builder = new AlertDialog.Builder(this);
    // 空1：设置标题
    
    // 空2：设置消息
    
    // 空3：设置确定按钮（点击时关闭Activity）
    
    
    
    
    // 空4：设置取消按钮
    
    
    
    
    // 空5：显示对话框
    
}
```

### 题目2：Intent传参（10分）

ActivityA 点击按钮跳转到 ActivityB，携带字符串 "zzuli"（key: `msg`）。

ActivityB 的TextView（id: `tv1`）接收并显示这个字符串。

**ActivityA的代码：**

```java
public void jump(View view) {
    // 完成此方法
    
    
    
}
```

**ActivityB的onCreate方法：**

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_b);
    
    // 接收数据并显示
    
    
    
}
```

---

## 第五题：Activity双向通信（20分）

ActivityA 有一个TextView（id: `tv1`）和一个Button（id: `btn1`）。

点击按钮跳转到 ActivityB，ActivityB 有一个EditText（id: `et_phone`）和一个Button（id: `btn_ret`）。

用户在 ActivityB 输入手机号后点击返回按钮，将手机号传回 ActivityA 并显示在 TextView 上。

### ActivityA 的代码：

```java
public class ActivityA extends AppCompatActivity {
    // 空1：声明TextView成员变量
    
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_a);
        
        // 空2：findViewById初始化tv1
        
    }
    
    public void getPhone(View view) {
        // 空3：跳转到ActivityB，requestCode为100
        
        
        
    }
    
    // 空4：重写onActivityResult，接收返回的手机号并显示
    
    
    
    
    
    
    
}
```

### ActivityB 的代码：

```java
public class ActivityB extends AppCompatActivity {
    // 空5：声明EditText成员变量
    
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_b);
        
        // 空6：findViewById初始化et_phone
        
    }
    
    public void retPhone(View view) {
        // 空7：获取输入的手机号，通过Intent返回给ActivityA
        
        
        
        
        
    }
}
```

---

## 第六题：网络请求与JSON解析（20分）

### 题目1：完成POST请求方法（10分）

完成 `httpPost` 方法，向指定URL发送POST请求，参数包括 `username` 和 `password`。

返回服务器响应的字符串。

```java
private String httpPost(String url, String name, String pwd) {
    // 完成此方法
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
```

### 题目2：完成JSON解析方法（10分）

JSON格式：
```json
{
    "code": 200,
    "result": {
        "list": [
            {"title": "文章1", "author": "作者1"},
            {"title": "文章2", "author": "作者2"}
        ]
    }
}
```

完成 `parseArticle` 方法，解析JSON并返回 `List<Article>`。

Article类已定义：`Article(String title, String author)`

```java
private List<Article> parseArticle(String strJson) {
    // 完成此方法
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
```

---

## 第七题：ContentObserver 与 Fragment（20分）

### 题目1：ContentObserver监听数据变化（15分）

已知内容提供者URI：`content://cn.zzuli.mycp`

要求：
1. 注册ContentObserver监听此URI（5分）
2. 在onDestroy中注销ContentObserver（2分）
3. 在onChange方法中查询数据，并将结果显示在TextView（id: `tv1`）上（8分）

查询返回的Cursor包含一个字段 `name`。

```java
public class MainActivity extends AppCompatActivity {
    private TextView tv1;
    private ContentObserver observer;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        tv1 = findViewById(R.id.tv1);
        
        observer = new ContentObserver(new Handler()) {
            @Override
            public void onChange(boolean selfChange) {
                super.onChange(selfChange);
                // 空3：查询数据并显示（8分）
                
                
                
                
                
                
                
                
                
                
            }
        };
        
        // 空1：注册ContentObserver（5分）
        
        
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        // 空2：注销ContentObserver（2分）
        
    }
}
```

### 题目2：Fragment动态加载（5分）

在 Activity 的 FrameLayout（id: `fcv`）中动态加载 `MyFragment`。

```java
// 写出动态加载MyFragment的代码




```

---

## 第八题：Service 与 Broadcast（20分）

已知 MyService 中有一个方法 `play()`，调用时会发送广播（action: `cn.zzuli.music`），携带数据 `"zzuli"`（key: `msg`）。

MainActivity 需要：
1. 启动服务
2. 通过Binder调用 `play()` 方法
3. 接收广播并显示数据

### MyService 的代码：

```java
public class MyService extends Service {
    
    public class MyBinder extends Binder {
        // 空1：返回MyService实例
        
    }
    
    @Override
    public IBinder onBind(Intent intent) {
        return new MyBinder();
    }
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        // 空2：调用play方法
        
        return super.onStartCommand(intent, flags, startId);
    }
    
    public void play() {
        // 空3：发送广播，action为cn.zzuli.music，携带数据"zzuli"（3分）
        
        
    }
}
```

### MainActivity 的代码：

```java
public class MainActivity extends AppCompatActivity {
    private MyService.MyBinder binder;
    private BroadcastReceiver receiver;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        // 空4：启动服务（3分）
        
        
        receiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                // 空6：接收广播数据并Toast显示（4分）
                
                
            }
        };
        
        // 注册广播接收者
        IntentFilter filter = new IntentFilter("cn.zzuli.music");
        registerReceiver(receiver, filter);
    }
    
    public void callPlay(View view) {
        // 空5：调用Service的play方法（10分）
        
        
        
        
        
        
        
        
        
        
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(receiver);
    }
}
```

---

## 第九题：SQLite 数据库（20分）

创建一个用户数据库 `user.db`，包含用户表 `user`。

### 要求：

① 创建数据库代码（2分）  
② onCreate中创建表，字段：`_id`（自增主键）、`name`、`password`（4分）  
③ onUpgrade中为表添加 `state` 字段（4分）  
④ 实现登录验证：查询数据库，如果用户名和密码匹配返回true，否则返回false（10分）

```java
public class MyDBHelper extends SQLiteOpenHelper {
    
    // ①：创建数据库代码（2分）
    
    
    
    @Override
    public void onCreate(SQLiteDatabase db) {
        // ②：创建用户表（4分）
        
        
    }
    
    @Override
    public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
        // ③：添加state字段（4分）
        
    }
}

public class UserDao {
    private MyDBHelper helper;
    
    public UserDao(Context context) {
        helper = new MyDBHelper(context);
    }
    
    // ④：登录验证方法（10分）
    public boolean login(String name, String password) {
        
        
        
        
        
        
        
        
        
        
    }
}
```

---

**答题说明**：
1. 编号处需填写代码，编号处不一定需要填写代码
2. 注意代码规范和缩进
3. 填空题按空给分，完整代码题按步骤给分
4. 总分180分，考试时间120分钟

**祝考试顺利！**
