# Redii AI Chat 功能

## 概述

Redii 应用现在包含一个类似 OpenAI 风格的 AI 对话界面，支持多种输入类型。

## 功能特性

### 📝 多模态输入
- **文本输入**：基本的文本对话
- **图片上传**：支持照片选择器
- **语音录制**：5-30秒语音笔记
- **视频上传**：支持视频文件
- **文件附件**：支持各种文件类型

### 🎨 界面设计
- **OpenAI 风格界面**：流畅的对话体验
- **智能消息流**：用户和 AI 消息自动区分
- **附件预览**：发送前可预览所有附件
- **加载动画**：优雅的处理状态指示器
- **自动滚动**：新消息自动滚动到底部

### 🔧 技术实现

#### 数据模型
- `AIMessage`: 消息模型，支持文本和附件
- `AIMessage.Attachment`: 附件模型，支持图片/语音/视频/文件
- 完全 Codable，支持本地存储

#### 视图模型
- `AIChatViewModel`: 管理消息状态和输入
- 与 `AIService` 集成，调用后端 API
- 支持异步消息发送和错误处理

#### 主要组件
- `AIChatView`: 主对话界面
- `MessageRow`: 消息行显示
- `AttachmentView`: 附件预览
- `ProcessingIndicator`: 处理状态指示器
- `ImagePicker`: 图片选择器
- `DocumentPicker`: 文件选择器

## 使用说明

### 在应用中访问
1. 打开 Redii 应用
2. 切换到 "AI Chat" 标签
3. 开始对话

### 发送文本消息
- 在输入框输入文本
- 点击发送按钮（当有内容时显示蓝色发送图标）

### 添加附件
底部工具栏提供：
- **📷 Photo**: 选择图片
- **🎥 Video**: 选择视频
- **🎤 Voice**: 录制语音
- **📄 File**: 选择文件

### 预览附件
选择附件后会在输入框上方显示预览，可以：
- 查看缩略图
- 点击删除按钮移除附件

## 后端集成

### API 端点
- `/ai/message-polish`: 润色文本消息
- `/ai/daily-prompt`: 获取每日提示
- `/ai/weekly-summary`: 生成每周总结

### 配置
在 `AIService.swift` 中配置：
```swift
private let baseURL: String = "https://your-worker.workers.dev"
private let apiToken: String = "your-api-token"
```

## 消息类型

### 用户消息
```swift
let message = AIMessage.userMessage(
    content: "Hello!",
    attachments: nil
)
```

### AI 消息
```swift
let message = AIMessage.assistantMessage(
    content: "Hello! How can I help you today?"
)
```

### 带附件的消息
```swift
let attachment = AIMessage.Attachment(
    type: .image,
    url: imageURL,
    name: "photo.jpg"
)
let message = AIMessage.userMessage(
    content: "Look at this!",
    attachments: [attachment]
)
```

## 示例截图功能

### 文本对话
```
User: "Today was great!"
AI: "Today was simply wonderful, filled with gentle joy and warm moments..."
```

### 图片对话
```
User: [照片] "Look at this sunset!"
AI: "What a breathtakingly beautiful sunset! The colors are so peaceful and romantic..."
```

## 未来增强

- [ ] 语音输入（语音转文字）
- [ ] 视频消息播放器
- [ ] 文件下载和打开
- [ ] 消息历史持久化
- [ ] 消息搜索功能
- [ ] 多语言支持

## 技术栈

- **SwiftUI**: 现代声明式 UI
- **Async/Await**: 现代并发处理
- **URLSession**: 网络请求
- **AVFoundation**: 音频处理
- **PhotosPicker**: 图片选择
- **DocumentPicker**: 文件选择

