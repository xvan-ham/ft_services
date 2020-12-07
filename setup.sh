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

#  Colors
green=$'\e[0;92;40m'
green_b=$'\e[0;30;102m'
green_d=$'\e[0;2;92;40m'
red=$'\e[0;92;31m'
blue=$'\e[0;34;40m'
cyan=$'\e[0;1;36;40m'
magenta=$'\e[0;1;95;40m'
reset=$'\e[0m'

# Global Variables
IP_VAR=$(minikube ip)
KEYW=("--clean" "--re" "--k_del" "--d_del" "--k_apply" "--d_nginx" "--d_grafana" "--d_influxdb" "--d_all")
RE=0

# Functions

function clean() {
	
	echo "${green}Cleaning up.${reset}"
	k_del
	d_del
	echo "${green}Cleaned up.${reset}"
	exit 0
}

function re() {
	RE=1
	echo "${green}Deleting dangling (untagged) docker images.${reset}"
	docker image rm $(docker images -q --filter "dangling=true")
}

function k_del() {
	echo "${green}Deleting minikube pods, deployments and services.${reset}"
	kubectl delete pod --all
	kubectl delete deployment --all
	kubectl delete service --all
	kubectl delete ingress --all
	wait
}

function k_apply() {
	echo "${green}Applying all yml files${reset}"
	kubectl apply -f srcs/grafana.yml
	kubectl apply -f srcs/influxdb.yml
	sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx.yml
	kubectl apply -f srcs/nginx.yml
	sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx.yml
	kubectl apply -f srcs/ingress.yml
}

function d_del() {
	echo "${green}Deleting docker images: nginx-services, grafana and influxdb${reset}"
	docker image rm -f nginx-services
	docker image rm -f grafana
	docker image rm -f influxdb
}

function d_nginx() {
	if [ $(containsElement "--d_del" $@) -eq 0 ]
	then
		echo "${green}Deleting nginx docker image${reset}"
		docker image rm -f nginx-services
	fi
	sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx/srcs/index.html
	echo "${green}BUILDING NGINX${reset}"
	docker build -t nginx-services srcs/nginx/.
	wait
	sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx/srcs/index.html
}

function d_grafana() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo "${green}Deleting grafana docker image${reset}"
		docker image rm -f grafana
	fi
	echo "${green}BUILDING GRAFANA${reset}"
	docker build -t grafana srcs/grafana/.
	wait
}

function d_influxdb() {
	if [ $(containsElement "--d_del" $@) -eq 0 ]
	then
		echo "${green}Deleting influxdb docker image${reset}"
		docker image rm -f influxdb
	fi
	echo "${green}BUILDING INFLUXDB${reset}"
	docker build -t influxdb srcs/influxdb/.
	wait
}

function containsElement() {
	local t=0 e match="$1"
	shift
	for e
	do [[ "$e" == "$match" ]] && echo 1 && t=1
	done
	if [ $t -eq 0 ]
	then
		echo 0
	fi
}

function setup() {
	local e
	if [ $# -eq 0 ]
	then
		echo "No args, default behaviour"
		k_del
		d_nginx
		d_influxdb
		d_grafana
		k_apply
	else
		for e in "${KEYW[@]}"
		do
			#$echo "checking keyword: $e"
			if [ $(containsElement $e $@) -eq 1 ]
			then
				#echo "found: $e"
				$(echo $e | cut -c 3-) # remove the "--" from the keyword and execute function with corresponding name
			#else
				#echo "nothing so far..."
			fi
		done
	fi
}

setup "$@"
