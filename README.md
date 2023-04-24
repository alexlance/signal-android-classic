### Build your own Signal app

This repo is intended to assist someone to modify, build and sign a Signal
Android APK package, so that you can install a version of Signal on your device
that works the way you would like it to work.


### Patch 001 Remove the forced upgrades

For example I've added `patch-001-forced-upgrades.diff` that removes the forced
version updating in the Signal app.

This is because I don't like forced version updating in any software, but
particularly when the latest version of the software has removed features that
I like.

Feel free to submit some more patches via PRs if you have any interesting
ideas.


### Patch 002 Keep SMS functionality

The github user `ubergeek77` has submitted patches to keep the SMS
functionality around, and also removes the messages that nag at you. (Wow).


### Here's some I built earlier

I went through every tag from Signal version 6.5.0 and upward, and rebuilt Android
packages for every version with the patches above. See the RELEASES page:

https://github.com/alexlance/signal-android-classic/releases


### HOW TO INSTALL

This process is not recommended unless you are insane and willing to lose
everything, but here we are:

1. Download an APK package from the releases page **that is the same version** as
   the version you are currently running
2. Backup your current Signal database to a file and transfer it somewhere safe
3. You will need the following to restore that backup file:
     * Your 30 digit backup decryption code
     * Your registration phone number, so you are able to receive confirmation SMS
     * Your Signal pin (if you set one)
4. Uninstall Signal **(you did back it up right?)**
5. Install the APK you downloaded from the releases page (or built!)
6. Walk yourself carefully through the Restore-Your-Backup-File process


### HOW TO UPGRADE

If you've previously installed an APK from the releases page (by doing the
delete-and-restore process above) then for future upgrades you can just select
the newer APK from the releases page and it'll be a one-click upgrade.

**i.e. the first time installation is painful, but subsequent upgrades are one-click**


### Build your own adventure

You don't have to trust my builds though because...

If you've got keytool, apksigner and docker installed, you can run `build.sh`
for yourself to build your own APK, transfer it to your device and perform the
installation steps above.

Another option is to perform the build process and use Signal's reproducible
builds facility to verify that the APKs that I've uploaded are in fact what
they say they are.


### Rationale

Frankly, I am hoping this will let me hold onto the SMS functionality in Signal
for a bit longer. But we'll see how that goes - so far so good.

