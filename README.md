# mpv-danmaku

用于 [mpv](https://mpv.io/) 播放器的 Bilibili 在线弹幕插件。在播放 B 站视频时全自动抓取、转换为矢量 ASS 字幕并动态挂载，并提供平滑滚动补偿，让本地播放器也能拥有极致的弹幕体验。

---

## 🌟 特性

- **自动识别与双源容错**：自动检测 `bilibili` 播放链接，优先使用 `yt-dlp` 下载弹幕 XML 文件，失败时自动无缝降级回退至 `BBDown`。
- **高质量 ASS 转换**：内置 [`danmaku2ass`](https://github.com/m13253/danmaku2ass) 转换引擎（并备选 `niconvert`），将弹幕转换为清晰美观的 1080p 矢量 ASS 字幕。
- **高刷平滑补偿（消除卡顿）**：针对帧率低于 58fps 的视频，自动根据显示器刷新率（`display-fps`）挂载 `lavfi` 帧率滤镜进行平滑对齐，彻底解决低帧率视频中弹幕滚动抖动、卡顿的问题。
- **整洁无痕（自动清理）**：mpv 退出或关闭文件时，自动清除加载的视频滤镜并清理运行过程中生成的临时弹幕及分块文件。

---

## 📦 环境依赖

使用本插件前，请确保系统已安装并配置好以下工具，且相关命令可在终端中全局调用（已加入系统 `PATH` 环境变量）：

| 依赖项 | 说明 | 必要性 |
| :--- | :--- | :---: |
| **[mpv](https://mpv.io/)** | 核心媒体播放器 | **必选** |
| **[Python 3](https://www.python.org/)** | 用于调用转换脚本与文件检索 | **必选** |
| **[yt-dlp](https://github.com/yt-dlp/yt-dlp)** | 主力弹幕下载后端（建议保持最新） | **推荐（至少选一）** |
| **[BBDown](https://github.com/nilaoda/BBDown)** | 备选 Bilibili 弹幕下载后端 | **推荐（至少选一）** |
| **niconvert** | 备选 Python 转码库 (`pip install niconvert`) | *可选* |

---

## 📥 安装方法

1. 下载或克隆本项目仓库：
   ```bash
   git clone https://github.com/escapezn/mpv-danmaku.git
   ```

2. 将整个文件夹（需包含 `main.lua`、`danmaku2ass.py`、`niconvert.pyw` 等文件）放置在 mpv 的脚本目录下：

   - **Windows**:
     ```text
     %APPDATA%\mpv\scripts\mpv-danmaku\
     # 或便携版 (portable) 目录下的:
     <mpv-dir>\portable_config\scripts\mpv-danmaku\
     ```

   - **Linux / macOS**:
     ```text
     ~/.config/mpv/scripts/mpv-danmaku/
     ```

> [!NOTE]
> 请保持 `danmaku2ass.py` 与 `main.lua` 位于同一目录，插件会通过脚本所在路径自动定位转码工具。

---

## 🚀 使用方法

直接使用 mpv 打开任意 Bilibili 视频链接即可，插件会自动在后台下载并挂载弹幕：

```bash
mpv "https://www.bilibili.com/video/BV1xx411c7mD"
```

你也可以配合浏览器扩展（如 *play-with-mpv*）或其他外部工具一键调用 mpv 播放。

---

## ⚙️ 个性化配置

如需自定义弹幕样式或转换参数，可直接编辑 [`main.lua`](main.lua)：

```lua
-- 弹幕输出位置（默认输出至系统桌面，可按需修改）
local desktop_dir = os.getenv("USERPROFILE") or os.getenv("HOME")
if desktop_dir ~= nil and desktop_dir ~= "" then
    out_directory = utils.join_path(desktop_dir, "Desktop")
end

-- danmaku2ass 转码参数
-- -s 1920x1080 : 画布分辨率
-- -fs 63        : 弹幕基础字号
-- -a 0.95       : 弹幕不透明度 (0.0 ~ 1.0)
-- -dm 10        : 滚动弹幕在屏幕上的持续时间（秒）
local convert = { 'python', py_path, '-o', assfile, '-s', '1920x1080', '-fs', '63', '-a', '0.95', '-dm', '10', xmlfile }
```

---

## 🤝 致谢与开源项目

- [danmaku2ass](https://github.com/m13253/danmaku2ass) by StarBrilliant (GPLv3)
- [niconvert](https://github.com/muzuiget/niconvert)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [BBDown](https://github.com/nilaoda/BBDown)
