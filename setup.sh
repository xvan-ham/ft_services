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
IP_VAR=0
KEYW=("--v" "--verbose" "--clean" "--re" "--k_del" "--d_del" "--k_apply" "--d_nginx" "--d_grafana" "--d_influxdb" "--d_all")
RE=0
M_FAIL=0
D_FAIL=0
MD_FAIL=0
D_B_FAIL=0
ERRORS=0
VERBOSE=0
FIRST_TIME=0

# Functions

function verbose() {
	VERBOSE=1
}

function v() {
	verbose "$@"
}

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
	if [ $VERBOSE -eq 1 ]
	then
		docker image rm $(docker images -q --filter "dangling=true")
	else
		docker image rm $(docker images -q --filter "dangling=true") &> /dev/null
	fi
}

function k_del() {
	echo -e "${red}Deleting ${cyan}minikube pods${green}, ${cyan}deployments${green} and ${cyan}services${green}.${reset}"
	if [ $VERBOSE -eq 1 ]
	then
		kubectl delete pod --all
		kubectl delete deployment --all
		kubectl delete service --all
		kubectl delete ingress --all
		echo -e "${green}Minikube items have all been deleted.${reset}"
	else
		kubectl delete pod --all &> /dev/null
		wait
		echo -e "${green}Minikube ${cyan}pods${green} deleted.${reset}"
		kubectl delete deployment --all &> /dev/null
		wait
		echo -e "${green}Minikube ${cyan}deployments${green} deleted.${reset}"
		kubectl delete service --all &> /dev/null
		wait
		echo -e "${green}Minikube ${cyan}services${green} deleted.${reset}"
		kubectl delete ingress --all &> /dev/null
		wait
		echo -e "${green}Minikube ${cyan}ingresses${green} deleted.${reset}"
	fi
	kubectl delete -f srcs/metallb.yml ##FORMAT ################################
}

function k_apply() {
	if [ $VERBOSE -eq 1 ]
	then
		echo -e "\n${green_b}Applying${green} all ${cyan}yml ${green}files${reset}\n"
		kubectl apply -f srcs/grafana.yml
		kubectl apply -f srcs/influxdb.yml
		sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx.yml
		kubectl apply -f srcs/nginx.yml
		sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx.yml
		#kubectl apply -f srcs/ingress.yml
	else
		echo -e "${green_b}Applying${green} all ${cyan}yml ${green}files${reset}"
		kubectl apply -f srcs/grafana.yml &> /dev/null
		kubectl apply -f srcs/influxdb.yml &> /dev/null
		sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx.yml
		kubectl apply -f srcs/nginx.yml &> /dev/null
		sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx.yml
		#kubectl apply -f srcs/ingress.yml &> /dev/null
		echo -e "${green_b}Applied${green} all ${cyan}yml ${green}file configurations${reset}"
	fi
	kubectl apply -f srcs/metallb.yml ##FORMAT ################################
}

function d_del() {
	echo -e "${red}Deleting${cyan} docker images${green}: nginx-services, grafana and influxdb${reset}"
	if [ $VERBOSE -eq 1 ]
	then
		docker image rm -f nginx-services
		docker image rm -f grafana
		docker image rm -f influxdb
	else
		docker image rm -f nginx-services &> /dev/null
		docker image rm -f grafana &> /dev/null
		docker image rm -f influxdb &> /dev/null
	fi
}

function d_nginx() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo -e "${red}Deleting${cyan} nginx docker image${reset}"
		if [ $VERBOSE -eq 1 ]
		then
			docker image rm -f nginx-services
		else
			docker image rm -f nginx-services &> /dev/null
		fi
	fi
	sed -i "" "s/__IP_VAR__/$IP_VAR/g" ./srcs/nginx/srcs/index.html
		for e in "${KEYW[@]}"
		do
			if [ $(containsElement $e $@) -eq 1 ]
			then
				$(echo $e | cut -c 3-) # remove the "--" from the keyword and execute function with corresponding name
			#else
			fi
		done
	echo -e "${green_b}BUILDING${cyan} nginx${reset}"
	if [ $VERBOSE -eq 1 ]
	then
		docker build -t nginx-services srcs/nginx/.
	else
		docker build -t nginx-services srcs/nginx/. &> /dev/null
	fi
	D_B_FAIL=$?
	wait
	sed -i "" "s/$IP_VAR/__IP_VAR__/g" ./srcs/nginx/srcs/index.html
	if [ $D_B_FAIL -eq 1 ]
	then
		echo -e "\n${red}Docker build for ${cyan}nginx${red} failed${reset}\n"
		error nginx
	fi
}

