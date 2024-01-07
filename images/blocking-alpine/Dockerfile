FROM alpine:3.10

RUN apk add --no-cache bash sudo
RUN adduser -D user
# Copies your code file from your action repository to the filesystem path `/` of the container
COPY block.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
CMD ["/entrypoint.sh"]
