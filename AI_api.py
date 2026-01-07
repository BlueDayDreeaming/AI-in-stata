# -*- coding: utf-8 -*-
"""
AI_api.py - Stata AI交互的Python API模块
版本: 1.0.0
日期: 2026-01-07

提供与OpenAI兼容API的交互功能
"""

import os
import json
import urllib.request
import urllib.error
import ssl
from pathlib import Path

# 尝试导入Stata的sfi模块
try:
    from sfi import SFIToolkit
    _in_stata = True
except ImportError:
    _in_stata = False

def stata_print(msg):
    """在Stata中显示消息"""
    if _in_stata:
        SFIToolkit.display(str(msg))
    else:
        print(msg)

# ============================================================================
# 全局配置
# ============================================================================

class AIConfig:
    """AI配置管理类"""
    
    def __init__(self):
        self.api_key = ""
        self.base_url = "https://api.openai.com/v1"
        self.model = "gpt-4o-mini"
        self.max_tokens = 4096
        self.temperature = 0.7
        self.timeout = 120
        self.config_file = self._get_config_path()
        self.load_config()
    
    def _get_config_path(self):
        """获取配置文件路径"""
        # 使用用户目录存储配置
        home = Path.home()
        config_dir = home / ".stata_ai"
        config_dir.mkdir(exist_ok=True)
        return config_dir / "config.json"
    
    def load_config(self):
        """加载配置文件"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    self.api_key = config.get('api_key', self.api_key)
                    self.base_url = config.get('base_url', self.base_url)
                    self.model = config.get('model', self.model)
                    self.max_tokens = config.get('max_tokens', self.max_tokens)
                    self.temperature = config.get('temperature', self.temperature)
                    self.timeout = config.get('timeout', self.timeout)
            except Exception as e:
                pass
    
    def save_config(self):
        """保存配置到文件"""
        config = {
            'api_key': self.api_key,
            'base_url': self.base_url,
            'model': self.model,
            'max_tokens': self.max_tokens,
            'temperature': self.temperature,
            'timeout': self.timeout
        }
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=2, ensure_ascii=False)
        except Exception as e:
            stata_print(f"保存配置失败: {e}")
    
    def set(self, key, value):
        """设置配置项"""
        key_map = {
            'apikey': 'api_key',
            'baseurl': 'base_url',
            'model': 'model',
            'max_tokens': 'max_tokens',
            'temperature': 'temperature',
            'timeout': 'timeout'
        }
        
        actual_key = key_map.get(key, key)
        
        if hasattr(self, actual_key):
            # 类型转换
            if actual_key in ['max_tokens', 'timeout']:
                value = int(value)
            elif actual_key == 'temperature':
                value = float(value)
            
            setattr(self, actual_key, value)
            self.save_config()
        else:
            stata_print(f"未知配置项: {key}")


# ============================================================================
# 对话历史管理
# ============================================================================

class ConversationHistory:
    """对话历史管理类"""
    
    def __init__(self, max_history=20):
        self.messages = []
        self.max_history = max_history
        self.system_prompt = self._default_system_prompt()
    
    def _default_system_prompt(self):
        """默认系统提示词"""
        return """你是一个专业的Stata统计软件助手。你的职责是：
1. 帮助用户解答Stata相关问题
2. 提供Stata代码示例和解释
3. 解释统计概念和方法
4. 帮助调试Stata代码错误
5. 推荐最佳的Stata实践方法

