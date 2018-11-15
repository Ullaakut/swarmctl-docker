# Let's build traefik for linux-amd64
FROM golang:1.11.0-alpine AS base-image

# Package dependencies
RUN apk --no-cache --no-progress add \
    bash \
    curl \
    gcc \
    git \
    make \
    musl-dev \
    docker \
    tar

RUN go get -u github.com/docker/swarmkit/...

FROM base-image as maker

RUN go get -u github.com/alecthomas/gometalinter

ARG license_server_url
ENV PROJECT_WORKING_DIR=/go/src/github.com/docker/swarmkit
WORKDIR "${PROJECT_WORKING_DIR}"

RUN make install

FROM maker as builder
# Prepare fakeroot
RUN mkdir /fakeroot && cp /usr/local/bin/swarmctl /fakeroot/swarmctl

FROM alpine AS base
COPY --from=builder /fakeroot/ /
VOLUME ["/tmp"]
ENTRYPOINT ["/swarmctl"]
