{smcl}
{* *! version 1.0.0  07jan2026}{...}
{viewerjumpto "语法" "AI##syntax"}{...}
{viewerjumpto "描述" "AI##description"}{...}
{viewerjumpto "选项" "AI##options"}{...}
{viewerjumpto "示例" "AI##examples"}{...}
{viewerjumpto "作者" "AI##author"}{...}
{title:Title}

{phang}
{bf:AI} {hline 2} Stata内部AI交互命令


{marker syntax}{...}
{title:语法}

{p 8 17 2}
{cmdab:ai}
{it:"你的问题"}
[{cmd:,} {it:options}]

{p 8 17 2}
{cmdab:ai}
{cmd:,} {opt config(设置选项)}

{p 8 17 2}
{cmdab:ai}
{cmd:,} {opt clear}

{p 8 17 2}
{cmdab:ai}
{cmd:,} {opt help}


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:主要选项}
{synopt:{opt sys:tem(string)}}设置自定义系统提示词{p_end}
{synopt:{opt noh:istory}}不使用对话历史（单次对话）{p_end}
{synopt:{opt raw}}显示API原始返回内容{p_end}

{syntab:配置选项}
{synopt:{opt config(apikey "密钥")}}设置API密钥{p_end}
{synopt:{opt config(model "模型")}}设置AI模型{p_end}
{synopt:{opt config(baseurl "URL")}}设置API基础地址{p_end}
{synopt:{opt config(show)}}显示当前配置{p_end}

{syntab:其他}
{synopt:{opt clear}}清除对话历史{p_end}
{synopt:{opt help}}显示帮助信息{p_end}
{synoptline}


{marker description}{...}
{title:描述}

{pstd}
{cmd:ai} 命令允许用户在Stata内部直接与AI进行交互。通过调用OpenAI兼容的API，
用户可以询问Stata相关问题、获取代码示例、解释统计结果等。

{pstd}
该命令支持多轮对话，会保留对话历史以便AI理解上下文。使用 {opt clear} 选项可以
清除对话历史开始新的对话。

{pstd}
首次使用前，需要配置API密钥。支持OpenAI官方API以及其他兼容OpenAI API格式的服务。


{marker options}{...}
{title:选项}

{dlgtab:主要选项}

{phang}
{opt system(string)} 设置自定义的系统提示词。系统提示词定义了AI的角色和行为方式。
默认提示词将AI设定为Stata专家助手。

{phang}
{opt nohistory} 不使用对话历史进行单次对话。适用于独立的问题查询。

{phang}
{opt raw} 显示API的原始JSON返回内容，用于调试。

{dlgtab:配置选项}

{phang}
{opt config(apikey "密钥")} 设置API密钥。密钥将保存在用户目录下的配置文件中。

{phang}
{opt config(model "模型")} 设置要使用的AI模型。默认为 gpt-4o-mini。

{phang}
{opt config(baseurl "URL")} 设置API基础URL。默认为 https://api.openai.com/v1。
可以修改为其他兼容OpenAI API的服务地址。

{phang}
{opt config(show)} 显示当前的配置信息。


{marker examples}{...}
{title:示例}

{pstd}设置API密钥（首次使用必须）{p_end}
{phang2}{cmd:. ai, config(apikey "sk-xxxxxxxxxxxxxxxx")}{p_end}

{pstd}基本问答{p_end}
{phang2}{cmd:. ai "如何在Stata中进行线性回归?"}{p_end}

{pstd}请求代码示例{p_end}
{phang2}{cmd:. ai "请给我一个使用sysuse auto数据进行回归分析的完整示例"}{p_end}

{pstd}使用自定义系统提示词{p_end}
{phang2}{cmd:. ai "解释p值的含义", system("你是一个统计学教授，用通俗易懂的语言解释")}{p_end}

{pstd}单次对话（不使用历史）{p_end}
{phang2}{cmd:. ai "什么是异方差?", nohistory}{p_end}

{pstd}清除对话历史{p_end}
{phang2}{cmd:. ai, clear}{p_end}

{pstd}查看当前配置{p_end}
{phang2}{cmd:. ai, config(show)}{p_end}

{pstd}使用其他API服务{p_end}
{phang2}{cmd:. ai, config(baseurl "https://api.example.com/v1")}{p_end}
{phang2}{cmd:. ai, config(model "gpt-4-turbo")}{p_end}


{marker author}{...}
{title:作者}

{pstd}
GitHub Copilot

{pstd}
问题反馈和建议请访问项目主页。
{p_end}
