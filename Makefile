build:
	docker build -t my-nginx .

push:
	docker tag $(docker images -q --filter=reference='my-nginx') jgaspar/my-nginx
	docker push jgaspar/my-nginx
