# Version History

### v0.25d
* Heavily modified "setup.sh" script to add or remove functionality as desired (using switches).
* Added switch to "setup.sh": "--clean" - cleans up by deleting all yml funcionality, deleting all docker images (incl. untagged images).
* Added switch to "setup.sh": "--re" - rebuild switch, when enabled the currently existing and relevant docker images are deleted before rebuilding.
* Added switch to "setup.sh": "--k_del" - removes all yml configurations.
* Added switch to "setup.sh": "--d_del" - deletes all docker images (used by ft_server) including all untagged images.
* Added switch to "setup.sh": "--k_apply" - applies all yml configurations.
* Added switch to "setup.sh": "--d_nginx" - rebuilds nginx docker image (without first deleting existing images, unless "-re" switch is also specified).
* Added switch to "setup.sh": "--d_grafana" - rebuilds grafana docker image (without first deleting existing images, unless "-re" switch is also specified).
* Added switch to "setup.sh": "--d_influxdb" - rebuilds influxdb docker image (without first deleting existing images, unless "-re" switch is also specified).
* Added switch to "setup.sh": "--d_all" - rebuilds all ft-services docker images (without first deleting existing images, unless "-re" switch is also specified).

### v0.2d
* Added Dockerfile and yml files for influxdb and grafana.
* Added grafana and influxdb services to ingress.
* Moved nginx.yml to ft_services/srcs.
* Changed font and background color of index.html (used in nginx pods).

### v0.16d
* Started working on influxdb-telegraf-grafana stack. Nothing major has been added, only loose instructions in "/srcs/influxdb/readme" used to get the stack working in a single docker container. Future work will be towards implementing this within a kubernetes environment.

### v0.15
* Moved "del" script to ft_server root folder.
* Deleted "mk" and "re" scripts.
* Created "setup.sh", which for now uses "del" scripts (to clean up running cluster) and passes minikube IP to both the html index page (in nginx) and creates an environment variable IP within every nginx pod (with the same minikube IP value).
* Restructured: moved yml files to ft_server/srcs; Dockerfile to ft_server/srcs/nginx/.
* Moved "readme" file to root folder (this file contains interesting commands which are useful during development).

### v0.11d
* Edited Dockerfile, now does not rely on "start" script.
* Modified "re", "mk", "del" scripts to stop any pods, deployments, services and ingresses before proceeding.
* Added index.html (forgot to add on v0.1d).
* Modified "ingress.yml".
* Modified "nginx.conf"

### v0.1d
(Version has a lot of forgotten items, avoid this version).
* Working nginx container launch with kubernetes (both http and https).
* Added html index page which will hold all the necessary links (correction v0.011d: forgot to add to this commit).
* Deleted "start.sh" and incorportated into Dockerfile.
* Added "re", "mk" and "del" scripts temporarily to speed up testing.

### v0.03d
* Added work in progress files towards completing nginx container deployment.

### v0.025a
* Hot fixed formatting issues on README.

### v0.025
* Fixed typos on README.

### v0.02
* Added info on Services to README. 
* Added info on Ingress with example to README.
* Added directory with all yaml files used up to now. 

### v0.01
* Added README with tutorial on Kubernetes.
