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

Once you've got keytool, apksigner and docker installed, run build.sh in this
repo to build your own APK, transfer it to your device and perform the hairy
task of: a) delete signal, b) install the new apk, c) restore your backup.

I don't recommend mixing and matching different backup file versions with
different versions of Signal.


### Rationale

Frankly, I am hoping this will let me hold onto the SMS functionality in Signal
for a bit longer. But we'll see how that goes.

There are obviously downsides associated with keeping older versions of software
alive - like not receiving security updates, and potentially running software
that is incompatible and doesn't work. But worst case scenario I can install
a legit version of Signal from upstream and restore a backup.


### How nice would it have been if...

They could have just added an option to their app's settings like:


![signal](https://user-images.githubusercontent.com/2713116/219929440-b547fa63-d0bc-440e-a9f0-5595d2c14b83.png)


