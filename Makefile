THIS_MAKEFILE_PATH = $(abspath $(lastword $(MAKEFILE_LIST)))
BUILD_TOP_DIR = $(abspath $(dir ${THIS_MAKEFILE_PATH}))

INSTALL_PREFIX = ${BUILD_TOP_DIR}/install
VERSION_STRING	?= $(error "Define VERSION_STRING")
NAME		= llvm-ve-rv-${VERSION_STRING}
RELEASE_STRING 	= 1
DIST_STRING = .el7.centos
LLVM_BRANCH ?= $(error "Define LLVM_BRANCH")
LLVM_DEV_BRANCH ?= $(error "Define LLVM_DEV_BRANCH")
SOTOC_DEFAULT_COMPILER = ncc
TAR=SOURCES/${NAME}-${VERSION_STRING}.tar
INSTALL_DIR=../local
BUILD_TYPE = Release

DIR=${NAME}-${VERSION_STRING}

# Update source codes under $DIR directory.
REPOS=$(error "Define REPOS")

# llvm-dev repository
DEVREPO=${REPOS}/llvm-dev.git

# DEVREPO=git@socsv218.svp.cl.nec.co.jp:ve-llvm/llvm-dev.git

all: source rpm

source: ${TAR}

${TAR}:
	LLVM_BRANCH=${LLVM_BRANCH} BRANCH=${LLVM_DEV_BRANCH} \
	    DIR=${DIR} DEVREPO=${DEVREPO} REPOS=${REPOS} ./update-source.sh
	mkdir -p SOURCES
	tar --exclude .git -cf $@ ${DIR}
	rm -rf ${DIR}

rpm:
	QA_SKIP_BUILD_ROOT=1 rpmbuild -ba --define "_topdir ${BUILD_TOP_DIR}" \
	  --define "name ${NAME}" \
	  --define "build_type ${BUILD_TYPE}" \
	  --define "version ${VERSION_STRING}" \
	  --define "release ${RELEASE_STRING}" \
	  --define "dist ${DIST_STRING}" \
	  --define "buildroot ${INSTALL_PREFIX}" \
	  --define "repos ${REPOS}" \
	  --define "branch ${LLVM_BRANCH}" \
	  --define "sotoc_default ${SOTOC_DEFAULT_COMPILER}" \
	  ${BUILD_TOP_DIR}/SPECS/llvm-ve-rv-rolling.spec

local-rpm:
	./mktar.sh ${INSTALL_DIR} ${VERSION_STRING}
	rpmbuild -bb SPECS/llvm-ve-local.spec \
		--define "_topdir `pwd`" \
		--define "name ${NAME}" \
		--define "version ${VERSION_STRING}" \
		--define "release ${RELEASE_STRING}"
	rpmbuild -bb SPECS/llvm-ve-link.spec \
		--define "_topdir `pwd`" \
		--define "version ${VERSION_STRING}" \
		--define "release ${RELEASE_STRING}"


clean:
	rm -rf ${INSTALL_PREFIX}

.PHONY: all source update rpm clean FORCE
