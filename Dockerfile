# Container image that runs your code
FROM node:12-alpine 

RUN npm install apigeetool -g && \
    apk update && \
    apk upgrade && \
    apk add bash && \ 
    apk add jq && \ 
    apk add --update curl 

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
ADD after-sources /after-sources
ADD before-sources /before-sources
ADD apigeetool-fixe /apigeetool-fixe

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
