# 帧知灼见：全链路智能视觉系统（1024×600 @ 60 Hz 原版工程）

本项目为 **全国大学生嵌入式芯片与系统设计竞赛（安路 FPGA 赛道）** 参赛作品的完整工程源码与比特流，适配 **1024×600 @ 60 Hz** 官方标准分辨率。

系统基于国产安路科技 **PH1P35MDG324** FPGA 核心器件与 **HX1P35A** 开发板构建，实现从 2-Lane MIPI CSI-2 摄像头视频采集，到硬件 ISP、片内 DDR2 三缓冲、多算法视觉处理、HDMI 显示以及 4G 短信告警的全链路处理。

---

## 一、开发环境与核心规格

| 项目 | 配置 |
| --- | --- |
| EDA 工具 | 安路科技 Tang Dynasty（TD）6.2.168116 |
| 核心器件 | Anlogic PH1P35MDG324（-3 speed grade） |
| 开发板 | HX1P35A V1.0 |
| 图像传感器 | 思特威 SC500CS（2-Lane MIPI CSI-2，1024×600 @ 60 fps，RAW10） |
| 显示接口 | HDMI 1.4 TMDS（1024×600 @ 60 Hz，像素时钟 52 MHz，串行时钟 260 MHz） |
| 物联网通信 | 合宙 Air780EPM 4G Cat.1 模组（UART 115200 bps，UCS2 PDU 短信告警） |

---

## 二、目录架构说明

```text
.
├── bitstream/                             # 预编译比特流，可直接烧录运行
│   ├── camera_to_dsi_display.bit
│   └── camera_to_dsi_display_compress.bit
│
├── td_project/                            # 安路 TD 6.2 顶层工程
│   ├── camera_to_dsi_display.al            # TD 工程主配置文件
│   ├── camera_to_dsi_display.sdc           # 物理管脚与全局时序约束
│   ├── al_ip/                              # 安路参数化 IP 核配置
│   └── camera_to_dsi_display_Runs/
│       └── best_result/                    # 最佳时序收敛结果归档
│
└── user_source/                            # Verilog / SystemVerilog 源代码
    ├── hdl_source/                         # 顶层与核心算法模块
    │   ├── design_top_wrapper.v            # 顶层系统互连与时钟复位管理
    │   ├── isp_top.v                       # 硬件 ISP 流水线：去马赛克、AWB、AE
    │   ├── video_process_96.v               # 算法内核：灰度化、二值化、Sobel
    │   ├── trash_detect.v                  # 多色目标识别与边界框提取
    │   ├── motion_detect.v                 # 32×32 块级帧差运动目标检测
    │   ├── target_tracker.v                # 动态目标关联跟踪与中心坐标解算
    │   ├── hdmi_mixer.v                   # OSD 图层混合、Logo ROM 与字库
    │   ├── uart_tx.v / uart_rx.v           # 4G 模组串口收发状态机
    │   └── sms_sender.v                    # UCS2 PDU 短信组包与防抖状态机
    │
    └── ip_source/                          # 时钟、缓存与接口相关模块
        ├── PLL 相关模块
        ├── 异步 FIFO
        └── LineBuffer 行缓存
```

---

## 三、快速上手与烧录

### 1. 直接烧录验证

1. 启动 **Tang Dynasty（TD）** 软件，并连接 Type-C AL-LINK 下载器。
2. 打开下载器工具，选择以下比特流文件：

   ```text
   bitstream/camera_to_dsi_display.bit
   ```

3. 将比特流烧录至 **SRAM** 或 **FLASH**，即可运行。

> 如果需要使用压缩版本，请选择 `bitstream/camera_to_dsi_display_compress.bit`。

### 2. 源码编译工程

1. 在 TD 软件中打开工程文件：

   ```text
   td_project/camera_to_dsi_display.al
   ```

2. 检查 SDC 物理管脚约束与时钟约束。
3. 依次执行以下流程：

   **Synthesis（综合）** → **Place & Route（布局布线）** → **Generate Bitstream（比特流生成）**

---

## 四、声明

本项目源码受全国大学生嵌入式芯片与系统设计竞赛相关知识产权与使用承诺约束，仅供竞赛评阅、团队内部备份与归档学习使用。
