# 2026-07-04 macOS 桌面端空白与手机布局放大

## Symptom

- macOS Debug app 打开后页面空白。
- 即使能打开，也只是手机端布局放大，不像桌面端。

## Root Cause

1. macOS entitlements 只有 `network.server`，没有 `network.client`。沙盒桌面包可能无法稳定访问 NAS 出站网络。
2. `main.dart` 只在窗口宽度 `>= 900` 时进入桌面布局。macOS 默认窗口约 800 宽，因此仍进入手机端 `IndexedStack + CurvedNavigationBar`。
3. 手机端路径会挂载旧用户页逻辑，并请求旧接口 `/login/status`，在 NAS 音乐服务下返回 404。

## Fix

- Debug/Release entitlements 增加 `com.apple.security.network.client`。
- 新增 `DesktopMusicHome` 桌面页：左侧导航、曲库列表、右侧歌曲详情、底部播放器。
- `main.dart` 改为 macOS/Windows/Linux 强制使用桌面布局，不再只依赖窗口宽度。

## Evidence

- `flutter analyze --no-fatal-infos --no-fatal-warnings` 通过。
- `flutter build macos --debug` 成功。
- 启动二进制 10 秒日志显示：
  - `POST https://os.xuguopeng.com/v1/music/auth/login` 成功。
  - `GET https://os.xuguopeng.com/v1/music/api/tracks?limit=80&offset=0` 成功。
  - 不再出现旧 `/login/status` 首屏请求。

## Status

DONE_WITH_CONCERNS：已修复桌面空白和桌面布局入口；视觉细节还需要后续真实使用后继续打磨。
