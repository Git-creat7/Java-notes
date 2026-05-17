+++
date = '2026-04-09'
draft = false
title = '未命名'
tags = []
categories = ["JavaWeb"]
+++

> 本文更新于 2026-04-09

# Vue

**Vue.js** 是一个用于构建用户界面的 **JavaScript 框架**。
它最核心的价值在于：**不再需要手动操作 DOM。**
- 框架：就是一套完整的项目解决方案，用于快速构建项目
- 优点：大大提升前端项目的开发效率 
![](Vue3%20&%20Ajax-1.png)
- 引入Vue模块
```html
	<div id="app">{{ message }}</div>
	
	<script type="module">
	  import { createApp, ref } from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'
	
	  createApp({
	    setup() {
	      const message = ref('Hello Vue!')
	      return {
	        message
	      }
	    }
	  }).mount('#app')
	</script>
```
![](Vue3%20&%20Ajax-2.png)

## 指令
![](Vue3%20&%20Ajax-3.png)
### 基础显示指令
|**指令**|**作用**|**说明**|
|---|---|---|
|**`v-text`**|更新元素的文本内容|类似 `innerText`，但通常直接用 `{{ }}` 更方便。|
|**`v-html`**|更新元素的 `innerHTML`|**内容按 HTML 解析**。注意：只在信任的内容上使用，防止 XSS 攻击。|
|**`v-once`**|只渲染一次|之后即使数据变了，这里也不会更新，用于性能优化。|
### 条件渲染指令 
- **`v-if` / `v-else-if` / `v-else`**：真正的条件渲染。如果条件为假，元素根本不会被创建（不出现在 DOM 树中）
	- **原理**:基于条件判断，来控制创建或移除元素节点(条件渲染)
	- **场景**:要么显示，要么不显示，不频繁切换的场景
    
- **`v-show`**：通过修改 CSS 的 `display: none` 来切换显隐。元素始终存在于 DOM 中
	- **原理**:基于CSS样式display来控制显示与隐藏
	- **场景**:频繁切换显示隐藏的场景
    

> **场景建议**：频繁切换显示用 `v-show`，运行时条件不大可能改变用 `v-if`

### 列表渲染指令
- **`v-for`**：基于一个数组来渲染一个列表
    
- **语法**：`v-for="(item, index) in list" :key="item.id"`
	- `item`：当前遍历项
	- `index`：当前索引（从 0 开始）
	- `list`：要循环的数组
	- `:key="item.id"`：给列表项唯一标识，提升渲染性能
```HTML
	<tbody>
            <tr v-for="(e, index) in empList" :key="e.id">
                <td>{{index+1}}</td>
                <td>{{e.name}}</td>
                <td>{{e.gender == 1?"男":"女" }}</td>
                <td>{{e.job}}</td>
                <td>{{e.entrydate}}</td>
                <td>{{e.updatetime}}</td>
            </tr>
      </tbody>
      
      
	empList: [
	  { "id": 1,
		"name": "姓名",
		"gender": 1,
		"job": "1",
		"entrydate": "2023-06-09",
		"updatetime": "2024-07-30T14:59:38"
	  }
```
>[!NOTE]
> - **关键点**：使用 `v-for` 时**必须**绑定 `:key`。这能帮助 Vue 的 Diff 算法精准识别每个节点，提高更新性能
> - **注意**：遍历的数组，必须在data中定义;要想让哪个标签循环展示多次，就在哪个标签上使用 v-for 指令。

### 属性绑定与事件监听
- **`v-bind` (缩写 `:`)**：动态绑定 HTML 属性。
```html
	<img v-bind:src="imageSrc">
	<img :src="imageSrc">
	插值表达式不能在标签内使用
```
    
- **`v-on` (缩写 `@`)**：绑定事件监听器。
	- **完整写法**：`v-on:事件名="方法名"`
	- **简写形式**（最常用）：**`@事件名="方法名"`**
```c
	//HTML
	<button type="button" @click="search">查询</button>
    <button type="reset" @click="clear">清空</button>
```
```js
	//JS
	methods:{
			search(){
				console.log(this.searchForm);
			},
			clear(){
				this.searchForm.name = '';
				this.searchForm.gender = '';
				this.searchForm.job = '';
			}
		}
```

