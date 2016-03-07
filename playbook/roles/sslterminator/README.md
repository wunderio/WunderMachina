# SSLTerminator role

Variables you can define:
papertrail_enabled: False
sslterminator_papertrail_follow:
  - /var/log/nginx/ssl-*error.log

sslterminators:
  - server_name: www.test.com
    server_forwards: test.com
    ssl_certificate: /etc/nginx/ssl/wk.dev.pem
    ssl_certificate_key: /etc/nginx/ssl/wk.dev.key
    use_dhparam: True
    backends:
      - 127.0.0.1:8081

httpforwards:
  - server_name: www.test.com
    forwarded_domains: 'test.com www.test.com'

basicauth_enabled: False
basicauth_username: wunder
basicauth_password: wunder123
basicauth_ip:
  - address: 127.0.0.1
  - address: 192.168.0.1

distro: "centos7"

extra_proxy_locations:
- location: "^~ /somepath"
  definition: |
              # Pass the request on to something.
              proxy_pass http://www.someaddress.com;

              # Pass a bunch of headers to the downstream server
              # so they'll know what's going on.
              proxy_set_header           Host             $host;
              proxy_set_header           X-Real-IP        $remote_addr;
              proxy_set_header           X-Forwarded-For  $proxy_add_x_forwarded_for;

              # Most web apps can be configured to read this header and
              # understand that the current session is actually HTTPS.
              proxy_set_header        X-Forwarded-Proto $scheme;
              add_header              Front-End-Https   on;

httpextraforwards:
- forward_from_domain: "www.example.com"
  port: "80"
  forwards:
    - forward_from_path: "/"
      forward_to: https://www.example.net
      type: permanent
- forward_from_domain: "www.example.com"
  port: "443 ssl http2"
  ssl_certificate: /etc/nginx/ssl/wk.dev.pem
  ssl_certificate_key: /etc/nginx/ssl/wk.dev.key
  use_dhparam: True
  forwards:
    - forward_from_path: "/test"
      forward_to: https://www.example.net/test
      type: permanent