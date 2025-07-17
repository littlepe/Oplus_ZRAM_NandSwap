### 项目简介
一款为 ColorOS 定制的小工具，通过动态配置 **zram** 提升多任务处理能力。  

### Project Introduction
A custom built gadget for ColorOS that boosts multitasking by dynamically configuring **zram** 。

### 许可证
本项目采用 **GPLv3** 许可证。详情见 [LICENSE](LICENSE) 文件。

### License
This project is licensed under the GPLv3 license. SEE THE [LICENSE](LICENSE) FILE FOR DETAILS.

### 错误代码解释
1005：设置 disksize 失败（找不到 disksize 文件）

1006： 在 $ZRAM_DEVICE 上执行 mkswap 失败

1007： $ZRAM_DEVICE 交换失败

### Error code explained
1005： Failed to set disksize (disksize file not found)

1006： Failed to mkswap on $ZRAM_DEVICE

1007： Failed to swapon $ZRAM_DEVICE
