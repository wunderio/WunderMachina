# Upcloud firewall role
This role defines [upcloud](https://www.upcloud.com) firewalls using [upcloud-ansible](https://github.com/UpCloudLtd/upcloud-ansible) role.

By default the firewalls are closed.

This role allows connections from deployment services.

## Variables
You can define these variables:
`vpn_ip_list` - List of machines allowed to connect through the firewalls to ssh (22)
`deployment_server_ip_list` - List of machines allowed to connect to ssh (22)
