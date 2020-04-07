# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        980969523@qq.com
# Organization: http://www.hiecho.cn/
# Description:  System init
#******************************************
kube-sysctl:
  file.managed:
    - name: /etc/sysctl.d/k8s.conf
    - source: salt://k8s/templates/system/k8s.sysctl.template
    - user: root
    - group: root
    - mode: 644
  cmd.run:
    - name: cat /etc/sysctl.d/k8s.conf >> /etc/sysctl.conf && sysctl --system

kube-ipvs:
  pkg.installed:
    - name: ipvsadm
    - version: 1.27-7.el7
  file.managed:
    - name: /etc/sysconfig/modules/ipvs.modules
    - source: salt://k8s/templates/system/ipvs.modules.template
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: source /etc/sysconfig/modules/ipvs.modules

