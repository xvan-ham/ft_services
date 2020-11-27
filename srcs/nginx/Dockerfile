# Based on https://wiki.alpinelinux.org/wiki/Nginx

FROM alpine

# Update
RUN apk update
RUN apk upgrade

# Install dependencies
RUN apk add nginx
RUN apk add openssh
RUN apk add openssl

# Creating new user and group 'www' for nginx (default used by nginx)
 RUN adduser -D -g 'www' www

# create dir for website content (will be specified in config file).
RUN mkdir -p /www
# nginx config will not work without following (related to pid):
RUN mkdir -p /run/nginx
# create file to give nginx read permissions
RUN mkdir -p /var/lib/nginx

# give read permissions to user and group "www", which is used by nginx (specified in config file).
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www

# copy nginx config file to container
COPY nginx.conf /etc/nginx/nginx.conf

# copy index page for a customized html index page
COPY index.html /www/index.html

# SSH user and SSL key creation
RUN adduser -D user
RUN echo "user:password"|chpasswd
RUN ssh-keygen -A
RUN yes "" | openssl req -new -x509 -days 365 -sha256 -nodes -out /etc/ssl/certs/xvan-ham.crt -keyout /etc/ssl/certs/xvan-ham.key -subj "/C=ES/ST=Madrid/L=Madrid/O=42 Madrid/OU=xvan-ham/CN=ft_server"
RUN echo 'SSH of ft_services by xvan-ham' > /etc/motd

# Start script to init nginx
COPY start.sh ./start.sh
RUN chmod +x /start.sh
CMD sh ./start.sh

# expose ports
EXPOSE 80
EXPOSE 443
EXPOSE 22
