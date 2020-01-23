MYNAME = korap
HOSTPORT = 10005
CONTPORT = 5555
DOCKERRUN = docker run --name $(MYNAME) -p $(HOSTPORT):$(CONTPORT) -v $$(pwd)/index/:/app/index/

build:
	docker build --rm -f "Dockerfile" -t korapdocker:latest "."
.PHONY: build


test: build
	$(DOCKERRUN) --rm -i -t korapdocker:latest /bin/bash
.PHONY: test


run:
	@make -s stop
	$(DOCKERRUN) --restart always -d korapdocker:latest
.PHONY: run


stop:
	@if [ "$$(docker container ls -f name=$(MYNAME) -q)" ] ; then \
		docker container stop $(MYNAME) ; \
	else \
		echo 'no running $(MYNAME) container' ; \
	fi
.PHONY: stop
