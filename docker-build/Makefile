UNAME := $(shell uname -m)

export BUILD_OS=arm64

ifeq ($(UNAME), x86_64)
export BUILD_OS=amd64
endif

# collectd.tar.gz: make-bundle.sh VERSION collect-libs.sh ../Dockerfile plugins.yaml install-plugins.sh $(shell find templates -type f)
# 	$(info PLATFORM="$(TARGET_PLATFORM)")
# 	bash ./make-bundle.sh

amd64:
	TARGET_PLATFORM=amd64 bash ./make-bundle.sh
	$(info PLATFORM="$(TARGET_PLATFORM)")

arm64:
	TARGET_PLATFORM=arm64 bash ./make-bundle.sh
	$(info PLATFORM="$(TARGET_PLATFORM)")

publish:
	docker tag collectd-dse-bundle-amd64 briangxchen/collectd-dse-bundle-amd64
	docker tag collectd-dse-bundle-arm64 briangxchen/collectd-dse-bundle-arm64
	docker push briangxchen/collectd-dse-bundle-arm64
	docker push briangxchen/collectd-dse-bundle-amd64