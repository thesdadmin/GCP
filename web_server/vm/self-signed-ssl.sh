openssl req -newkey rsa:4096 -nodes -keyout /etc/pki/tls/private/labtest.key -x509 -days 3650 -out /etc/pki/tls/certs/labtest.crt \
-subj "/C=CA/ST=STATE/L=CITY/O=ORG NAME/OU=Department/CN=test.thesdadmin.com/emailAddress=name@domain"