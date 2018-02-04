##  ------------------------------------------------------------------------  ##
##                                Build Project                               ##
##  ------------------------------------------------------------------------  ##

# .SILENT:

.EXPORT_ALL_VARIABLES:

# .IGNORE:
##  ------------------------------------------------------------------------  ##

APP_NAME := cmdb-rtm
APP_REPO := $(shell git ls-remote --get-url)
GIT_COMMIT := $(shell git rev-list --remove-empty --remotes --max-count=1 --date-order --reverse)

APP_ENV := $(shell cat NODE_ENV)
CODE_VERSION := $(shell cat ./VERSION)
APP_BANNER := $(shell cat ./assets/BANNER)
APP_BRANCH := dev

WD := $(shell pwd -P)
APP_DIRS := $(addprefix ${WD}/,build-* dist-* webroot)
APP_SRC := ${WD}/src
APP_BUILD := ${WD}/build-${CODE_VERSION}
APP_DIST := ${WD}/dist-${CODE_VERSION}

DT = $(shell date +'%Y%m%d%H%M%S')

include ./bin/.bash_colors

##  ------------------------------------------------------------------------  ##

COMMIT_EXISTS := $(shell [ -e COMMIT ] && echo 1 || echo 0)
ifeq ($(COMMIT_EXISTS), 0)
$(file > COMMIT,${GIT_COMMIT})
$(warning ${BYellow}[${DT}] Created file [COMMIT]${NC})
endif

DIR_SRC := ${WD}/src
DIR_BUILD := ${WD}/build-${CODE_VERSION}
DIR_DIST := ${WD}/dist-${CODE_VERSION}
DIR_COMMIT := ${GIT_COMMIT}
DIR_WEB := ${WD}/web

##  ------------------------------------------------------------------------  ##
# Query the default goal.

ifeq ($(.DEFAULT_GOAL),)
.DEFAULT_GOAL := default
endif

##  ------------------------------------------------------------------------  ##
##                                  INCLUDES                                  ##
##  ------------------------------------------------------------------------  ##

include ./bin/Makefile.*

##  ------------------------------------------------------------------------  ##

.PHONY: default

default: all;

##  ------------------------------------------------------------------------  ##

.PHONY: test

test: banner state help banner;

##  ------------------------------------------------------------------------  ##

.PHONY: fetch clone rights

clone:
	@  git clone -b ${APP_ENV} ${APP_REPO} \
	&& cd ${APP_NAME} \
	&& git pull \;

rights:
	@  find . -type f -exec chmod 664 {} \; \
	&& find . -type d -exec chmod 775 {} \; \
	&& find . -type f -name "*.sh" -exec chmod 755 {} \;

fetch: clone rights;

##  ------------------------------------------------------------------------  ##

.PHONY: banner

banner:
	@ [ -s ./assets/BANNER ] && cat ./assets/BANNER;

##  ------------------------------------------------------------------------  ##

.PHONY: clean clean-all
.PHONY: clean-src clean-deps
.PHONY: clean-build clean-dist clean-web clean-files

clean-all: clean clean-web clean-files

clean: clean-build clean-dist

clean-src:
	@ rm -rf ${DIR_SRC}

clean-build:
	@ rm -rf ${DIR_BUILD}

clean-dist:
	@ rm -rf ${DIR_DIST}

clean-web:
	@ rm -rf ${DIR_WEB}

clean-deps:
	@ rm -rf bower_modules/ \
					 node_modules/ ;

clean-files:
	@ rm -rf ${APP_DIRS}  			\
		bitbucket-pipelines.yml		\
		codeclimate-config.patch	\
		_config.yml ;

##  ------------------------------------------------------------------------  ##

.PHONY: setup build deploy dev

setup:
	@ npm i
	@ bower i

build:
	@ NODE_ENV=${APP_ENV};

deploy:
	@  cp -prv ${DIR_SRC}/* ./ 		 \
	&& sudo chmod a+x app/bin/*.sh ;

##  ------------------------------------------------------------------------  ##

.PHONY: rebuild redeploy

rebuild: build;

redeploy: rebuild deploy;

##  ------------------------------------------------------------------------  ##

.PHONY: all full cycle
#* means the word "all" doesn't represent a file name in this Makefile;
#* means the Makefile has nothing to do with a file called "all" in the same directory.

all: banner clean cycle;

full: clean-all all;

cycle: rights setup build deploy;

##  ------------------------------------------------------------------------  ##
