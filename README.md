
# Build LineageOS 17.1 for the Pixel 3a aka sargo

Installation instructions can be found below as well.

These instructions will also likely work for the Pixel 3a XL aka bonito with some modification. 

There are two ways to build, the easy way and the hard way. The easy way uses a docker image as the build environment and applies functionality patches and optionally patches for microg support. This is the recommend way as the build dependency versions your linux distro provides may cause unexpected issues. 

The hard way requires you to set up your own build environment and apply the patches manually. You may want to choose this route if you want to familiarize yourself with AOSP, lineaseos, and the build process. If you choose this route I suggest using Debian Stretch.

_At the bottom of this page are some troubleshooting and debug instructions_

# Get adb and fastboot
_Required for both the easy and hard ways_
the platform tools provided by distros is often wayyyy out of date. We have to grab the binaries ourselves.

get adb and fastboot from google https://dl.google.com/android/repository/platform-tools-latest-linux.zip
cd to your home directory, and extract them: `unzip platform-tools-latest-linux.zip -d ~` 
and add them to your path by adding the following to your `~/.profile`
```
# add Android SDK platform tools to path
if [ -d "$HOME/platform-tools" ] ; then
    PATH="$HOME/platform-tools:$PATH"
fi
```

and run `source ~/.profile`

 
# Build lineageos 17.1 for pixel 3a (sargo) docker aka the easy way

This uses https://github.com/SolidHal/docker-lineage-cicd/ which automates the build. 

Install docker for your OS. Instructions can be found on the docker website.

clone a copy of the repo

```
cd ~/
mkdir lineage-docker-solidhal
cd lineage-docker-solidhal
git clone https://github.com/SolidHal/docker-lineage-cicd.git .
```

and build the docker image

```
docker build --tag solidhal/docker-lineage-cicd .
```

Now clone a copy of this repo if you haven't already

```
cd ~/
mkdir lineage-sargo
cd lineage-sargo
git clone https://github.com/SolidHal/Build-lineageos-sargo.git .
```

make the directories we will pass into the docker:
```
mkdir src zips logs ccache
```
and the a directory for your signing keys. If you already have these, you can skip this step
```
mkdir ~/.android-certs
```

now we can build. 

`build_sargo.sh` builds lineageos with support for signature spoofing and other location providers both of which are required for microg and unifiedNLP support.
It also includes the f-droid privileged extension, which allows f-droid to be used without the "unknown sources" permission and allows for a cleaner app install process. 

The script `before.sh` in `userscripts` applies a handful of patches to fix a bootloop, improve battery life, and fix bluetooth

If all of that sounds good, you can build by running
```
./build_sargo.sh
```
this will take over an hour most likely, especially the first time.

you can watch the progress by reading the logs in `logs`.
The repo log is the process of syncing all of the repos. When that is complete, a second log in the `logs/sargo` directory will track the build progress.

when the build is complete, you can find the lineageos zip and the `boot.img` in `zips/sargo`

### Install
_Install instructions can be found farther down this readme_

### Customization

if you don't have any interest in microg, you can remove `SIGNATURE_SPOOFING` and `SUPPORT_UNIFIEDNLP`.

Additional environment variables can be added to the script to further customize the build. See https://github.com/SolidHal/docker-lineage-cicd/ for a list


# Build lineageos 17.1 for pixel 3a (sargo) no docker aka the hard way
This is more difficult, as you have to setup the environment yourself. It is also less reliable as build dependencies can cause unknown issues depending on the version your distro provides. 


Basing these instructions off of https://wiki.lineageos.org/devices/sailfish/build with modifications for the pixel 3a aka sargo

Note that while the pixel 3a is codenamed `sargo`, it is very closely related to the pixel 3a XL codenamed `bonito`. Because of this,
most of the files we care about are actually under `bonito` directories. This is important to keep in mind if you want to modify this process. 

## Setup build enviroment

