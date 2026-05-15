import re

with open('阶段性项目问答.md', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')
result = []
in_answer = False
i = 0
while i < len(lines):
    line = lines[i]
    if line.startswith('> [!tip]- 参考答案'):
        result.append('<details>')
        result.append('<summary>参考答案</summary>')
        result.append('')
        i += 1
        in_answer = True
    elif in_answer and line.startswith('---'):
        result.append('')
        result.append('</details>')
        result.append('')
        result.append(line)
        in_answer = False
        i += 1
    else:
        result.append(line)
        i += 1

if in_answer:
    result.append('')
    result.append('</details>')

with open('阶段性项目问答.md', 'w', encoding='utf-8') as f:
    f.write('\n'.join(result))

print('Done, processed', len([l for l in result if l == '<details>']), 'blocks')
