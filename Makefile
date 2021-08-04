MAKEFLAGS += -j$(NPROCS)

.PHONY: all
all: gen/native/simple-example gen/object/simple-example

gen/native:
	@mkdir -p gen/native

gen/native/terraform-cdk: gen/native
	rm -rf $@ && git clone git@github.com:hashicorp/terraform-cdk.git $@ && cd $@ && yarn install && yarn build

gen/native/terraform-cdk/packages/cdktf-cli/bin/cdktf: gen/native/terraform-cdk
	cd gen/native/terraform-cdk && yarn install && yarn build

gen/native/%: gen/native/terraform-cdk/packages/cdktf-cli/bin/cdktf
	mkdir -p $@
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf init --local --template=typescript --project-name=% --project-description=% --cdktf-version=0.5.0
	cp src/$$(basename $@)/native.ts $@/main.ts
	node ./combineJson.js $@/cdktf.json src/$$(basename $@)/cdktf.json
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf get

gen/object:
	@mkdir -p gen/object

gen/object/terraform-cdk: gen/object
	rm -rf $@ && git clone git@github.com:hashicorp/terraform-cdk.git $@ && cd $@ && git fetch && git checkout pr/706 && yarn install && yarn build

gen/object/%: gen/object/terraform-cdk
	mkdir -p $@
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf init --local --template=typescript --project-name=% --project-description=% --cdktf-version=0.5.0
	cp src/$$(basename $@)/object.ts $@/main.ts
	node ./combineJson.js $@/cdktf.json src/$$(basename $@)/cdktf.json
	cd $@ && ../terraform-cdk/packages/cdktf-cli/bin/cdktf get
	
