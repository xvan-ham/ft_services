#!/bin/bash

# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    setup.sh                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: xvan-ham <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/12/02 17:24:26 by xvan-ham          #+#    #+#              #
#    Updated: 2020/12/02 17:24:26 by xvan-ham         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

bash del
wait
IP_VAR=$(minikube ip)
echo $IP_VAR

sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx/srcs/index.html
docker build -t nginx-services srcs/nginx/.
sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx/srcs/index.html

sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx.yml
kubectl apply -f srcs/nginx.yml
sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx.yml

kubectl apply -f srcs/ingress.yml

