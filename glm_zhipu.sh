#!/bin/sh

# 引入配置文件
. .git/hooks/config.sh

echo "使用智谱大语言模型进行codeReview"

# 定义API URL
url="https://open.bigmodel.cn/api/paas/v4/chat/completions"

# 读取传递的参数
changes=$1
processedFilename=$2
originalFilename=$3

# 创建临时文件存储代码变更
temp_changes_file=$(mktemp )
echo "$changes" > "$temp_changes_file"

# 构建请求体 - 使用文件读取而非直接嵌入变量
jsonInputFile=$(mktemp)
cat > "$jsonInputFile" <<EOF
{
    "model": "glm-4-flash",
    "messages": [
        {
            "role": "user",
            "content": "$prompt"
        },
        {
            "role": "user",
            "content": "$(cat "$temp_changes_file" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g')"
        }
    ]
}
EOF

# 发送HTTP POST请求并保存原始响应到文件
response=$(curl -s -o "$originalFilename" -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $zhipu_api_key_secret" \
  -H "Content-Type: application/json" \
  -H "User-Agent: Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt )" \
  -d @"$jsonInputFile" \
  "$url")

# 清理临时文件
rm -f "$temp_changes_file" "$jsonInputFile"

# 检查HTTP响应码
if [ "$response" -eq 200 ]; then
  echo "Processing response and saving to processed file..."

  # 使用更健壮的方式提取内容
  if jq -e '.choices[0].message.content' "$originalFilename" > /dev/null 2>&1; then
    # 直接提取完整内容，避免逐行处理可能引起的问题
    jq -r '.choices[0].message.content' "$originalFilename" > "$processedFilename"

    # 检查处理后的文件
    if [ -s "$processedFilename" ]; then
      if grep -q "^null$" "$processedFilename"; then
        echo "本次没有评审结果"
        # 清空文件内容，避免保存"null"字符串
        > "$processedFilename"
      else
        echo "本次有评审结果"
        # 可选：保留原始响应用于调试
        # rm "$originalFilename"
      fi
    else
      echo "处理后的文件为空"
    fi
  else
    echo "无法从响应中提取内容，请检查API返回格式"
    # 保存错误信息到处理后的文件
    echo "API响应解析失败，请查看原始响应文件：$originalFilename" > "$processedFilename"
  fi
else
  echo "Failed to get a successful response. HTTP code: $response"
  # 保存错误信息到处理后的文件
  echo "API请求失败，HTTP状态码：$response" > "$processedFilename"
fi
