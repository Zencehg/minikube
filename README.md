# minikube
Hosting for minikube use case 

Notes:
```text
# Windows 11 minikube installation with WSL and Docker:
PS C:\Windows\system32> kubectl get po -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS      AGE
kube-system   coredns-6f6b679f8f-xgkxt           1/1     Running   0             34s
kube-system   etcd-minikube                      1/1     Running   0             40s
kube-system   kube-apiserver-minikube            1/1     Running   0             41s
kube-system   kube-controller-manager-minikube   1/1     Running   0             39s
kube-system   kube-proxy-4n5xt                   1/1     Running   0             34s
kube-system   kube-scheduler-minikube            1/1     Running   0             39s
kube-system   storage-provisioner                1/1     Running   1 (12s ago)   37s

# Add cilium repo to helm:
helm repo add cilium https://helm.cilium.io/

# installation with default values
helm install cilium cilium/cilium --version 1.16.1  --namespace kube-system
NAME: cilium
LAST DEPLOYED: Tue Sep 17 15:33:25 2024
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
You have successfully installed Cilium with Hubble.

Your release version is 1.16.1.

# helm list
PS C:\Windows\system32> helm list -n kube-system
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
cilium  kube-system     1               2024-09-17 15:33:25.982933 +0300 EEST   deployed        cilium-1.16.1   1.16.1 

# cilium pods
PS C:\Windows\system32> kubectl get po -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS      AGE
kube-system   cilium-89tzj                       1/1     Running   0             25m
kube-system   cilium-envoy-f8svh                 1/1     Running   0             25m
kube-system   cilium-operator-5c7867ccd5-8ghnl   0/1     Pending   0             25m
kube-system   cilium-operator-5c7867ccd5-k298t   1/1     Running   0             25m
kube-system   coredns-6f6b679f8f-4cnzn           1/1     Running   0             24m
kube-system   etcd-minikube                      1/1     Running   0             41m
kube-system   kube-apiserver-minikube            1/1     Running   0             41m
kube-system   kube-controller-manager-minikube   1/1     Running   0             41m
kube-system   kube-proxy-4n5xt                   1/1     Running   0             41m
kube-system   kube-scheduler-minikube            1/1     Running   0             41m
kube-system   storage-provisioner                1/1     Running   1 (40m ago)   41m

# get daemonsets
PS C:\Windows\system32> kubectl get daemonsets -n kube-system
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
cilium         1         1         1       1            1           kubernetes.io/os=linux   31m
cilium-envoy   1         1         1       1            1           kubernetes.io/os=linux   31m
kube-proxy     1         1         1       1            1           kubernetes.io/os=linux   47m

# get configmaps 
kubectl get configmaps -n kube-system kubeadm-config -o yaml
...
networking:
      dnsDomain: cluster.local
      podSubnet: 10.244.0.0/16
      serviceSubnet: 10.96.0.0/12
...

# Check Cilium config
kubectl -n kube-system exec ds/cilium -- cilium-dbg status
...
Masquerading:            IPTables [IPv4: Enabled, IPv6: Disabled]
...

# apply config changes (adding ingress)
## cilium-values.yaml
...
ingressController:
  enabled: true
  loadbalancerMode: dedicated
...

helm upgrade -n kube-system cilium cilium/cilium -f cilium/cilium-values.yaml


# restart ds
$ kubectl -n kube-system rollout restart deployment/cilium-operator
$ kubectl -n kube-system rollout restart ds/cilium

# install nginx
helm install nginx ngnix-test -n nginx

# add repo for httpd
helm repo add bitnami https://charts.bitnami.com/bitnami

```