### 双向绑定指令(表单)
- **`v-model`**：在表单元素（input, select, textarea）上创建双向数据绑定。
    
- **原理**：它是 `v-bind:value` 和 `v-on:input` 的语法糖
	- **从数据到视图**：当变量值改变时，输入框的内容自动变
	- **从视图到数据**：当用户在输入框打字时，变量的值实时更新
```html
	<select name="gender" v-model="searchForm.gender">
		...
	</select>
	
	<select name="job" v-model="searchForm.job">
		...
	</select>
	
	searchForm:{
				name:'',
				gender:'',
				job:''
                },
```
---
## Ajax
**Ajax (Asynchronous JavaScript and XML)** 是让网页实现“局部刷新”的核心技术。它允许网页在不重新加载整个页面的情况下，从服务器请求数据。

>**XML:** (Extensible Markup Language)可扩展标记语言，本质是一种数据格式，可以用来存储复杂的数据结构。

- **作用**
	- **数据交换:** 通过Ajax可以给服务器发送请求，并获取服务器响应的数据。
	- **异步交互:** 可以在不重新加载整个页面的情况下，与服务器交换数据并更新部分网页的技术，如:搜索联想、用户名是否可用的校验等等。
### 同步异步
#### 同步
浏览器页面在发送请求给服务器，在服务器处理请求的过程中，浏览器页面不能做其他的操作。只能等到服务器响应结束后才能，浏览器页面才能继续做其他的操作
![](Vue3%20&%20Ajax-5.png)
#### 异步
浏览器页面发送请求给服务器，在服务器处理请求的过程中，浏览器页面还可以做其他的操作。
![](Vue3%20&%20Ajax-6.png)

### async & await
可以通过async、await可以让异步变为同步操作。async就是来声明一个异步方法，await是用来等待异步任务执行
```JavaScript

  async search() {
    //基于axios发送异步请求，请求http://127.0.0.1:5500/json/simple.json，根据条件查询员工列表
    const result = await axios.get(`http://127.0.0.1:5500/json/simple.json?name=${this.searchForm.name}&gender=${this.searchForm.gender}&job=${this.searchForm.job}`);
    
    this.empList = result.data.data;
  },
```

## [Axios](https://www.axios-http.cn)
- **步骤**
	- 引入Axios的js文件
	- 使用Axios发送请求，并获取响应结果
![](Vue3%20&%20Ajax-4.png)
- 为了方便，Axios已经为所有支持的请求方法提供了别名
- 格式：`axios.请求方式(url [,data [, config ]])`

```js
	//GET请求
    document.querySelector('#getData').onclick = function() {
    
        //发出请求后 不会等待服务器返回（异步），而是继续执行后续代码
	axios.get('https://jsonplaceholder.typicode.com/posts/1').then((result) => {
	   console.log(result.data);
	}).catch((err) => {
		console.log(err);
	});
	
	console.log('================================');//先输出
	
	}
