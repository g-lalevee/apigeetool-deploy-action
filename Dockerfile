# Container image that runs your code
FROM node:12-alpine 

RUN npm install apigeetool -g && \
    apk update && \
    apk upgrade && \
    apk add bash && \ 
    apk add jq && \ 
    apk add --update curl \
    sed -i 's/developer.attributes = opts.attributes/developer.attributes =  JSON.parse(opts.attributes)/g' /usr/local/lib/node_modules/apigeetool/lib/commands/createdeveloper.js \
    sed '177 r apigeetool-update/commands.js.add' /usr/local/lib/node_modules/apigeetool/lib/commands/commands.js

   
# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh
ADD after-sources /after-sources
ADD before-sources /before-sources

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
