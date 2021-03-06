# -*- coding: utf-8 -*-
#********************************************
# Author:       Rongbo Chen
# Email:        chenrongbo666@foxmail.com
# Organization: http://www.hiecho.cn
# Description:  Kubernetes Config with Pillar
#********************************************

#设置Master的IP地址(必须修改)
MASTER_IP: "172.16.1.6"

#通过Grains FQDN自动获取本机IP地址，请注意保证主机名解析到本机IP地址
NODE_IP: {{ grains['fqdn_ip4'][0] }}


#配置Service IP地址段
SERVICE_CIDR: "10.254.0.0/16"

#Kubernetes服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_KUBERNETES_SVC_IP: "10.254.0.1"

#Kubernetes DNS 服务 IP (从 SERVICE_CIDR 中预分配)
CLUSTER_DNS_SVC_IP: "10.254.0.2"

#设置Node Port的端口范围
NODE_PORT_RANGE: "30000-40000"

#设置POD的IP地址段
POD_CIDR: "10.0.0.0/16"

#设置集群的DNS域名
CLUSTER_DNS_DOMAIN: "cluster.local."

#设置Docker Registry地址
DOCKER_REGISTRY: "https://hub.hiecho.cn"
