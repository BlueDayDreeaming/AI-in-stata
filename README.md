# ai - Stata AI 交互命令

在 Stata 内部直接与 AI 进行对话交互。

## 功能特点

- 🤖 在 Stata 命令行直接与 AI 对话
- 💬 支持多轮对话，保持上下文
- ⚙️ 支持 OpenAI 及兼容 API（DeepSeek、通义千问等）
- 📦 配置持久化存储

## 安装

### 方法一：从 SSC 安装（推荐）

```stata
ssc install ai
```

### 方法二：手动安装

1. 下载以下文件：
   - `ai.ado`
   - `AI_api.py`
   - `AI.sthlp`

2. 将文件放入 Stata 的 ado 目录：
   ```stata
   adopath
   ```

## 系统要求

- Stata 16.0 或更高版本
- Python 3.6+（已集成到 Stata）

## 快速开始

```stata
* 设置 API 密钥
ai, config(apikey "your-api-key")

* 设置 API 地址（如使用第三方服务）
ai, config(baseurl "https://api.siliconflow.cn/v1")

* 设置模型
ai, config(model "deepseek-ai/DeepSeek-V2.5")

* 开始对话
ai 如何在 Stata 中进行回归分析？
```

## 使用方法

### 基本对话

```stata
ai "你的问题"
```

### 配置选项

| 命令 | 说明 |
|------|------|
| `ai, config(apikey "密钥")` | 设置 API 密钥 |
| `ai, config(baseurl "URL")` | 设置 API 地址 |
| `ai, config(model "模型")` | 设置模型名称 |
| `ai, config(timeout "秒数")` | 设置超时时间 |
| `ai, config(show)` | 显示当前配置 |

### 其他选项

| 命令 | 说明 |
|------|------|
| `ai, clear` | 清除对话历史 |
| `ai, help` | 显示帮助信息 |
| `ai "问题", system("提示词")` | 使用自定义系统提示词 |
| `ai "问题", nohistory` | 单次对话，不使用历史 |

## 支持的 API 服务

### OpenAI

```stata
ai, config(baseurl "https://api.openai.com/v1")
ai, config(model "gpt-4o-mini")
```

### DeepSeek（硅基流动）

```stata
ai, config(baseurl "https://api.siliconflow.cn/v1")
ai, config(model "deepseek-ai/DeepSeek-V2.5")
```

### 通义千问

```stata
ai, config(baseurl "https://dashscope.aliyuncs.com/compatible-mode/v1")
ai, config(model "qwen-turbo")
```

## 示例

```stata
* 统计分析问题
ai 如何进行面板数据的固定效应回归？

* 代码调试
ai 这段代码有什么问题：reg y x1 x2, robust cluster

* 多轮对话
ai 什么是工具变量？
ai 能给我一个 Stata 的例子吗？
ai 如何检验工具变量的有效性？

* 清除历史开始新话题
ai, clear
ai 如何绘制生存曲线？
```

## 配置文件位置

配置存储在：`c(sysdir_personal)/stata_ai/ai_config.dta`

## 许可证

MIT License

## 作者

GitHub Copilot

## 反馈与贡献

欢迎提交 Issue 和 Pull Request！
