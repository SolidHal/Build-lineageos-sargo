#!/bin/bash

# # Apply patch to increase CONFIG_HZ to 1000 to improve performance and decrease power usage
# # see https://source.android.com/devices/tech/debug/jank_jitter for source
cd kernel/google/msm-4.9
git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/40/263940/1 && git cherry-pick FETCH_HEAD
cd ../../..

#used to build in opengapps if desired
# cd device/google/bonito
# patch -p1 < /srv/userscripts/include-opengapps-pico.patch
# git commit -a -m 'build in opengapps pico'
# cd ../../..
