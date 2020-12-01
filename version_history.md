# Version History

### v0.11dd
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
