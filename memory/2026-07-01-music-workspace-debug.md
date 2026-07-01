# Music Workspace Debug Report

## Symptom

- 音乐模块 Daoliyu 登录状态显示 `读取 Daoliyu 登录状态失败：Load failed`。
- 底部流程日志区域太高且滚动不顺。
- 音乐播放体验不明确，歌曲详情把歌词混在 JSON 里展示。

## Root Cause

- NAS 服务公网接口本身可访问，CORS 预检也正常；问题集中在 Tauri/WebView 直接 `fetch` 外网时可能返回通用 `Load failed`。音乐状态、搜索、播放等请求都走前端 fetch，因此桌面端不稳定。
- 流程日志父容器使用固定高度和 `overflow-hidden`，子组件再用 `h-[calc(100%-3rem)]` 计算高度，导致可滚动区域不可靠。
- 歌曲详情复用了调试用 JSON 组件，歌词字段没有被拆成用户可读内容。
- Daoliyu 当前 OpenAPI 没有稳定列出音频 stream/download 接口；现有“播放”只会更新 Daoliyu 服务端播放器状态，不等同于 PC 应用内出声。

## Fix

- 新增 Tauri 命令 `nas_json_request`，桌面端 NAS JSON 请求由 Rust `reqwest` 发起，浏览器预览继续使用 fetch fallback。
- 音乐登录状态、服务端登录、搜索、详情、播放控制、歌单操作统一走 `fetchNasJson`，从而在 Tauri 下自动使用 Rust 桥接。
- 底部流程日志改成 flex 高度布局，日志主体和左右栏都使用明确的 `min-h-0` / `overflow-auto`。
- 歌曲详情增加歌词区和音频信息区，移除整段 JSON 展示。
- 当前播放区明确说明：按钮发送 Daoliyu 播放指令；PC 应用内真实音频输出需要后续接稳定音频流地址。

## Evidence

- `CI=true pnpm build` passed.
- `cargo check` passed.
- `cargo test` passed.
- Added regression test: `nas_json_request_rejects_invalid_method`.

## Status

DONE_WITH_CONCERNS: 请求失败、日志滚动、歌词展示已修复。PC 应用内真实出声仍依赖 Daoliyu 稳定音频流接口，后续需要单独确认和接入。
