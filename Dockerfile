FROM klakegg/hugo AS hugo


COPY . /target
WORKDIR /target

RUN hugo

FROM nginx:1.15-alpine 

WORKDIR /usr/share/nginx/html/

RUN rm -fr * .??*

RUN sed -i '9i\        include /etc/nginx/conf.d/expires.inc;\n' /etc/nginx/conf.d/default.conf

COPY _docker/expires.inc /etc/nginx/conf.d/expires.inc
RUN chmod 0644 /etc/nginx/conf.d/expires.inc

COPY --from=hugo /target/public /usr/share/nginx/html



