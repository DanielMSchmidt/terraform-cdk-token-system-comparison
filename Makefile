# MAKEFLAGS += -j$(NPROCS)
DOCKER_IMG := docker.mirror.hashicorp.services/hashicorp/jsii-terraform

ifneq ($(SKIP_DOCKER),true)    
    DOCKER_CMD := docker run -it --rm -w /home -v $$(pwd):/home ${DOCKER_IMG}
endif

.PHONY: all
all: gen/native/simple-example gen/object/simple-example

.PHONY: image
image: 
	docker pull ${DOCKER_IMG}

gen: image
	mkdir -p gen 

gen/native: gen
	mkdir -p gen/native

gen/native/terraform-cdk: gen/native
	rm -rf $@ && git clone https://github.com/hashicorp/terraform-cdk.git $@

gen/native/terraform-cdk/dist: gen/native/terraform-cdk
	${DOCKER_CMD} sh -c "cd $$(dirname /home/$@/) && yarn install && yarn build && yarn package"


gen/native/%: gen/native/terraform-cdk/dist
	mkdir -p $@
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf init --local --template=typescript --project-name=% --project-description=% --dist ../terraform-cdk/dist
	cp src/$$(basename $@)/native.ts $@/main.ts
	node ./combineJson.js $@/cdktf.json src/$$(basename $@)/cdktf.json
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf get


gen/object: gen
	mkdir -p gen/object

gen/object/terraform-cdk: gen/object
	rm -rf $@ && git clone https://github.com/hashicorp/terraform-cdk.git $@ && cd $@ && git fetch && git checkout pr/706

# gen/object/terraform-cdk/dist: gen/object/terraform-cdk
# 	${DOCKER_CMD} sh -c "cd $$(dirname /home/$@/) && yarn install && yarn build && yarn package"

gen/object/terraform-cdk/dist: gen/object/terraform-cdk
	${DOCKER_CMD} sh -c "cd $$(dirname /home/$@/) && yarn install && yarn build"

# gen/object/%: gen/object/terraform-cdk/dist
# 	mkdir -p $@
# 	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf init --local --template=typescript --project-name=% --project-description=% --dist ../terraform-cdk/dist
# 	cp src/$$(basename $@)/object.ts $@/main.ts
# 	node ./combineJson.js $@/cdktf.json src/$$(basename $@)/cdktf.json
# 	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf get
	
gen/object/%: gen/object/terraform-cdk/dist
	mkdir -p $@
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf init --local --template=typescript --project-name=% --project-description=% --cdktf-version=0.5.0
	cp src/$$(basename $@)/object.ts $@/main.ts
	node ./combineJson.js $@/cdktf.json src/$$(basename $@)/cdktf.json
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf get
	

