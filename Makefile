all: build

build:
	docker build --tag cvprojectscpp:latest -f Dockerfile .

run:
	docker stop $(docker ps --filter="name=planbeamer-cvprojectscpp" --format '{{.Names}}') || true
	docker rm planbeamer-cvprojectscpp || true

	# docker run --runtime=nvidia --name planbeamer-cvprojectscpp --net=host -v ${PWD}:/home -p 5678:5678 -e DISPLAY=${DISPLAY} --volume="${HOME}/.Xauthority:/root/.Xauthority:rw" -v /disk/mfund/kitti/training/:/home/dataset/kitti/training:ro -v /disk/mfund/kitti/testing/:/home/dataset/kitti/testing:ro cvprojectscpp:latest
	docker run --runtime=nvidia -it --name planbeamer-cvprojectscpp --net=host -v ${PWD}:/home -p 1111:1111 -e DISPLAY=${DISPLAY} --volume="${HOME}/.Xauthority:/root/.Xauthority:rw" cvprojectscpp:latest
	