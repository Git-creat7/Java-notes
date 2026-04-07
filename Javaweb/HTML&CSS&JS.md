+++
date = '2026-04-07'
draft = false
title = 'HTML'
tags = []
categories = ["MySQL"]
+++

> 本文更新于 2026-04-07


# HTML
- HyperText Markup Language

HTML 不是一种编程语言，而是一种**标记语言**（Markup Language）。它通过一系列“标签”来描述网页的结构，是构建 Web 页面的基石。

## HTML 核心标签

HTML 是网页的骨架，用于定义页面内容。

- **标题标签 (`<h1>` - `<h6>`)**：用于定义 1 到 6 级标题，数字越小级别越高，字体越大。
    
- **超链接标签 (`<a>`)**：
    
    - **`href` 属性**：指定资源访问的 URL 地址。
        
    - **`target` 属性**：指定打开链接的位置。
        
        - `_self`：在当前页面打开（默认）。
            
        - `_blank`：在新的空白页面打开。
            

# CSS
- Cascading Style Sheets

CSS 负责网页的**表现（Presentation）**。如果说 HTML 是建筑的骨架，那么 CSS 就是装修、油漆和家具布局。它通过选择器定位 HTML 元素，并应用样式属性。

---

## CSS 引入方式

CSS 用于美化 HTML 页面，主要有三种引入手段：

- **行内样式 (Inline Styles)**：直接写在标签的 `style` 属性中，优先级最高但不易维护。
    
- **内部样式表 (Internal Style Sheet)**：写在 `<head>` 标签内的 `<style>` 标签中，适用于单页样式。
    
- **外部样式表 (External Style Sheet)**：**推荐做法**。通过 `<link rel="stylesheet" href="路径.css">` 引入独立的 `.css` 文件，实现结构与表现分离。
