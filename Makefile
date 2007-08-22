CC=arm-apple-darwin-cc
LD=$(CC)
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit

all:	Finder install

Finder:	MFMain.o MFApp.o MFBrowser.o MFSettings.o MobileStudio/MSAppLauncher.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

install:
		cp -f Finder ./Finder.app
clean:
		rm -f *.o MobileFinder MobileStudio/*.o

