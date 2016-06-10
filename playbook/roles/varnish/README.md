# Varnish role

Variables you can define:
varnish:
	port: 8081
	memory: 1G
	acl_internal:
	  - ip: 127.0.0.1
	acl_upstream_proxy:
	  - ip: 127.0.0.1
	enforce_ssl: 720
	directors:
	  # One app
	  - name: test_com_director
	    host: test.com
	    backends:
	      - name: test1_web
	        address: 127.0.0.1
	        port: 8080
	        ignore: False