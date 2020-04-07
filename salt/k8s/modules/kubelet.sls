# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        980969523@qq.com
# Organization: http://www.hiecho.cn/
# Description:  Kubernetes Node kubelet
#******************************************

{% set k8s_version = "1.14.9-0" %}

include:
  - k8s.modules.init
  - k8s.modules.repo

kubelet-install:
  pkg.installed:
    - name: kubelet
    - version: {{ k8s_version }}
    - require:
      - file: k8s-repo
  file.managed:
    - name: /etc/sysconfig/kubelet
    - source: salt://k8s/templates/kubelet/kubelet.sysconfig.template
    - user: root
    - group: root
    - mode: 644
  service.running:
    - name: kubelet
    - enable: True
    - watch:
      - file: kubelet-install 
