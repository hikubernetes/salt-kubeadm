# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        chenrongbo666@foxmail.com
# Organization: http://www.hiecho.cn
# Description:  Kubernetes Master
#******************************************

include:
  - k8s.modules.init
  - k8s.modules.docker
  - k8s.modules.repo
  - k8s.modules.kubelet
  - k8s.modules.kubemaster
  - k8s.modules.flannel
  - k8s.modules.master-init
