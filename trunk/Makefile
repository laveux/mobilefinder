CC=arm-apple-darwin-cc
LD=$(CC)
LDFLAGS=-lobjc -framework CoreFoundation -framework Foundation -framework UIKit -framework LayerKit

all:	Finder install

Finder:	MobileFinder.o MobileFinderApp.o MobileFinderBrowser.o
	$(LD) $(LDFLAGS) -o $@ $^

%.o:	%.m
		$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@

install:
		cp -f Finder ./Finder.App
clean:
		rm -f *.o MobileFinder

