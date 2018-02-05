# dind-gocd-agent

Dockerhub - https://hub.docker.com/r/varshavs/dind-gocd-agent/

#### Build 
docker build . -t dind-gocd-agent:v18.1.0

#### Run
docker run -it --privileged -e GO_SERVER_URL="https://go_server_ip:8154/go" dind-gocd-agent:v18.1.0
