#!/bin/bash
#Quick repo with some help from chatgpt4 but filtered to only do repos extras,os,updates which we use in most setups. Only for use on centos7 servers.

check_os_centos7() {
 # Check if /etc/os-release exists to detect OS
    if [[ -f /etc/os-release ]]; then
        os_name=$(grep '^ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
        os_version=$(grep '^VERSION_ID=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')

        # Check if the OS is CentOS and the version is 7
        if [[ "$os_name" == "centos" && "$os_version" == "7" ]]; then
            echo "Running on CentOS 7"
        else
            echo "This script requires CentOS 7. Exiting."
            exit 1
        fi
    else
        echo "Unable to detect OS. Exiting."
        exit 1
    fi    

}

generate_repo() {
# URL of the CentOS 7 vault
#base_url="https://vault.centos.org/centos/7/"
base_url="https://vault.centos.org/centos/\$releasever"

# Directory to store generated .repo files
repo_dir="centos7_repos"

# Create the directory if it doesn't exist
mkdir -p "${repo_dir}"
mkdir /etc/yum.repos.d/backup 
mv /etc/yum.repos.d/CentOS-* /etc/yum.repos.d/backup/

# Fetch repository list
repo_list=$(curl -s "${base_url}")

# Extract repository URLs from the HTML
repos=$(echo "${repo_list}" | grep -oP '(?<=href=")[^"]+(?=/?"\>)' | grep '^atomic\|^cloud\|^config\|^cr\|^extras\|^fasttrack\|^highavailability\|^iso\|^os\|^paas\|^rt\|^sclo\|^storage\|^updates\|^virt')

# List of repositories to generate .repo files for
# Others excluded check https://vault.centos.org/centos/7/
repos=(
    "extras"
    "os"
    "updates"
)

for repo_name in "${repos[@]}"; do
    cat << EOF > "${repo_dir}/${repo_name}.repo"
[${repo_name}]
name=CentOS-\$releasever - ${repo_name}
baseurl=${base_url}/${repo_name}/\$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
enabled=1
EOF
 echo "Created /etc/yum.repos.d/${repo_name}.repo"
done
mv ${repo_dir}/* /etc/yum.repos.d/

}

check_os_centos7
generate_repo
