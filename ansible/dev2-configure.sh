# -k, --ask-pass        ask for connection password
# -K, --ask-become-pass ask for privilege escalation password
ansible-playbook -i inventory/dev.ini ./ubuntu-lts/playbook/dev/configure.yaml -u ansible -k -K