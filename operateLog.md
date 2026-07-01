# Operate Log

## 2026-07-01

- 将 NAS Agent Server 的 Docker 数据挂载从匿名 volume 改为绿联 NAS 宿主机路径：`/volume1/docker/personal-os-agent/data:/data`。
- 新增 `data/README.md` 和 `data/secrets/daoliyu.env.example`，用于在 NAS 文件管理里创建 `/data/secrets/daoliyu.env`。
- 更新 `.gitignore`：继续忽略真实数据库和真实 `.env` 密钥文件，但允许提交数据目录说明和示例模板。
- 移除 `docker-compose.yml` 里的空 `DAOLIYU_USERNAME` / `DAOLIYU_PASSWORD`，避免空环境变量覆盖 `/data/secrets/daoliyu.env`。
- 调整服务端配置读取逻辑：环境变量为空字符串时视为未配置，继续读取 env 文件。
- 音乐工作台接入 NAS Agent Server 的 Daoliyu 登录状态、播放器、曲目和歌单概览；登录状态只显示在音乐模块。
- NAS Agent Server 增加 CORS 允许规则，方便 Tauri/Web 预览直接读取 `https://os.xuguopeng.com/v1/music/*`。
- 音乐工作台升级为可操作版本：支持搜索歌曲、查看歌曲详情、播放/暂停/上一首/下一首、创建歌单、把选中歌曲加入歌单。
- 聊天 Agent 增加第一批 `@音乐` 命令：搜索、播放、暂停、上一首、下一首、创建歌单，并把动作写入流程日志。
- 修复音乐模块在 Tauri WebView 中请求 NAS 可能出现 `Load failed`：桌面端音乐/NAS JSON 请求改为走 Rust `nas_json_request` 桥接，浏览器预览继续使用 fetch fallback。
- 修复底部流程日志高度和滚动布局；歌曲详情不再展示整段 JSON，歌词和音频信息分区显示。
