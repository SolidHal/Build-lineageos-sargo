#!/bin/bash

docker run \
	    -e "BRANCH_NAME=lineage-17.1" \
	    -e "DEVICE_LIST=sargo" \
	    -e "INCLUDE_PROPRIETARY=false" \
      -e "CLEAN_AFTER_BUILD=false" \
      -e "SIGN_BUILDS=true" \
      -e "SIGNATURE_SPOOFING=yes" \
      -e "SUPPORT_UNIFIEDNLP=true" \
      -e "BOOT_IMG=true" \
      -e "CUSTOM_PACKAGES=F-DroidPrivilegedExtension" \
      -v "/home/solidhal/android/lineage-docker/src:/srv/src" \
      -v "/home/solidhal/android/lineage-docker/zips:/srv/zips" \
	    -v "/home/solidhal/android/lineage-docker/logs:/srv/logs" \
      -v "/home/solidhal/android/lineage-docker/ccache:/srv/ccache" \
	    -v "/home/solidhal/android/lineage-docker/local_manifests:/srv/local_manifests" \
      -v "/home/solidhal/.android-certs:/srv/keys" \
	    -v "/home/solidhal/android/lineage-docker/userscripts:/srv/userscripts" \
      solidhal/docker-lineage-cicd
