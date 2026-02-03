# 1. 设置路径（请根据实际情况确认）
$sourceDir = "E:\Java-notes"
$hugoPostDir = "D:\download_chrome\hugo_0.155.2\Mysite\content\post"

# 2. 检查并创建 Hugo 目标目录
if (!(Test-Path $hugoPostDir)) { New-Item -ItemType Directory -Path $hugoPostDir }

# 3. 开始批量搬运
Get-ChildItem -Path $sourceDir -Filter *.md | ForEach-Object {
    $fileName = $_.BaseName        # 获取文件名（如：00-基础知识拓展）
    $targetFolder = Join-Path $hugoPostDir $fileName
    
    # 为每篇笔记创建独立文件夹
    if (!(Test-Path $targetFolder)) { New-Item -ItemType Directory -Path $targetFolder }
    
    $targetFile = Join-Path $targetFolder "index.md"
    
    Write-Host "正在处理并导入: $fileName" -ForegroundColor Green

    # 读取原文件内容
    $content = Get-Content $_.FullName -Raw
    
    # 构造 Front Matter
    $header = @"
---
title: "$fileName"
date: $(Get-Date -Format "yyyy-MM-dd")
draft: false
---
"@

    # 写入新位置并改名为 index.md
    $header + "`n" + $content | Set-Content $targetFile -Encoding UTF8
}