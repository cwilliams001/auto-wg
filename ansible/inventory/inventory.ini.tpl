[wireguard_servers]
${wireguard_ip} ansible_user=root ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

[all:vars]
auth_key=${auth_key}