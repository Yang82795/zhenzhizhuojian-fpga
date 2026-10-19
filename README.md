# 帧知灼见：全链路智能视觉系统（1024×600@60Hz 原版工程）

本项目为 **全国大学生嵌入式芯片与系统设计竞赛（安路 FPGA 赛道）** 参赛作品的全部工程源码与比特流（1024×600@60Hz 官方标准原版）。

系统基于国产安路科技 **PH1P35MDG324** FPGA 核心器件与 **HX1P35A** 开发板构建，实现从 2-Lane MIPI CSI-2 摄像头视频采集、全硬件 ISP、片内 DDR2 三缓冲、多算法模式实时切换、多色识别与跟踪、32×32 块级运动检测、HDMI 高清显示到 4G Cat.1 物联网 PDU 中文短信告警的端到端全链路工程闭环。

---

## 一、 开发环境与核心规格

- **EDA 工具**: 安路科技 Tang Dynasty (TD) 6.2.168116
- **核心器件**: Anlogic PH1P35MDG324 (-3 speed grade)
- **开发板型号**: HX1P35A V1.0 开发板
- **图像传感器**: 思特威 SC500CS (2-Lane MIPI CSI-2, 1024×600@60fps, RAW10)
- **显示时序**: HDMI 1.4 TMDS (1024×600 @ 60Hz, 像素时钟 52MHz, 串行时钟 260MHz)
- **物联网通信**: 合宙 Air780EPM 4G Cat.1 模组 (UART 115200bps, UCS2 PDU 短信告警)

---

## 二、 目录架构说明

`
.
├── bitstream/                     # 预编译生成的比特流文件（可直接烧录上板运行）
│   ├── camera_to_dsi_display.bit
│   └── camera_to_dsi_display_compress.bit
├── td_project/                    # 安路 TD 6.2 顶层工程目录
│   ├── camera_to_dsi_display.al  # TD 工程主配置文件
│   ├── camera_to_dsi_display.sdc # 物理管脚与全局时序约束
│   ├── al_ip/                    # 安路参数化 IP 核配置
│   └── camera_to_dsi_display_Runs/best_result/ # 最佳时序收敛比特流归档
└── user_source/                   # 纯 Verilog HDL 顶层与各子算法模块源代码
    ├── hdl_source/                # 核心 HDL 逻辑
    │   ├── design_top_wrapper.v  # 顶层系统互连与时钟复位管理
    │   ├── isp_top.v             # 硬件 ISP 流水线 (去马赛克插值、AWB、AE)
    │   ├── video_process_96.v    # 多模式算法内核 (min(R,G,B) 极值灰度、自适应二值化、Sobel)
    │   ├── trash_detect.v        # 多色目标识别与外接边界框提取引擎
    │   ├── motion_detect.v       # 32×32 块级帧差运动目标检测引擎
    │   ├── target_tracker.v      # 动态目标时序关联跟踪器与中心像素坐标解算
    │   ├── hdmi_mixer.v          # OSD 图层混叠、安路 Logo ROM、ASCII 与中文字库
    │   ├── uart_tx.v / uart_rx.v # 4G 模组串口通信收发状态机
    │   └── sms_sender.v          # UCS2 编码 PDU 中文短信组包与防抖状态机
    └── ip_source/                 # 时钟锁相环 PLL、异步 FIFO、行缓存 LineBuffer
`

---

## 三、 快速上手与烧录

1. **直接烧录验证**:
   - 启动 **Tang Dynasty (TD)** 软件，连接 Type-C AL-LINK 下载器；
   - 打开下载器工具，选择 itstream/camera_to_dsi_display.bit 烧录至 SRAM 或 FLASH 即可运行。
2. **源码编译工程**:
   - 在 TD 软件中打开 	d_project/camera_to_dsi_display.al；
   - 检查 SDC 物理管脚约束与时钟约束；
   - 依次执行 Synthesis (综合) -> Place & Route (布局布线) -> Generate Bitstream (比特流生成)。

---

## 四、 声明

本项目源码受全国大学生嵌入式芯片与系统设计竞赛相关知识产权与使用承诺约束，仅供竞赛评阅、团队内部备份与归档学习使用。
