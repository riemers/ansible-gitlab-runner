# Creating local ansible user
$secpwd = ConvertTo-SecureString "Ans1ble_User!" -AsPlainText -Force
New-LocalUser "ansible" -Password $secpwd -FullName "ansible" -Description "ansible user"
Add-LocalGroupMember -Group "Administrators" -Member "ansible"

# Install Ubuntu 1804 on WSL
& choco install -y --ignore-checksums wsl-ubuntu-1804

# Install Ansbile
& C:/Windows/System32/bash.exe -c "export DEBIAN_FRONTEND=noninteractive && apt update && apt install -y python3 python3-pip"
& wsl pip3 install ansible pywinrm

# Prepare system that it can be accessed by ansible
$url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"

(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file