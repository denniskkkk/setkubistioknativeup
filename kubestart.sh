kubeadm config images list
kubeadm config images pull
kubeadm init --pod-network-cidr=10.244.0.0/16 
#--certificate-renewal=true
rm -Rfv .kube
mkdir -p $HOME/.kube
cp -iv /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
kubectl get pods --all-namespaces
kubectl taint nodes --all node-role.kubernetes.io/master-

#calico
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

#canal
#kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/canal.yaml

#netweaver remember set /proc/sys/net/bridge/bridge-nf-call-iptables to 1 
#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

kubectl create namespace kubernetes-dashboard

kubectl apply -f - << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f - << EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc1/aio/deploy/recommended.yaml



