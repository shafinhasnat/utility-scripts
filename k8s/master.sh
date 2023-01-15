echo -e "#################\nInitialize Control Pane\n#################"
lsmod | grep br_netfilter
sudo systemctl enable kubelet
sudo kubeadm config images pull
sleep 1

sudo kubeadm init --pod-network-cidr=10.244.0.0/16
sleep 1

echo -e "#################\nInitialize Control Pane\n#################"
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sleep 1

echo -e "#################\nInstall Weave\n#################"
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
sleep 1