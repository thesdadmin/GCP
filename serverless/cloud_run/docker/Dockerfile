FROM docker.io/nginxinc/nginx-unprivileged:latest

USER root

RUN rm /usr/share/nginx/html/index.html

COPY index.html /usr/share/nginx/html/index.html

USER nginx