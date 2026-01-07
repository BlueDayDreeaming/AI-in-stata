*! version 2.0.0  07jan2026
*! ai - Stata内部AI交互命令（整合版）
*! 作者: GitHub Copilot
*! 
*! 功能: 在Stata内部与AI进行交互
*! 
*! 语法:
*!     ai "你的问题"                    - 向AI提问
*!     ai, config(apikey "你的API密钥") - 设置API密钥
*!     ai, config(model "模型名称")     - 设置模型
*!     ai, config(baseurl "API地址")    - 设置API基础URL
*!     ai, config(show)                 - 显示当前配置
*!     ai, clear                        - 清除对话历史
*!     ai, help                         - 显示帮助信息

* ============================================================================
* 主程序: ai
* ============================================================================
program define ai
    version 16.0
    
    * 解析语法
    syntax [anything(name=query)] [, ///
        CONFig(string)                ///
        CLEAR                         ///
        HELP                          ///
        SYStem(string)                ///
        NOHistory                     ///
        RAW                           ///
        ]
    
    * 显示帮助
    if "`help'" != "" {
        ai_show_help
        exit
    }
    
    * 清除历史
    if "`clear'" != "" {
        ai_clear_history
        exit
    }
    
    * 配置设置
    if `"`config'"' != "" {
        ai_config `config'
        exit
    }
    
    * 如果没有提问内容，显示使用说明
    if `"`query'"' == "" {
        display as text "用法: ai " `""你的问题""'
        display as text "      ai, config(apikey " `""你的API密钥""' ")"
        display as text "      ai, help"
        exit
    }
    
    * 调用AI API
    ai_query `"`query'"' `"`system'"' "`nohistory'" "`raw'"
    
end

