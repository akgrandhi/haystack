# Getting Started

### Where are the components?

All of Haystack's backend components are released as [Docker images](https://expediadotcom.github.io/haystack/deployment/sub_systems.html) on **ExpediaDotCom Docker Hub**

### How to run these components?

We have automated deployment of Haystack components using [Kubernetes](github.com/jaegertracing/jaeger-kubernetes). Entire haystack runs locally on minikube(k8s), with a 1 click deployment and Kubernetes on the rest of the environments. Deployment scripts are not tied up with minikube(local development),we can use the same script to deploy in production and that is what we use in Expedia

#### Installation

Clone this repository and run the script, as documented in the next section.

#### Versioning of components

All components and their docker images will be semantically versioned and they will be compatible with each other unless major version is different.

for e.g. 0.1.1 of trace-indexer will be compatible with 0.1.3 of trends components

#### Usage

From the root of the location to which haystack has been cloned:

```
cd deployment/k8s
./apply-compose.sh -a install
```
will install required third party software, start the minikube and install all haystack components in dev mode.


#### What components get installed ?

The list of components that get installed in dev mode can be found at k8s/compose/dev.yaml. 'dev' is a logic name of an environment, one can create compose files for different environments namely staging, test, prod etc. The script understands the environment name with '-e' option. 'dev' is used as default.


#### How to deploy haystack on AWS?

This script does not create/delete the kubernetes cluster whether local(minikube) or cloud. We recommend to use open source tools like [kops](https://github.com/kubernetes/kops) to manage your cluster on AWS. Once you have your cluster up and running, configure the 'kubectl' to point to your cluster. 

Please note the default context for all environments will be minikube. In other words, --use-context will always point to minikube. This is done intentionally to safeguard developers from pushing their local dev changes to other environments.

For details, go [here](https://github.com/ExpediaDotCom/haystack/tree/master/deployment)

### How to send spans?

Span is the unit of telemetry data. A span typically represents a service call or a block of code. Lets look at the former for now, it starts from the time client sent a request to the time client received a response along with metadata associated with the service call.

#### Creating test data in kafka

fakespans is a simple go app which can generate random spans and push to kafka

#### Using fakespans

Run the following commands on your terminal to start using fake spans you should have golang installed on your box
```
export $GOPATH=location where you want your go binaries
export $GOBIN=$GOPATH/bin
cd fakespans
go install
$GOPATH/bin/fakespans
##fakespans options

./fake_metrics -h
Usage of fakespans:
  -interval int
        period in seconds between spans (default 1)
  -kafka-broker string
        kafka TCP address for Span-Proto messages. e.g. localhost:9092 (default "localhost:9092")
  -span-count int
        total number of unique spans you want to generate (default 120)
  -topic string
        Kafka Topic (default "spans")
  -trace-count int
        total number of unique traces you want to generate (default 20)
```

For details, click [here](https://github.com/ExpediaDotCom/haystack-idl)

### How to see on UI?

Once you have cname record to minikube, access haystack UI at-

 ```
 https://haystack.local:32300
 ```
