#include <linux/i2c.h>
#include <linux/delay.h>
#include <media/v4l2-device.h>

// Camera Sensor 配置（以 IMX586 為例）
#define IMX586_I2C_ADDR     0x1A
#define IMX586_CHIP_ID      0x0586
#define IMX586_REG_CHIP_ID  0x0016

typedef struct {
    struct i2c_client* i2c_client;
    struct v4l2_subdev subdev;
    
    // Sensor 參數
    struct {
        u32 pixel_rate;
        u32 link_freq;
        u32 width;
        u32 height;
        u32 fps;
    } current_mode;
    
    // 控制
    struct v4l2_ctrl_handler ctrl_handler;
    struct v4l2_ctrl* exposure;
    struct v4l2_ctrl* gain;
    struct v4l2_ctrl* hblank;
    struct v4l2_ctrl* vblank;
    
    // UMS 整合
    void* ums_buffer;
    dma_addr_t ums_dma_addr;
    
} imx586_sensor_t;

// Sensor 初始化序列
static const struct reg_sequence imx586_init_settings[] = {
    // PLL 設定
    {0x0301, 0x05},  // VT_PIX_CLK_DIV
    {0x0303, 0x02},  // VT_SYS_CLK_DIV
    {0x0305, 0x04},  // PRE_PLL_CLK_DIV
    {0x0306, 0x01},  // PLL_MULTIPLIER
    {0x0307, 0x5E},  // PLL_MULTIPLIER
    {0x030B, 0x01},  // OP_SYS_CLK_DIV
    
    // MIPI 設定
    {0x0112, 0x0A},  // CSI_DATA_FORMAT (RAW10)
    {0x0113, 0x0A},  // CSI_LANE_MODE
    
    // Frame timing
    {0x0340, 0x0C},  // FRAME_LENGTH_LINES
    {0x0341, 0xE4},  
    {0x0342, 0x21},  // LINE_LENGTH_PCK
    {0x0343, 0x00},
    
    // 輸出大小 (4000x3000)
    {0x0344, 0x00},  // X_ADD_STA
    {0x0345, 0x00},
    {0x0346, 0x00},  // Y_ADD_STA
    {0x0347, 0x00},
    {0x0348, 0x0F},  // X_ADD_END
    {0x0349, 0x9F},
    {0x034A, 0x0B},  // Y_ADD_END
    {0x034B, 0xB7},
    
    // 數位增益
    {0x0204, 0x00},
    {0x0205, 0x00},
    {0x020E, 0x01},
    {0x020F, 0x00},
};

// 讀取 Sensor 暫存器
static int imx586_read_reg(imx586_sensor_t* sensor, u16 reg, u8* val) {
    struct i2c_msg msgs[2];
    u8 reg_buf[2] = {reg >> 8, reg & 0xff};
    
    // 寫入暫存器地址
    msgs[0].addr = sensor->i2c_client->addr;
    msgs[0].flags = 0;
    msgs[0].len = 2;
    msgs[0].buf = reg_buf;
    
    // 讀取數值
    msgs[1].addr = sensor->i2c_client->addr;
    msgs[1].flags = I2C_M_RD;
    msgs[1].len = 1;
    msgs[1].buf = val;
    
    return i2c_transfer(sensor->i2c_client->adapter, msgs, 2);
}

// 寫入 Sensor 暫存器
static int imx586_write_reg(imx586_sensor_t* sensor, u16 reg, u8 val) {
    u8 buf[3] = {reg >> 8, reg & 0xff, val};
    
    return i2c_master_send(sensor->i2c_client, buf, 3);
}

// 啟動串流
static int imx586_start_streaming(imx586_sensor_t* sensor) {
    int ret;
    
    // 應用初始化設定
    for (int i = 0; i < ARRAY_SIZE(imx586_init_settings); i++) {
        ret = imx586_write_reg(sensor, 
                              imx586_init_settings[i].reg,
                              imx586_init_settings[i].def);
        if (ret < 0) {
            dev_err(&sensor->i2c_client->dev, 
                   "Failed to write reg 0x%04x\n",
                   imx586_init_settings[i].reg);
            return ret;
        }
    }
    
    // 設定曝光和增益
    imx586_set_exposure(sensor, sensor->exposure->val);
    imx586_set_gain(sensor, sensor->gain->val);
    
    // 啟動串流
    ret = imx586_write_reg(sensor, 0x0100, 0x01);  // MODE_SELECT
    if (ret < 0) {
        dev_err(&sensor->i2c_client->dev, "Failed to start streaming\n");
        return ret;
    }
    
    // 配置 DMA 到 UMS buffer
    setup_sensor_dma_to_ums(sensor);
    
    return 0;
}

// 配置 DMA 直接寫入 UMS
static int setup_sensor_dma_to_ums(imx586_sensor_t* sensor) {
    // 從 UMS 獲取實體地址
    sensor->ums_dma_addr = ums_get_dma_addr(sensor->ums_buffer);
    
    // 配置 MIPI CSI-2 接收器 DMA
    csi2_set_dma_addr(sensor->ums_dma_addr);
    csi2_set_frame_size(sensor->current_mode.width * 
                       sensor->current_mode.height * 2);  // RAW10
    
    // 啟動 DMA
    csi2_enable_dma();
    
    return 0;
}
