# Introduction #

See /System/Library/CoreServices/SpringBoard.app/DisplayOrder.plist

This file can be modified to put finder in the "12" position by adding an entry similar to the others and appID com.googlecode.MobileFinder


# Details #

Here is one example:

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>buttonBar</key>
	<array>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobilephone</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobilemail</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobilesafari</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobileipod</string>
		</dict>
	</array>
	<key>iconList</key>
	<array>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.MobileSMS</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobilecal</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobileslideshow-Photos</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobileslideshow-Camera</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.youtube</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.stocks</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.Maps</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.weather</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobiletimer</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.calculator</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.mobilenotes</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.Preferences</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.googlecode.MobileFinder</string>
		</dict>
	</array>
	<key>special</key>
	<array>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.springboard</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.fieldtest</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.DemoApp</string>
		</dict>
		<dict>
			<key>displayIdentifier</key>
			<string>com.apple.MALogger</string>
		</dict>
	</array>
</dict>
</plist>

```