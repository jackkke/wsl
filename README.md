# 自定义 WSL2 镜像、WSL2+Docker 镜像
[官网说明](https://learn.microsoft.com/zh-cn/windows/wsl/build-custom-distro)

## 目前支持发行版
* **RockyLinuxDocker** `10.1`
  * 基于 Rocky-XXX-WSL-Base-XXX-XXX.x86_64.wsl
  * 补充了一些基础包
  * 增加了 Docker、Docker Compose 离线包
* **Alpine** `3.23.2`
  * 基于 alpine-minirootfs-XXX-x86_64.tar.gz
  * 安装了一些基础包
  * 处理了 openrc network 等问题
* **AlpineDocker** `3.23.2`
  * 同 Alpine
  * 增加了 Docker、Docker Compose 离线包

## 更新说明

### AlpineDocker-3.23.2-3、Alpine-3.23.2-3
* 增加终端颜色
* 增加 ls、grep 等命令颜色高亮

## RockyDocker-10.1-20251116.0-1
* 首次发布
