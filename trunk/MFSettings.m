/*
	MFSettings.m
	
	Finder settings changer control.
	
	Copyright 2007 Matt Stoker
	Begun: Aug/18/2007
	
	Thanks: iPhone Dev Team
	Compilation Toolchain and Hello World Applicaiton
	
	Thanks: NES.app Dev Team
	Basic idea for settings pane
	
	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; version 2
	of the License.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UITable.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UITextField.h>
#import <UIKit/UIImage.h>
#import <UIKit/UISliderControl.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UIKeyboard.h>
#import "MFSettings.h"
#import "MFApp.h"

@implementation MFSettings : UIView

- (id) initWithFrame: (struct CGRect)rect
	withSettingsPath: (NSString*)settingsPath
	withMFApp: (MFApp*)app
{
	//Init view with frame rect
	self = [super initWithFrame: rect];
	
	//Save pointer to app
	_app = app;
	[app retain];
	
	//Setup preferences table
	_prefsTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
	[_prefsTable setDataSource: self];
    [_prefsTable setDelegate: self];
	
	//Create control frame rects
	//TODO: Make these orientation-compatible
	CGRect switchRect = CGRectMake(rect.size.width - 114.0f, 9.0f, 296.0f - 200.0f, 32.0f);//[_prefsTable rowHeight]);
	CGRect sliderRect = CGRectMake(rect.size.width - 220.0f, 8.0f, 296.0f - 100.0f, 32.0f);//[_prefsTable rowHeight]);
	CGRect buttonRect = CGRectMake(rect.size.width - 84.0f, 9.0f, 64.0f, 32.0f);//[_prefsTable rowHeight]);
	float buttonBuffer = 4.0f;
	
	//Setup filesystem group
	//TODO: Make settings changes effective immediately
	_filesystemGroup = [[UIPreferencesTableCell alloc] init];
	[_filesystemGroup setTitle: @"File System"];
	[_filesystemGroup setIcon: [UIImage applicationImageNamed: @"Folder_32x32.png"]];	
	_startupDirCell = [[UIPreferencesTextTableCell alloc] init];	
	[_startupDirCell setTitle: @"Startup"];
	_startupInLastPathCell = [[UIPreferencesTableCell alloc] init];
	[_startupInLastPathCell setTitle: @"Start In Last Location"];
	_startupInLastPathSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_startupInLastPathCell addSubview: _startupInLastPathSwitch];
	_showHiddenFilesCell = [[UIPreferencesTableCell alloc] init];
	[_showHiddenFilesCell setTitle: @"Show Hidden Files"];
	_showHiddenFilesSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_showHiddenFilesCell addSubview: _showHiddenFilesSwitch];
	_showDotDotCell = [[UIPreferencesTableCell alloc] init];
	[_showDotDotCell setTitle: @"Show \"..\" Entry"];
	_showDotDotSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_showDotDotCell addSubview: _showDotDotSwitch];
	_sortFilesCell = [[UIPreferencesTableCell alloc] init];
	[_sortFilesCell setTitle: @"Sort By Kind"];
	_sortFilesSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_sortFilesCell addSubview: _sortFilesSwitch];
	_launchApplicationsCell = [[UIPreferencesTableCell alloc] init];
	[_launchApplicationsCell setTitle: @"Application Launch"];
	_launchApplicationsSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_launchApplicationsCell addSubview: _launchApplicationsSwitch];
	_launchExecutablesCell = [[UIPreferencesTableCell alloc] init];
	[_launchExecutablesCell setTitle: @"Executable Launch"];
	_launchExecutablesSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_launchExecutablesCell addSubview: _launchExecutablesSwitch];
	_systemFileAccessCell = [[UIPreferencesTableCell alloc] init];
	[_systemFileAccessCell setTitle: @"System File Access"];
	_systemFileAccessSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_systemFileAccessCell addSubview: _systemFileAccessSwitch];
	_closeAppCell = [[UIPreferencesTableCell alloc] init];
	[_closeAppCell setTitle: @"Close Finder Completely"];
	_closeAppButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_closeAppButton setAutosizesToFit: FALSE];
	[_closeAppButton setNavBarButtonStyle: 0];
	[_closeAppButton setTitle: @"Close"];
	[_closeAppButton addTarget: _app action: @selector(terminateWithSuccess) forEvents: 1];
	[_closeAppCell addSubview: _closeAppButton];
	
	//Setup sync group
	_syncGroup = [[UIPreferencesTableCell alloc] init];
	[_syncGroup setTitle: @"File Synchronization"];
	[_syncGroup setIcon: [UIImage applicationImageNamed: @"Sync_32x32.png"]];	
	_srcPathCell = [[UIPreferencesTextTableCell alloc] init];	
	[_srcPathCell setTitle: @"Local Path"];
	_dstPathCell = [[UIPreferencesTextTableCell alloc] init];	
	[_dstPathCell setTitle: @"Remote Path"];
	_serverAddressCell = [[UIPreferencesTextTableCell alloc] init];	
	[_serverAddressCell setTitle: @"Server"];
	_usernameCell = [[UIPreferencesTextTableCell alloc] init];	
	[_usernameCell setTitle: @"Username"];
			
	//Setup appearance group
	_appearenceGroup = [[UIPreferencesTableCell alloc] init];
	[_appearenceGroup setTitle: @"Appearance"];
	[_appearenceGroup setIcon: [UIImage applicationImageNamed: @"Finder_32x32.png"]];
		
	_browserRowHeightCell = [[UIPreferencesTableCell alloc] init];
	[_browserRowHeightCell setTitle: @"Row Size"];
	_browserRowHeightSlider = [[UISliderControl alloc] initWithFrame: sliderRect];
	[_browserRowHeightSlider setMinValue: 20];
	[_browserRowHeightSlider setMaxValue: 128];
	[_browserRowHeightSlider setShowValue: TRUE];
	[_browserRowHeightCell addSubview: _browserRowHeightSlider];
		
	_buttonStylesCell = [[UIPreferencesTableCell alloc] init];
	[_buttonStylesCell setTitle: @"Button Style"];
	_buttonStyleBlueButton = [[UINavBarButton alloc] initWithFrame: 
		CGRectMake(buttonRect.origin.x - buttonRect.size.width - buttonBuffer, buttonRect.origin.y, buttonRect.size.width, buttonRect.size.height)];
	[_buttonStyleBlueButton setAutosizesToFit: FALSE];
	[_buttonStyleBlueButton setNavBarButtonStyle: 3];
	[_buttonStyleBlueButton setTitle: @"Blue"];
	[_buttonStyleBlueButton addTarget: self action: @selector(setButtonStyleBlue) forEvents: 1];
	[_buttonStylesCell addSubview: _buttonStyleBlueButton];
	_buttonStyleRedButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_buttonStyleRedButton setAutosizesToFit: FALSE];
	[_buttonStyleRedButton setNavBarButtonStyle: 1];
	[_buttonStyleRedButton setTitle: @"Red"];
	[_buttonStyleRedButton addTarget: self action: @selector(setButtonStyleRed) forEvents: 1];
	[_buttonStylesCell addSubview: _buttonStyleRedButton];
		
	_barStylesCell = [[UIPreferencesTableCell alloc] init];
	[_barStylesCell setTitle: @"Bar Style"];
	_barStyleBlueButton = [[UINavBarButton alloc] initWithFrame: 
		CGRectMake(buttonRect.origin.x - buttonRect.size.width - buttonBuffer, buttonRect.origin.y, buttonRect.size.width, buttonRect.size.height)];
	[_barStyleBlueButton setAutosizesToFit: FALSE];
	[_barStyleBlueButton setNavBarButtonStyle: 0];
	[_barStyleBlueButton setTitle: @"Blue"];
	[_barStyleBlueButton addTarget: self action: @selector(setBarStyleBlue) forEvents: 1];
	[_barStylesCell addSubview: _barStyleBlueButton];
	_barStyleBlackButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_barStyleBlackButton setAutosizesToFit: FALSE];
	[_barStyleBlackButton setNavBarButtonStyle: 0];
	[_barStyleBlackButton setTitle: @"Black"];
	[_barStyleBlackButton addTarget: self action: @selector(setBarStyleBlack) forEvents: 1];
	[_barStylesCell addSubview: _barStyleBlackButton];
	
	//Setup file associations group
	_associationsGroup = [[UIPreferencesTableCell alloc] init];
	[_associationsGroup setTitle: @"File Associations"];
	[_associationsGroup setIcon: [UIImage applicationImageNamed: @"File_32x32.png"]];
	
	//Read in settings from settings plist
	_settingsPath = [[NSString alloc] initWithString: settingsPath];
	[self readSettings];

	//Put prefs table into settings pane
	[self addSubview: _prefsTable];
		
	return self;
}

- (void) dealloc
{	
	[_app release];
	
	[_filesystemGroup release];
	[_startupInLastPathCell release];
	[_startupDirCell release];
	[_showHiddenFilesCell release];
	[_showDotDotCell release];
	[_sortFilesCell release];
	[_launchApplicationsCell release];
	[_systemFileAccessCell release];	
	[_closeAppCell release];
	
	[_syncGroup release];
	[_srcPathCell release];	
	[_dstPathCell release];	
	[_serverAddressCell release];		
	[_usernameCell release];
	
	[_appearenceGroup release];
	[_browserRowHeightCell release];	
	[_buttonStylesCell release];
	[_barStylesCell release];
	
	[_associationsGroup release];
	[_associationsCells release];
	
	[_startupInLastPathSwitch release];
	[_showHiddenFilesSwitch release];
	[_showDotDotSwitch release];
	[_sortFilesSwitch release];
	[_launchApplicationsSwitch release];
	[_launchExecutablesSwitch release];
	[_systemFileAccessSwitch release];
	[_closeAppButton release];
	[_browserRowHeightSlider release];
	[_buttonStyleBlueButton release];
	[_buttonStyleRedButton release];
	[_barStyleBlueButton release];
	[_barStyleBlackButton release];
		
	[_applicationStartupPaths release];
	
	[_settingsPath release];

	[_prefsTable release];
	
	[super dealloc];
}

- (id) delegate
{
	return _delegate;
}

- (NSString*) startupPath
{
	return [[[_startupDirCell textField] text] stringByStandardizingPath];
}

- (NSString*) startupPathForApplication: (NSString*)appID
{
	return [_applicationStartupPaths objectForKey: appID];
}

- (BOOL) startupInLastPath
{
	return [_startupInLastPathSwitch value] != 0;
}

- (BOOL) showHiddenFiles
{
	return [_showHiddenFilesSwitch value] != 0;
}

- (BOOL) showDotDot
{
	return [_showDotDotSwitch value] != 0;
}

- (BOOL) sortFiles
{
	return [_sortFilesSwitch value] != 0;
}

- (BOOL) launchApplications
{
	return [_launchApplicationsSwitch value] != 0;
}

- (BOOL) launchExecutables
{
	return [_launchExecutablesSwitch value] != 0;
}

- (BOOL) systemFileAccess
{
	return [_systemFileAccessSwitch value] != 0;
}

- (NSString*) syncLocalPath
{
	return [[[_srcPathCell textField] text] stringByStandardizingPath];
}

- (NSString*) syncRemotePath
{
	return [[_dstPathCell textField] text];
}

- (NSString*) syncServerAddress
{
	return [[_serverAddressCell textField] text];
}

- (NSString*) syncUsername
{
	return [[_usernameCell textField] text];
}

- (int) browserRowHeight
{
	//HACK: Convert "long" return value to float by direct copy because of _objc_msgSend_fpret linker issue
	long value = [_browserRowHeightSlider value];
	float finalValue;
	memcpy(&finalValue, &value, sizeof(long));
	
	return finalValue;
}

- (int) buttonInactiveStyle
{
	return _buttonInactiveStyle;
}

- (int) buttonActiveStyle
{
	return _buttonActiveStyle;
}

- (int) buttonBackStyle
{
	return _buttonBackStyle;
}

- (int) barStyle
{
	return _barStyle;
}

- (NSArray*) fileTypeAssociations
{
	//Extract file type associations from the preferences cells, checking their validity
	NSMutableArray* fileTypeAssociations = [[NSMutableArray alloc] init];
	NSEnumerator *enumerator = [_associationsCells objectEnumerator];
	UIPreferencesTextTableCell* cell;
	while (cell = [enumerator nextObject])
	{
		NSString* fileTypeAssociation = [[cell textField] text];
		
		//Ensure that there is one and only one colon in the name.  Thats good enough for me!
		NSArray* fileTypeAssociationComponents = [fileTypeAssociation componentsSeparatedByString: @":"];
		if ([fileTypeAssociationComponents count] == 2)
		{
			[fileTypeAssociations addObject: [[NSString alloc] initWithString: fileTypeAssociation]];
		}
	}
		
	return [fileTypeAssociations autorelease];
}

- (void) setDelegate: (id)delegate
{
	[_delegate autorelease];
	_delegate = [delegate retain];
}

- (void) setStartupPath: (NSString*)startupPath
{
	BOOL isDirectory;
	if ([[NSFileManager defaultManager] fileExistsAtPath: [startupPath stringByStandardizingPath]
		isDirectory: &isDirectory] && isDirectory)
	{
		[[_startupDirCell textField] setText: startupPath];
	}
}

- (void) setStartupPath: (NSString*)path forApplication: (NSString*)appID
{
	[_applicationStartupPaths setObject: path forKey: appID];
}

- (void) setStartupInLastPath: (BOOL)startupInLastPath
{
	[_startupInLastPathSwitch setValue: (startupInLastPath == TRUE ? 1 : 0)];
}

- (void) setShowHiddenFiles: (BOOL)showHiddenFiles
{
	[_showHiddenFilesSwitch setValue: (showHiddenFiles == TRUE ? 1 : 0)];
}

- (void) setShowDotDot: (BOOL)showDotDot
{
	[_showDotDotSwitch setValue: (showDotDot == TRUE ? 1 : 0)];
}

- (void) setSortFiles: (BOOL)sortFiles
{
	[_sortFilesSwitch setValue: (sortFiles == TRUE ? 1 : 0)];
}

- (void) setLaunchApplications: (BOOL)launchApplications
{
	[_launchApplicationsSwitch setValue: (launchApplications == TRUE ? 1 : 0)];
}

- (void) setLaunchExecutables: (BOOL)launchExecutables
{
	[_launchExecutablesSwitch setValue: (launchExecutables == TRUE ? 1 : 0)];
}

- (void) setSystemFileAccess: (BOOL)systemFileAccess
{
	[_systemFileAccessSwitch setValue: (systemFileAccess == TRUE ? 1 : 0)];
}

- (void) setSyncLocalPath: (NSString*)localPath
{
	[[_srcPathCell textField] setText: localPath];
}

- (void) setSyncRemotePath: (NSString*)remotePath
{
	[[_dstPathCell textField] setText: remotePath];
}

- (void) setSyncServerAddress: (NSString*)serverAddress
{
	[[_serverAddressCell textField] setText: serverAddress];
}

- (void) setSyncUsername: (NSString*)username
{
	[[_usernameCell textField] setText: username];
}

- (void) setBrowserRowHeight: (int)value
{
	[_browserRowHeightSlider setValue: (float)value];
}

- (void) setButtonInactiveStyle: (int)style
{
	_buttonInactiveStyle = style;
	[_app applyStyles];
}
- (void) setButtonActiveStyle: (int)style
{
	_buttonActiveStyle = style;
	[_app applyStyles];
}
- (void) setButtonBackStyle: (int)style
{
	_buttonBackStyle = style;
	[_app applyStyles];
}
- (void) setButtonStyleBlue 
{ 
	[self setButtonInactiveStyle: 0]; 
	[self setButtonActiveStyle: 3];
	[self setButtonBackStyle: 2];
}
- (void) setButtonStyleRed 
{ 
	[self setButtonInactiveStyle: 0]; 
	[self setButtonActiveStyle: 1];
	[self setButtonBackStyle: 2];
}

- (void) setBarStyle: (int)style
{
	_barStyle = style;
}
- (void) setBarStyleBlue 
{ 
	[self setBarStyle: 0];
	[_app applyStyles]; 
}
- (void) setBarStyleBlack 
{ 
	[self setBarStyle: 1];
	[_app applyStyles];
}

- (void) setFileTypeAssociations: (NSArray*)fileTypeAssociations
{
	//Ensure we have a clean filetype cell array
	[_associationsCells release];				
	_associationsCells = [[NSMutableArray alloc] init];
	
	//Create a cell for adding a filetype
	UIPreferencesTextTableCell* emptyCell = [[UIPreferencesTextTableCell alloc] init];
	[_associationsCells addObject: emptyCell];
	[emptyCell release];
	
	//Create cells for all of the file type associations passed
	NSEnumerator* enumerator = [fileTypeAssociations objectEnumerator];
	NSString* fileTypeAssociation;
	while (fileTypeAssociation = [enumerator nextObject])
	{					
		UIPreferencesTextTableCell* cell = [[UIPreferencesTextTableCell alloc] init];
		[_associationsCells insertObject: cell 
			atIndex: [_associationsCells count] - 1];
		[[cell textField] setText: fileTypeAssociation];
		[cell release];			
	}
}

- (void) readSettings
{
	//Set defaults for simple settings
	[self setStartupPath: @"/Applications"];
	[self setStartupInLastPath: TRUE];
	[self setShowHiddenFiles: FALSE];
	[self setShowDotDot: FALSE];
	[self setSortFiles: TRUE];
	[self setLaunchApplications: TRUE];
	[self setLaunchExecutables: FALSE];
	[self setSystemFileAccess: TRUE];
	[self setSyncLocalPath: @"~/Library/MobileFinder/Sync"];
	[self setSyncRemotePath: @"~/iPhone"];
	[self setSyncServerAddress: @""];
	[self setSyncUsername: @""];
	[self setBrowserRowHeight: 48];
	[self setButtonStyleBlue];
	[self setBarStyleBlue];	
	
	//Ensure we have a clean application startup array
	[_applicationStartupPaths release];
	_applicationStartupPaths = [[NSMutableDictionary alloc] init];
		
	//Read in settings to replace defaults
	BOOL foundFileTypeAssociations = FALSE;
	BOOL foundStartPaths = FALSE;
	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath])
	{
		NSDictionary* settingsDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
		NSEnumerator* enumerator = [settingsDict keyEnumerator];
		NSString* currKey;
		while (currKey = [enumerator nextObject])
		{					
			if ([currKey isEqualToString: @"MFStartupDir"])
			{
				[self setStartupPath: [settingsDict valueForKey: currKey]];
			}
			else if ([currKey isEqualToString: @"MFApplicationStartupPaths"])
			{
				NSDictionary* applicationStartupPaths = [settingsDict objectForKey: currKey];
				[_applicationStartupPaths setDictionary: applicationStartupPaths];
			}
			else if ([currKey isEqualToString: @"MFStartupInLastPath"])
			{
				[self setStartupInLastPath: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFShowHiddenFiles"])
			{
				[self setShowHiddenFiles: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFShowDotDot"])
			{
				[self setShowDotDot: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFSortFiles"])
			{
				[self setSortFiles: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFLaunchApplications"])
			{
				[self setLaunchApplications: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFLaunchExecutables"])
			{
				[self setLaunchExecutables: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFSystemFileAccess"])
			{
				[self setSystemFileAccess: ([[settingsDict valueForKey: currKey] intValue] == 0 ? FALSE : TRUE)];
			}
			else if ([currKey isEqualToString: @"MFSyncLocalPath"])
			{
				[self setSyncLocalPath: [settingsDict valueForKey: currKey]];
			}
			else if ([currKey isEqualToString: @"MFSyncRemotePath"])
			{
				[self setSyncRemotePath: [settingsDict valueForKey: currKey]];
			}
			else if ([currKey isEqualToString: @"MFSyncServerAddress"])
			{
				[self setSyncServerAddress: [settingsDict valueForKey: currKey]];
			}
			else if ([currKey isEqualToString: @"MFSyncUsername"])
			{
				[self setSyncUsername: [settingsDict valueForKey: currKey]];
			}
			else if ([currKey isEqualToString: @"MFBrowserRowHeight"])
			{
				[self setBrowserRowHeight: [[settingsDict valueForKey: currKey] intValue]];
			}
			else if ([currKey isEqualToString: @"MFButtonInactiveStyle"])
			{
				[self setButtonInactiveStyle: [[settingsDict valueForKey: currKey] intValue]];
			}
			else if ([currKey isEqualToString: @"MFButtonActiveStyle"])
			{
				[self setButtonActiveStyle: [[settingsDict valueForKey: currKey] intValue]];
			}
			else if ([currKey isEqualToString: @"MFButtonBackStyle"])
			{
				[self setButtonBackStyle: [[settingsDict valueForKey: currKey] intValue]];
			}
			else if ([currKey isEqualToString: @"MFBarStyle"])
			{
				[self setBarStyle: [[settingsDict valueForKey: currKey] intValue]];
			}		
			else if ([currKey isEqualToString: @"MFFileTypeAssociations"])
			{
				//Get filetype associations and create cells for them, inserting behind the empty cell
				NSArray* fileTypeAssociations = [settingsDict objectForKey: currKey];
				if (fileTypeAssociations != nil && [fileTypeAssociations count] > 0)
				{
					[self setFileTypeAssociations: fileTypeAssociations];					
					foundFileTypeAssociations = TRUE;
				}
			}
		}		
	}
	
	//Init file type associaions with defaults, if none were found
	if (foundFileTypeAssociations == FALSE)
	{
		NSArray* defaultAssociations = [[NSArray alloc] initWithObjects:
			@"plist:com.google.code.MobileTextEdit",
			@"txt:com.google.code.MobileTextEdit",
			@"xml:com.google.code.MobileTextEdit"
			@"gif:com.google.code.MobilePreview",
			@"jpg:com.google.code.MobilePreview",
			@"jpeg:com.google.code.MobilePreview",
			@"png:com.google.code.MobilePreview",
			@"tiff:com.google.code.MobilePreview",
			@"gif:com.google.code.MobilePreview",
			nil];
		
		[self setFileTypeAssociations: defaultAssociations];
				
		[defaultAssociations release];
	}
	
	[_prefsTable reloadData];
}

- (void) writeSettings
{
	//Verify startup path setting
	BOOL startDirIsDirectory;	
	NSString* startDir = [[_startupDirCell textField] text];
	startDir = [startDir stringByStandardizingPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath: startDir isDirectory: &startDirIsDirectory] == FALSE || 
		startDirIsDirectory == FALSE)
	{
		startDir = [[NSString alloc] initWithString: @"/Applications"]; 
	}
	startDir = [startDir stringByAbbreviatingWithTildeInPath];
	
	//Extract plist-able versions of other settings
	NSString* startupInLastPath = [self startupInLastPath] == FALSE ? @"0" : @"1";
	NSString* showHiddenFilesValue = [self showHiddenFiles] == FALSE ? @"0" : @"1";
	NSString* showDotDotValue = [self showDotDot] == FALSE ? @"0" : @"1";
	NSString* sortFilesValue = [self sortFiles] == FALSE ? @"0" : @"1";
	NSString* launchApplicationsValue = [self launchApplications] == FALSE ? @"0" : @"1";
	NSString* launchExecutablesValue = [self launchExecutables] == FALSE ? @"0" : @"1";
	NSString* systemFileAccessValue = [self systemFileAccess] == FALSE ? @"0" : @"1";
	NSString* syncLocalPath = [self syncLocalPath];
	NSString* syncRemotePath = [self syncRemotePath];
	NSString* syncServerAddress = [self syncServerAddress];
	NSString* syncUsername = [self syncUsername];
	NSString* browserRowHeight = [[NSNumber numberWithInt: [self browserRowHeight]] stringValue];
	NSString* buttonInactiveStyle = [[NSNumber numberWithInt: [self buttonInactiveStyle]] stringValue];
	NSString* buttonActiveStyle = [[NSNumber numberWithInt: [self buttonActiveStyle]] stringValue];
	NSString* buttonBackStyle = [[NSNumber numberWithInt: [self buttonBackStyle]] stringValue];
	NSString* barStyle = [[NSNumber numberWithInt: [self barStyle]] stringValue];
	NSArray* fileTypeAssociations = [self fileTypeAssociations];
	NSDictionary* applicationStartupPaths = _applicationStartupPaths;
	
	//Build settings dictionary
	NSDictionary* settingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		startDir, @"MFStartupDir",
		applicationStartupPaths, @"MFApplicationStartupPaths",
		startupInLastPath, @"MFStartupInLastPath",
		showHiddenFilesValue, @"MFShowHiddenFiles",
		showDotDotValue, @"MFShowDotDot",
		sortFilesValue, @"MFSortFiles",
		launchApplicationsValue, @"MFLaunchApplications",
		launchExecutablesValue, @"MFLaunchExecutables",
		systemFileAccessValue, @"MFSystemFileAccess",
		syncLocalPath, @"MFSyncLocalPath",
		syncRemotePath, @"MFSyncRemotePath",
		syncServerAddress, @"MFSyncServerAddress",
		syncUsername, @"MFSyncUsername",
		browserRowHeight, @"MFBrowserRowHeight",
		buttonInactiveStyle, @"MFButtonInactiveStyle",
		buttonActiveStyle, @"MFButtonActiveStyle",
		buttonBackStyle, @"MFButtonBackStyle",
		barStyle, @"MFBarStyle",
		fileTypeAssociations, @"MFFileTypeAssociations",
		nil];
	
	//Seralize settings dictionary
	NSString* error;
	NSData* rawPList = [NSPropertyListSerialization dataFromPropertyList: settingsDict		
		format: NSPropertyListXMLFormat_v1_0
		errorDescription: &error];
	
	//Write settings plist file
	[rawPList writeToFile: _settingsPath atomically: YES];
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 8;
}

- (int) preferencesTable: (UIPreferencesTable*)table 
	numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 0;
		case 1: return 9;
		case 2: return 0;
		case 3: return 4;
		case 4: return 0;
		case 5: return 3;
		case 6: return 0;
		case 7: return [_associationsCells count];
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
	cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _filesystemGroup;
		case 1: return _filesystemGroup;
		case 2: return _syncGroup;
		case 3: return _syncGroup;
		case 4: return _appearenceGroup;
		case 5: return _appearenceGroup;
		case 6: return _associationsGroup;
		case 7: return _associationsGroup;
		default: return nil;
	}
} 

- (BOOL) preferencesTable: (UIPreferencesTable*)table 
    isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return TRUE;
		case 1: return FALSE;
		case 2: return TRUE;
		case 3: return FALSE;
		case 4: return TRUE;
		case 5: return FALSE;
		case 6: return TRUE;
		case 7: return FALSE;
		default: return TRUE;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table 
	heightForRow: (int)row 
	inGroup: (int)group 
	withProposedHeight: (float)proposed 
{
	float groupLabelSize = 32.0f;
	
	switch (group)
	{
		case 0: return groupLabelSize;
		case 2: return groupLabelSize;
		case 4: return groupLabelSize;
		case 6: return groupLabelSize;
		default: return proposed;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
    cellForRow: (int)row 
    inGroup: (int)group 
{
	switch (group)
	{
		case 0: return _filesystemGroup;
		case 1:
			switch (row)
			{
				case 0:	return _startupDirCell;
				case 1: return _startupInLastPathCell;
				case 2: return _showHiddenFilesCell;
				case 3: return _showDotDotCell;
				case 4: return _sortFilesCell;
				case 5: return _launchApplicationsCell;
				case 6: return _launchExecutablesCell;
				case 7: return _systemFileAccessCell;
				case 8: return _closeAppCell;
			}
		case 2: return _syncGroup;
		case 3:
			switch (row)
			{
				case 0:	return _srcPathCell;
				case 1:	return _dstPathCell;
				case 2:	return _serverAddressCell;
				case 3:	return _usernameCell;
			}
		case 4: return _appearenceGroup;
		case 5:
			switch (row)
			{
				case 0:	return _browserRowHeightCell;
				case 1:	return _buttonStylesCell;
				case 2:	return _barStylesCell;
			}
		case 6: return _associationsGroup;
		case 7: return [_associationsCells objectAtIndex: row];		
		default: return nil;
	}
}

@end