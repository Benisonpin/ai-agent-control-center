# Next Steps - Hardware Integration Roadmap

## Week 1-2: Camera Sensor Integration
- [ ] I2C driver for IMX586/IMX766
- [ ] V4L2 subdevice implementation  
- [ ] MIPI CSI-2 configuration
- [ ] Raw image capture validation

## Week 3-4: Real ISP Pipeline
- [ ] Port AAHD demosaic to NEON
- [ ] Implement lens shading correction
- [ ] Bad pixel correction
- [ ] Black level compensation

## Week 5-6: 3A Implementation
- [ ] Auto Exposure (AE) with face priority
- [ ] Auto White Balance (AWB) with AI scene detection
- [ ] Phase Detection Auto Focus (PDAF)
- [ ] Flicker detection

## Week 7-8: AI Integration
- [ ] NPU driver integration
- [ ] TensorFlow Lite runtime
- [ ] Scene detection model (13 classes)
- [ ] Face detection/beautification

## Week 9-10: Advanced Features
- [ ] HDR tone mapping (3-exposure)
- [ ] Night mode (multi-frame fusion)
- [ ] Portrait mode (depth estimation)
- [ ] Video stabilization (EIS)

## Week 11-12: Optimization & Testing
- [ ] NEON SIMD optimization
- [ ] GPU compute shaders
- [ ] Power optimization
- [ ] Compliance testing

## Hardware Requirements
1. Development Board: 
   - Qualcomm RB5 or 
   - NVIDIA Jetson Nano or
   - Custom board with ISP

2. Camera Module:
   - IMX586 48MP or
   - IMX766 50MP
   - With OIS support

3. Test Equipment:
   - Color checker
   - Light box
   - Resolution charts
   - Oscilloscope (for timing)

## Success Metrics
- 4K@30fps with full ISP
- <100ms shot-to-shot latency
- >80 dB dynamic range
- <5W power consumption
- 95% color accuracy
