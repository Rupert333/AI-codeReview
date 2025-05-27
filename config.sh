#!/bin/sh

# 定义API密钥和URL
zhipu_api_key_secret="feb48960fdfdb24f76b2dd60b0774214.wymJnthzeiwF9abc"
openai_api_key="your-openai-api-key-here"

# 配置文件路径
directory="codeReviewLog"

# 构建请求体中的提示词 - 使用更清晰的格式
read -r -d '' prompt << 'ENDPROMPT'
你是一位资深的编程架构师，精通架构设计、最佳实践、以及各种编程语言。请根据以下git diff记录，对代码进行全面评审，重点关注以下几点：

1. 代码是否符合最佳实践和设计模式？
2. 是否存在潜在的bug或安全隐患？
3. 代码的可读性和可维护性如何？
4. 是否有需要优化的地方，如性能或逻辑简化？

请以Markdown格式输出评审结果，包含以下部分：
- 总体评价
- 具体问题和建议（按严重程度排序）
- 改进建议和最佳实践推荐
ENDPROMPT

# 选择要使用的模型 ('zhipu' 或 'openai')
selected_model="zhipu"

# 添加调试模式开关
debug_mode=false

# 添加API超时设置（秒）
api_timeout=30
