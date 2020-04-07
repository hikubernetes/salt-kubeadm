# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        980969523@qq.com
# Organization: http://www.hiecho.cn/
# Description:  Kubeadm Master init YAML
#******************************************

master-init:
  cmd.run:
    - name: kubeadm init --config /etc/sysconfig/kubeadm.yml --ignore-preflight-errors=Swap,NumCPU
    - unless: test -f /etc/kubernetes/admin.conf
