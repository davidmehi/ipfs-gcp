docker stop ipfs
docker rm ipfs
docker image rm ipfs

docker build -f ./Dockerfile -t ipfs .
docker run -d -p 4001:4001 -p 5001:5001 -p 8080:8080 --log-driver=gcplogs --name=ipfs ipfs

sleep 5

docker ps

docker logs ipfs