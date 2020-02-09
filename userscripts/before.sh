#!/bin/bash

#Apply the msm HBM (High brightness mode) patch, this is required for sargo to prevent a bootloop
cd kernel/google/msm-4.9
git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/27/263927/2 && git cherry-pick FETCH_HEAD
cd ../../..

# Apply patch to increase CONFIG_HZ to 1000 to improve performance and decrease power usage
# see https://source.android.com/devices/tech/debug/jank_jitter for source
cd kernel/google/msm-4.9
git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/40/263940/1 && git cherry-pick FETCH_HEAD
cd ../../..

echo Applying the Bluetooth Selinux patch
cd device/google/bonito
git fetch "https://github.com/LineageOS/android_device_google_bonito" refs/changes/45/268545/1 && git cherry-pick FETCH_HEAD
cd ../../..

# uncomment the following to set selinux to permissive, useful for debugging

# set selinux to permissive
# echo Applying the selinux disable
# cd device/google/bonito
# patch --quiet -p1 -i "/srv/userscripts/disable-selinux.patch"
# git commit -a -m "Set Selinux to permissive"
# cd ../../..