```
## Vue 的生命周期
|**阶段**|**状态名 (Vue 2)**|**Vue 3 (组合式 API)**|**状态描述**|
|---|---|---|---|
|**创建**|`beforeCreate`|`setup`|实例初始化，无数据|
||`created`|`setup`|**数据可用**，无 DOM|
|**挂载**|`beforeMount`|`onBeforeMount`|虚拟 DOM 已准备好|
||**`mounted`**|**`onMounted`**|**DOM 已渲染**（最常用）|
|**更新**|`beforeUpdate`|`onBeforeUpdate`|数据变了，页面没变|
||`updated`|`onUpdated`|页面更新完成|
|**销毁**|`beforeDestroy`|`onBeforeUnmount`|**清理现场**（防内存泄漏）|
||`destroyed`|`onUnmounted`|完全消失|
```js
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script type="module">
    // 导入 Vue 3 的 createApp 方法
    import { createApp } from 'https://unpkg.com/vue@3/dist/vue.esm-browser.js'
    createApp({
        data() {
            return {
                // 搜索表单绑定的数据
                searchForm: {
                    name: '',   // 姓名
                    gender: '', // 性别
                    job: ''     // 职位
                },
                // 员工列表，表格渲染的数据
                empList: []
            }
        },
        methods: {
            // 查询方法，点击“查询”按钮或页面加载时调用
            search() {
                // 发送 GET 请求到远程接口，带上表单参数
                axios.get(`https://web-server.itheima.net/emps/list?name=${this.searchForm.name}&gender=${this.searchForm.gender}&job=${this.searchForm.job}`)
                    .then((result) => {
                        // 将返回的员工数组赋值给 empList，页面自动渲染
                        this.empList = result.data.data;
                    })
                // 控制台输出分隔线，调试用
                console.log('================================');
            },
            /*
              result.data：是整个响应体（包含 code、msg、data 等字段）
              result.data.data：才是真正需要的员工数组
            */
            // 清空方法，点击“清空”按钮时调用
            clear() {
                // 重置表单
                this.searchForm = {
                    name: '',
                    gender: '',
                    job: ''
                };
                // 重新查询，显示所有数据
                this.search();
            }
        },
        // 生命周期钩子，页面加载完成后自动查询一次，显示所有数据
        mounted() {
            this.search();
        }
    }).mount('#container')
</script>
```


# Vue工程化
**Vue 工程化**是指通过一系列工具和技术栈，将 Vue 项目从传统的“面条式代码”转变为标准化、规模化、自动化的现代前端开发模式

\*.vue是vue项目中的组件文件，在vue项目中也称为单文件组件(SFC，Single-Filecomponents)。
vue 的单文件组件会将一个组件的逻辑(JS)，模板(HTML)和样式(CSS)封装在同一个文件里(\*.vue)


## API 风格：选项式API
在选项式 API 中，通常会看到以下几个最常用的选项：

- **`data()`**: 定义组件的响应式状态（数据）。
    
- **`methods`**: 定义可以在组件中调用的函数。
    
- **`computed`**: 定义基于现有数据计算而来的属性（具有缓存机制）。
    
- **`watch`**: 监听数据的变化并执行特定的逻辑。
    
- **生命周期钩子** (如 `mounted`, `updated`): 在组件生命周期的特定阶段执行代码
```Js
export default {
  // 1. 数据，响应式对象
  data() {
    return {
      count: 0
    }
  },
  
  // 2. 方法，可以通过组件实例访问
  methods: {
    increment() {
      this.count++
    }
  },
  
  // 3. 计算属性
  computed: {
    doubleCount() { //声明钩子函数
      return this.count * 2
    }
  },
  
  // 4. 生命周期钩子
  mounted() {
    console.log('组件已挂载！')
  }
}
```


---
## API 风格：选项式API

在选项式 API 中，处理同一个功能（比如“搜索用户”）的代码往往散落在不同的选项中。 而在**组合式 API** 中，可以把“搜索用户”相关的所有数据、方法、生命周期钩子写在一起，甚至提取到一个独立的函数（自定义 Hook）中

`setup` 是组合式 API 的入口。在 `<script setup>` 语法糖下，编写体验非常接近原生 `JavaScript`
**基本结构**
```Js
<script setup>

</script>
<template>

</template>
<style scoped>

</style>
```
**示例：APIDemo.vue**
```Js
<script setup>
	//引入ref函数
	import {ref,onMounted} from 'vue';
	//声明响应式数据
	const count = ref(0);
	
	//声明函数 - 组合式API没有this，直接访问和修改响应式数据
	function increment(){
	    count.value++; //组合式API中，访问和修改响应式数据需要使用.value
	}
	
	//钩子函数
	onMounted(() => {
	
	    console.log('Vue mounted, count is:', count.value);
	
	});
</script>

<template>
    <button @click="increment">Count: {{ count }}</button>
</template>


<style scoped>

</style>
```
**App.vue：引入APIDemo.vue**
```Js
<script setup>
//引入ApiDemo组件
import ApiDemo from './views/ApiDemo.vue';
</script>

