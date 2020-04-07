# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        980969523@qq.com
# Organization: http://www.hiecho.cn/
# Description:  Kubeadm init YAML
#******************************************

{% set k8s_version = "1.14.9" %}

include:
  - k8s.modules.repo

kubectl-install:
  pkg.installed:
    - name: kubectl
    - version: 1.14.9-0
    - require:
      - file: k8s-repo

kubeadm-install:
  pkg.installed:
    - name: kubeadm
    - version: 1.14.9-0
    - require:
      - file: k8s-repo
  file.managed:
    - name: /etc/sysconfig/kubeadm.yml
    - source: salt://k8s/templates/kubeadm/kubeadm.yml.template
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        SERVICE_CIDR: {{ pillar['SERVICE_CIDR'] }}  
        POD_CIDR: {{ pillar['POD_CIDR'] }}  
        MASTER_IP: {{ pillar['MASTER_IP'] }}  
