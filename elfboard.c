#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h> // PPSIX 终端控制定义
#include <sys/select.h>

// 全局定义串口设备节点
#define UART_DEVICE "/dev/ttyS9"

/**
 * @brief  配置并打开串口设备
 * @param  device_path : 串口设备文件的路径
 * @return int : 成功返回文件描述符，失败返回-1
 */
int initialize_serial_port(const char *device_path) {
    int serial_fd = open(device_path, O_RDWR | O_NOCTTY | O_NDELAY);
    if (serial_fd < 0) {
        perror("打开串口设备失败");
        return -1;
    }

    // 恢复为阻塞模式，以便后续使用 select 进行精确控制
    fcntl(serial_fd, F_SETFL, 0);

    struct termios new_config, old_config;

    // 1. 获取当前串口配置
    if (tcgetattr(serial_fd, &old_config) != 0) {
        perror("获取串口属性失败");
        return -1;
    }

    // 2. 设置新的串口配置
    bzero(&new_config, sizeof(new_config));
    new_config.c_cflag |= CLOCAL | CREAD; // 启用接收器并设置为本地模式
    new_config.c_cflag &= ~CSIZE;         // 清除数据位掩码

    // 设置数据位、停止位和校验位
    new_config.c_cflag |= CS8;            // 8位数据位
    new_config.c_cflag &= ~PARENB;        // 无奇偶校验
    new_config.c_cflag &= ~CSTOPB;        // 1位停止位
    
    // 设置输入输出波特率
    cfsetispeed(&new_config, B115200);      // 设置输入波特率为115200
    cfsetospeed(&new_config, B115200);      // 设置输出波特率为115200

    // 设置等待时间和最小接收字符数
    new_config.c_cc[VTIME] = 0;           // 不使用超时控制
    new_config.c_cc[VMIN] = 0;            // 不设置最小字符数

    // 3. 清空串口缓冲区并激活新配置
    tcflush(serial_fd, TCIFLUSH);
    if (tcsetattr(serial_fd, TCSANOW, &new_config) != 0) {
        perror("设置串口属性失败");
        return -1;
    }

    printf("串口 %s 初始化成功！\n", device_path);
    return serial_fd;
}

/**
 * @brief  从串口接收数据
 * @param  serial_fd : 串口文件描述符
 * @param  rx_buffer : 接收数据缓冲区
 * @param  buffer_size : 缓冲区最大长度
 * @return int : 成功返回接收到的字节数，失败返回-1
 */
int receive_data_from_uart(int serial_fd, unsigned char *rx_buffer, int buffer_size) {
    fd_set read_fds;
    struct timeval timeout;
    
    FD_ZERO(&read_fds);
    FD_SET(serial_fd, &read_fds);

    // 设置select超时时间为500毫秒
    timeout.tv_sec = 0;
    timeout.tv_usec = 500000;

    int ret = select(serial_fd + 1, &read_fds, NULL, NULL, &timeout);
    if (ret < 0) {
        perror("select 调用失败");
        return -1;
    } else if (ret == 0) {
        // 在超时时间内没有数据可读
        return 0;
    }

    if (FD_ISSET(serial_fd, &read_fds)) {
        int bytes_read = read(serial_fd, rx_buffer, buffer_size);
        if (bytes_read < 0) {
            perror("读取数据失败");
            return -1;
        }
        return bytes_read;
    }
    
    return -1; // 理论上不会执行到这里
}

/**
 * @brief  向串口发送数据
 * @param  serial_fd : 串口文件描述符
 * @param  tx_data : 待发送的数据
 * @param  data_length : 数据长度
 * @return int : 成功返回发送的字节数，失败返回-1
 */
int send_data_to_uart(int serial_fd, const unsigned char *tx_data, int data_length) {
    int bytes_written = write(serial_fd, tx_data, data_length);
    if (bytes_written < 0) {
        perror("写入数据失败");
    }
    return bytes_written;
}


int main(int argc, char *argv[]) {
    // 初始化串口
    int serial_port_fd = initialize_serial_port(UART_DEVICE);
    if (serial_port_fd < 0) {
        return -1;
    }

    unsigned char tx_buffer[] = "Hello, this is ELF2 UART test!";
    unsigned char rx_buffer[128];
    int tx_len = strlen((const char*)tx_buffer);

    // 进入主循环，进行收发操作
    while (1) {
        // 1. 发送数据
        int sent_bytes = send_data_to_uart(serial_port_fd, tx_buffer, tx_len);
        if (sent_bytes > 0) {
            printf("--> 已发送 %d 字节: %s\n", sent_bytes, tx_buffer);
        } else {
            printf("发送失败或未发送任何数据。\n");
        }

        // 2. 等待一秒
        sleep(1);

        // 3. 接收数据
        memset(rx_buffer, 0, sizeof(rx_buffer)); // 清空接收缓冲区
        int received_bytes = receive_data_from_uart(serial_port_fd, rx_buffer, sizeof(rx_buffer));
        if (received_bytes > 0) {
            printf("<-- 已接收 %d 字节: %s\n", received_bytes, rx_buffer);
        } else if (received_bytes == 0) {
            printf("...未接收到数据...\n");
        }
        
        printf("------------------------------------\n");
    }

    // 关闭串口
    close(serial_port_fd);
    return 0;
}