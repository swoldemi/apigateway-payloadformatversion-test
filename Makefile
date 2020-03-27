all : tmpl check build sam-package sam-deploy
.PHONY: all

S3_BUCKET ?= swoldemi-tmp
DEFAULT_REGION ?= us-east-2
DEFAULT_STACK_NAME ?= httpgatewayheaderstest

build:
	go build -v -a -installsuffix cgo -tags netgo -ldflags '-w -extldflags "-static"' main.go

# Static code analysis tooling and checks
.PHONY: check
check:
	gofumports -w -l -e .
	gofumpt -s -w .
	golangci-lint run ./... \
		-E goconst \
		-E gocyclo \
		-E gosec  \
		-E gofmt \
		-E maligned \
		-E misspell \
		-E nakedret \
		-E unconvert \
		-E unparam \
		-E dupl
	goreportcard-cli -v -t 90

.PHONY: tmpl
tmpl: 
	sam validate

sam-package:
	sam package --template-file template.yaml --s3-bucket $(S3_BUCKET) --output-template-file packaged.yaml

.PHONY: sam-deploy
sam-deploy:
	sam deploy \
	--region $(DEFAULT_REGION) \
	--template-file ./packaged.yaml \
	--stack-name $(DEFAULT_STACK_NAME) \
	--capabilities CAPABILITY_IAM

invoke:
	./invoke.sh > invoke.out 2>&1