* ============================================================================
* 子程序: ai_show_help - 显示帮助信息
* ============================================================================
program define ai_show_help
    display as text ""
    display as result "AI命令 - Stata内部AI交互工具"
    display as text "{hline 60}"
    display as text ""
    display as text "{bf:基本用法:}"
    display as text `"    {cmd:ai "你的问题"}              向AI提问"'
    display as text ""
    display as text "{bf:配置选项:}"
    display as text `"    {cmd:ai, config(apikey "密钥")}  设置API密钥"'
    display as text `"    {cmd:ai, config(model "模型")}   设置AI模型"'
    display as text `"    {cmd:ai, config(baseurl "URL")} 设置API地址"'
    display as text `"    {cmd:ai, config(show)}          显示当前配置"'
    display as text ""
    display as text "{bf:其他选项:}"
    display as text "    {cmd:ai, clear}                  清除对话历史"
    display as text `"    {cmd:ai, system("提示词")}      设置系统提示词"'
    display as text "    {cmd:ai, nohistory}              不使用历史记录(单次对话)"
    display as text "    {cmd:ai, raw}                    显示原始返回内容"
    display as text ""
    display as text "{bf:示例:}"
    display as text `"    . ai, config(apikey "sk-xxx")"'
    display as text `"    . ai "如何在Stata中进行回归分析?""'
    display as text `"    . ai "请用中文解释结果" , system("你是Stata专家")"'
    display as text ""
    display as text "{bf:支持的模型:}"
    display as text "    OpenAI: gpt-4o, gpt-4o-mini, gpt-4-turbo, gpt-3.5-turbo"
    display as text "    其他兼容OpenAI API的模型服务"
    display as text ""
end

* ============================================================================
* 子程序: ai_clear_history - 清除对话历史
* ============================================================================
program define ai_clear_history
    * 先尝试初始化Python模块（如果未加载）
    capture python: AI_api
    if _rc {
        * 模块未加载，尝试初始化
        capture ai_init_python
        if _rc {
            display as text "对话历史为空（Python模块未初始化）"
            exit
        }
    }
    
    capture python: AI_api.clear_history()
    if _rc {
        display as text "对话历史为空"
    }
    else {
        display as result "对话历史已清除"
    }
end

* ============================================================================
* 子程序: ai_config - 配置路由
* ============================================================================
program define ai_config
    * 使用gettoken正确解析参数
    gettoken subcmd value : 0
    
    * 清理value：去除前导空格和引号
    local value = strtrim(`"`value'"')
    local value = subinstr(`"`value'"', `"""', "", .)
    local value = strtrim(`"`value'"')
    
    if "`subcmd'" == "show" {
        ai_config_dta, show
        exit
    }
    
    if "`subcmd'" == "apikey" {
        if `"`value'"' == "" {
            display as error "请提供API密钥"
            exit 198
        }
        ai_config_dta, set(apikey) value("`value'")
        display as result "API密钥已设置"
        exit
    }
    
    if "`subcmd'" == "model" {
        if `"`value'"' == "" {
            display as error "请提供模型名称"
            exit 198
        }
        ai_config_dta, set(model) value("`value'")
        display as result "模型已设置为: `value'"
        exit
    }
    
    if "`subcmd'" == "baseurl" {
        if `"`value'"' == "" {
            display as error "请提供API基础URL"
            exit 198
        }
        ai_config_dta, set(baseurl) value("`value'")
        display as result "API基础URL已设置为: `value'"
        exit
    }
    
    if "`subcmd'" == "max_tokens" {
        if `"`value'"' == "" {
            display as error "请提供最大token数"
            exit 198
        }
        ai_config_dta, set(max_tokens) value("`value'")
        display as result "最大token数已设置为: `value'"
        exit
    }
    
    if "`subcmd'" == "temperature" {
        if `"`value'"' == "" {
            display as error "请提供温度参数"
            exit 198
        }
        ai_config_dta, set(temperature) value("`value'")
        display as result "温度参数已设置为: `value'"
        exit
    }
    
    if "`subcmd'" == "timeout" {
        if `"`value'"' == "" {
            display as error "请提供超时时间"
            exit 198
        }
        ai_config_dta, set(timeout) value("`value'")
        display as result "超时时间已设置为: `value'秒"
        exit
    }
    
    display as error "未知的配置选项: `subcmd'"
    display as text "可用选项: apikey, model, baseurl, max_tokens, temperature, timeout, show"
    exit 198
end

* ============================================================================
* 子程序: ai_config_dta - DTA配置文件管理
* ============================================================================
program define ai_config_dta, rclass
    version 16.0
    syntax , [GET(string) SET(string) VALUE(string) SHOW]
    
    * 配置文件路径
    local configdir "`c(sysdir_personal)'stata_ai"
    local configfile "`configdir'/ai_config.dta"
    
    * 确保目录存在
    capture mkdir "`configdir'"
    
    * 显示配置
    if "`show'" != "" {
        capture confirm file "`configfile'"
        if _rc {
            display as text "配置文件不存在，使用默认配置"
            display as text ""
            display as text "API密钥:   未设置"
            display as text "API地址:   https://api.openai.com/v1"
            display as text "模型:      gpt-4o-mini"
            exit
        }
        
        preserve
        quietly use "`configfile'", clear
        
        display as text ""
        display as result "{hline 50}"
        display as result "AI 配置信息"
        display as result "{hline 50}"
        
        * 显示各项配置
        local vars "apikey baseurl model max_tokens temperature timeout"
        foreach var of local vars {
            quietly count if key == "`var'"
            if r(N) > 0 {
                quietly levelsof value if key == "`var'", local(val) clean
                
                if "`var'" == "apikey" {
                    local keylen = strlen("`val'")
                    if `keylen' > 8 {
                        local masked = substr("`val'", 1, 4) + "****" + substr("`val'", -4, 4)
                    }
                    else {
                        local masked "***已设置***"
                    }
                    display as text "API密钥:     `masked'"
                }
                else if "`var'" == "baseurl" {
                    display as text "API地址:     `val'"
                }
                else if "`var'" == "model" {
                    display as text "模型:        `val'"
                }
                else if "`var'" == "max_tokens" {
                    display as text "最大Token:   `val'"
                }
                else if "`var'" == "temperature" {
                    display as text "温度参数:    `val'"
                }
                else if "`var'" == "timeout" {
                    display as text "超时时间:    `val'秒"
                }
            }
        }
        
        display as result "{hline 50}"
        display as text "配置文件: `configfile'"
        
        restore
        exit
    }
    
    * 获取配置
    if "`get'" != "" {
        capture confirm file "`configfile'"
        if _rc {
            * 返回默认值
            if "`get'" == "baseurl" {
                return local value "https://api.openai.com/v1"
            }
            else if "`get'" == "model" {
                return local value "gpt-4o-mini"
            }
            else if "`get'" == "max_tokens" {
                return local value "4096"
            }
            else if "`get'" == "temperature" {
                return local value "0.7"
            }
            else if "`get'" == "timeout" {
                return local value "120"
            }
            else {
                return local value ""
            }
            exit
        }
        
        preserve
        quietly use "`configfile'", clear
        quietly count if key == "`get'"
        if r(N) > 0 {
            quietly levelsof value if key == "`get'", local(val) clean
            restore
            return local value "`val'"
        }
        else {
            restore
            * 返回默认值
            if "`get'" == "baseurl" {
                return local value "https://api.openai.com/v1"
            }
            else if "`get'" == "model" {
                return local value "gpt-4o-mini"
            }
            else if "`get'" == "max_tokens" {
                return local value "4096"
            }
            else if "`get'" == "temperature" {
                return local value "0.7"
            }
            else if "`get'" == "timeout" {
                return local value "120"
            }
            else {
                return local value ""
            }
        }
        exit
    }
    
    * 设置配置
    if "`set'" != "" {
        capture confirm file "`configfile'"
        local file_exists = (_rc == 0)
        
        if !`file_exists' {
            * 创建新的配置文件
            preserve
            clear
            quietly set obs 1
            quietly generate str100 key = "`set'"
            quietly generate str500 value = `"`value'"'
            quietly save "`configfile'", replace
            restore
        }
        else {
            preserve
            quietly use "`configfile'", clear
            
            * 检查是否已存在
            quietly count if key == "`set'"
            if r(N) > 0 {
                quietly replace value = `"`value'"' if key == "`set'"
            }
            else {
                local newobs = _N + 1
                quietly set obs `newobs'
                quietly replace key = "`set'" in `newobs'
                quietly replace value = `"`value'"' in `newobs'
            }
            
            quietly save "`configfile'", replace
            restore
        }
        exit
    }
    
