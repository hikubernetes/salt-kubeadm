### Docker Registry 镜像仓库安装

###### 1. 安装脚本

```shell
#/bin/bash
# -*- coding: utf-8 -*-
#********************************************
# Author:       Rongbo Chen
# Email:        casparchen007@foxmail.com
# Organization: http://www.hiceho.cn/
# Description:  Install Registry with Shell
#********************************************
namespace = "kube-registry"
kubectl create ns $namespace
#生成证书文件；使用K8S根CA签发新的CA证书
cfssl gencert -ca=/etc/kubernetes/ssl/ca.pem -ca-key=/etc/kubernetes/ssl/ca-key.pem -config=ca-config.json -profile=docker docker-csr.json | cfssljson -bare docker
#将文件内容配置到ConfigMap
domainkey=`sed ':a;N;$!ba;s/\n/\\\\r\\\\n/g' docker-key.pem`
domaincrt=`sed ':a;N;$!ba;s/\n/\\\\r\\\\n/g' docker.pem`

cp -i docker-registry.yaml.template docker-registry.yaml

echo "
apiVersion: v1
kind: ConfigMap
data:
  domain.crt: \"$domaincrt\"
  domin.key: \"$domainkey\"
metadata:
  name: tls-external
  namespace: $namespace
" >> docker-registrybectl apply -f ./docker-registry.yaml
```



###### 2. K8S配置模板

- ConfigMap 模板

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: registry-config
  namespace: kube-registry
data:
  config.yml: |+
    version: 0.1
    log:
      level: debug
      fields:
        service: registry
    storage:
        cache:
            layerinfo: inmemory
            blobdescriptor: inmemory
        filesystem:
            rootdirectory: /var/lib/registry
        maintenance:
          uploadpurging:
              enabled: false
        delete:
          enabled: true
    http:
        addr: :443
        secert: placeholder
        host: https://hub.hiecho.cn
        debug:
            addr: :5001
        tls:
            certificate: /etc/registry/domain.crt
            key: /etc/registry/domain.key
    auth:
      htpasswd:
        realm: basic-realm
        path: /etc/docker/registry/authpasswd

  authpasswd:
    rongbochen:$2y$05$CMJvP.33BRZ1YfWhjjglse8JX/.PCbvLhjjhgjpeI1HXkF.zXvTO.
```

- Deployment 模板

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: registry
  namespace: kube-registry
  labels:
    app: registry
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: registry
    spec:
      nodeSelector:
        k8s_cluster: kube-registry
      containers:
        - name: registry
          image: "registry.cn-hangzhou.aliyuncs.com/hikubernetes/registry:2.6.2"
          imagePullPolicy: IfNotPresent
          command:
          - /bin/registry
          - serve
          - /etc/docker/registry/config.yml
          ports:
            - containerPort: 443
              hostPort: 443
              name: porthttps
          volumeMounts:
            - name: data
              mountPath: /var/lib/registry/
            - name: registry-config
              mountPath: /etc/docker/registry
            - name: tls-registry
              mountPath: /etc/registry
      volumes:
        - name: registry-config
          configMap:
            name: registry-config
        - name: data
          hostPath:
            path: /Docker
        - name: tls-registry
          configMap:
            name: tls-registr
```

- 证书请求文件模板

```yaml
{
        "CN": "docker",
        "hosts": [
                "hub.hiecho.cn",
                "172.16.1.6",
                "127.0.0.1"
        ],
        "key": {
                "algo": "rsa",
                "size": 2048
        },
        "names": [{
                "C": "CN",
                "ST": "BeiJing",
                "L": "BeiJing",
                "O": "k8s",
                "OU": "System"
        }]
}
```

- CA配置文件
```
{
    "signing": {
      "default": {
        "expiry": "87600h"
      },
      "profiles": {
        "docker": {
          "usages": [
              "signing",
              "key encipherment",
              "server auth",
              "client auth"
          ],
          "expiry": "87600h"
        }
      }
    }
  }
```

  

