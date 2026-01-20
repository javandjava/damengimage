# 使用 ARM64 架构的 Ubuntu 22.04 镜像
FROM ubuntu:jammy-20251013

# 设置环境变量
ENV DM_HOME_CMD=/home/dmdba/dmdbms/bin \
    DM_HOME=/home/dmdba/dmdbms \
    DM_DATA=/dbdata \
    DM_INSTALL=/dm

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=$PATH:$DM_HOME_CMD 

# 创建 dmdba 用户,创建数据目录,安装文件目录
RUN groupadd -g 1001 -r dmdba \
    && useradd -u 1001 -r -g dmdba -m -d /home/dmdba -s /bin/bash dmdba \
    && echo "dmdba:password123" | chpasswd \
    && echo "root:password123" | chpasswd \
    && usermod -aG sudo dmdba \
    && mkdir $DM_DATA \
    && mkdir $DM_INSTALL \
    && mkdir $DM_HOME

# 复制安装文件，静默安装配置，启动文件
COPY ./install/DMInstall.bin ./install/dm_init.xml $DM_INSTALL/
COPY ./install/entrypoint.sh /

# 修改权限
RUN chown dmdba:dmdba $DM_INSTALL -R \
    && chown dmdba:dmdba $DM_HOME -R \
    && chown dmdba:dmdba $DM_DATA -R \
    && chmod 755 $DM_INSTALL -R \
    && chmod +x /entrypoint.sh

# 切换到dmdba用户
USER dmdba

# 安装数据库，创建实例
RUN echo "------INSTALL DAMENG-------" \
    && cd $DM_INSTALL \
    && ./DMInstall.bin -q $DM_INSTALL/dm_init.xml \
    && echo "------INSTALL OVER--------"

# 删除安装文件
RUN rm -f $DM_INSTALL/DMInstall.bin
    
# 工作目录
WORKDIR $DM_HOME_CMD
    
# 暴露端口（根据需要）
EXPOSE 5236
EXPOSE 4236

ENTRYPOINT ["/entrypoint.sh"]