请用清晰、简洁的中文回答问题。当提供代码时，请确保代码可以直接在Stata中运行。"""
    
    def add_message(self, role, content):
        """添加消息到历史"""
        self.messages.append({
            "role": role,
            "content": content
        })
        
        # 保持历史记录在限制范围内
        if len(self.messages) > self.max_history * 2:
            self.messages = self.messages[-self.max_history * 2:]
    
    def get_messages(self, system_prompt=None):
        """获取完整的消息列表（包含系统提示）"""
        prompt = system_prompt if system_prompt else self.system_prompt
        messages = [{"role": "system", "content": prompt}]
        messages.extend(self.messages)
        return messages
    
    def clear(self):
        """清除历史记录"""
        self.messages = []


# ============================================================================
# API 客户端
# ============================================================================

class AIClient:
    """AI API客户端"""
    
    def __init__(self, config):
        self.config = config
    
    def chat(self, messages):
        """发送聊天请求"""
        url = f"{self.config.base_url}/chat/completions"
        
        payload = {
            "model": self.config.model,
            "messages": messages,
            "max_tokens": self.config.max_tokens,
            "temperature": self.config.temperature,
            "stream": False
        }
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.config.api_key}"
        }
        
        try:
            # 创建请求
            data = json.dumps(payload).encode('utf-8')
            req = urllib.request.Request(url, data=data, headers=headers, method='POST')
            
            # 处理SSL
            context = ssl.create_default_context()
            
            # 发送请求
            with urllib.request.urlopen(req, timeout=self.config.timeout, context=context) as response:
                result = json.loads(response.read().decode('utf-8'))
                return result
                
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8')
            try:
                error_json = json.loads(error_body)
                error_msg = error_json.get('error', {}).get('message', error_body)
            except:
                error_msg = error_body
            raise Exception(f"API错误 ({e.code}): {error_msg}")
            
        except urllib.error.URLError as e:
            raise Exception(f"网络错误: {e.reason}")
            
        except Exception as e:
            raise Exception(f"请求错误: {str(e)}")


# ============================================================================
# 全局实例
# ============================================================================

_config = None
_history = None
_client = None


def init():
    """初始化模块"""
    global _config, _history, _client
    _config = AIConfig()
    _history = ConversationHistory()
    _client = AIClient(_config)


def set_config(key, value):
    """设置配置"""
    global _config
    if _config is None:
        init()
    _config.set(key, value)


def set_config_from_stata(apikey, baseurl, model, max_tokens, temperature, timeout):
    """从Stata接收配置（使用dta文件存储的配置）"""
    global _config, _client
    if _config is None:
        init()
    
    _config.api_key = apikey
    _config.base_url = baseurl
    _config.model = model
    _config.max_tokens = int(max_tokens) if max_tokens else 4096
    _config.temperature = float(temperature) if temperature else 0.7
    _config.timeout = int(timeout) if timeout else 120
    
    # 更新客户端
    _client = AIClient(_config)


def show_config():
    """显示当前配置"""
    global _config
    if _config is None:
        init()
    
    # 隐藏API密钥的大部分内容
    api_key_display = "未设置"
    if _config.api_key:
        key = _config.api_key
        if len(key) > 8:
            api_key_display = key[:4] + "*" * (len(key) - 8) + key[-4:]
        else:
            api_key_display = "***已设置***"
    
    stata_print("")
    stata_print("=" * 50)
    stata_print("AI 配置信息")
    stata_print("=" * 50)
    stata_print(f"API密钥:     {api_key_display}")
    stata_print(f"API地址:     {_config.base_url}")
    stata_print(f"模型:        {_config.model}")
    stata_print(f"最大Token:   {_config.max_tokens}")
    stata_print(f"温度参数:    {_config.temperature}")
    stata_print(f"超时时间:    {_config.timeout}秒")
    stata_print(f"配置文件:    {_config.config_file}")
    stata_print("=" * 50)


def clear_history():
    """清除对话历史"""
    global _history
    if _history is None:
        init()
    _history.clear()


def query(question, system_prompt=None, use_history=True, show_raw=False):
    """
    向AI发送查询
    
    参数:
        question: 用户问题
        system_prompt: 自定义系统提示词
        use_history: 是否使用对话历史
        show_raw: 是否显示原始返回
    """
    global _config, _history, _client
    
    if _config is None:
        init()
    
    # 检查API密钥
    if not _config.api_key:
        stata_print("")
        stata_print("错误: 未设置API密钥")
        stata_print('请使用命令: ai, config(apikey "你的API密钥")')
        stata_print("")
        return
    
    try:
        # 构建消息
        if use_history:
            _history.add_message("user", question)
            messages = _history.get_messages(system_prompt)
        else:
            prompt = system_prompt if system_prompt else _history.system_prompt
            messages = [
                {"role": "system", "content": prompt},
                {"role": "user", "content": question}
            ]
        
        # 发送请求
        response = _client.chat(messages)
        
        # 显示原始返回
        if show_raw:
            stata_print("=" * 50)
            stata_print("原始返回:")
            stata_print(json.dumps(response, indent=2, ensure_ascii=False))
            stata_print("=" * 50)
        
        # 提取回复内容
        if 'choices' in response and len(response['choices']) > 0:
            content = response['choices'][0]['message']['content']
            
            # 保存到历史
            if use_history:
                _history.add_message("assistant", content)
            
            # 显示回复（只显示内容）
            stata_print(content)
        else:
            stata_print("错误: 未收到有效回复")
            
    except Exception as e:
        stata_print(f"\n错误: {str(e)}")
        if use_history and "context" in str(e).lower():
            stata_print("提示: 对话历史可能过长，尝试使用 'ai, clear' 清除历史")


def _display_response(content):
    """格式化显示AI回复（保留用于raw模式）"""
    stata_print(content)


# ============================================================================
# Stata调用接口
# ============================================================================

def stata_query(question):
    """Stata直接调用的简化接口"""
    query(question)


def stata_set_key(api_key):
    """Stata设置API密钥的简化接口"""
    set_config('apikey', api_key)


def stata_set_model(model):
    """Stata设置模型的简化接口"""
    set_config('model', model)


# 模块加载时自动初始化
if __name__ != "__main__":
    # 作为模块导入时不自动初始化
    pass
