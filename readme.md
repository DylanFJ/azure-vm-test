## Configure an Ubuntu Azure VM with Ansible

### Resources
https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html  
https://docs.microsoft.com/fr-fr/azure/virtual-machines/linux/quick-create-cli

### Get started
First, install ansible on your local machine.

#### Azure CLI
- Create a resources group
```
az group create --name myResourceGroup --location eastus
```
- Create a virtual machine
```
az vm create \
--resource-group myResourceGroup \
--name myVM \
--image UbuntuLTS \
--admin-username azureuser \
--generate-ssh-keys
```
You should have something like this  
Output:
```
{
  "fqdns": "",
  "id": "/subscriptions/<guid>/resourceGroups/myResourceGroup/providers/Microsoft.Compute/virtualMachines/myVM",
  "location": "eastus",
  "macAddress": "00-0D-3A-23-9A-49",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "40.68.254.142",
  "resourceGroup": "myResourceGroup"
}
```
- Open port 80 for web traffic
```
az vm open-port --port 80 --resource-group myResourceGroup --name myVM
```

- Connect to your azure vm
For example, we have ```40.68.254.142``
```
ssh azureuser@40.68.254.142
```

- Update and install some tools
```
sudo -i
apt update
apt upgrade
# or full-upgrade if you want major update
apt install python3 acl python3-apt
reboot
```
- Reconnect to your vm and get root access and then
```
useradd ansible
passwd ansible
mkdir /home/ansible
mkdir /home/ansuble/.ssh
chown -R ansible:ansible /home/ansible/
chmod -R 700 /home/ansible/
```
###### (Optional) Allow root login with ssh  
- You must be connected as root before doing below steps  
- Add a root password if not present
```
passwd
```  
- Open "/etc/ssh/sshd_config" with text editor
```
nano /etc/ssh/sshd_config
```  
 - Find these options
```
#PermitRootLogin no
#PasswordAuthentication no  
```
- If they are commented or have "no" for value, change it by
```
PermitRootLogin yes
PasswordAuthentication yes
```
You can let "PasswordAuthentication" to "no" if you want just use ssh keys.  
- Save and close  
- Restart the sshd service
```
systemctl restart sshd
# or
service sshd restart
```

##### Local terminal
- To make life easier, you can add your azure vm ip in your hosts
```
nano /etc/hosts
```
Example, the vm ip is ```40.68.254.142```
```
127.0.0.1  localhost
40.68.254.142    azure-vm
```
- Save and close
- Now, from your system terminal  
```
ssh ansible@azure-vm
```
or
```
ssh ansible@40.68.254.142
```
##### SSH with no password
- Generate ssh key on your local machine if you don't have
```
ssh-keygen -t rsa -b 4096 -C "ansible@azure-vm"
```
When prompted, change the file name by "azure-vm_rsa"
- Add it to your keychain
```
ssh-add /your_ssh_key_rsa
```
On macOS, add option "-K"
```
ssh-add -K /your_ssh_key_rsa
```
- Copy the ssh public key to your vm
```
scp /your_ssh_key_rsa.pub ansible@azure-vm:/tmp/
# or 
scp /your_ssh_key_rsa.pub ansible@40.68.254.142:/tmp/
```  
- Connect to the remote machine
```
ssh ansible@azure-vm
# or 
ssh ansible@40.68.254.142
```  
- Get root access and Move the public key to ansible ssh home dir
```
su -
mv /tmp/your_ssh_key_rsa.pub /home/ansible/.ssh/authorized_keys
exit
```
- Now , connect to your vm without password

#### Ansible
The user ansible must be in group sudo  
- Connect to your vm and then
```
sudo usermod -aG sudo ansible
```
The change will take effect the next time the user logs in.  
This works because ```/etc/sudoers``` is pre-configured to grant permissions to all members of this group.
You should not have to make any changes to this: Allow members of group sudo to execute any command
```
%sudo   ALL=(ALL:ALL) ALL
```

You can now run scripts from your local machine

#### Run scripts
On your local machine
- Create an inventory file "dev.ini" in ansible/inventory and put in:
```
# Example
[vm]
40.68.254.142 ansible_python_interpreter="/usr/bin/python3"
```
or 
```
# Example
[vm]
azure-vm ansible_python_interpreter="/usr/bin/python3"
```
Now
```
cd ./ansible
./dev1-install.sh
./dev2-configure.sh
./enable-site.sh
```
You're done.