function d_grafana() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo -e "${red}Deleting${cyan} grafana docker image${reset}"
		if [ $VERBOSE -eq 1 ]
		then
			docker image rm -f grafana
		else
			docker image rm -f grafana &> /dev/null
		fi
	fi
	echo -e "${green_b}BUILDING${cyan} grafana${reset}"
	if [ $VERBOSE -eq 1 ]
	then
		docker build -t grafana srcs/grafana/.
	else
		docker build -t grafana srcs/grafana/. &> /dev/null
	fi
	D_B_FAIL=$?
	wait
	if [ $D_B_FAIL -eq 1 ]
	then
		echo -e "\n${red}Docker build for ${cyan}Grafana${red} failed${reset}\n"
		error Grafana
	fi
}

function d_influxdb() {
	if [ $(containsElement "--d_del" $@) -eq 0 ] && [ $RE -eq 1 ]
	then
		echo "${red}Deleting${cyan} influxdb docker image${reset}"
		if [ $VERBOSE -eq 1 ]
		then
			docker image rm -f influxdb
		else
			docker image rm -f influxdb &> /dev/null
		fi
	fi
	echo -e "${green_b}BUILDING${cyan} influxdb${reset}"
	if [ $VERBOSE -eq 1 ]
	then
		docker build -t influxdb srcs/influxdb/.
	else
		docker build -t influxdb srcs/influxdb/. &> /dev/null
	fi
	D_B_FAIL=$?
	wait
	if [ $D_B_FAIL -eq 1 ]
	then
		echo -e "\n${red}Docker build for ${cyan}influxDB${red} failed${reset}\n"
		error influxDB
	fi
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

function checks() {
	echo -e "${green}Performing pre-run checks on necessary processes before running...${reset}"
	echo ""
	echo -ne "${cyan}Minikube${green}:...................."
	minikube ip &> /dev/null
	if [ $? -ne 0 ]
	then
		echo -e "${red}FAIL${reset}"
		M_FAIL=1
	else
		echo -e "${green}OK${reset}"
		M_FAIL=0
	fi
	echo -ne "${cyan}Docker${green}:......................"
	docker image ls &> /dev/null
	if [ $? -ne 0 ]
	then
		echo -e "${red}FAIL${reset}"
		D_FAIL=1
	else
		echo -e "${green}OK${reset}"
		D_FAIL=0
	fi
	echo -ne "${cyan}Minikube docker env. vars${green}:..." #29chars
	if [ $D_FAIL -eq 1 ]
	then
		echo -e "${red}FAIL${reset}"
		MD_FAIL=1
	elif [ $(docker image ls | grep "k8s.gcr.io" -ic) -gt 0 ]
	then
			echo -e "${green}OK${reset}"
			D_FAIL=0
	else
		echo -e "${red}FAIL${reset}"
		MD_FAIL=1
	fi
	echo ""
	if [ $D_FAIL -eq 0 ] && [ $M_FAIL -eq 0 ] && [ $MD_FAIL -eq 0 ]
	then
		echo -e "${green_b}No errors${green}. Continuing.\n${reset}"
		return 0
	else
		echo -e "${red}Errors found.\n${green}List of recommendations:${reset}"
	fi
	if [ $D_FAIL -ne 0 ]
	then
		echo -e "${green}- Initiate ${cyan}Docker${green}, for example by running the 42Toolbox init_docker scripts.${reset}"
	fi
	if [ $M_FAIL -ne 0 ]
	then
		echo -e "${green}- Initiate ${cyan}minikube${green}, for example by running ${blue}minikube start${green}.${reset}"
	fi
	if [ $MD_FAIL -ne 0 ]
	then
		echo -e "${green}- Evaluate ${cyan}minikube docker-env vars${green}, by running ${blue}eval \$(minikube docker-env)${green}.${reset}"
	fi
	echo ""
	echo -e "${green}It is recommended that you exit and fix the necessary items before continuing as some elements will not work correctly without them.${reset}"
	prompt_exit
}

function prompt_exit() {
	ERRORS=1
	while [ "$input" != "n" ] && [ "$input" != "y" ] && [ "$input" != "N" ] && [ "$input" != "Y" ]
		do
			echo ""
			read -n1 -p "${blue}Stop setup? ${green_d}(${magenta}no ${green_d}will continue with setup)${magenta} (y/n)${blue} " input
			echo -e "${reset}\n"
		done
	if [ "$input" = "y" ] || [ "$input" = "Y" ]
		then
			input=""
			echo -e "${green}Exiting setup.${reset}"
			exit 0
	fi
	if [ "$input" = "n" ] || [ "$input" = "N" ]
		then
			input=""
			echo -ne "${green}Continuing with setup (${magenta}WARNING: ${reset}"
			if [ $M_FAIL -eq 1 ]
			then
				echo -ne "${green_d}ft_services cannot run without ${cyan}minikube${reset} "
			fi
			if [ $D_FAIL -eq 1 ]
			then
				echo -ne "${green_d}Docker images will not be built!${reset} "
			fi
			if [ $MD_FAIL -eq 1 ]
			then
				echo -ne "${green_d}Docker images that are built will not be accessible to minikube!${reset} "
			fi
	fi
	echo -e "${green})."
	sleep 3
}

function error() {
	echo -e "${green}An ${red}error${green} was encountered when building the docker image for: ${cyan}$1${green}.${reset}"
	if [ $D_FAIL -eq 0 ] && [ $M_FAIL -eq 0 ] && [ $MD_FAIL -eq 0 ]
	then
		echo -e "${cyan}Docker${green} seems to be running. There may be a problem with the ${cyan}Dockerfile.${reset}"
	else
		echo -e "${green}There were ${cyan}pre-run errors${green}, these may be the source of the error.${reset}"
	fi
	prompt_exit
}

function first_time_check() {
	filename=./.settings
	test -f $filename || echo "FIRST_TIME=1" > $filename
	if [ $(grep "FIRST_TIME=1" -ic $filename) -gt 0 ]
	then
		FIRST_TIME=1
	fi
}

function metallb() {
	if [ "$(kubectl get configmap kube-proxy -n kube-system -o yaml | \
	sed -e "s/strictARP: false/strictARP: true/" | \
	kubectl diff -f - -n kube-system)" == "" ]
	then
		echo -e "    ${cyan}MetalLB:${green} No changes need to be made to configmap.${reset}"
	else
		echo -e "    ${cyan}MetalLB:${green} Changing configmap (setting strictARP to true).${reset}"
		kubectl get configmap kube-proxy -n kube-system -o yaml | \
		sed -e "s/strictARP: false/strictARP: true/" | \
		kubectl apply -f - -n kube-system
	fi
	if [ $VERBOSE -eq 1 ]
	then
		kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml
		kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml
	else
		kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/namespace.yaml &> /dev/null
		kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.5/manifests/metallb.yaml &> /dev/null
	fi
		echo -e "${reset}  "
	# On first install only
	if [ $FIRST_TIME -eq 1 ]
	then
		kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
	fi
}

function setup() {
	local e
	local action_f=0
	
	checks
	IP_VAR=$(minikube ip)
	if [ $M_FAIL -eq 0 ] && [ $D_FAIL -eq 0 ]
	then
		first_time_check
		metallb
	else
		echo -e "${magenta}WARNING: ${green}Did ${red}NOT${green} set up ${cyan}MetalLB${green}, minikube will most likely ${red}NOT${green} be accessible to localhost (through browser).${reset}"
	fi
	if [ $# -eq 0 ] || ( [ $# -eq 1 ] && ( [ $(containsElement "--v" $@) -eq 1 ] || [ $(containsElement "--verbose" $@) -eq 1 ] ) )
	then
		echo "${green}No args provided, ${blue}default${green} behaviour${reset}"
		if [ $# -eq 1 ]
		then
			verbose
		fi
		# Define default behavior:
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
				action_f=1
				$(echo $e | cut -c 3-) # remove the "--" from the keyword and execute function with corresponding name
			fi
		done
	fi
	echo ""
	if [ $ERRORS -eq 1 ]
	then
		echo -e "${green_b}Finished${red} with errors${green}.${reset}"
	else
		echo -e "${green_b}Finished${green} without errors.${reset}"
	fi
	sed -i "" "s/FIRST_TIME=1/FIRST_TIME=0/g" ./.settings
}

setup "$@"
