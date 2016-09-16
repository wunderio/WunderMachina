Ansible Role: Mongodb
=========

Installs [Mongodb](https://www.mongodb.com) on RHEL/CentOS or Debian/Ubuntu.

[![Build Status](https://travis-ci.org/d4rkstar/ansible-role-mongodb.svg?branch=master)](https://travis-ci.org/d4rkstar/ansible-role-mongodb)

## Requirements

None

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

	mongo_storage_dbpath: /var/lib/mongodb
	mongo_storage_journal_enabled: "true"
	
	# System log
	mongo_systemlog_destination: "file"
	mongo_systemlog_append: "true"
	mongo_systemlog_path: /var/log/mongodb/mongod.log
	
	# Network
	mongo_network_port: 27017
	mongo_network_interfaces:
  		- 127.0.0.1

## Dependencies

None.

## Example Playbook

    - hosts: all
      roles:
        - { role: d4rkstar.mongodb }

## License

GPLv3

## Author Information

This role was created in 2016 by [Bruno Salzano](http://brunosalzano.com/).
