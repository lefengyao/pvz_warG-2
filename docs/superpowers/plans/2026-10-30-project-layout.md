# 项目目录规范化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** 将 pvz_warG 的脚本、场景、素材和配置分类整理，修正全部资源引用，并验证冷导入、菜单、选关、选卡和战斗启动。

**Architecture:** 根目录按文件用途分类，分类内按游戏功能组织。保持节点名称、class_name、信号、游戏数值和资源 UID；显式更新路径字符串与项目入口，避免依赖旧缓存。图片和音频文件保留现有文件名，以便追溯素材来源，新建文件使用英文 snake_case。

**Tech Stack:** Godot 4.7.1、GDScript、Python 3、PowerShell。

---

## 已确认的现状

- 原始非缓存文件 655 个：112 个 GDScript、60 个场景、183 个导入配置、113 个 UID 文件、1 个 shader 等。
- `plant/` 与 `plants/` 分类重复，`Scrips/` 拼写不统一，`UI/UI/` 重复嵌套；素材、脚本和场景混存，根目录散放脚本与日志。
- 项目无 Git 仓库；本次不自动创建仓库或提交。
- 原始主菜单已用 Godot 无界面模式启动成功；发现缺失的 `godot_daedalus` 插件配置，Godot 基线扫描已经将其禁用。
- 原文件已保存到 `E:/生产项目/项目/Godot/_project_backups/pvz_warG_20261030/before_restructure.zip`，缓存另行保留。

## 目标目录与职责

```text
pvz_warG/
├── project.godot
├── README.md
├── .gitignore
├── assets/
│   ├── textures/{plants,zombies,levels,ui,objects,projectiles}/
│   ├── audio/{plants,zombies,levels,projectiles,general_music,general_music_zombie}/
│   ├── fonts/
│   └── shaders/levels/
├── src/
│   ├── autoload/          # 仅实际注册的六个自动加载脚本
│   ├── core/              # 角色属性、状态机等基础脚本
│   ├── resources/         # 自定义 Resource 类型
│   ├── levels/            # 关卡控制、选关、波次、音乐
│   ├── plants/
│   ├── zombies/
│   ├── projectiles/
│   ├── objects/
│   ├── ui/
│   └── special/           # 阳光集合、僵尸环境音等辅助行为
├── scenes/{components,levels,plants,zombies,projectiles,objects,ui}/
├── resources/audio/       # 音频总线配置
├── docs/
│   ├── superpowers/plans/ # 本实施计划
│   ├── maintenance/       # 完整迁移清单、验证报告
│   └── archive/           # 历史反编译日志
├── tests/                # 资源加载与实际场景流程测试
└── tools/                # 引用检查和验证入口
```

## Task 1：备份、迁移预演与基线

**Files:** `before_restructure.zip`、外部 `restructure.py`、`migration_manifest.json`、`baseline_import.log`、`baseline_runtime.log`。

- [x] 备份所有原始非缓存文件，保留原始 UID 和导入参数。
- [x] 执行原项目编辑器导入和主场景启动，记录基线。
- [x] 生成逐文件映射；验证 654 项移动无目标重名（按 Windows 大小写不敏感规则）。

迁移脚本完整实现保存在备份目录。执行预演：

```powershell
& 'C:/Users/15610/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'E:/生产项目/项目/Godot/_project_backups/pvz_warG_20261030/restructure.py'
```

预期：`655 files, 654 moves, no collisions`。

## Task 2：迁移目录并更新引用

**Files:** 清单内 655 个原始文件、`project.godot`、`docs/maintenance/migration_manifest.json`。

- [x] 编写并执行 `tools/verify_references.py`，确认迁移前检查能识别旧目录。
- [x] 运行以下命令一次，将脚本、场景、素材和附属文件按清单迁移：

```powershell
& 'C:/Users/15610/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' 'E:/生产项目/项目/Godot/_project_backups/pvz_warG_20261030/restructure.py' --apply
```

- [x] 同步替换所有 `res://` 引用，包括 `load()`、动态选卡列表、场景外部资源和 `.import` 的 `source_file`。
- [x] 入口、图标、全局字体及六个 Autoload 使用迁移后的明确路径，音频总线通过 `[audio] buses/default_bus_layout` 指定。
- [x] 在 Settings 加载界面前兼容旧音量存档：备份原文件，替换其中旧脚本路径，保留原始音量。
- [x] 将旧 `.godot` 缓存移到外部备份目录，从空缓存导入；只移除已空的旧目录。
- [x] 用 SHA-256 对比全部原始素材；检查 UID 文件和场景 UID 未变；检查所有迁移目标均存在。

迁移示例：

| 原路径 | 新路径 |
|---|---|
| `Scrips/plants/front_yard/nut/nut.gd` | `src/plants/front_yard/nut/nut.gd` |
| `plant/front_yard/wukong/wukong.tscn` | `scenes/plants/front_yard/wukong/wukong.tscn` |
| `UI/UI/slot/progressBar/progress_bar.gd` | `src/ui/slot/progress_bar/progress_bar.gd` |
| `autoloads/StateMachine.gd` | `src/core/state_machine.gd` |
| `plants/front_yard/nut/nutwall1.png` | `assets/textures/plants/front_yard/nut/nutwall1.png` |
| `maps/front_yard/Grasswalk.front.mp3` | `assets/audio/levels/front_yard/Grasswalk.front.mp3` |
| `default_bus_layout.tres` | `resources/audio/default_bus_layout.tres` |

## Task 3：持续维护规范

**Create:** `README.md`、`.gitignore`、`tools/verify_references.py`、`tools/verify_project.ps1`。

- [x] README 写明每个目录的职责、命名约定、资源移动方法、启动与测试命令。
- [x] 忽略 `.godot/`、构建输出、临时文件和测试日志；保留源素材、`.uid`、`.import`。
- [x] 工具、测试与文档目录使用 `.gdignore`，避免混入编辑器资源扫描；测试场景由命令行显式加载。
- [x] 引用检查器验证路径存在、大小写正确、UID 能解析、迁移文件完整和素材哈希不变；失败时返回非零退出码。

## Task 4：引擎与场景流程验收

**Create:** `tests/project_smoke.gd`、`tests/project_smoke.tscn`、`docs/maintenance/validation_report.md`。

- [x] 运行 Godot `--headless --editor --import`，退出码为 0，日志无脚本错误、资源丢失、无效 UID 或插件缺失。
- [x] 运行引用检查器，确认零断链、零 UID 丢失、零原始素材差异。
- [x] 由 Godot ResourceLoader 加载全部运行资源，验证脚本解析与场景依赖。
- [x] 启动实际主菜单，调用实际按钮流程进入前院选关，再依次验证选关配置中的每个关卡、选卡确认和战斗启动。
- [x] 正常窗口模式启动项目，验证图形设备初始化、主菜单绘制；保存可核对的运行证据。
- [x] 保存实际测试数量、命令、退出码与范围；任何原有问题与本次迁移问题分别记录，修复后重测相关流程。

执行入口（引擎支持参数覆盖，不依赖全局 PATH）：

```powershell
./tools/verify_project.ps1 -GodotPath '../Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' -PythonPath 'C:/Users/15610/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
```

## 回退

保留现有整理后目录，另行解压 `before_restructure.zip` 到一个新目录，即可恢复原始项目；Godot 会重新生成缓存。不要将 ZIP 直接覆盖解压到整理后目录，避免混合两套路径。