<template>
  <ApiDemo />
</template>

<style scoped>
</style>
```
### 为什么选择组合式API？
- **逻辑关注点聚集**：相同功能的代码排在一起。在维护一个几百行的组件时，你不需要在文件顶部和底部来回滚动。
    
- **极佳的逻辑复用**：你可以轻松地将逻辑提取到以 `use` 开头的函数中（如 `useMousePosition.js`），并在多个组件间共享，彻底解决了 Mixins 的命名冲突和来源不明问题。
    
- **更好的类型推导**：对 TypeScript 的支持极其友好，不需要像选项式 API 那样处理复杂的 `this` 类型。
    
- **更小的生产包**：由于不依赖 `this` 上下文，代码更容易被压缩工具（如 Terser）进行变量名混淆和优化

| **特性**    | **选项式 API (Options API)** | **组合式 API (Composition API)** |
| --------- | ------------------------- | ----------------------------- |
| **逻辑组织**  | 按代码类型（数据、方法、钩子）           | 按业务功能（搜索、分页、排序）               |
| **复用性**   | Mixins (存在命名冲突风险)         | 组合式函数 (Hooks)                 |
| **学习曲线**  | 低，适合初学者                   | 略高，需理解响应式原理                   |
| **TS 支持** | 一般                        | 完美                            |
## [Element Plus](https://element-plus.org/zh-CN)
- **技术栈**：基于 Vue 3 编写，完全支持 **TypeScript**。
    
- **设计风格**：延续了经典的桌面端简洁设计。
    
- **组件丰富**：提供了从基础的“按钮”、“输入框”到复杂的“表格”、“日期选择器”、“树形控件”等数十个开箱即用的组件
### 引入
`npm install element-plus --save`

## Vue路由
Vue Router 是 Vue.js 的官方路由管理器，它通过控制 **URL** 与 **组件** 之间的映射关系，让我们能够轻松构建单页面应用（SPA）。

在 Vue Router 中，当 URL 发生变化时，页面不会重新加载，而是由 Vue Router 动态地渲染对应的组件

### 路由定义与组件映射

每一个路由都是一个配置对象，包含 `path`（路径）和 `component`（对应的 Vue 组件）。

### `<router-link>`：导航链接

浏览器会解析成 `<a>` 标签，但它通过插件内部逻辑跳转，不会刷新页面。
```HTML
<router-link to="/home">首页</router-link>
```
### `<router-view>`：渲染出口

动态视图组件，这是路由组件展示的“占位符”。当路径匹配成功时，对应的组件会渲染到这个位置

### 嵌套路由

在 Vue.js 中，**嵌套路由（Nested Routes）** 是构建复杂应用（如带有侧边栏、顶部导航或分级菜单的后台管理系统）的核心功能。它允许你在一个组件内部再渲染另一个子组件


#### 父组件中的容器

在父组件的模板中，必须包含一个 `<router-view>`。这个标签充当了“占位符”，告诉 Vue 子路由对应的组件应该渲染在哪里
```Html
<!-- User.vue (父组件) -->
<div class="user-profile">
  <h1>用户中心</h1>
  <!-- 子路由组件将在这里渲染 -->
  <router-view></router-view>
</div>
```

#### 路由配置
在定义路由表时，通过 `children` 数组来配置嵌套关系
```js
const routes = [
  {
    path: '/user/:id',
    component: User,
    children: [
      {
        // 当访问 /user/:id/profile 时
        path: 'profile',
        component: UserProfile
      },
      {
        // 当访问 /user/:id/posts 时
        path: 'posts',
        component: UserPosts
      },
      {
        // 空路径：当访问 /user/:id 时默认渲染的内容
        path: '',
        component: UserHome
      }
    ]
  }
]
```

---

## 调试数据
```JS
<script setup>
import { ref,onMounted } from 'vue'
import axios from 'axios'

//钩子函数
onMounted(()=>{
  search();
})

