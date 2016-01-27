# MobileFinder #
## Description ##

  * An official SDK version of MobileFinder is available! See [http://www.pixiotech.com](http://www.pixiotech.com)
  * This MobileFinder is **not** the official MobileFinder available from the App Store
  * MobileFinder is a filesystem navigator for use with iPhones which have been jailbroken running iPhone OS version 1.1.4 or lower.
  * MobileFinder is celebrating over **1,600,000** downloads to date!
  * MobileFinder is part of a larger collection of tools in the [MobileStudio](http://mobilestudio.googlecode.com)

## News ##
  * Version 2.0 of iPhone OS has removed support for many of the features that MobileFinder depends on. This has made transitioning MobileFinder's codebase to 2.0 very difficult. The official SDK version of MobileFinder is a complete rewrite, and thus has been tailored to make use of the features that are supported on 2.0. Unfortunately, a 2.0 version of MobileFinder based on the hacked SDK is not likely in the near future.
  * It has come to my attention that file operations in the system portion of the filesystem don't work on 1.1.3 and later due to access restrictions (I use 1.1.2, so I'm a bit behind). I will attempt to address this in MobileFinder 1.9. Until then, issuing the following commands in terminal or via an ssh client fixes the problem:
```
chmod 4755 /Applications/Finder.app/Finder
chmod 4755 /bin/cat /bin/chmod /usr/bin/chown /bin/cp /bin/ls
chmod 4755 /bin/mkdir /bin/mv /bin/rm /bin/rmdir /bin/unlink
```

## Icons ##
|![http://mobilefinder.googlecode.com/files/icon_shlomogoltz.png](http://mobilefinder.googlecode.com/files/icon_shlomogoltz.png)|![http://mobilefinder.googlecode.com/files/icon_tedroddy.png](http://mobilefinder.googlecode.com/files/icon_tedroddy.png)|![http://mobilefinder.googlecode.com/files/icon_jasonsmith.png](http://mobilefinder.googlecode.com/files/icon_jasonsmith.png)|![http://mobilefinder.googlecode.com/files/icon_vesabios.png](http://mobilefinder.googlecode.com/files/icon_vesabios.png)|![http://mobilefinder.googlecode.com/files/icon_nickbwheat.png](http://mobilefinder.googlecode.com/files/icon_nickbwheat.png)|![http://mobilefinder.googlecode.com/files/icon_jonathanlane6.png](http://mobilefinder.googlecode.com/files/icon_jonathanlane6.png)|![http://mobilefinder.googlecode.com/files/icon_mattstoker_1_3_0.png](http://mobilefinder.googlecode.com/files/icon_mattstoker_1_3_0.png)|![http://mobilefinder.googlecode.com/files/icon_mattstoker_0_9_0.png](http://mobilefinder.googlecode.com/files/icon_mattstoker_0_9_0.png)|![http://mobilefinder.googlecode.com/files/icon_mattstoker_0_5_0.png](http://mobilefinder.googlecode.com/files/icon_mattstoker_0_5_0.png)|
|:------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------|
|shlomogoltz                                                                                                                    |tedroddy                                                                                                                 |jasonsmith                                                                                                                   |vesabios                                                                                                                 | **nickbwheat**                                                                                                              |jonathanlane6                                                                                                                      |mattstoker                                                                                                                               |mattstoker                                                                                                                               |mattstoker                                                                                                                               |

Here are a few icons submitted by helpful folks. To use them:
  1. Download your favorite icon and rename it to "icon.png" LoWeRcAsE!
  1. Right click on "Finder.app" and select "Show Package Contents"
  1. Drag "icon.png" into the resulting window and confirm the replace
  1. Upload Finder.app to your iPhone!

Have a good icon?  Post it as an issue using the tab above!

## Features ##
  * Filesystem navigation with system file protection
  * **Application Launch** - Launches regular apps and enhanced MobileStudio apps
  * **Executable Launch** - Launches [Term-vt100](http://mobileterminal.googlecode.com) with executable files (eg. UNIX scripts)
  * **Send files by Email**
  * **Desktop synchronization** via ssh and rsync
  * File permissions modification and file detail viewer
  * Suspended operation for quick application launching and switching (currently turned off)
  * User modifiable associated file types launch file viewer apps
  * Icons differentiate different filetypes and includes image preview
  * Copy, Move, Delete operations (requires that /bin/mv and /bin/cp be installed)
  * Deletion trash area and button
  * File creation and renaming
  * Executable launch via system call (scripts, etc)
  * Sort by name or by kind
  * Preferences screen with filesystem browse settings
  * Open mode when launched by other apps in MobileStudio
  * Bookmarks area (requires that /bin/ln be installed)

## Planned Features ##
  * Launch Safari to open PDFs
  * Improve launch speed
  * Filesystem information pane
  * File Search
  * Improved visuals
  * SFTP/FTP/SMB connections with browser to allow file downloads/uploads

## Popularity ##
  * Over **1,100,000 downloads** since version 0.5.0 from Google Code and Installer.app!

## Usage Ideas ##
  * Email pictures full size
  * Synchronize files from desktop for quick access anywhere
  * Use Application Launch feature to break the 16 app barrier
  * Manage, view and edit your files
  * Use Copy/Paste to copy songs from your library in ~/Media/iTunes\_Control/Music to /Library/RingTones
  * Delete ~/Library sub-folders to reset your settings (fixed my MobileTimer when it stopped allowing me to add clocks)
  * Delete unwanted applications
  * Examine the inner workings of the filesystem and applications

## How To Help ##
  * Use [Issues List](http://code.google.com/p/mobilefinder/issues/list) to report bugs and give ideas for further development.  The issues system is built for bugs, but just go ahead an explain your idea in any of the fields.  We're humans, we understand. :) Please let us know if you are developing an app!
  * Write launchable viewers for Movies, Images, Audio, and Documents as part of MobileStudio
  * Link to us!

# Screenshots #
![http://mobilefinder.googlecode.com/files/MobileFinder_1_3_0_Springboard.png](http://mobilefinder.googlecode.com/files/MobileFinder_1_3_0_Springboard.png)
![http://mobilefinder.googlecode.com/files/MobileFinder_1_3_0.png](http://mobilefinder.googlecode.com/files/MobileFinder_1_3_0.png)
![http://mobilefinder.googlecode.com/files/MobileFinder_1_3_0_Settings.png](http://mobilefinder.googlecode.com/files/MobileFinder_1_3_0_Settings.png)
![http://mobilefinder.googlecode.com/files/MobileFinder_1_4_0_FileInfo.png](http://mobilefinder.googlecode.com/files/MobileFinder_1_4_0_FileInfo.png)

# Thanks #
  * [iPhone Dev Team](http://iphone.fiveforty.net/wiki/index.php?title=Main_Page) for compilation toolchain and MUCH more
  * [Launcher.app Dev Team](http://iphone.nullriver.com/beta/) for information on launching applications
  * [Nes.app Dev Team](http://iphone.natetrue.com/nesapp/) for ideas on settings screen