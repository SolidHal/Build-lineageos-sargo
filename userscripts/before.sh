#!/bin/bash

#Apply the msm HBM (High brightness mode) patch, this is required for sargo to prevent a bootloop
cd kernel/google/msm-4.9
git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/27/263927/2 && git cherry-pick FETCH_HEAD
cd ../../..

# # Apply patch to increase CONFIG_HZ to 1000 to improve performance and decrease power usage
# # see https://source.android.com/devices/tech/debug/jank_jitter for source
cd kernel/google/msm-4.9
git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/40/263940/1 && git cherry-pick FETCH_HEAD
cd ../../..

# Apply patch to fix bluetooth, disables enforcement of product RRO
cd device/google/bonito
git fetch "https://github.com/LineageOS/android_device_google_bonito" refs/changes/39/271139/4 && git cherry-pick FETCH_HEAD
cd ../../..

