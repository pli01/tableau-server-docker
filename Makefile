##############################################
# WARNING : THIS FILE SHOULDN'T BE TOUCHED   #
#    FOR ENVIRONNEMENT CONFIGURATION         #
# CONFIGURABLE VARIABLES SHOULD BE OVERRIDED #
# IN THE 'artifacts' FILE, AS NOT COMMITTED  #
##############################################

# default values
include Makefile.mk

# override default values
dummy               := $(shell touch artifacts)
include ./artifacts

export

install-prerequisites:
ifeq ($(UNAME),Linux)
ifeq ("$(wildcard /usr/bin/docker)","")
	@echo install docker-ce, still to be tested
	sudo apt-get update ; \
        sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
	curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo apt-key add -
	sudo add-apt-repository \
                "deb https://download.docker.com/linux/ubuntu \
                `lsb_release -cs` \
                stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce
	sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
endif
endif

# build image with custom args installer
build:
	@./scripts/build.sh

up:
	docker-compose ${DC_TABLEAU_RUN_CONF} up  --no-build -d

registry-login:
	@if [ -z "${DOCKER_REGISTRY_TOKEN}" -a -z "${DOCKER_REGISTRY_USERNAME}" ] ; then echo "ERROR: DOCKER_REGISTRY_TOKEN and DOCKER_REGISTRY_USERNAME not defined" ; exit 1 ; fi
	@[ -n "${DOCKER_REGISTRY_TOKEN}" -a -n "${DOCKER_REGISTRY_USERNAME}" ] && echo "${DOCKER_REGISTRY_TOKEN}" | docker login ${DOCKER_REGISTRY} -u ${DOCKER_REGISTRY_USERNAME}  --password-stdin

registry-logout:
	@[ -n "${DOCKER_REGISTRY}" ] && docker logout ${DOCKER_REGISTRY} || true

push-image: registry-login push-image-tableau push-image-tableau-latest
push-image-tableau-latest: BUILD_VERSION
	image_name=$$(cat BUILD_VERSION | cut -f1 -d":") ; \
	image_version=$$(cat BUILD_VERSION | cut -f2 -d":") ; \
	docker tag $$image_name:$$image_version ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/$$image_name:latest ; \
	docker push ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/$$image_name:latest
push-image-tableau: BUILD_VERSION
	image_name=$$(cat BUILD_VERSION) ; \
         docker tag $$image_name ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/$$image_name ; \
         docker push ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/$$image_name
pull-image: registry-login pull-image-tableau-latest
pull-image-%-latest:
	image_name=$$(docker-compose $(DC_TABLEAU_RUN_CONF) config | python -c 'import sys, yaml, json; cfg = json.loads(json.dumps(yaml.load(sys.stdin, Loader=yaml.SafeLoader), sys.stdout, indent=4)); print cfg["services"]["$*"]["image"]') ; \
         echo docker pull ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/$$image_name ; \
         echo docker tag ${DOCKER_REGISTRY}/${DOCKER_REPOSITORY}/$$image_name $$image_name

