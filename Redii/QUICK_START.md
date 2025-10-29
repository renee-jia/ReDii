# Redii iOS 项目 - 快速开始

## 项目概述

Redii 是一个私密的伴侣应用，让两个人记录共同的美好时光。

## 核心功能

### 🏠 首页
- 显示在一起的天数
- 快速添加时刻
- 快速访问 AI Chat 和 Partner Chat

### ⭐ 时刻 (Moments)
- 支持多种类型：笔记、照片、心情、语音
- 筛选功能（全部/笔记/照片/心情/语音）
- 下拉刷新
- 滑动删除

### 🤖 AI Chat（新功能）
- **OpenAI 风格的对话界面**
- **多模态输入支持**：
  - 📝 文本
  - 🎤 语音
  - 📷 图片
  - 🎥 视频
  - 📄 文件
- 与后端 API 集成
- 消息自动滚动
- 优雅的加载动画

### 💬 Partner Chat
- 私密聊天
- 表情回应
- 实时同步

### 📸 记忆画廊
- 照片和语音网格展示
- 详细查看
- 时间线浏览

### ⚙️ 设置
- 主题颜色
- 应用锁定
- 数据导出

## 技术栈

- **UI**: SwiftUI
- **架构**: MVVM + Repository
- **数据**: Core Data + CloudKit
- **依赖注入**: DI Container
- **异步**: async/await
- **测试**: 单元测试（包含测试示例）

## AI Chat 详细功能

### 输入类型
```swift
enum InputType {
    case text      // 文本输入
    case voice     // 语音录制
    case image     // 图片选择
    case video     // 视频选择
    case file      // 文件上传
}
```

### 消息模型
```swift
struct AIMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    let timestamp: Date
    let role: MessageRole  // user / assistant
    var attachments: [Attachment]?
}
```

### 使用方法

1. **访问 AI Chat**
   - 在标签栏选择 "AI Chat"
   - 或在首页点击 "AI Chat" 按钮
   - 或在顶部工具栏点击 sparkles 图标

2. **发送文本消息**
   - 输入文本
   - 点击蓝色发送按钮

3. **添加附件**
   - 点击底部工具栏的图标：
     - 📷 Photo: 选择图片
     - 🎥 Video: 选择视频
     - 🎤 Voice: 录制语音
     - 📄 File: 选择文件

4. **预览附件**
   - 附件会在输入框上方显示
   - 点击 X 删除附件

## 后端 API

### 配置
在 `Redii/Redii/Services/AIService.swift` 中配置：
```swift
private let baseURL: String = "https://your-worker.workers.dev"
private let apiToken: String = "your-api-token"
```

### API 端点
- `POST /ai/message-polish` - 润色消息
- `GET /ai/daily-prompt` - 每日提示
- `POST /ai/weekly-summary` - 每周总结

## 项目结构

```
Redii/
├── Redii/
│   ├── Models/              # 数据模型
│   │   ├── Moment.swift
│   │   ├── User.swift
│   │   ├── ChatMessage.swift
│   │   ├── AIMessage.swift     # AI 消息模型
│   │   └── AppState.swift
│   ├── Views/               # 视图层
│   │   ├── RediiApp.swift
│   │   ├── HomeView.swift
│   │   ├── AIChatView.swift    # AI Chat 界面
│   │   ├── ChatView.swift
│   │   └── ...
│   ├── ViewModels/          # 视图模型
│   │   ├── AIChatViewModel.swift  # AI Chat 逻辑
│   │   └── ...
│   ├── Repositories/        # 数据访问
│   ├── Services/           # 服务层
│   │   ├── AIService.swift     # AI API 服务
│   │   ├── CloudKitService.swift
│   │   └── ...
│   └── Core/               # 核心配置
├── RediiTests/             # 单元测试
└── RediiBackend/           # 后端服务
```

## 开发指南

### 运行项目
1. 打开 Xcode
2. 导入 `Redii/Redii` 文件夹
3. 配置 CloudKit（可选）
4. 运行项目

### 运行后端
```bash
cd RediiBackend
npm install
wrangler secret put OPENAI_API_KEY
wrangler secret put API_TOKEN
wrangler dev
```

### 测试
```bash
# 运行单元测试
# 在 Xcode 中按 Cmd+U
```

## 特色亮点

✅ **生产级代码质量**
- 完整错误处理
- 异步架构
- 协议抽象
- 依赖注入

✅ **现代化的 UI/UX**
- SwiftUI
- SF Symbols
- 触觉反馈
- 流畅动画

✅ **完整的功能**
- AI 对话
- 多模态支持
- 本地缓存
- CloudKit 同步

✅ **完善的测试**
- 单元测试覆盖
- 内存测试版本
- ViewModel 测试

## 下一步

- [ ] 实现实际的语音录制
- [ ] 添加视频播放器
- [ ] 完善文件预览
- [ ] 添加消息历史持久化
- [ ] 实现表情回应
- [ ] 添加主题切换动画

## 许可证

MIT License

