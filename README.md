# ft_services

42 Madrid Project. Introduction to kubernetes. Involves cluster management and deployment with Kubernetes. The following task has to be accomplished: virtualize a network and do "clustering".
Note: VirtualBox needs to be installed through the "Managed Software Center", only after that is it possible to launch `minikube start --vm-driver=virtualbox --cpus 3 --memory=3000mb` or such commands.

## kubectl

*kubectl* controls Kubernetes cluster manager.
In 42, it is already installed, you can check in:
```sh
cd /usr/local/bin/
```
Here you will see the *kubectl* directory.
[link to kubectl overview.](https:/Y/kubernetes.io/docs/reference/kubectl/overview/)

## Minikube
### Install minikube

*Minikube* controls/manages the cluster. It will run a VM and run a master node and worker node.


**Warning:** Don't launch *minikube* at this stage as it is heavy and will fill your local partition (at 42).
```sh
brew install minikube
```

### Start minikube in /goinfre

Minikube will use a lot of disk-space, probably all of it so do not start it as is, we want to start in in `/goinfre` (which is local, it will only be saved on that computer).

Minikube creates the VM on `~/.minikube`, a symbolic link needs to be created so that `~/.minikube` points to `/goinfre/\<user_name\>/.minikube`

Create the `.minikube` directory:
```sh
mkdir /goinfre/$USER/.minikube
```

*Note*: if you don't have a folder in `goinfre` already, you need to create it first.

Soft link the `/goinfre/\<user_name\>/.minikube` to `~/.minikube`
```sh
ln -s /goinfre/$USER/.minikube ~/.minikube
```

Important note: you'll have to do this everytime you change computer, therefore it might be of interest to make a script that does this for you.

Now when you start minikube, it will be loaded into the goingfre space instead of your personal home partition.

To start, essentially you can use:
```sh
minikube start
```
However, it will launch with the default VM which requires sudo permissions.
Therefore, we need to specify the virtual machine.
For this, we have 3 options:
* Method 1: Pass the VM-driver as a parameter on the start command.
* Method 2: Add the desired VM-driver (virtualbox) to the config by command.
* Method 3: Copy a config file to `~/.minikube/config`.

#### Method 1

The first option means re-typing the command every time we start up.
Run with command:
```sh
minikube start --vm-driver=virtualbox
```

#### Method 2

The second option is persistent as it is saved in a `config.json` file.
```sh
minikube config set vm-driver virtualdriver
```
It will warn us that these changes will only take place when we delete (not just stop) the instance. If you have not already started minikube you can ignore the next 2 commands.

Stop the curret instance of minikube:
```sh
minikube stop
```

Delete the minikube instance:
```sh
minikube delete
```

Now you can just start minikube and the correct VM-driver will be used.
```sh
minikube start
```

You can always view the current config with:
```sh
minikube config view
```
Which you can also see in `~/.minikube/config/config.json`

#### Method 3

The last of the methods involves copying a set-up config-file (which you can make using the previous method once, and carry over to any system) to `~/.minikube/config/`.


#### Once started

Once you have started minikube, which will take a while... you will notice on VirtualBox, that you have *minikube* running on the left-pane. Clicking on it will show the specifics of the instance. By defeult it will run on 2Gb of memory. We can change this setting (among others) by using:

(Change *nginx-pod* to whatever name you used.)
```sh
minikube config set memory 4000
```
To set the memory to 4000Mb for instance. This is using *Method 2*, which is persistent but will require deleting the current instance.

### Learning to use minikube

Having reached this stage, you can *start*, *stop*, *delete*, set-up some basic *config* and *view config*.

#### Using more profiles

Using more profiles might be useful when we want instances for different things, with different specs (e.g. less memory).

To create a new profile (default profile is called: *minikube*) you must first ensure no other instance is currently running and execute:
```sh
minikube start -p <name>
```
Where \<name\> is the name of the profile you want, e.g. *client2*.
If you applied changes to the config file before this command, they will be used to configure this new instance. You will also notice a new instance running on your VistualBox.

To stop this instance, run:
```sh
minikube stop -p <name>
```
If you don't specify the profile (`-p` switch), it will default to *minikube*.
Note: profile name can come before or after the command, both will work.

To delete this profile:
```sh
minikube delete -p <name>
```

#### Viewing Namespaces

Namespaces are used to sub-divide a cluster into several virtual clusters. Useful for example to have a development namespace (virtual cluster) running in parallel with a testing and production namespace.

To view namespaces, on a running instance, execute:
```sh
minikube dashboard
```
Which will open a graphical interface in a web-browser. Among all the items you will find the menu *namespaces* on the left hand side. Clicking on this will list the *default* and other namespaces minikube uses internally.

To view on the console, on another terminal tab, execute:
```sh
kubectl get namespaces
```
This command will list all currently used namespaces.

#### Creating Namespaces

On another tab (if you have the dashboard open it will not register commands on that tab - use Ctrl+C to exit dashboard if desired), run:

```sh
kubectl create namespace <name>
```
Which will create a namespace of your chosen name. You can confirm this by appying what you learnt on *Viewing Namespaces*.

Another method is to create a template (yml file) such as:
```yml
apiVersion: v1
kind: Namespace
metadata:
	name: my_namespace_or_whatever
```
Change directory to the file's location and run:
```sh
kubectl apply -f <name>
```
Which will create the namespace. Note that templates are the most interesting way of working with Kubernetes, as this is a tool primarily built for automatization.

#### Delete Namespaces

To delete, simply execute:
```sh
cubectl delete namespace <name>
```

### Create a Pod

A pod is the smallest unit used in Kubernetes. To create one from a template, use a template such as:

