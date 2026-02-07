set -e
set -o pipefail

echo "Starting installation of Docker, KIND and kubectl..."

#1. Installing Docker


if ! command -v docker &>/dev/null; then
	echo "Installing docker..."
	sudo apt-get update -y
	sudo apt-get install -y docker.io
	echo "Adding current user to the docker group..."
	sudo usermod -aG docker "$USER"
	echo "Docker installed and user added to the docker group..."
else
	echo "Docker is already installed!"
fi

# 2. Installing KIND

if ! command -v kind &>/dev/null; then
	echo "Installing KIND...."
	ARCH=$(uname -m)
	if [ "$ARCH" = "x86_64" ]; then
	  curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64"
	elif [ "$ARCH" = "aarch64" ]; then
	  curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64"
	else
	  echo "Unsupported architecture: $ARCH"
	  exit 1
	fi

	chmod +x ./kind
	sudo mv ./kind /usr/local/bin/kind
	echo "KIND installed successfully!"
else
	echo "KIND is already installed!"
fi


# 3. Installing kubectl


if ! command -v kubectl &>/dev/null; then
	echo "Installing kubectl (latest stable version)..."

	ARCH=$(uname -m)
	VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)

	if [ "$ARCH" = "x86_64" ]; then
	  curl -Lo ./kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl"
	elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
	  curl -Lo ./kubectl "https://dl.k8s.io/release/${VERSION}/bin/linux/arm64/kubectl"
	else
	  echo "Unsupported architecture : $ARCH"
	  exit 1
	fi

	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/kubectl
	echo "kubectl installed succesfully!!"
else
	echo "kubectl already installed!!"
fi


# 4. Confirm version


echo 
echo "Installed versions..."

docker --version
kind --version

kubectl version --client --output=yaml

echo
echo "Docker, KIND, and kubectl installation done!!"