//查询
const search = async() => {
  //本地测试
  const  res = await axios.get('本地Mock')
  if(res.data.code){ //js隐式类型转换
      deptList.value = res.data.data
  }
}
//模拟数据
const deptList = ref([])
</script>
```
### 调试优化
随着接口（API）数量的增加，直接在组件里写长 URL 会导致代码冗余且难以维护。封装一个 `request.js` 工具类（通常基于 **Axios**）是标准的工程化做法。

优点：**统一配置基础路径、处理超时、拦截请求/响应（如自动携带 Token 或统一报错）**。


### 1. 基础封装示例 (`utils/request.js`)

你可以创建一个实例，将重复的配置抽离出来：
```js
import axios from 'axios'

//创建axios实例对象
const request = axios.create({
  baseURL: 'http://127.0.0.1:4523/m1/8123520-7880670-default',
  timeout: 600000
})

//axios的响应 response 拦截器
request.interceptors.response.use(
  (response) => { //成功回调
    return response.data
  },
  (error) => { //失败回调
    return Promise.reject(error)
  }
)

//可导出request对象，在其他组件中使用
export default request
```

---

### 2. 模块化管理接口 (`api/dept.js`)

不要在组件里直接调用 `request.js`，而是按照业务模块进一步拆分：
```js
import request from "../utils/request";
//查询全部部门数据
export const queryAllDept = ()=>request.get('/depts');
```
### 3. 组件中简洁调用

```JS
<script setup>
import { ref,onMounted } from 'vue'
import { queryAllDept } from '@/api/dept'

//钩子函数
onMounted(()=>{
  search();
})

//查询
const search = async() => {
  const res = await queryAllDept();
  if(res.code == 1){
    deptList.value = res.data;
  }
}

//模拟数据
const deptList = ref([])

</script>
```
### 代理服务器重写路径
在配置代理服务器时，**路径重写（Path Rewrite）** 是最核心的步骤之一。它的主要作用是：**消除前端为了区分请求而人为添加的“路径前缀”**。

> **为什么需要路径重写？**

通常为了方便管理，我们会给所有后端请求统一加一个前缀（例如 `/api`）。

- **前端请求：** `http://localhost:5173/api/login`
    
- **后端接口：** `http://localhost:8080/login`
    

如果没有重写，代理服务器会将 `/api/login` 直接拼接到目标地址，变成 `http://localhost:8080/api/login`。因为后端并没有 `/api` 路径，就会报 **404 Not Found**。
![](img/Vue3%20&%20Ajax-7.png)

```js
server: {
    proxy: {
        // 当请求地址以/api开头时
        // 代理服务器会将请求转发到http://localhost:8080
        // 并且在转发过程中会去掉/api前缀
      '/api': {
        target: 'http://localhost:8080',
        secure: false,
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      }
    }
  }
```

---

### 环境变量
可以在项目根目录创建 `.env.development` 和 `.env.production` 文件：

- **开发环境 (`.env.development`)**: `VITE_APP_BASE_API = 'http://localhost:8080'`
    
- **生产环境 (`.env.production`)**: `VITE_APP_BASE_API = '[https://api.production.com](https://api.production.com)'`
    

在 `request.js` 中使用 `baseURL: import.meta.env.VITE_APP_BASE_API`，这样程序在不同环境下会自动切换 URL。

---
## 表单校验

![](img/Vue3%20&%20Ajax-8.png)

- **绑定模型**：`<el-form :model="formData">`
    
- **绑定规则**：`<el-form :rules="rules">`
    
