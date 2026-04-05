<%*
try {
  // 获取原始文件名（不含后缀）
  const fileName = tp.file.title;
  const file = tp.file.find_tfile(tp.file.path(true));
  const content = await app.vault.read(file);

  // 1. 匹配 TOML 格式：title = 'xxx' 或 title = "xxx"，直接替换为原始文件名
  const titleRegex = /(title\s*=\s*)(['"])(.*?)\2/;
  let newContent = content.replace(titleRegex, `$1$2${fileName}$2`);
  
  // 2. 【新增】刷新正文里的更新日期：替换 本文更新于 后的日期
const updateDateRegex = /(> 本文更新于\s+)(\d{4}-\d{2}-\d{2})/;
const today = tp.date.now("YYYY-MM-DD");
newContent = newContent.replace(updateDateRegex, `$1${today}`);

  // 3. 写入修改后的内容
  await app.vault.modify(file, newContent);
  new Notice("✅ TOML 标题已同步为原始文件名！");
} catch (e) {
  new Notice(`❌ 同步失败：${e.message}`);
  console.error("错误详情：", e);
}
%>