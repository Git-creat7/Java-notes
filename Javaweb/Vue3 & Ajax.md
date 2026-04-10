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
```html
	<button @click="count++">点我</button>
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
