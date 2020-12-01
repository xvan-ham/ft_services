# Based on https://wiki.alpinelinux.org/wiki/Nginx

FROM alpine 

USER root

# Update
RUN apk update
RUN apk upgrade

# Install dependencies
RUN apk add nginx
RUN apk add openssh
RUN apk add openssl
RUN apk add openrc

# Copy necessary files
COPY srcs/nginx.conf /etc/nginx/nginx.conf
COPY srcs/index.html /var/www/localhost/ft_services/index.html

# Generate private SSL key and certificate
RUN yes "" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/certs/localhost.key -out /etc/ssl/certs/localhost.crt
#RUN yes "" | openssl req -new -x509 -days 365 -sha256 -nodes -out /etc/ssl/certs/localhost.crt -keyout /etc/ssl/certs/localhost.key -subj "/C=ES/ST=Madrid/L=Madrid/O=42 Madrid/OU=xvan-ham/CN=ft_server"
#RUN echo 'SSH of ft_services by xvan-ham' > /etc/motd

# ssh
RUN adduser -D "__SSH_USERNAME__"
RUN echo "__SSH_USERNAME__:__SSH_PASSWORD__" | chpasswd

# create directory to save nginx master process PID
RUN mkdir -p /run/nginx

# Add services to rc list 
RUN openrc
RUN touch /run/openrc/softlevel
RUN rc-update add sshd

EXPOSE 22 80 443

# On entry: OpenSSH server process (which listens to incomming connections using the SSH protocol); and nginx process with daemon off.
ENTRYPOINT /etc/init.d/sshd start; nginx -g "daemon off;"
