#!/bin/bash

# 零员工公司中文版 - PDF/HTML构建脚本（带表格样式优化）
set -e

echo "📚 正在生成 '零员工公司' HTML (带表格边框样式)..."

# 定义文件列表
FILES=(
    "index.md"
    "./PART-1-WHY/00-introduction.md"
    "./PART-1-WHY/01-nobodys-being-honest.md"
    "./PART-1-WHY/02-smash-the-loom.md"
    "./PART-1-WHY/03-one-person-one-billion.md"
    "./PART-2-WHAT/04-not-a-chatbot.md"
    "./PART-2-WHAT/05-paperclip.md"
    "./PART-3-HOW/07-open-your-terminal.md"
    "./PART-3-HOW/08-who-does-what.md"
    "./PART-3-HOW/09-kill-switch.md"
    "./PART-4-WHAT-IF/10-run-ten-at-once.md"
    "./PART-4-WHAT-IF/11-you-are-not-optional.md"
    "./PART-4-WHAT-IF/12-48-hours.md"
    "./PART-4-WHAT-IF/13-afterword.md"
)

# 创建临时目录和合并文件
TEMP_DIR=$(mktemp -d /tmp/zero-employee-book-XXXXXX)
TEMP_MERGED="$TEMP_DIR/book.md"

echo "📝 预处理文件..."

# 处理 index.md：提取 frontmatter
head -n $(grep -n "^---$" index.md | head -1 | cut -d: -f1) index.md > "$TEMP_MERGED"
sed -i '' '$ d' "$TEMP_MERGED"

# 处理其他文件：跳过 frontmatter，替换内容中的 standalone ---
for file in "${FILES[@]:1}"; do
    echo "" >> "$TEMP_MERGED"
    
    if head -1 "$file" | grep -q "^---$"; then
        START_LINE=$(grep -n "^---$" "$file" | head -2 | tail -1 | cut -d: -f1)
        START_LINE=$((START_LINE + 1))
        tail -n +"$START_LINE" "$file" | sed 's/^---$/<hr>/g' >> "$TEMP_MERGED"
    else
        cat "$file" | sed 's/^---$/<hr>/g' >> "$TEMP_MERGED"
    fi
done

echo "🌐 生成带优化样式的 HTML..."

# 创建自定义 CSS
cat > "$TEMP_DIR/custom.css" << 'EOF'
/* 基础排版 */
body {
    font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Helvetica Neue", Arial, sans-serif;
    line-height: 1.6;
    color: #333;
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

/* 标题样式 */
h1, h2, h3, h4, h5, h6 {
    color: #1a1a1a;
    margin-top: 2em;
    margin-bottom: 0.5em;
    line-height: 1.3;
}

h1 { font-size: 2.5em; border-bottom: 2px solid #eee; padding-bottom: 0.3em; }
h2 { font-size: 2em; border-bottom: 1px solid #eee; padding-bottom: 0.3em; }
h3 { font-size: 1.5em; }

/* 引用块 */
blockquote {
    border-left: 4px solid #007bff;
    padding-left: 1em;
    margin-left: 0;
    color: #555;
    font-style: italic;
    background-color: #f8f9fa;
    padding: 10px 20px;
}

/* 代码块 */
pre {
    background-color: #f4f4f4;
    border: 1px solid #ddd;
    border-radius: 4px;
    padding: 15px;
    overflow-x: auto;
}

code {
    font-family: "Menlo", "Monaco", "Courier New", monospace;
    background-color: #f4f4f4;
    padding: 2px 6px;
    border-radius: 3px;
}

pre code {
    padding: 0;
    background-color: transparent;
}

/* === 表格样式优化（重点）=== */
table {
    width: 100%;
    border-collapse: collapse;
    margin: 2em 0;
    font-size: 1rem;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

th, td {
    border: 1px solid #444; /* 单元格边框 */
    padding: 12px 15px;     /* 内边距 */
    text-align: left;       /* 左对齐 */
}

th {
    background-color: #007bff; /* 表头背景色 */
    color: white;              /* 表头文字颜色 */
    font-weight: bold;
    border-bottom: 2px solid #0056b3;
}

tr:nth-child(even) {
    background-color: #f8f9fa; /* 偶数行背景色 */
}

tr:hover {
    background-color: #e9ecef; /* 悬停效果 */
}

/* 列表样式 */
ul, ol {
    padding-left: 2em;
}

li {
    margin-bottom: 0.5em;
}

/* 引用 */
hr {
    border: none;
    height: 1px;
    background-color: #ddd;
    margin: 2em 0;
}

/* 打印优化 */
@media print {
    body {
        max-width: none;
        padding: 0;
    }
    
    table {
        page-break-inside: avoid;
    }
    
    pre, blockquote {
        page-break-inside: avoid;
    }
}
EOF

# 使用 Pandoc 生成带自定义样式的 HTML
pandoc \
    --from=markdown \
    --to=html5 \
    -o "$TEMP_DIR/book.html" \
    --toc \
    --standalone \
    -V title="零员工公司" \
    --css="$TEMP_DIR/custom.css" \
    "$TEMP_MERGED"

echo "✅ HTML 生成完成！文件位置：$TEMP_DIR/book.html"
echo ""
echo "📊 已优化的样式包括："
echo "   - 🟦 表格单元格边框 (1px solid #444)"
echo "   - 🎨 表头蓝色背景 + 白色文字"
echo "   - 📏 偶数行浅灰背景 (斑马纹)"
echo "   - ✨ 鼠标悬停高亮效果"
echo "   - 📱 响应式排版 + 打印优化"
echo ""
echo "🖥️ 正在打开 HTML 文件..."

# 打开浏览器查看效果
open "$TEMP_DIR/book.html"

echo ""
echo "💡 提示：在浏览器中按 Cmd+P 即可保存为 PDF"
echo "📁 HTML 文件保存在: $TEMP_DIR/book.html"
