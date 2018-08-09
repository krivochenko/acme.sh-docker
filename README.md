Run container by docker-compose with [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy "jwilder/nginx-proxy"):

```
version: '3'
services:
  nginx:
    image: nginx
    container_name: nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./conf.d:/etc/nginx/conf.d
      - ./certs:/etc/nginx/certs

  nginx-gen:
    image: jwilder/docker-gen
    command: -notify-sighup nginx -watch /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    container_name: nginx-gen
    restart: always
    volumes:
      - ./conf.d:/etc/nginx/conf.d
      - ./certs:/etc/nginx/certs
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro
  
  acme:
    image: krivochenko/acme.sh-docker
    container_name: acme.sh
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./certs:/certs
    environment:
      PDD_Token: <YOUR_TOKEN>    
```

Notice, [nginx.tmpl](https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl) have to be stored in the same directory as docker-compose.yml.

Instead of PDD_Token you can define credentials for your DNS-hosting provider.

After run with stack you can issue certs by follow command:
```
docker exec -it acme.sh acme.sh --issue -d example.com -d *.example.com --dns dns_yandex --accountemail "your@example.com"
```
Don't forget to define your domain for which you issue certs and your e-mail for notification about certs expiration.

After issuing certs you have to install it:
```
docker exec -it acme.sh acme.sh --install-cert -d example.com --cert-file /certs/example.com.crt --key-file /certs/example.com.key --reloadcmd "docker exec nginx-gen kill -SIGHUP 1"
```

This command copy certs in corresponding place and force docker-gen container to regenerate config and restart proxy.

Installed certs will be renewed automatically. 