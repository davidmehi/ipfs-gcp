# ipfs-gcp
Deploy IPFS to GCP

## Hardcoded values


Dockerfile

```
ENV KUBO_GCS_BUCKET=gcda-ipfs-ds-gcs
```

config

Datastore.Spec.mounts[0].child.bucket
```
  "Datastore": {
    "BloomFilterSize": 0,
    "GCPeriod": "1h",
    "HashOnRead": false,
    "Spec": {
      "mounts": [
        {
          "child": {
            "bucket": "gcda-ipfs-ds-gcs",
            "cachesize": 40000,
            "prefix": "ipfs",
            "type": "gcsds",
            "workers": 100
          },
          "mountpoint": "/blocks",
          "prefix": "flatfs.datastore",
          "type": "measure"
        },
        {
          "child": {
            "compression": "none",
            "path": "datastore",
            "type": "levelds"
          },
          "mountpoint": "/",
          "prefix": "leveldb.datastore",
          "type": "measure"
        }
      ],
      "type": "mount"
    },
    "StorageGCWatermark": 90,
    "StorageMax": "10GB"
  },
```

datastore_spec

mounts.bucket
```
{
    "mounts": [
        {
            "bucket": "gcda-ipfs-ds-gcs",
            "mountpoint": "/blocks",
            "prefix": "ipfs"
        },
        {
            "mountpoint": "/",
            "path": "datastore",
            "type": "levelds"
        }
    ],
    "type": "mount"
}
```


# Docker Build

```
docker rm ipfs
docker image rm ipfs
cd docker
docker build -f ./Dockerfile -t ipfs .
docker images 
```

# Docker Run

```
docker run -d -p 4001:4001 -p 5001:5001 -p 8080:8080 --log-driver=gcplogs --name=ipfs ipfs
docker ps
docker logs ipfs
```


## Test Docker container

echo "Hello IPFS4" > /data/content/hello4.txt
ipfs add hello4.txt
ipfs cat {hash}

docker exec -it ipfs /bin/sh

docker exec -it ipfs sh -c "mkdir -p /data/content"
docker exec -it ipfs sh -c "echo 'Hello IPFS4' > /data/content/hello4.txt"
docker exec -it ipfs ipfs add /data/content/hello4.txt
docker exec -it ipfs ipfs cat {hash}
docker exec -it ipfs ipfs files read hello5.txt
docker exec -it ipfs ipfs ls /data/content/

docker exec -it ipfs ipfs get {hash}



## Publish to GCP Arififact Registry

docker tag ipfs:v0.30.0-gcs us-central1-docker.pkg.dev/gcda-dev/gcda-dev-ipfs/ipfs:v0.30.0-gcs
docker push us-central1-docker.pkg.dev/gcda-dev/gcda-dev-ipfs/ipfs:v0.30.0-gcs




## GCP Service account

create service account ipfs
Add role for Cloud Storage read/write

# Changes to go.mod

## Compile

When compiling, there is a dependency conflict.  Make these changes to kubo/go.mod

remove (lines 245-246)

	google.golang.org/genproto/googleapis/api v0.0.0-20240617180043-68d350f18fd4 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20240617180043-68d350f18fd4 // indirect

Add these three

ADD_LINE="google.golang.org/api v0.122.0 // indirect \
google.golang.org/appengine v1.6.8 // indirect \
google.golang.org/genproto v0.0.0-20230410155749-daa745c078e1 // indirect"

REPLACE_LINE="google.golang.org/genproto/googleapis/rpc v0.0.0-20240617180043-68d350f18fd4"

sed -i 's/$REPLACE_LINE/$ADD_LINE/g' ./go.mod -i.bak2

Update mimetype version

github.com/gabriel-vasile/mimetype v1.4.4 // indirect
github.com/gabriel-vasile/mimetype v1.4.6 // indirect



# Binary - Initialize
ipfs init
sudo sysctl -w net.core.rmem_max=7500000
sudo sysctl -w net.core.wmem_max=7500000

ipfs daemon

KUBO_GCS_BUCKET=gcda-ipfs-ds-gcs ipfs init --profile gcsds

