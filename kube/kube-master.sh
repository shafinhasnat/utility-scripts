echo "***********************"
echo "STEP 1 : ENABLE KUBELET"
echo "***********************"
lsmod | grep br_netfilter
sudo systemctl enable kubelet

echo "******************************"
echo "STEP 2 : PULL CONTAINER IMAGES"
echo "******************************"
sudo kubeadm config images pull

echo "**********************************************"
echo "STEP 3 : BOOTSTRAPING KUBERNETES CONTROL PLANE"
echo "**********************************************"
sudo kubeadm init --pod-network-cidr=10.17.0.0/16 --service-cidr=10.18.0.0/24

echo "**********************************************"
echo "STEP 4 : ADD CONFIG TO KUBECONFIG"
echo "**********************************************"
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "*****************************************"
echo "STEP 5 : INSTALL WEAVE NET NETWORK PLUGIN"
echo "*****************************************"
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# kubeadm token create --print-join-command
