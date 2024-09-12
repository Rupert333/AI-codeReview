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

#echo "changes: $changes"
#echo "processedFilename: $processedFilename"

# 构建请求体
jsonInputString=$(cat <<EOF
{
    "model": "glm-4-flash",
    "messages": [
        {
            "role": "user",
            "content": "${prompt} $changes"
        }
    ]
}
EOF
)



# 发送HTTP POST请求并保存原始响应到文件
response=$(curl -s -o "$originalFilename" -w "%{http_code}" -X POST \
  -H "Authorization: Bearer $zhipu_api_key_secret" \
  -H "Content-Type: application/json" \
  -H "User-Agent: Mozilla/4.0 (compatible; MSIE 5.0; Windows NT; DigExt)" \
  -d "$jsonInputString" \
  "$url")

# 打印HTTP响应码
#echo "Response Code: $response"

# Check if the response code is 200
if [ "$response" -eq 200 ]; then
  echo "Processing response and saving to processed file..."
  jq -r '.choices[0].message.content' "$originalFilename" | while IFS= read -r line; do
    echo "${line%\"}" | sed 's/^"//; s/"$//' >> "$processedFilename"
  done
  echo "Processed data saved to $processedFilename"

  # Check if the processed file content is 'null'
  if [ -s "$processedFilename" ] && [ "$(cat "$processedFilename")" = 'null' ]; then
    echo "本次没有评审结果"
  else
    echo "本次有评审结果"
    rm "$originalFilename"
  fi
else
  echo "Failed to get a successful response."
fi