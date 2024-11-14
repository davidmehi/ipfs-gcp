FROM golang:1.23-bookworm AS builder

WORKDIR /
RUN apt update -y && apt install -y jq bash libpcre2-8-0 zlib1g git

ENV GO111MODULE=on
ENV GOPROXY=direct
ENV KUBO_GCS_BUCKET=gcda-ipfs-ds-gcs
ENV IPFS_LOGGING="debug"

RUN git clone https://github.com/ipfs/kubo
WORKDIR /kubo

ENV SRC_DIR=/kubo
RUN git checkout tags/v0.30.0

# Copies modified go.mod (contains dependency adjustments)
COPY go.mod $SRC_DIR

# Install the plugin and build ipfs
RUN go get github.com/ipfs-shipyard/go-ds-gcs/plugin@latest
RUN echo "\ngcsds github.com/ipfs-shipyard/go-ds-gcs/plugin 0" >> plugin/loader/preload_list
RUN make IPFS_VERSION=v0.30.0 build || : #first build will fail
RUN go mod tidy
RUN make IPFS_VERSION=v0.30.0 build
RUN make IPFS_VERSION=v0.30.0 install
RUN ipfs --version

FROM ipfs/kubo:v0.30.0
WORKDIR /kubo

ENV SRC_DIR=/kubo

# We copy the new binaries we built in the 'builder' stage (--from=builder)
COPY --from=builder $SRC_DIR/cmd/ipfs/ipfs /usr/local/bin/ipfs
COPY --from=builder $SRC_DIR/bin/container_daemon /usr/local/bin/start_ipfs
COPY --from=builder $SRC_DIR/bin/container_init_run /usr/local/bin/container_init_run

RUN chmod 0755 /usr/local/bin/start_ipfs

COPY --from=builder /usr/bin/jq /usr/local/bin/jq
COPY --from=builder /usr/lib/*-linux-*/libjq.so.1 /usr/lib/
COPY --from=builder /usr/lib/*-linux-*/libonig.so.5 /usr/lib/
COPY --from=builder /usr/bin/git /usr/local/bin/git
COPY --from=builder /usr/lib/*-linux-*/libpcre2-8.so.0 /usr/lib/
COPY --from=builder /usr/lib/*-linux-*/libz.so.1 /usr/lib/


# Copy config files 
COPY config /data/ipfs/config
COPY version /data/ipfs/version
COPY datastore_spec /data/ipfs/datastore_spec
RUN chmod 777 /data/ipfs/config
RUN chmod 777 /data/ipfs/version
RUN chmod 777 /data/ipfs/datastore_spec

# init.d script IPFS runs before starting the daemon. Used to manipulate the IPFS config file.
#COPY 001-config.sh /container-init.d/001-config.sh