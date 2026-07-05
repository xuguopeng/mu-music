# Step 138 完成记录：PC 端 NAS 连接配置

## 背景

NAS Agent Server 已经代理到公网域名：

- `https://os.xuguopeng.com`

验证结果：

- `/health` 返回 200。
- `/v1/modules` 返回模块蓝图。
- 当前本机默认 DNS 一度未解析到域名，但公共 DNS 已解析到 Cloudflare；用 `curl --resolve` 验证服务可用。

## 已完成

### Tauri 后端

新增命令：

- `get_nas_server_config`
- `save_nas_server_config`
- `check_nas_server`

数据策略：

- 使用现有 `app_settings` 表保存 `nas.server_url`。
- 默认地址为 `https://os.xuguopeng.com`。
- 检测逻辑由 Tauri 后端请求 `${server_url}/health`，避免浏览器 CORS 影响桌面端检测。

### 前端

新增类型和封装：

- `NasServerConfig`
- `NasServerStatus`
- `getNasServerConfig`
- `saveNasServerConfig`
- `checkNasServer`

设置页新增：

- NAS Agent Server 地址输入框。
- “保存并检测”按钮。
- 状态、服务名、地址、数据库路径展示。
- 公网未鉴权提醒。

## 安全提醒

当前 NAS 服务已经可以公网访问，但还没有鉴权。

下一步需要优先做：

1. 服务端 token 鉴权。
2. PC 端安全保存 token。
3. 设备注册/配对。
4. 再开始同步真实隐私数据。

## 验证

- `CI=true pnpm build`：通过。
- `cargo check`：通过。
- `cargo test`：通过，32 个测试全部成功。

## 下一步

Step 139: NAS 服务鉴权和 PC 端 token 配置。

小计划：

1. NAS 服务端读取 `AGENT_SERVER_TOKEN`。
2. 除 `/health` 外的 `/v1/*` 接口要求 `Authorization: Bearer <token>`。
3. PC 设置页增加 NAS token 密钥状态。
4. token 使用系统 keychain 保存，不写入 SQLite。
5. PC 检测连接时带 token。
6. 未配置 token 时只允许健康检查，不允许同步资产/记忆/任务。
