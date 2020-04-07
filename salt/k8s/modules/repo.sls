# -*- coding: utf-8 -*-
#******************************************
# Author:       Rongbo Chen
# Email:        980969523@qq.com
# Organization: http://www.hiecho.cn/
# Description:  Kubernetes repo
#******************************************

k8s-repo:
  file.managed:
    - name: /etc/yum.repos.d/kubernetes.repo
    - source: salt://k8s/templates/docker/kubernetes.repo.template
    - user: root
    - group: root
    - mode: 644
