# SaltStack自动化部署Kubernetes(kubeadm版)
test

- 本文是基于saltstack与kubeadm自动化部署k8s集群

## 版本明细：

- 测试通过系统：CentOS 7.6
- salt-ssh:     3000.1
- kubernetes：  v1.14.9
- docker-ce:    18.09.7

本实例可以单节点部署整个K8S集群的组件

### 架构介绍
1. 使用Salt Grains进行角色定义，增加灵活性。
2. 使用Salt Pillar进行配置项管理，保证安全性。
3. 使用Salt SSH执行状态，不需要安装Agent，保证通用性。
4. 使用Kubernetes当前稳定版本v1.14.9，保证稳定性。


## 1.系统初始化(必备)

1.1 设置主机名，且保证主机名能被DNS解析
```
cat /etc/hosts
linux-noed1 172.16.1.6
```

1.2关闭SELinux

```
[root@linux-node1 ~]# vim /etc/sysconfig/selinux
SELINUX=disabled #修改为disabled
```

1.3 关闭NetworkManager和防火墙开启自启动
```
[root@linux-node1 ~]# systemctl stop firewalld && systemctl disable firewalld
[root@linux-node1 ~]# systemctl stop NetworkManager && systemctl disable NetworkManager
```

## 2.安装Salt-SSH并克隆本项目代码。

2.1 设置部署节点到其它所有节点的SSH免密码登录（包括本机）
```bash
 ssh-keygen -t rsa
 ssh-copy-id linux-node
```

2.2 安装Salt SSH（注意：老版本的Salt SSH不支持Roster定义Grains，需要2017.7.4以上版本）
```bash
yum install -y https://mirrors.aliyun.com/saltstack/yum/redhat/salt-repo-latest-2.el7.noarch.rpm
sed -i "s/repo.saltstack.com/mirrors.aliyun.com\/saltstack/g" /etc/yum.repos.d/salt-latest.repo
yum install -y salt-ssh git
```

2.3 获取本项目代码，并放置在/srv目录
```bash
git clone https://github.com:hikubernetes/salt-kubeadm.git
cd salt-kubeadm/
mv * /srv/
cp /srv/roster /etc/salt/roster
cp /srv/master /etc/salt/master
```


## 3.Salt SSH管理的机器以及角色分配

- k8s-role: 用来设置K8S的角色

```
[root@linux-node1 ~]# vim /etc/salt/roster 
# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        casparchen007@foxmail.com
# Organization: http://www.hiecho.cn
# Description:  Salt SSH Roster
#******************************************

linux-node1:
  host: 172.16.1.6
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts: 
    grains:
      k8s-role: master

linux-node2:
  host: 172.16.1.6
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
```

## 4.修改对应的配置参数，本项目使用Salt Pillar保存配置
```
[root@k8s-master-m srv]# cat /srv/pillar/k8s.sls 
# -*- coding: utf-8 -*-
#********************************************
# Author:       Rongbo Chen
# Email:        casparchen007@foxmail.com
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
```

## 5.单Master集群部署

5.1 测试Salt SSH联通性
```bash
salt-ssh '*' test.ping
```

5.2 部署K8S集群
执行高级状态，会根据定义的角色再对应的机器部署对应的服务
```bash
salt-ssh '*' state.highstate
```
5.3 初始化Master节点

如果是在实验环境，只有1个CPU，并且虚拟机存在交换分区，在执行初始化的时候需要增加--ignore-preflight-errors=Swap,NumCPU。
```bash
kubeadm init --config /etc/sysconfig/kubeadm.yml --ignore-preflight-errors=Swap,NumCPU 
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
```

5.4 部署网络插件Flannel 

```bash
kubectl create -f /etc/sysconfig/kube-flannel.yml 
```

5.5 节点加入集群
1.在Master节点上输出加入集群的命令：
```bash
[root@linux-node1 ~]# kubeadm token create --print-join-command
```
2.在Node节点上执行上面输出的命令，进行部署并加入集群，注意如果节点存在交换分区请增加--ignore-preflight-errors=Swap参数。

## 6.测试Kubernetes安装
```
[root@linux-node1 ~]# kubectl get cs
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   

[root@linux-node1 ~]# kubectl get node
NAME            STATUS    ROLES     AGE       VERSION
172.16.1.6   Ready     master    1m        v1.14.9
```

## 7.测试Kubernetes集群和Flannel网络

```
[root@linux-node1 ~]# kubectl run net-test --image=alpine --replicas=2 sleep 360000
deployment "net-test" created

测试联通性，如果都能ping通pod ip，说明Kubernetes集群部署完毕。
```
## 8.如何新增Kubernetes节点

- 1.设置SSH无密码登录
- 2.在/etc/salt/roster里面，增加对应的机器
- 3.执行SaltStack状态salt-ssh '*' state.highstate。
```bash
[root@linux-node1 ~]# vim /etc/salt/roster 
linux-node4:
  host: 172.16.1.4
  user: root
  priv: /root/.ssh/id_rsa
  minion_opts:
    grains:
      k8s-role: node
[root@linux-node1 ~]# salt-ssh 'linux-node2' state.highstate
```

