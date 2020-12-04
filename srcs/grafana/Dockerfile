# Persistent volume guide: https://blog.gojekengineering.com/diy-set-up-telegraf-influxdb-grafana-on-kubernetes-d55e32f8ce48

FROM alpine 

USER root

# Update
RUN apk update
RUN apk upgrade

# Install InfluxDB, Grafana, Telegraf and openrc
RUN apk add grafana telegraf --repository http://dl-3.alpinelinux.org/alpine/edge/testing/
RUN apk add openrc

# Add services to rc list 
#RUN openrc
#RUN touch /run/openrc/softlevel
#RUN rc-update add telegraf

RUN mkdir -p /etc/telegraf
RUN /usr/bin/telegraf -sample-config -input-filter cpu:mem:disk -output-filter influxdb > /etc/telegraf/telegraf.conf

EXPOSE 3000

# On entry: OpenSSH server process (which listens to incomming connections using the SSH protocol); and nginx process with daemon off.
ENTRYPOINT /etc/init.d/telegraf start; /usr/sbin/grafana-server --config /etc/grafana.ini --homepath /usr/share/grafana
