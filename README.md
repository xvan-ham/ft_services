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
[link to kubectl overview.](https://kubernetes.io/docs/reference/kubectl/overview/)

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

```sh
minikube config set memory 4000
```
To set the memory to 4000Mb for instance. This is using *Method 2*, which is persistent but will require deleting the current instance.

### Learning to use minikube

Having reached this stage, you can *start*, *stop*, *delete*, set-up some basic *config* and *view config*.

#### Using more profile

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
(Change *nginx-pod* to whatever name you used.)

