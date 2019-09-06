#!/bin/bash

# Function: followIoTEdgeInstruction()
# Desc:   Execute the commands from the IoT Edge tutorial to install IoT Edge module on a device
# Inputs: $OS_NAME, $OS_VERS, ./microsoft-prod.list
# Ref:    https://docs.microsoft.com/en-us/azure/iot-edge/how-to-install-iot-edge-linux
followIoTEdgeInstruction () {
  
    # Copy the generated list
    sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/ ||
      { echo "Copy the generated list Failed" && exit 1; }

    # Install Microsoft GPG public key
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg ||
      { echo "Install Microsoft GPG public key Failed" && exit 1; }

    sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/ ||
      { echo "Copy trusted.gpg.d Failed" && exit 1; }

    sudo apt-get update ||
      { echo "apt-get update Failed" && exit 1; }

    # Install the Moby engine
    sudo apt-get install -y moby-engine ||
      { echo "Install moby-engine Failed" && exit 1; }

    # Install the Moby command-line interface (CLI)
    sudo apt-get install -y moby-cli ||
      { echo "Install moby-cli Failed" && exit 1; }

    # apt update
    sudo apt-get update ||
      { echo "apt-get update Failed" && exit 1; }

    # Install the security daemon. 
    # The package is installed at /etc/iotedge/
    sudo apt-get install -y iotedge ||
      { echo "Install iotedge Failed" && exit 1; }
    
    # Clean-up
    rm -f ./microsoft-prod.list ./microsoft.gpg

} #followIoTEdgeInstruction
  
# Function: installDotnetCoreSDK
# Desc: Install .Net Core SDK
# Inputs: $OS_VERS, ./packages-microsoft-prod.deb
# Ref: https://dotnet.microsoft.com/download/linux-package-manager/ubuntu18-04/sdk-current
installDotnetCoreSDK () {

  sudo dpkg -i packages-microsoft-prod.deb ||
  { echo "Failed to register .Net Core SDk" && exit 1; }

  if [ $OS_VERS == 18.04 ]; then 
    sudo add-apt-repository -y universe ||
    { echo "Failed to register the universe" && exit 1; }
  fi

  sudo apt-get install -y apt-transport-https ||
  { echo "Failed to install apt-transport-https" && exit 1; }

  sudo apt-get -y update ||
  { echo "Failed to apt-get update" && exit 1; }

  sudo apt-get install -y dotnet-sdk-2.2 ||
  { echo "Failed to install dotnet-sdk-2.2" && exit 1; }

  rm -f ./packages-microsoft-prod.deb

} #installDotnetCoreSDK


################### MAIN ####################
# Installing: openssh-server, .NetCoreSDK, AzureCLI, IotEdge



# Fetch the $OS_NAME and $OS_VERS
. ./GetOsVersion.sh

case $OS_NAME in
  Ubuntu)
    sudo apt-get -y update ||
    { echo "apt-get update failed" && exit 1; }

    # Install curl
    if [ -z $(which curl) ]; then
      sudo apt install -y curl         || 
        { echo "Installation Failed: Curl" && exit 1; }
    fi

    # Install Azure CLI
    if [ -z $(which az) ]; then
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash;
    fi

    # Enable ssh
    { sudo service ssh status | grep running; } || 
    sudo apt-get install -y openssh-server || 
    { echo "Failed to install openssh-server" && exit 1; }

    sudo apt autoremove -y

    # Install java using jre 
    if [ -z $(which java) ]; then
      sudo apt-get install -y default-jre || 
        { echo "Installation Failed: java" && exit 1; }
    fi

    case $OS_VERS in 
      16.04)
        # Installing .Net Core SDK
        wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb ||
        { echo "Failed to download .Net Core SDk" && exit 1; }
        installDotnetCoreSDK

        # Setup for IoT Edge installation
        curl https://packages.microsoft.com/config/ubuntu/16.04/multiarch/prod.list > ./microsoft-prod.list ||
          { echo "Installation Failed: IoT Edge" && 
            exit 1; }
        ;;

      18.04)
        # Installing .Net Core SDK
        # see: https://dotnet.microsoft.com/download/linux-package-manager/ubuntu16-04/sdk-current
        wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb ||
        { echo "Failed to download .Net Core SDk" && exit 1; }
        installDotnetCoreSDK

        # Setup for IoT Edge installation
        curl https://packages.microsoft.com/config/ubuntu/18.04/multiarch/prod.list > ./microsoft-prod.list ||
          { echo "Installation Failed: IoT Edge" && 
            exit 1; }
        ;;
      
      *)
        echo "InstallIoTEdge.sh does not support Iot Edge installation for the OS Version";
        exit 1;
        ;;
    esac #case $OS_VERS

    # Install IoT Edge Linux
    followIoTEdgeInstruction

    ;; #Ubuntu)

  Raspbian)
    sudo apt-get -y update ||
    { echo "apt-get update failed" && exit 1; }

    # Install curl
    if [ -z $(which curl) ]; then
      sudo apt install -y curl         || 
        { echo "Installation Failed: Curl" && exit 1; }
    fi

    # Install Azure CLI
    if [ -z $(which az) ]; then
      curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash;
    fi

    case $OS_VERS in 
      10)
        curl https://packages.microsoft.com/config/ubuntu/16.04/multiarch/prod.list > ./microsoft-prod.list ||
          { echo "Installation Failed: IoT Edge" && exit 1; }
        ;;
      *)
        echo "InstallIoTEdge.sh does not support Iot Edge installation for the OS Version";
        exit 1;
        ;;
    esac #case $OS_VERS

    # Install IoT Edge Linux
    followIoTEdgeInstruction

    ;; #Raspbian)

  *)
    echo "InstallIoTEdge.sh does not support Iot Edge installation for this OS";
    ;; #*)
    
esac #case $OS_NAME 

