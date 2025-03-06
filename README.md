# witwat aka What if there was a train?

Personal project imagining utilizing existing rail lines for high speed rail travel.

`tickety_split`
The React frontend. Renders a map of the rail lines.

`dispatch`
The Rust backend. An API that serves up lines and routes.

Related: [`osm2rail`](https://github.com/hanakslr/osm2rail) parses OSM data - cleans and segments it.

## Local development

Local development environment can be set up with `minikube`.

Start up minikube.

```
minikube start
```

Then switch to the minikube context and build the docker images. The eval command sets the context.

```
eval $(minikube docker-env)

docker build -t dispatch:dev -f ./dispatch/Dockerfile.dev ./dispatch && docker build -t tickety_split:dev -f ./tickety_split/Dockerfile.dev ./tickety_split
```

Then start everything up with `kubectl apply -f config/k8s/witwat.yaml`

To access the deployments run `minikube tunnel` and to view the status `minikube dashboard`.

Server changes aren't set up with hot reloading yet. To get them to apply run the following to rebuild the image and delete the current pod, to trigger a new one to start up with the new image.

```
docker build -t dispatch:dev -f ./dispatch/Dockerfile.dev ./dispatch
kubectl delete pod -l app=dispatch`
```
