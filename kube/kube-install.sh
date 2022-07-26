echo "*********************************************"
echo "STEP 1 : INSTALLING KUBELET, KUBEADM & KUBECTL"
echo "*********************************************"
sudo apt update
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt -y install vim git curl wget kubelet=1.23.6-00 kubeadm=1.23.6-00 kubectl=1.23.6-00
sudo apt-mark hold kubelet kubeadm kubectl
sleep 1

echo "*********************"
echo "STEP 2 : DISABLE SWAP"
echo "*********************"
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a
sleep 1

echo "******************************"
echo "STEP 3 : ENABLE KERNEL MODULES"
echo "******************************"
# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter
# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
# Reload sysctl
sudo sysctl --system
sleep 1

echo "***************************************************"
echo "STEP 4 : INSTALLING CONTAINERD AS CONTAINER RUNTIME"
echo "***************************************************"
# Configure persistent loading of modules
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure sysctl params are set
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs
sudo sysctl --system

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Add Docker repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io=1.5.11-1

sudo su <<EOF
mkdir -p /etc/containerd
containerd config default>/etc/containerd/config.toml
EOF

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
