FROM docker:latest
RUN apk update && apk add openssl && apk add curl
RUN wget -O - https://get.acme.sh | sh
RUN ln -s /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
VOLUME '/root/.acme.sh'
WORKDIR '/root/.acme.sh'
CMD sh -c "crond -f"
