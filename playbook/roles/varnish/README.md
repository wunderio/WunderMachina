# Varnish role

Variables you can define:
varnish:
	port: 8081
	memory: 1G
	acl_internal:
	  - ip: 127.0.0.1
	acl_upstream_proxy:
	  - ip: 127.0.0.1
	directors:
	  # One app
	  - name: test_com_director
	    host: test.com
	    backends:
	      - name: test1_web
	        address: 127.0.0.1
	        port: 8080
	        ignore: False
  custom_error_template: |
    // Custom error
    set resp.http.Cache-Control = "no-cache, max-age: 0, must-revalidate";
    set resp.http.x-sitename = "insert_sitename";
    set resp.http.x-sitetitle = "insert_site_title";
    set resp.http.x-ua = "insert_GA_code";
    synthetic( {"
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml">
      <head><title>Error loading the page</title></head><body>NEVER!</body></html>
    "} );
