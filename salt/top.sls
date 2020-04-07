# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        980969523@qq.com
# Organization: http://www.hieco.cn/
# Description:  SaltStack Top File
#******************************************

base:
  'k8s-role:master':
    - match: grain
    - k8s.master
  'k8s-role:node':
    - match: grain
    - k8s.node
