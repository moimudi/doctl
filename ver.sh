#!/usr/bin/env bash

###############################
# Check for curl              #
###############################
hasCurl() {
  which curl > /dev/null
  if [ "$?" = "1" ]; then
    echo "You need curl to use this script."
    exit 1
  fi
}

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# Clear the screen
clear

# Define color codes
CYAN='\033[0;36m'
PINK='\033[1;35m'
NC='\033[0m'


# These are the colours from tput setaf
NC=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
PINK=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
###############################################################################################

# Get the latest version of helm
function get_helm_version {
    helm=$(curl -s https://github.com/helm/helm/releases)
    helm=$(echo $helm | grep -oP '(?<=tag\/v)[0-9][^"]*' | grep -v \- | sort -Vr | head -1)

    # Get the installed version of helm
    installedhelm=$(helm version | grep -oP 'version.BuildInfo{Version:"v\K[^"]+')

    # Check if the installed version is up to date
    if [ "${helm}" == "${installedhelm}" ]; then
        echo -e "${CYAN}You have latest version of helm $helm${NC}"
    else
        echo -e "${PINK}You need to update to the latest helm version $helm. Your current version is $installedhelm${NC}"
        curl -LO https://get.helm.sh/helm-v$helm-linux-amd64.tar.gz
        tar -zxvf helm-v$helm-linux-amd64.tar.gz && rm -f /usr/local/bin/helm && mv linux-amd64/helm /usr/local/bin/helm

        rm -rf linux-amd64
        rm helm-v${helm}-linux-amd64.tar.gz
    fi
}

###############################################################################################

# Get the latest version of doctl
function get_doctl_version {
    doctl=$(curl -s https://github.com/digitalocean/doctl/releases)
    doctl=$(echo $doctl | grep -oP '(?<=tag\/v)[0-9][^"<]*' | grep -v \- | sort -Vr | head -1)
    # echo "Latest doctl version is $doctl"

    # doctl Installed version
    installeddoctl=$(doctl version | grep -oP '(?<=version )[^-]+')
    # echo "current installed doctl version is $installeddoctl"

    # Check if the installed version is up to date
    if [ "${doctl}" == "${installeddoctl}" ]; then
        echo -e "${CYAN}You have latest version of doctl $doctl${NC}"
    else
        echo -e "${PINK}You need to update to the latest doctl version $doctl. Your current version is $installeddoctl${NC}"

        cd ~
        wget https://github.com/digitalocean/doctl/releases/download/v$doctl/doctl-$doctl-linux-amd64.tar.gz \
        && tar xf ~/doctl-$doctl-linux-amd64.tar.gz \
        && sudo mv ~/doctl /usr/local/bin
        rm doctl-$doctl-linux-amd64.tar.gz
        
    fi
}


###############################################################################################

# Get the latest version of civo

function get_civo_version {
    civo=$(curl -s https://github.com/civo/cli/releases)
    civo=$(echo $civo\" |grep -oP '(?<=tag\/v)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest civo version is $civo"

    # civo Installed version
    installedcivo=$(civo version | grep -oP '(?<=v)\d+\.\d+\.\d+')
    # echo "current installed civo version is $installedcivo"

    if [ "${civo}" == "${installedcivo}" ]; then
        echo "${CYAN}You have latest version of civo $civo${NC}"
    else
      echo "${PINK}You need to updte to latest civo version $civo${NC}"
      curl -sL https://civo.com/get | sh

    fi
}
###############################################################################################

# Get the latest version of kubectl

function get_kubectl_version {

    kubectl=$(curl -s https://github.com/kubernetes/kubernetes/releases)
    kubectl=$(echo $kubectl\" |grep -oP '(?<=tag\/v)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest kubectl version is $kubectl"

    # kubectl Installed version
    installedkubectl=$(kubectl version 2> /dev/null | grep -oP 'GitVersion:"v\K[^"]+'|head -1)
    # echo "current installed kubectl version is $installedkubectl"

    if [ "${kubectl}" == "${installedkubectl}" ]; then
        echo "${CYAN}You have latest version of kubectl $kubectl${NC}"
    else
      echo "${PINK}You need to updte to latest kubectl version $kubectl, your current version is $installedkubectl${NC}"
      # install kubectl
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
      echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
      sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm -f kubectl
      rm -f kubectl.sha256
      kubectl version --client
      kubectl version --client --output=yaml
      
    fi
}
###############################################################################################
# terraform latest

function get_terraform_version {
    terraform=$(curl -s https://github.com/hashicorp/terraform/releases)
    terraform=$(echo $terraform\" |grep -oP '(?<=tag\/v)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest terraform version is $terraform"

    # terraform Installed version
    installedterraform=$(terraform version 2> /dev/null | grep -oP '(?<=v)\d+\.\d+\.\d+')
    # echo "current installed terraform version is $installedkubectl"

    if [ "${terraform}" == "${installedterraform}" ]; then
        echo "${CYAN}You have latest version of terraform $terraform${NC}"
    else
      echo "${PINK}You need to updte to latest terraform version $terraform, your current version is $installedterraform${NC}"
      wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
      sudo apt update && sudo apt install terraform
      terraform -install-autocomplete
      
    fi
}



###############################################################################################
# aws cli latest

function get_awscli_version {
    awscli=$(curl -s https://github.com/aws/aws-cli/tags)
    awscli=$(echo $awscli\" |grep -oP '(?<=tag\/)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest awscli version is $awscli"

    # aws cli Installed version
    installedawscli=$(aws --version 2> /dev/null | grep -oP '(?<=aws-cli\/)\d+\.\d+\.\d+')
    # echo "current installed awscli version is $installedawscli"

    if [ "${awscli}" == "${installedawscli}" ]; then
        echo "${CYAN}You have latest version of awscli $awscli${NC}"
    else
      echo "${PINK}You need to updte to latest awscli version $awscli, your current version is $installedawscli${NC}"
      # Build from source code
      wget "https://github.com/aws/aws-cli/archive/refs/tags/$awscli.tar.gz" -O "$awscli.tar.gz"
      tar -xzf $awscli.tar.gz && cd aws-cli-$awscli
      apt install python3.10-venv
      ./configure --with-download-deps
      make
      make install
      rm -f $awscli.tar.gz 
      rm -rf aws-cli-$awscli
      aws --version


    fi
}

###############################################################################################
# golang latest

function get_golang_version {
    go=$(curl -s https://github.com/golang/go/tags)
    go=$(echo $go\" |grep -oP '(?<=tag\/go)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest go version is $go"

    # go Installed version
    installedgo=$(go version 2> /dev/null |  grep -oP 'go\K\d+\.\d+\.\d+')
    # echo "current installed go version is $installedgo"

    if [ "${go}" == "${installedgo}" ]; then
        echo "${CYAN}You have latest version of go $go${NC}"
    else
      echo "${PINK}You need to updte to latest go version $go, your current version is $installedgo${NC}"
      # install go
      wget "https://go.dev/dl/go$go.linux-amd64.tar.gz" -O "go$go.linux-amd64.tar.gz"
      rm -rf /usr/local/go && tar -C /usr/local -xzf go$go.linux-amd64.tar.gz
      echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
      . ~/.bashrc
      go version
      rm go$go.linux-amd64.tar.gz
            
    fi
}

###############################################################################################
# maven latest

function get_maven_version {
    maven=$(curl -s https://github.com/apache/maven/tags)
    maven=$(echo $maven\" |grep -oP '(?<=tag\/maven-)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest maven version is $maven"

    # maven Installed version
    installedmaven=$(mvn --version 2> /dev/null | grep -oP '(?<=Apache Maven )\d+\.\d+\.\d+')
    # echo "current installed maven version is $installedmaven"

    if [ "${maven}" == "${installedmaven}" ]; then
        echo "${CYAN}You have latest version of maven $maven${NC}"
    else
      echo "${PINK}You need to updte to latest maven version $maven, your current version is $installedmaven${NC}"
      # Build from source code
      BASE_URL=https://dlcdn.apache.org/maven/maven-3/${maven}/binaries/apache-maven-${maven}-bin.tar.gz
      curl -fsSL -o /tmp/apache-maven-${maven}-bin.tar.gz ${BASE_URL} && \
      \
      # echo "Checking download hash" && \
      # echo "${SHA}  /tmp/apache-maven-${maven}-bin.tar.gz" | sha512sum -c - && \
      \
      echo "Unziping maven" && \
      tar -xzf /tmp/apache-maven.tar.gz && \
      rm -rf /opt/apache-maven-${maven} && \
      mv apache-maven-${maven} /opt/ && \
      echo "M2_HOME='/opt/apache-maven-${maven}'" >> ~/.profile && \
      echo 'PATH="$M2_HOME/bin:$PATH"' >> ~/.profile && \
      echo "export PATH" >> ~/.profile && \
      source  ~/.profile && \
      \
      echo "Cleaning and setting links" && \
      rm -f /tmp/apache-maven-${maven}-bin.tar.gz 
      
    #   echo "###########################################################################" && \
    #   echo `mvn -version` && \
    #   echo "###########################################################################"
      
    fi
}
###############################################################################################
# docker latest

function get_docker_version {
    docker=$(curl -s https://github.com/moby/moby/tags)
    docker=$(echo $docker\" |grep -oP '(?<=tag\/v)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    # echo "Latest docker version is $docker"

    # docker Installed version
    installeddocker=$(docker --version 2> /dev/null | grep -oP '(?<=version )\d+\.\d+\.\d+(?=,)')
    # echo "current installed docker version is $installeddocker"

    if [ "${docker}" == "${installeddocker}" ]; then
        echo "${CYAN}You have latest version of docker $docker${NC}"
    else
      echo "${PINK}You need to updte to latest docker version $docker, your current version is $installeddocker${NC}"
      # Build from source code
      curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

    #   echo "###########################################################################" 
    #   echo `docker --version`
    #   echo "###########################################################################"
      
    fi
}
###############################################################################################
# openjdk 11 latest

function get_openjdk_version {

    openjdk=$(curl -s https://github.com/openjdk/jdk11u/tags)
    openjdk=$(echo $openjdk\" |grep -oP '(?<=tag\/jdk-)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    openjdk=$(urldecode $openjdk)
    # echo "Latest openjdk version is $openjdk"

    # openjdk Installed version
    installedopenjdk=$(java --version 2> /dev/null | grep -oP "(?<=openjdk )\d+\.\d+\.\d+")
    # echo "current installed openjdk version is $installedopenjdk"

    if [ "${openjdk}" == "${installedopenjdk}" ]; then
        echo "${CYAN}You have latest version of openjdk $openjdk${NC}"
    else
      echo "${PINK}You need to updte to latest openjdk version $openjdk, your current version is $installedopenjdk${NC}"
      # Build from source code
      
      # echo "###########################################################################" 
      # echo `java --version`
      # echo "###########################################################################"
      
    fi
}
###############################################################################################
# graalvm

function get_graalvm_version {

    graalvm=$(curl -s https://github.com/graalvm/graalvm-ce-builds/tags)
    graalvm=$(echo $graalvm\" |grep -oP '(?<=tag\/vm-)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    graalvm=$(urldecode $graalvm)
    # echo "Latest graalvm version is $graalvm"

    # graalvm Installed version
    installedgraalvm=$(java --version 2> /dev/null | grep -oP "(?<=GraalVM CE )\d+\.\d+\.\d+" |head -1)
    # echo "current installed graalvm version is $installedgraalvm"

    if [ "${graalvm}" == "${installedgraalvm}" ]; then
        echo "${CYAN}You have latest version of graalvm $graalvm${NC}"
    else
      echo "${PINK}You need to updte to latest graalvm version $graalvm, your current version is $installedgraalvm${NC}"
      # Build from source code
      BASE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-$graalvm/graalvm-ce-java11-linux-amd64-$graalvm.tar.gz
      curl -fsSL -o /tmp/graalvm-ce-java11-linux-amd64-$graalvm.tar.gz ${BASE_URL} && \
      \
      echo "Unziping graalvm" && \
      tar -xzf /tmp/graalvm-ce-java11-linux-amd64-$graalvm.tar.gz && \

      rm -rf /usr/lib/jvm/graalvm-ce-java11-$graalvm && \
      mv graalvm-ce-java11-$graalvm/ /usr/lib/jvm/ && \
      cd /usr/lib/jvm && \
      ln -s graalvm-ce-java11-$graalvm graalvm && \
      update-alternatives --install /usr/bin/java java /usr/lib/jvm/graalvm/bin/java 2 && \
      update-alternatives --config java && \
      2 && \
      cd ~
      echo "export GRAALVM_HOME=/usr/lib/jvm/graalvm-ce-java11-${graalvm}" >> ~/.bashrc && \
      source ~/.bashrc && \
      ll $GRAALVM_HOME && \
      $GRAALVM_HOME/bin/gu install native-image && \
      cd $GRAALVM_HOME/bin && \
      ./native-image --version && \
      echo "export PATH=$PATH:/usr/lib/jvm/graalvm-ce-java11-${graalvm}/lib/installer/bin" >> ~/.bashrc && \
      echo "export PATH=$PATH:/usr/lib/jvm/graalvm-ce-java11-${graalvm}/lib/svm/bin" >> ~/.bashrc && \
      echo "export PATH=$PATH:/usr/lib/jvm/graalvm-ce-java11-${graalvm}/lib/installer/bin" >> ~/.profile && \
      echo "export PATH=$PATH:/usr/lib/jvm/graalvm-ce-java11-${graalvm}/lib/svm/bin" >> ~/.profile && \
      source ~/.bashrc && \
      source ~/.profile && \
      gu install native-image && \
      gu --version && \
      \
      echo "Cleaning and setting links" && \
      rm -f /tmp/graalvm-ce-java11-linux-amd64-$graalvm.tar.gz && \
      
      echo "###########################################################################" 
      echo `java --version`
      echo "###########################################################################"
      
    fi
}
###############################################################################################
# krew

function get_krew_version {

    krew=$(curl -s https://github.com/kubernetes-sigs/krew/tags)
    krew=$(echo $krew\" |grep -oP '(?<=tag\/v)[0-9][^"<]*'|grep -v \-|sort -Vr|head -1)
    krew=$(urldecode $krew)
    # echo "Latest krew version is $krew"

    # krew Installed version
    installedkrew=$(kubectl krew version 2> /dev/null | grep -oP 'GitTag\s+v\K.+')
    # echo "current installed krew version is $installedkrew"

    if [ "${krew}" == "${installedkrew}" ]; then
        echo "${CYAN}You have latest version of krew $krew${NC}"
    else
      echo "${PINK}You need to updte to latest krew version $krew, your current version is $installedkrew${NC}"
      # Build from source code
     (
        set -x; cd "$(mktemp -d)" &&
        OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
        ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
        KREW="krew-${OS}_${ARCH}" &&
        curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
        tar zxvf "${KREW}.tar.gz" &&
        ./"${KREW}" install krew &&
        echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc &&
        echo 'export PATH="${PATH}:${HOME}/.krew/bin"' >> .bashrc &&
        source ~/.bashrc
    )

    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> ~/.bashrc 
    echo 'export PATH="${PATH}:${HOME}/.krew/bin"' >> .bashrc
    source ~/.bashrc

    kubectl krew update
    kubectl krew version
    kubectl krew install stern
      
    fi
}
###############################################################################################
# Call the function

function call_em_all {
  hasCurl &
  get_helm_version &
  get_doctl_version &
  get_civo_version &
  get_kubectl_version &
  get_terraform_version &
  get_awscli_version &
  get_golang_version &
  get_maven_version &
  get_docker_version &
  get_openjdk_version &
  get_graalvm_version &
  get_krew_version &
}

{
call_em_all 

}

wait
