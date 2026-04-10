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

