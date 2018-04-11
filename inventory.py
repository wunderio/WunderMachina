#!/usr/bin/env python
# -*- coding: utf-8 -*-

### A simple helper script for using ansible and vagrant together.
# Usually you don't need an inventory file for vagrant, since one is created
# automatically. But if you want to give your vagrant host a special group
# or assign some variables, this script becomes handy.
# 

import json, subprocess

def get_vagrant_sshconfig():
    p = subprocess.Popen("vagrant ssh-config", stdout=subprocess.PIPE, shell=True)
    raw = p.communicate()[0]
    sshconfig = {}
    lines = raw.split("\n")
    for line in lines:
        kv = line.strip().split(" ", 1)
        if len(kv) == 2:
            sshconfig[kv[0]] = kv[1]
    return sshconfig

sshconfig = get_vagrant_sshconfig()
host = {
    "dev": {
        "hosts": [ "default" ],
        "vars": {
            "ansible_ssh_host": sshconfig.get('HostName', '127.0.0.1'),
            "ansible_ssh_port": sshconfig.get('Port', '2222'),
            "ansible_ssh_user": sshconfig.get('User', 'vagrant'),
            "ansible_ssh_private_key_file": sshconfig.get('IdentityFile', '.vagrant/machines/default/virtualbox/private_key')
        }
    }
}
print json.dumps(host);
