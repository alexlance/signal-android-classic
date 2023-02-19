### Build your own Signal app

This repo is intended to assist someone to modify, build and sign a Signal
Android APK package, so that you can install a version of Signal on your device
that works the way you would like it to work.


### Remove the forced upgrades

For example I've added `patch-001-forced-upgrades.diff` that removes the forced
version updating in the Signal app.

This is because I don't like forced version updating in any software, but
particularly when the latest version of the software has removed features that
I like.

Feel free to submit some more patches via PRs if you have any interesting
ideas.


### Here's some I built earlier

I went through every tag from Signal version 6.5.0 and upward, and rebuilt them
all without the forced upgrade functionality. See the RELEASES page:

https://github.com/alexlance/signal-android-classic/releases


### HOW TO INSTALL

This process is not recommended unless you are insane and willing to lose
everything, but here we are:

1. Download an APK package that is the same version as the version you are currently running
2. Backup your current Signal database, you will need the following to restore:
     * 30 digit backup decryption code
     * Your registration phone number able to receive SMS
     * Your Signal pin (if you set one)
3. Uninstall Signal
4. Install the APK you downloaded (or built!)
5. Walk yourself carefully through the Restore Your Backup File process


### Build your own adventure

You don't have to trust my builds though because...

If you've got keytool, apksigner and docker installed, you can run build.sh for
yourself to build your own APK, transfer it to your device and perform the
installation steps above.


### Rationale

Frankly, I am hoping this will let me hold onto the SMS functionality in Signal
for a bit longer. But we'll see how that goes.

There are obviously downsides associated with keeping older versions of software
alive - like not receiving security updates, and potentially running software
that is incompatible and doesn't work.


### How nice would it have been if...

They could have just added an option to their app's settings like:


![signal](https://user-images.githubusercontent.com/2713116/219929440-b547fa63-d0bc-440e-a9f0-5595d2c14b83.png)