```yml
apiVersion: v1
kind: pod
metadata:
	name: nginx-pod
spec:
	containers:
	-name: nginx-container
		image: nginx

```
Name this file however you like, e.g. pod.yml.
Apply the file:
```sh
kubectl apply -f pod.yml
```
(Change *pod.yml* to whatever name you used.)

The console will notify that a pod has been created.
You can view this in the dashboard under: *Workloads* and find your pod there.

You can also view this using:
```sh
kubectl get pods
```

To get more info about a pod, use:
```sh
kubectl describe pod nginx-pod
```
(Change *nginx-pod* to whatever name you used.)

### Enter the Pod

Once a pod is created, to access it, there are 2 options:
* Through graphical interface.
* Through console using kubectl (most common way).

To enter the pod through the graphical interface, open the dashboard, click on the desired pod and choose "exec into pod", a button on the top-right edge of the interface.

To do the same on the console, execute:
```sh
kubectl exec -it nginx-pod -- /bin/bash
```
(Change *nginx-pod* to whatever name you used.)
Note: The only difference with running with docker is the *--* part, which is not necessary with docker (`docker exec -it [image] [command]`). Docker's method is deprecated and will be removed in a future version, however, at the time of writing it is still functional.

### View Pod Logs

Viewing a pod's logs is also possible both through the grapical interface and through console.

To view the pod's log through the graphical interface, open the dashboard, click on the desired pod and choose "View Logs", a button on the top-right edge of the interface, just left of the exec button.

To view the logs through console, run:
```sh
kubectl logs -f nginx-pod
```
(Change *nginx-pod* to whatever name you used.).

### Create a Deployment

A deployment orchestrates the number of pods. A deployment can be launched through the dashboard interface (+ new app) or by applying a template such as the example shown below. 

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-awesome-deployment
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

To delete a deployment, execute the following command:

```sh
kubectl -n default delete <name_of_deployment>
```
Note that "*default*"is the namespace, which, if you haven't changed should be called *default*.

### Services

Pods are mortal. It is important that this is clear from the outset. For this reason, we do not want to access pods directly because those pods could (and will) disappear. For this reason **services** are used, these expose pods in a unified manner. The rest of the applications will engage a service (rather than a pod), and it is the service itself which is in charge of distributing the workload between the pods it handles.

Services can be created throught the dashboard or by applying a template such as the example below.

```yml
apiVersion: v1
kind: Service
metadata:
  name: mariadb-service
spec:
  selector:
    app: mariadb
  ports:
      - protocol: TCP
        port: 3306
        targetPort: 3306
```

Note that the service needs to know which pods to hook to. This is what the **selector** field is for.
In this particular example the service is hooked to any components that meet the following criteria:
```yml
app: mariadb
```
Meaning that all pods running mariadb app will be hooked by this service.

*Note*: Notice we used the **selector** field in previous templates as well.

### Get a Pod Description

Get a pod's name using:
```sh
kubectl get pod
```
Note: you can use *pod* or *pods*.

Copy the pod's name, e.g.: mariadb-deployment-84f67bd45d-w877t.
Execute:
```sh
kubectl describe pod mariadb-deployment-84f67bd45d-w877t
```

### Communication between pods: Services

This section covers communication between 2 pods by means of an example.
Launch 2 deployments (for instance, mariadb and nginx).

Enter nginx:
```sh
kubectl exec -it <name of nginx_pod> -- /bin/bash
```

Note: if command **ping** is not recognized execute the following.
```sh
apt-get update
apt-get install iputils-ping
```
Now check communication between nginx pod and mariadb pod.
```sh
ping mariadb
```
You will note that the name or service is unknown. This makes sense as there could be many mariadb pods, how can this pod know which one to communicate with? How can it even recognize the name? (Answer: Services - described further below).
Instead, lets ping the ip of a mariadb pod (which you can get with the describe command from the previous point).

```sh
ping <mariadb_pod_ip>
```
You'll notice that now it does indeed ping the pod. **However**, it is important to remember that **pods are mortal**, therefore it is not of great interest to communicate directly with a pod which may cease existing at any moment. What we want is to address a service, which will in turn decide which pod to engage with.

If we now create a service, using what was covered in **Services** and repeat the process:

```sh
ping mariadb-service
```
(Note: mariadb-service is the name given to the service through the yaml template.)

This time we see that ping successfully pings the service (though no reply is heard).

### Get a Service Description

Much the same as with the pod description, we execute:

```sh
kubectl describe service <service_name>
```

### Ingress (with example)

What is ingress used for?

Internal services are only available inside the cluster. In order to expose services externally (provide connectivity) **ingress** is used.

This a beta feature (as Kubernetes is not a full final product) and is disabled by default.
To enable, run the following:
```sh
minikube addons enable ingress
```

Creating an ingress, is only possible through console. For this we use a template.

[Ingress documentation.](https://kubernetes.io/docs/concepts/services-networking/ingress/)



In the following example, we want to run nginx pods (using deployment or pods).

Next, we are going to apply an nginx service using the following template.
```yml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
      - protocol: TCP
        port: 80
        targetPort: 80
```

Apply this service using:
```sh
kubectl apply -f service-nginx.yml
```
(Using *service-nginx.yml* as an example file name).

Next we create an ingress template.
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
      nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
                name: nginx-service
                port:
                    number: 80
```

Apply the ingress using:
```sh
kubectl apply -f <filename.yml>
```

It might take some time but eventually when you run:
```sh
kubectl get ingress
```
You will see the name of the ingress and that the HOSTS value is **\*** which means it is listening to ALL.

Get the minikube IP using:

```sh
minikube ip
```

Copy this IP and paste it into the browser. You should now see the nginx intro-page.
