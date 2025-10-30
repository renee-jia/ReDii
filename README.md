# Redii Project

一个私密的伴侣应用，让两个人记录共同的美好时光。

## 项目结构

```
ReDii/
├── Redii/                    # iOS 客户端
│   ├── Redii/                # 源代码
│   │   ├── Models/           # 数据模型
│   │   ├── Views/            # UI 视图
│   │   ├── ViewModels/       # MVVM 视图模型
│   │   ├── Repositories/      # 数据访问层
│   │   ├── Services/         # 服务层
│   │   ├── Core/            # 核心配置
│   │   └── CoreData/        # Core Data 模型
│   ├── RediiTests/          # 单元测试
│   └── Package.swift        # Swift Package Manager
├── RediiBackend/            # Cloudflare Worker 后端
│   ├── src/                 # TypeScript 源代码
│   │   ├── index.ts        # 主入口
│   │   ├── lib/            # 工具库
│   │   └── types.ts        # TypeScript 类型
│   └── wrangler.toml       # Cloudflare 配置
├── .gitignore               # Git 忽略规则
└── README.md               # 本文档
```

## 快速开始

### iOS 应用

1. 打开 Xcode
2. 创建新的 iOS 项目
3. 导入 `Redii/Redii` 文件夹
4. 配置 CloudKit（可选）
5. 运行

### 后端服务

```bash
cd RediiBackend
npm install
wrangler secret put OPENAI_API_KEY
wrangler secret put API_TOKEN
npm run dev
```

## 功能特性

### iOS 客户端
- ✅ 优雅的 SwiftUI 界面
- ✅ MVVM 架构
- ✅ Core Data + CloudKit 同步
- ✅ 依赖注入
- ✅ 单元测试
- ✅ AI Chat 功能（类 OpenAI 界面）
- ✅ 多模态输入支持

### 后端服务
- ✅ Cloudflare Worker
- ✅ OpenAI API 集成
- ✅ JWT 身份验证
- ✅ 限流保护
- ✅ CORS 支持

## Git 忽略规则

项目已配置完整的 .gitignore：

- **macOS 系统文件**：.DS_Store 等
- **Xcode 构建产物**：DerivedData、构建输出等
- **依赖**：node_modules、Pods
- **敏感信息**：.env、API keys
- **后端**：Cloudflare Worker 缓存和日志

## 许可证

MIT License