end

* ============================================================================
* 子程序: ai_init_python - Python初始化
* ============================================================================
program define ai_init_python
    
    * 检查Python环境
    capture python: import sys
    if _rc {
        display as error "Python环境未配置，请先配置Stata的Python集成"
        display as text "参考: help python"
        exit 198
    }
    
    * 获取ado文件路径（静默模式）
    quietly findfile AI_api.py
    local pypath = r(fn)
    
    * 转换路径格式（Windows反斜杠转正斜杠）
    local pypath = subinstr("`pypath'", "\", "/", .)
    local pydir = subinstr("`pypath'", "/AI_api.py", "", .)
    
    * 添加路径到sys.path
    python: import sys; pydir = r"`pydir'"; sys.path.insert(0, pydir) if pydir not in sys.path else None
    
    * 导入并reload模块（写成一行避免命名空间问题）
    python: import sys, importlib; exec("import AI_api; AI_api = importlib.reload(AI_api) if 'AI_api' in sys.modules else AI_api; globals()['AI_api'] = AI_api; AI_api.init()")
    
end

* ============================================================================
* 子程序: ai_query - 执行AI查询
* ============================================================================
program define ai_query
    args query system nohistory raw
    
    * 从dta配置获取设置
    ai_config_dta, get(apikey)
    local apikey = r(value)
    
    if `"`apikey'"' == "" {
        display as error "错误: 未设置API密钥"
        display as text `"请使用命令: ai, config(apikey "你的API密钥")"'
        exit 198
    }
    
    ai_config_dta, get(baseurl)
    local baseurl = r(value)
    
    ai_config_dta, get(model)
    local model = r(value)
    
    ai_config_dta, get(max_tokens)
    local max_tokens = r(value)
    
    ai_config_dta, get(temperature)
    local temperature = r(value)
    
    ai_config_dta, get(timeout)
    local timeout = r(value)
    
    * 初始化Python
    ai_init_python
    
    * 传递配置给Python（使用import确保模块可用）
    python: import AI_api; AI_api.set_config_from_stata("`apikey'", "`baseurl'", "`model'", `max_tokens', `temperature', `timeout')
    
    * 执行查询（静默模式）
    
    * 调用API
    local use_history = cond("`nohistory'" == "", "True", "False")
    local show_raw = cond("`raw'" == "", "False", "True")
    
    * 处理查询字符串（转义引号）
    local query_escaped = subinstr(`"`query'"', `"""', `"\""', .)
    
    if `"`system'"' != "" {
        local system_escaped = subinstr(`"`system'"', `"""', `"\""', .)
        python: import AI_api; AI_api.query("`query_escaped'", system_prompt="`system_escaped'", use_history=`use_history', show_raw=`show_raw')
    }
    else {
        python: import AI_api; AI_api.query("`query_escaped'", use_history=`use_history', show_raw=`show_raw')
    }
end
