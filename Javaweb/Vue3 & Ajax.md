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