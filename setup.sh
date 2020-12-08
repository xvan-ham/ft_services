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
	echo -e "${red}Deleting ${cyan}dangling ${green}(untagged) docker images.${reset}"
	docker image rm $(docker images -q --filter "dangling=true")
}

function k_del() {
	echo -e "${red}Deleting ${cyan}minikube pods${green}, ${cyan}deployments${green} and ${cyan}services${green}.${reset}"
	kubectl delete pod --all
	kubectl delete deployment --all
	kubectl delete service --all
	kubectl delete ingress --all
	wait
}

function k_apply() {
	echo -e "${green_b}Applying${green} all ${cyan}yml ${green}files${reset}"
	kubectl apply -f srcs/grafana.yml
	kubectl apply -f srcs/influxdb.yml
	sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx.yml
	kubectl apply -f srcs/nginx.yml
	sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx.yml
	kubectl apply -f srcs/ingress.yml
}

function d_del() {
	echo -e "${red}Deleting${cyan} docker images${green}: nginx-services, grafana and influxdb${reset}"
	docker image rm -f nginx-services
	docker image rm -f grafana
	docker image rm -f influxdb
}

function d_nginx() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo -e "${red}Deleting${cyan} nginx docker image${reset}"
		docker image rm -f nginx-services
	fi
	sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx/srcs/index.html
	echo -e "${green_b}BUILDING${cyan} nginx${reset}"
	docker build -t nginx-services srcs/nginx/.
		echo -e "${red}Docker return val pre-wait: $? ${reset}"
	wait
		echo -e "${red}Docker return val: $? ${reset}"
	sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx/srcs/index.html
}

function d_grafana() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo -e "${red}Deleting${cyan} grafana docker image${reset}"
		docker image rm -f grafana
	fi
	echo "${green_b}BUILDING${cyan} grafana${reset}"
	docker build -t grafana srcs/grafana/.
		echo -e "${red}Docker return val: $? ${reset}"
	wait
}

function d_influxdb() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo "${red}Deleting${cyan} influxdb docker image${reset}"
		docker image rm -f influxdb
	fi
	echo "${green_b}BUILDING${cyan} influxdb${reset}"
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

function error() {
	echo -e "${green}An ${red}error${green} was encountered when building the docker image for: ${cyan}$1${green}."
	docker image ls > /dev/null
	local ret1=$?
	local ret2
	if [ $(docker image ls | grep "k8s.gcr.io" -ic) -gt 0 ]
	then
		ret2=1
	else
		ret2=0
	fi
	echo -e "${red}ret1 is: $ret1${reset}"
	echo -e "${red}ret2 is: $ret2${reset}"
	
	if [ $ret1 -eq 1 ]
	then
		echo -e "${green}A simple check reveals that ${cyan}Docker${green} is not running, or that the Docker daemon is otherwise not responding.${reset}"
		echo -e "Check whether this is the case, initiate Docker and re-run this setup."
 # CONTINUE HERE ************************
	while [ "$input" != "n" ] && [ "$input" != "y" ] && [ "$input" != "N" ] && [ "$input" != "Y" ]
		do
			if [ $ret -eq 1 ]
			then
				read -n1 -p "${green}A simple check reveals that ${cyan}Docker${green} is not running, or that the Docker daemon is otherwise not responding.
			read -n1 -p "${green}An ${red}error${green} was encountered when building the docker image for: ${cyan}$1${green}."
		   
			Is Do you want to setup${cyan} $1${green}?${green_d}$3 ${magenta}(y/n)${blue} " input
			echo "${reset}"
		done
	if [ "$input" = "y" ] || [ "$input" = "Y" ]
		then
		echo "${green}Executing: ${cyan}$2${reset}"
		bash $2
		echo "${green_b}Done${reset}"
	fi
	if [ "$input" = "n" ] || [ "$input" = "N" ]
		then
		echo "Skipping ${cyan}$1${reset}"
	fi
	input=""
}

function setup() {
	local e
	if [ $# -eq 0 ]
	then
		echo "${green}No args, ${blue}default${green} behaviour${reset}"
		k_del
		d_nginx
		d_influxdb
		d_grafana
		k_apply
	else
		for e in "${KEYW[@]}"
		do
			if [ $(containsElement $e $@) -eq 1 ]
			then
				$(echo $e | cut -c 3-) # remove the "--" from the keyword and execute function with corresponding name
			#else
			fi
		done
	fi
}

setup "$@"