- **指定字段**：`<el-form-item prop="username">`
```Js
<script setup>
import { ref,onMounted,reactive } from 'vue';
import { queryAllDeptApi,addDeptApi } from '@/api/dept';
import { ElMessage } from 'element-plus';

//钩子函数
onMounted(()=>{
  search();
})
//模拟数据
const deptList = ref([]);
//查询
const search = async() => {
  const res = await queryAllDeptApi();
  if(res.code == 1){
    deptList.value = res.data;
  }
}

//Dialog对话框
const dialogFormVisible = ref(false);
const dept = ref({name:''});
const formTitle = ref('');

//新增部门
const addDept = () => {
  dialogFormVisible.value = true;
  formTitle.value = '新增部门';
  dept.value = {name:''};
  //重置表单的校验
  if(deptFormRef.value){
    deptFormRef.value.resetFields();
  }
}

const save = async() =>{
  //表单校验
  if(!deptFormRef.value) return;
  deptFormRef.value.validate(async(valid) => {//表示是否校验通过
    if(valid){
      const res = await addDeptApi(dept.value);
      if(res.code){
        ElMessage.success('操作成功');
        dialogFormVisible.value = false;
        search();
      }else{
          ElMessage.error(res.msg);
      }
    }else{
      ElMessage.error('表单校验未通过');
    }
  })
}

//表单校验
const rules = reactive({
  name: [
    //必填项 blur鼠标离焦触发
    { required: true, message: '部门名称不能为空', trigger: 'blur' },
    //长度限制
    { min: 2, max: 10, message: '部门名称长度必须在2到10个字符之间', trigger: 'blur' },
  ]
})
const deptFormRef = ref();

</script>
```

---
## watch侦听
在 Vue 3 中，`watch` 侦听器是处理侧边效应（Side Effects）的核心工具。当你需要在某个数据发生变化时执行异步操作（如调用 `request.js` 接口）、修改 DOM 或操作本地存储时，`watch` 是最佳选择
### 基础语法

在 `<script setup>` 中，最基本的用法是侦听一个 `ref` 或一个计算属性：
```JS
import { ref, watch } from 'vue'

const question = ref('')

// 侦听 question 的变化
watch(question, (newValue, oldValue) => {
  console.log(`从 ${oldValue} 变成了 ${newValue}`)
  // 这里可以触发请求处理工具类
  // getSearchResult(newValue)
})
```
### 侦听不同类型的数据源

`watch` 的第一个参数可以是多种形式：

- **Ref**: 直接传入 ref 对象。
    
- **Getter 函数**: 侦听响应式对象的某个属性。
    
- **多个来源**: 传入数组同时侦听多个数据。
```Js
// 侦听 reactive 对象的某个属性
const user = reactive({ name: 'Zhang', age: 20 })
watch(
  () => user.name, 
  (newName) => console.log('名字变了:', newName)
)

// 侦听多个数据源
watch([question, () => user.age], ([newQ, newAge], [oldQ, oldAge]) => {
  // 数组中的任何一个变化都会触发
})
```

```Js
const user = ref({name: '张三',age: 18});
watch(() => user.value.age , (newVal,oldVal)=>{ //只侦听age

  console.log('a的值发生了变化:${{newVal}}--->${{oldVal}}',newVal,oldVal)

},{immediate: true, /*立即执行一次 */deep: true /* 深度监听 */}
```
### 另外配置
| **选项**                | **描述**                                                |
| --------------------- | ----------------------------------------------------- |
| **`deep: true`**      | **深度侦听**。当侦听一个对象时，如果对象内部属性变化，默认是侦听不到的，需要开启此项。         |
| **`immediate: true`** | **立即执行**。侦听器创建时立刻执行一次回调（此时 `oldValue` 为 `undefined`）。 |
| **`once: true`**      | **只执行一次**。触发一次回调后，该侦听器就会被停止（Vue 3.4+）。                |
```Js
watch(user, (newValue) => {
  /* 只有开启 deep 才能监听到 user.name 的修改 */
}, { deep: true, immediate: true })
```

## 携带令牌访问服务端
- **携带令牌（Token，通常是 JWT）访问服务端**是实现用户身份验证和权限控制的标准流程
- 高效的做法是利用 **Axios 请求拦截器**
### 交互流程
- **登录成功**：客户端输入账号密码，服务端验证通过后返回一个 Token（令牌）。
    
- **本地存储**：客户端将 Token 存入 `localStorage`、`sessionStorage` 或 `Pinia/Vuex` 中。
    
- **拦截附加**：后续客户端发起任何数据请求，`request.js` 的**请求拦截器**都会自动在 HTTP Header 中加入该 Token。
    
- **服务端校验**：服务端收到请求，拦截器/中间件校验 Token 是否合法、是否过期。合法则放行，不合法则返回 `401 Unauthorized`