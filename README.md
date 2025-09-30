# HandMouse

> A Real-Time Vision-Based Gesture Recognition System for Contactless Mouse Control

<div style="text-align: left;">
  <img src="./image/p1.png" alt="System Demo" width="50%" /><br/>
</div>

## 📖 Overview | 概述

**HandMouse** is a computer vision-based Human-Computer Interaction (HCI) system that enables contactless mouse control through real-time gesture recognition. Built with MATLAB and traditional image processing algorithms, this system achieves low-latency cursor manipulation without requiring deep learning frameworks.

**HandMouse** 是一个基于计算机视觉的人机交互（HCI）系统，通过实时手势识别实现非接触式鼠标控制。采用 MATLAB 和传统图像处理算法构建，无需深度学习框架即可实现低延迟的光标操控。

<div style="text-align: left;">
  <img src="./image/p2.png" alt="Processing Pipeline" width="50%" /><br/>
</div>

### 🎥 Demo Video | 演示视频

- [Watch on Bilibili | 在 B 站观看](https://www.bilibili.com/video/BV11x4y1J7Rf/)

---

## ✨ Features | 核心特性

### Functional Capabilities | 功能特性
- **Real-Time Tracking**: 20 FPS gesture recognition with <50ms latency
- **Multi-Gesture Support**: Cursor movement, left-click, right-click, and drag operations
- **Adaptive Tracking**: Finger ID persistence across frames using displacement-based matching
- **Visual Debugging**: Quad-view interface displaying original, filtered, labeled, and status frames

### Technical Highlights | 技术亮点
- ✅ HSV color space segmentation for robust red marker detection
- ✅ Morphological operations (opening/closing) for noise reduction
- ✅ Centroid-based tracking with configurable displacement threshold
- ✅ Motion stabilization through threshold-based filtering
- ✅ Java AWT Robot integration for cross-platform mouse control

---

## 🛠️ Technical Architecture | 技术架构

### Algorithm Pipeline | 算法流程

```
┌─────────────────┐
│  Webcam Input   │ RGB Frame (640×480 @ 20fps)
└────────┬────────┘
         ↓
┌─────────────────┐
│  RGB → HSV      │ Color Space Transformation
└────────┬────────┘
         ↓
┌─────────────────┐
│  Thresholding   │ H: [0.95,1] ∪ [0,0.05]
│                 │ S: [0.6, 1.0]
│                 │ V: [0.4, 1.0]
└────────┬────────┘
         ↓
┌─────────────────┐
│  Morphological  │ Opening (5px) → Closing (5px)
│  Operations     │ Noise Removal & Gap Filling
└────────┬────────┘
         ↓
┌─────────────────┐
│  Region Props   │ Area Filtering (≥1000 px²)
│  Analysis       │ Centroid Computation
└────────┬────────┘
         ↓
┌─────────────────┐
│  Finger ID      │ Displacement Matching (<100px)
│  Assignment     │ X-axis Sorting (Finger 1 < 2)
└────────┬────────┘
         ↓
┌─────────────────┐
│  Gesture        │ 2 Fingers → Move
│  Classification │ Finger 2 Only → Left Click
│                 │ Finger 1 Only → Right Click
└────────┬────────┘
         ↓
┌─────────────────┐
│  Mouse Control  │ Java AWT Robot API
│  (Java AWT)     │ mouseMove() / mousePress()
└─────────────────┘
```

### Gesture Mapping | 手势映射

| Gesture State | Finger 1 | Finger 2 | Mouse Action | Use Case |
|--------------|----------|----------|--------------|----------|
| **Move** | ✓ | ✓ | Cursor Translation | Navigation |
| **Left Click** | ✗ | ✓ | BUTTON1_MASK Press | Click & Drag |
| **Right Click** | ✓ | ✗ | BUTTON3_MASK Press | Context Menu |
| **Idle** | ✗ | ✗ | Release All Buttons | Reset State |

> **Note**: Finger 2 serves as the primary tracking reference for cursor positioning.

---

## 📋 Requirements | 环境要求

### Software Dependencies | 软件依赖
- **MATLAB**: R2018b or later (tested on R2023a)
- **Required Toolboxes**:
  - Image Processing Toolbox
  - Computer Vision Toolbox
  - MATLAB Support Package for USB Webcams
- **Java Runtime**: JRE 8+ (bundled with MATLAB)

### Hardware Requirements | 硬件要求
- **Camera**: USB webcam with 640×480 resolution (minimum)
- **Markers**: Red-colored finger caps/stickers for tracking
  - Recommended: Bright red (HSV: H≈0°, S>60%, V>40%)
  - Size: ≥1000 pixels projected area at working distance
- **System**: 4GB RAM, Dual-core CPU (2.0GHz+)

### Environment Setup | 环境配置
- **Lighting**: Uniform ambient lighting (avoid strong backlighting)
- **Background**: Non-red background to minimize false positives
- **Distance**: 40-80 cm from camera for optimal tracking

---

## 🚀 Quick Start | 快速开始

### Installation | 安装

1. **Clone the repository | 克隆仓库**
   ```bash
   git clone https://github.com/OlyMarco/HandMouse.git
   cd HandMouse
   ```

2. **Verify webcam connection | 验证摄像头连接**
   ```matlab
   % In MATLAB Command Window
   webcamlist
   ```

3. **Prepare red markers | 准备红色标记物**
   - Attach red stickers/caps to your index and middle fingers
   - Ensure consistent red hue under your lighting conditions

### Running the System | 运行系统

```matlab
% Navigate to project directory
cd('path/to/HandMouse')

% Execute main script
HandMouse
```

The system will launch a quad-view window:
- **Top-Left**: Original webcam feed
- **Top-Right**: Binary mask (red region detection)
- **Bottom-Left**: Labeled frame (finger IDs)
- **Bottom-Right**: Current gesture state

### Basic Operation | 基本操作

1. **Initialization**: Show both fingers to camera (labeled as "1" and "2")
2. **Move Cursor**: Keep both fingers visible and move finger 2
3. **Left Click**: Hide finger 1, keep finger 2 visible
4. **Right Click**: Hide finger 2, keep finger 1 visible
5. **Exit**: Close the MATLAB figure window

---

## ⚙️ Configuration | 参数配置

### Tunable Parameters | 可调参数

Edit `HandMouse.m` to customize system behavior:

```matlab
% Color Detection Thresholds | 颜色检测阈值
redThresh = [0.95, 0.05];    % Hue range for red (wraps at 1.0)
satThresh = [0.6, 1];        % Saturation threshold
valThresh = [0.4, 1];        % Value (brightness) threshold

% Tracking Parameters | 跟踪参数
fingerDisplacementThreshold = 100;  % Max pixel displacement between frames
minArea = 1000;                     % Minimum finger region area (pixels²)

% Mouse Control | 鼠标控制
scaleFactor = 2.0;           % Cursor movement sensitivity (1.0-5.0)
moveThreshold = 5;           % Motion stabilization threshold (pixels)
```

### Performance Tuning | 性能调优

- **Increase FPS**: Reduce `pause(0.05)` value (line 220)
- **Improve Accuracy**: Adjust HSV thresholds for your lighting
- **Reduce Jitter**: Increase `moveThreshold` value
- **Faster Response**: Decrease `fingerDisplacementThreshold`

---

## 🔧 Troubleshooting | 故障排除

### Common Issues | 常见问题

**Q: Fingers not detected | 手指未被检测到**
- Check red color visibility in "Top-Right" window (should show white regions)
- Adjust `redThresh`, `satThresh`, `valThresh` for your lighting
- Ensure finger area ≥ 1000 pixels (move closer to camera)

**Q: Cursor movement too sensitive/slow | 光标移动过于灵敏/缓慢**
- Modify `scaleFactor` (default 2.0):
  - Increase for faster movement
  - Decrease for precise control

**Q: Finger IDs switching unexpectedly | 手指编号意外切换**
- Reduce `fingerDisplacementThreshold` to enforce stricter tracking
- Move fingers more slowly to maintain ID consistency

**Q: Mouse clicks not responding | 鼠标点击无响应**
- Verify Java AWT permissions (run MATLAB as administrator on Windows)
- Check if other applications are blocking mouse events

---

## 📊 Performance Metrics | 性能指标

| Metric | Value |
|--------|-------|
| Frame Rate | ~20 FPS |
| Latency | <50 ms |
| Tracking Accuracy | 95%+ (stable lighting) |
| False Positive Rate | <5% (red-free background) |
| CPU Usage | ~25% (Intel i5-8250U) |
| Memory Footprint | ~300 MB |

---

## 🔬 Technical Details | 技术细节

### Color Space Selection | 色彩空间选择

HSV was chosen over RGB for:
- **Illumination Invariance**: V channel separates brightness from chrominance
- **Perceptual Uniformity**: H channel aligns with human color perception
- **Threshold Simplicity**: Hue wrapping naturally handles red (0°/360°)

### Morphological Operations | 形态学操作

```matlab
% Opening: Erosion → Dilation (removes small noise)
redMask = imopen(redMask, strel('disk', 5));

% Closing: Dilation → Erosion (fills internal gaps)
redMask = imclose(redMask, strel('disk', 5));
```

**Structuring Element**: Disk-shaped kernel (5px radius) balances noise removal and shape preservation.

### Finger Tracking Algorithm | 手指跟踪算法

**ID Persistence Strategy**:
1. Sort detected centroids by X-coordinate (left-to-right)
2. Match current centroids to previous positions via Euclidean distance
3. Assign unmatched centroids to inactive IDs
4. Mark IDs inactive if unmatched for current frame

**Benefits**:
- Maintains consistent finger IDs during occlusion
- Prevents ID flipping when fingers cross
- No training data required (rule-based)

---

## 📄 License | 许可证

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author | 作者

**Temmie**  
- GitHub: [@OlyMarco](https://github.com/OlyMarco)
- Project Date: July 6, 2024

