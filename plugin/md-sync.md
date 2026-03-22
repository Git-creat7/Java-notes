<%*
try {
  const fileName = tp.file.title;
  const newTitle = fileName.replace(/-/g, " ").replace(/\b\w/g, c => c.toUpperCase());
  const file = tp.file.find_tfile(tp.file.path(true));
  const content = await app.vault.read(file);

  // 匹配 TOML 格式：title = 'xxx' 或 title = "xxx"
  const titleRegex = /(title\s*=\s*)(['"])(.*?)\2/;
  let newContent = content.replace(titleRegex, `$1$2${newTitle}$2`);
  // 替换正文一级标题
  newContent = newContent.replace(/^#\s*(.*?)$/m, `# ${newTitle}`);

  await app.vault.modify(file, newContent);
  new Notice("✅ TOML 标题同步成功！");
} catch (e) {
  new Notice(`❌ 同步失败：${e.message}`);
  console.error("错误：", e);
}
%>