In my experience, over 16GB of RAM + swap is needed to build.
I have 16GB of ram but my first build failed because I only had 2GB of swap :(
If you get a random failure in the build process, because something was "killed" low memeory is likely why
I needed over 8GB of swap, ended up using 16GB

Guides all over the internet can tell you how to grow your swap, but to start you can check it with:
`free -h`

You also need about 150-200GB of free disk space.


install the repo command

```
curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo
chmod a+x /usr/bin/repo
```

## Setup sources
make and enter a desired source directory

```
cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b lineage-17.1
```


and now let repo grab all of the sources

`repo sync`

if that fails, you may have to run the following to clear any conflicts:

```
repo sync --force-sync
```

now download the device specific config and kernel:

```
source build/envsetup.sh
breakfast sargo
```

### proprietary blobs
these are unfortunately required, there is no android phone without some proprietary blobs.
we have to specifiy them explicitly because they are not provided by lineageos for potential copyright issues.

add the following to `.repo/local_manifests/muppets.xml`
```
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="TheMuppets/proprietary_vendor_google" path="vendor/google" remote="github" />
</manifest>
```

and run `repo sync`
to get the proprietary blobs.



now to patch in signature spoofing and add the fdroid privileged extension:

### Fdroid & microg
include the fdroid privileged extension in the build. This combined with the fdroid.apk will allow us to securely install microg from the supported fdroid repo.
information on this process can be found here: https://gitlab.com/fdroid/privileged-extension/#f-droid-privileged-extension

make a file called `fdroid_extension.xml` in `.repo/local_manifests` and add the following to it:
```
<?xml version="1.0" encoding="UTF-8"?>
<manifest>

  <remote name="fdroid" fetch="https://gitlab.com/fdroid/" />
  <project path="packages/apps/F-DroidPrivilegedExtension"
           name="privileged-extension.git" remote="fdroid"
           revision="refs/tags/0.2.11" />

</manifest>
```
note that when fdroid privileged extension is updated the revision (0.2.11) will need to be updated to build the new version into lineageos

now run `repo sync` again to pull in the fdroid privileged extension files

Next to actually include it in the build, add `F-DroidPrivilegedExtension` to the `PRODUCT_PACKAGES` list in `device/google/bonito/device-common.mk`
```
PRODUCT_PACKAGES += \
    F-DroidPrivilegedExtension \
```

after bootup, we can then install fdroid, and then installing the microg apks from there. This is the "supported" method of microg inclusion.
This also provides the benefit of having a microg-free ROM if desired.


*NOTE: if you run repo sync after this point, you will have to re apply the patches* 

_Patches can be found in the following places
 Signature Spoofing: 
_

### Signature Spoofing patch for android 10
to take advantage of microg, we need to allow signature spoofing.

The patch can be found here https://github.com/SolidHal/docker-lineage-cicd/tree/master/src/signature_spoofing_patches
```
cd frameworks/base/core
patch -p1 < sig_spoofing_patch/android_frameworks_base-Q.patch
```


### UnifiedNLP patch
The patch can be found here https://github.com/SolidHal/docker-lineage-cicd/tree/master/src/location_services_patches
```
cd frameworks/base/core`
patch -p1 < location_patch/android_frameworks_base-Q.patch
```

### msm patches
there is one patch to prevent a bootloop that has not yet been merged. Lets cherry pick it now. 

`cd kernel/google/msm-4.9`
`git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/27/263927/2 && git cherry-pick FETCH_HEAD`

### bluetooth patch
bluetooth is currently broken due to hal_bluetooth_default lacking some permissions, cherry pick the patch. This may get merged, making this step unnecessary:
```
cd device/google/bonito
git fetch "https://github.com/LineageOS/android_device_google_bonito" refs/changes/45/268545/1 && git cherry-pick FETCH_HEAD
```

### battery life improvement patch
this may also get merged at some point

```
cd kernel/google/msm-4.9
git fetch "https://github.com/LineageOS/android_kernel_google_msm-4.9" refs/changes/40/263940/1 && git cherry-pick FETCH_HEAD
```

Now we can get back to building.

## ccache
setup ccache, I highly recommend this. Android takes a very long time to build (>1 hour). This _greatly_ speeds up subsequent builds:

run: 
```
export USE_CCACHE=1
```
and add that line to your `~/.bashrc`

and choose a size for your ccache. The wiki recommends 50G but I went with 75G to be safe.
```
ccache -M 75G
```

## build
And finally, start the build. This will take a while.
```
croot
brunch sargo
```

you can find the build results in `$OUT` which is 
```
croot
cd out/target/product/sargo
```

inside you'll find the `lineage-17.1-XXXXXXXX-UNOFFICIAL-sargo.zip`

# Install

Plug your phone into you computer, power it off, and hold down `power` + `volume down` to boot into the bootloader

make sure your bootloader is unlocked. You can unlock it by running:
`fastboot flashing unlock`
accept the bootloader unlock, and reboot into bootloader

Now to flash the recovery image we built, which is part of the boot.img 
for the hard way, the boot.img is located in ``out/target/product/sargo`
for the easy way it is along with your lineageos image in `zips`

flash boot.img by running:
`fastboot flash boot boot.img`

reboot into the bootloader and boot into recovery by using volume up or volume down in the bootloader
Do a factory wipe of user data to avoid any issues.
Next choose `Apply update from adb`
Locate your built lineageos.zip and sideload it
 `adb sideload lineage-17.1*.zip`

it will get stuck at 47% for a bit, just give it a few minutes
When it is done, you will be back at the android recovery screen
choose "Reboot System Now"


# Fdroid and microg setup
Right now you need an alpha version of fdroid to function with the privileged extension on Android 10
get version `1.8-alpha1` or newer

Once installed, add the microg fdroid repo. A quick search will lead you to it.

Install microg services core, microg services framework proxy, fakestore, and a unified nlp backend.

I found for installing microg services, I still had to give fdroid unknown sources permission. This doesn't seem to happen with any other app from fdroid. 

Open the microg app, give it the permissions it requests and then in the self check tap "system grants signature spoofing permission" and grant it signature spoofing

Now we have to grant unified nlp location permissions. This is done easily from adb root

enable adb and root adb in developer options, plug in your phone, and run:

```
adb root
adb shell
```
then run the following in the adb shell
```
pm grant com.google.android.gms android.permission.ACCESS_FINE_LOCATION
pm grant com.google.android.gms android.permission.ACCESS_COARSE_LOCATION
```

Finally, grant the fakestore signature spoofing permissions

```
pm grant com.android.vending android.permission.FAKE_PACKAGE_SIGNATURE
```

and reboot your phone
you can now disable developer options

Further troubleshooting information can be found here https://old.reddit.com/r/MicroG/wiki/issues

# Debug build
useful for debugging bootloops, provides access to adb functions like `adb logcat` right away.

### docker
TODO

### no docker
to build a debug eng image on lineageos  do the following:
`TARGET_BUILD_TYPE=debug breakfast sargo eng`
`TARGET_BUILD_TYPE=debug brunch sargo eng`

sideload the `lineage-17.1-XXXXXXXX-UNOFFICIAL-sargo.zip` like a usual build

### fastboot usage
sargo is an A/B device, so you can flash either slot_a or slot_b by adding `_b` to the partition
example for boot:
```
fastboot flash boot_a boot.img
fastboot flash boot_b boot.img
```

### Troubleshooting:

at some point, I got stuck where I couldn't get into recovery from the bootloader. 

to get out I took the following from `out/target/product/sargo` and flashed them. 
flash `boot.img`, `dtbo.img`, `vbmeta.img`
```
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot flash vbmeta vbmeta.img
fastboot reboot bootloader
```
then use the volume keys to choose "recovery" and boot to recovery

wipe the data and system partitions


### how to debug selinux issues

To test if selinux is at fault, you can apply the selinux-permissive.patch, build, and see if it is fixed

check if selinux is permissive or enforcing:
```
adb root
adb shell
getenforce
```

in permissive mode, it will log the requests that would be denied if enforcing
you can see all of the requests the sepolicy has denied by running 
```
adb shell dmesg | grep denied
```

find the policy file, which end in `.te` in `device/<manufacturer>/<board>/sepolicy` or `sepolicy-lineage`

you can used the old audit2allow.perl, which will turn the denieds into policies to add the the policy file

get the perl script:
`wget https://github.com/OpenDarwin-CVS/SEDarwin/raw/master/sedarwin7/src/sedarwin/policycoreutils/audit2allow/audit2allow.perl`
give it execution permissions:
`sudo chmod +x audit2allow.perl`
and then run it like this:
`adb shell dmesg | grep denied | perl ~/android/audit2allow.perl`

this page has some information, but some of it is outdated right now https://source.android.com/security/selinux/implement

### Flashing the stock google rom

the latest factory image for the 3a from here
https://developers.google.com/android/images

extract and run `flash-all.sh`

### Additional information I stumbled upon during this process:
tried to setup debug using somgthing like this: https://groups.google.com/forum/#!topic/mozilla.dev.b2g/epQ6qhIFZ50
unpacking the boot.img with with this https://github.com/xiaolu/mkbootimg_tools
but that didn't work
https://source.android.com/compatibility/vts/vts-on-gsi
