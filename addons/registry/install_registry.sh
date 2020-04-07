#/bin/bash
# -*- coding: utf-8 -*-
#********************************************
# Author:       Rongbo Chen
# Email:        rongbochen@foxmail.com
# Organization: http://www.hiceho.cn/
# Description:  Install Registry with Shell
#********************************************
namespace="kube-registry"
kubectl create ns $namespace
#生成证书文件；使用K8S根CA签发新的CA证书
#cfssl gencert -ca=./ca.pem -ca-key=./ca-key.pem -config=./ca-config.json -profile=docker docker-csr.json | cfssljson -bare docker
#将文件内容配置到ConfigMap
domainkey=`sed ':a;N;$!ba;s/\n/\\\\r\\\\n/g' docker-key.pem`
domaincrt=`sed ':a;N;$!ba;s/\n/\\\\r\\\\n/g' docker.pem`


cp -i docker-registry.yaml.template docker-registry.yaml

echo "
apiVersion: v1
kind: ConfigMap
data:
  domain.crt: \"$domaincrt\"
  domain.key: \"$domainkey\"
metadata:
  name: tls-registry
  namespace: $namespace
" >> docker-registry.yaml
#kubectl apply -f ./docker-registry.yaml
