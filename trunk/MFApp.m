/*
	MFApp.m
	
	Finder application UI.
	
	Copyright 2007 Matt Stoker
	Begun: Aug/10/2007
	
	Thanks: iPhone Dev Team
	Compilation Toolchain and Hello World Applicaiton
	
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

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UINavBarButton.h>
#import <UIKit/UIGradientBar.h>
#import <UIKit/UITransitionView.h>
#import "MFApp.h"
#import "MFBrowser.h"
#import "MFSettings.h"
#import "MobileStudio/MSAppLauncher.h"

/*
Thanks: MobileTerminal old code
typedef struct __GSEvent 
{
	long i0; 
	long i1;
	long eventType;
	long i3;
	long i4;
	long i5;
} __GSEvent;
*/

@implementation MFApp : UIApplication

- (void) runApplication
{   
	//Set applicationID
	_applicationID = [@"com.googlecode.MobileFinder" copy];
	
	//Set private global data
	_appLibraryPath = [[self userLibraryDirectory] 
		stringByAppendingPathComponent: @"MobileFinder"];
	[_appLibraryPath retain];
	_trashPath = [_appLibraryPath 
		stringByAppendingPathComponent: @"Trash"];
	[_trashPath retain];
	_bookmarksPath = [_appLibraryPath 
		stringByAppendingPathComponent: @"Bookmarks"];
	[_bookmarksPath retain];
	_settingsPath = [[[[self userLibraryDirectory]
		stringByAppendingPathComponent: @"Preferences"]
		stringByAppendingPathComponent: _applicationID]
		stringByAppendingPathExtension: @"plist"];
	[_settingsPath retain];
	
	//Ensure library directories exsist
	[[NSFileManager defaultManager] createDirectoryAtPath: _appLibraryPath attributes: nil];
	[[NSFileManager defaultManager] createDirectoryAtPath: _trashPath attributes: nil];
	[[NSFileManager defaultManager] createDirectoryAtPath: _bookmarksPath attributes: nil];
	
	//Setup content view
    struct CGRect screenRect = [UIHardware fullScreenApplicationContentRect];
    screenRect.origin.x = 0.0;
	screenRect.origin.y = 0.0f;
    _contentView = [[UITransitionView alloc] initWithFrame: screenRect];
    
	//Control sizes
	float navBarWidth = screenRect.size.width;
	float navBarHeight = 74.0f;
	float fileOpBarWidth = screenRect.size.width;
	float fileOpBarHeight = 46.0f;
	
	//Setup the main transition view
	CGRect viewRect = CGRectMake(0.0f, 0.0f, screenRect.size.width, screenRect.size.height - navBarHeight - fileOpBarHeight);
	CGRect mainViewRect = viewRect;
	mainViewRect.origin.y = navBarHeight;
	_mainView = [[UITransitionView alloc] initWithFrame: mainViewRect];
	[_mainView setDelegate: self];
	[_contentView addSubview: _mainView];
	
	//Setup the settings pane (and load settings)
	_settings = [[MFSettings alloc] initWithFrame: viewRect	withSettingsPath: _settingsPath	withMFApp: self];
	[_settings setDelegate: self];
	[_settings readSettings];
	
	//Setup the file browser
	_browser = [[MFBrowser alloc] initWithApplication: self withAppID: _applicationID withFrame: viewRect];
	[_browser setDelegate: self];
	
	//Setup navigation bars
	_navBarFrame = CGRectMake(0.0, 0.0, navBarWidth, navBarHeight);
	_fileOpBarFrame = CGRectMake(0.0f, screenRect.size.height - fileOpBarHeight, fileOpBarWidth, fileOpBarHeight);
	
	//Make the browser active at start
	//TODO: no longer suspends! Why!?!
	//[self makeSettingsActive];
	[self makeBrowserActive];
	
	//Create window and other initalization tasks
	[self resumeApplication];
}

- (void) dealloc
{
	//Release UI elements
	[_window release];
	[_contentView release];
	[_mainView release];
	[_browser release];
	[_settings release];
	[_navBar release];
	[_backButton release];
	[_finderButton release];
	[_settingsButton release];
	[_homeButton release];
	[_fileOpBar release];
	[_moveButton release];
	[_copyButton release];
	[_deleteButton release];
	[_specialButton release];
	[_newButton release];
	
	//Release private data
	[_applicationID release];
	[_launchingApplicationID release];
	[_appLibraryPath release];
	[_settingsPath release];
	[_bookmarksPath release];
	[_trashPath release];
	[_pathSelectedForFileOp release];
	
	[super dealloc];
}

- (void) resumeApplication
{
	//If already resumed, just return
	if (_window != nil)
		return;		
	
	//Get launch info from plist
	[self getLaunchInfo];
	
	//Read settings file
	[_settings readSettings];
	
	//If launched by an application, enter mandatory launch mode
	if (_launchingApplicationID != nil)
	{
		[_browser setMandatoryLaunchApplication: _launchingApplicationID];
		[_browser openPath: [_settings startupPathForApplication: _launchingApplicationID]];
		
	}	
	//Change to the current startup path 
	else
	{
		[_browser setMandatoryLaunchApplication: nil];
		[_browser openPath: [_settings startupPath]];
	}
	
	//Initialize window
	_window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	[_window setContentView: _contentView];
	[_window orderFront: self];
	[_window makeKey: self];
	[_window _setHidden: NO];
		
	//Notify system of successful resume
	[self applicationDidResume];
}

- (void) suspendApplication
{
	//If already suspended, just return
	if (_window == nil)
		return;
	
	//Save path for application if in mandatory open mode
	if (_launchingApplicationID != nil)
	{
		[_settings setStartupPath: [_browser currentDirectory] forApplication: _launchingApplicationID];
	}
	else 
	{
		//Change the startup path if the setting is true
		if ([_settings startupInLastPath] == TRUE)
		{
			[_settings setStartupPath: [_browser currentDirectory]];
		}
	}
	
	//Save settings
	[_settings writeSettings];
	
	//Release window
	[_window release];
	_window = nil;
		
	//TODO: Need to "didSuspend"?
}

- (void) getLaunchInfo
{
	//Get launch information
	//If we were launched using another AppLauncher-aware program, enter the mandatory app launch mode
	NSDictionary* launchInfo = [MSAppLauncher readLaunchInfoForAppID: _applicationID
		withApplication: self
		deletingLaunchPList: TRUE];
	if (launchInfo != nil)
	{
		[_launchingApplicationID autorelease];
		_launchingApplicationID = [launchInfo valueForKey: @"MSLaunchingAppIdentifier"];
		[_launchingApplicationID retain];
	}
	else
	{
		[_launchingApplicationID autorelease];
		_launchingApplicationID = nil;
	}
}

- (void) createNavigationBar
{
	//Control sizes
	float navBarButtonHeight = 32.0f;
	float navBarSouthBuffer = 5.0f;
	float navBarSideButtonBuffer = 4.0f;
	float navBarButtonBuffer = 4.0f;
	float backButtonWidth = 52.0f;
	float appleButtonWidth = 32.0f;
	float homeButtonWidth = 32.0f;
	float finderButtonWidth = 68.0f;
	float settingsButtonWidth = 68.0f;
	
	//Setup navigation bar
	[_navBar release];
	_navBar = [[UINavigationBar alloc] initWithFrame: _navBarFrame];
	[_navBar setBarStyle: [_settings barStyle]];
	[_navBar setDelegate: self];
	
	//Setup navigation bar buttons
	_backButton = [_navBar createButtonWithContents: @"Back" 
		width: backButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonBackStyle] 
		isRight: FALSE];
	[_backButton setFrame: CGRectMake(
		navBarSideButtonBuffer,
		_navBarFrame.size.height - navBarButtonHeight - navBarSouthBuffer, 
		backButtonWidth, navBarButtonHeight)];
	[_backButton addTarget: self action: @selector(backButtonPressed) forEvents: 1];
	[_navBar addSubview: _backButton];
	
	_finderButton = [_navBar createButtonWithContents: @"Finder" 
		width: finderButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_finderButton setFrame: CGRectMake(
		_navBarFrame.size.width / 2.0f - finderButtonWidth - navBarButtonBuffer / 2.0f,
		_navBarFrame.size.height - navBarButtonHeight - navBarSouthBuffer, 
		finderButtonWidth, navBarButtonHeight)];
	[_finderButton addTarget: self action: @selector(makeBrowserActive) forEvents: 1];
	[_navBar addSubview: _finderButton];
	
	_settingsButton = [_navBar createButtonWithContents: @"Settings" 
		width: settingsButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_settingsButton setFrame: CGRectMake(
		_navBarFrame.size.width / 2.0f + navBarButtonBuffer / 2.0f,
		_navBarFrame.size.height - navBarButtonHeight - navBarSouthBuffer, 
		settingsButtonWidth, navBarButtonHeight)];
	[_settingsButton addTarget: self action: @selector(makeSettingsActive) forEvents: 1];
	[_navBar addSubview: _settingsButton];	
	
	_appleButton = [_navBar createButtonWithContents: [NSString stringWithUTF8String: "\uf8ff"]
		width: appleButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_appleButton setFrame: CGRectMake(
		_navBarFrame.size.width - homeButtonWidth - navBarButtonBuffer - appleButtonWidth - navBarSideButtonBuffer,
		_navBarFrame.size.height - navBarButtonHeight - navBarSouthBuffer, 
		appleButtonWidth, navBarButtonHeight)];
	[_appleButton addTarget: self action: @selector(appleButtonPressed) forEvents: 1];
	[_navBar addSubview: _appleButton];
	
	_homeButton = [_navBar createButtonWithContents: @"~" 
		width: homeButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_homeButton setFrame: CGRectMake(
		_navBarFrame.size.width - homeButtonWidth - navBarSideButtonBuffer,
		_navBarFrame.size.height - navBarButtonHeight - navBarSouthBuffer, 
		homeButtonWidth, navBarButtonHeight)];
	[_homeButton addTarget: self action: @selector(homeButtonPressed) forEvents: 1];
	[_navBar addSubview: _homeButton];
	
	//Add nav bar to view
	[_contentView addSubview: _navBar];
}

- (void) createFileOpBar
{
	//Control sizes
	float fileOpBarNorthBuffer = 8.0f;
	float fileOpBarButtonHeight = 32.0f;
	float fileOpBarButtonBuffer = 1.0f;
	float fileOpBarButtonGroupBuffer = 0.0f;
	float moveButtonWidth = 59.0f;
	float copyButtonWidth = 59.0f;
	float deleteButtonWidth = 80.0f;
	float infoButtonWidth = 59.0f;
	float newButtonWidth = 59.0f;
	
	//Setup file operations bar
	[_fileOpBar release];
	_fileOpBar = [[UINavigationBar alloc] initWithFrame: _fileOpBarFrame];
	[_fileOpBar setBarStyle: [_settings barStyle]];
		
	//Setup file operation buttons
	_copyButton = [_fileOpBar createButtonWithContents: @"Copy" 
		width: copyButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_copyButton setFrame: CGRectMake(
		_fileOpBarFrame.size.width / 2.0f - deleteButtonWidth / 2.0f - moveButtonWidth - copyButtonWidth - fileOpBarButtonBuffer * 2.0 - fileOpBarButtonGroupBuffer,
		fileOpBarNorthBuffer, 
		copyButtonWidth, fileOpBarButtonHeight)];
	[_newButton setAutosizesToFit: FALSE];
	[_copyButton addTarget: self action: @selector(copyButtonPressed) forEvents: 1];
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _copyButton];
	
	_moveButton = [_fileOpBar createButtonWithContents: @"Move" 
		width: moveButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_moveButton setFrame: CGRectMake(
		_fileOpBarFrame.size.width / 2.0f - deleteButtonWidth / 2.0f - moveButtonWidth - fileOpBarButtonBuffer * 1.0 - fileOpBarButtonGroupBuffer, 
		fileOpBarNorthBuffer, 
		moveButtonWidth, fileOpBarButtonHeight)];
	[_moveButton setAutosizesToFit: FALSE];
	[_moveButton addTarget: self action: @selector(moveButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _moveButton];
	
	_deleteButton = [_fileOpBar createButtonWithContents: @"Delete" 
		width: deleteButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_deleteButton setFrame: CGRectMake(
		_fileOpBarFrame.size.width / 2.0f - deleteButtonWidth / 2.0, 
		fileOpBarNorthBuffer, 
		deleteButtonWidth, fileOpBarButtonHeight)];
	[_deleteButton setAutosizesToFit: FALSE];
	[_deleteButton addTarget: self action: @selector(deleteButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _deleteButton];
		
	_newButton = [_fileOpBar createButtonWithContents: @"New" 
		width: newButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_newButton setFrame: CGRectMake(
		_fileOpBarFrame.size.width / 2.0f + deleteButtonWidth / 2.0f + fileOpBarButtonBuffer * 1.0 + fileOpBarButtonGroupBuffer, 
		fileOpBarNorthBuffer, 
		newButtonWidth, fileOpBarButtonHeight)];
	[_newButton setAutosizesToFit: FALSE];
	[_newButton addTarget: self action: @selector(newButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _newButton];
	
	_specialButton = [_fileOpBar createButtonWithContents: @"Info" 
		width: infoButtonWidth 
		barStyle: [_settings barStyle]
		buttonStyle: [_settings buttonInactiveStyle] 
		isRight: FALSE];
	[_specialButton setFrame: CGRectMake(
		_fileOpBarFrame.size.width / 2.0f + deleteButtonWidth / 2.0f + newButtonWidth + fileOpBarButtonBuffer * 2.0 + fileOpBarButtonGroupBuffer, 
		fileOpBarNorthBuffer, 
		infoButtonWidth, fileOpBarButtonHeight)];
	[_specialButton setAutosizesToFit: FALSE];
	[_specialButton addTarget: self action: @selector(infoButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _specialButton];
	
	[_contentView addSubview: _fileOpBar];
}

- (void) backButtonPressed
{
	if (_activeView == _browser)
		[_browser changeDirectoryToLast];
	else //if (_activeView == _settings)
		[self makeBrowserActive];
	
	[self updateBackButton];
}

- (void) appleButtonPressed
{
	[_browser openPath: _appLibraryPath];
}

- (void) homeButtonPressed
{
	[_browser changeDirectoryToHome];
}

- (void) makeBrowserActive
{
	if (_activeView == _browser)
		return;
		
	//Update settings
	[_browser setShowHiddenFiles: [_settings showHiddenFiles]];
	[_browser setShowDotDotRow: [_settings showDotDot]];
	[_browser setSortFiles: [_settings sortFiles]];
	[_browser setLaunchApplications: [_settings launchApplications]];
	[_browser setLaunchExecutables: [_settings launchExecutables]];
	[_browser setSystemFileAccess: [_settings systemFileAccess]];
	[_browser setFileTypeAssociations: [_settings fileTypeAssociations]];
	//TODO: Buffer height setting or constant
	[_browser setRowHeight: (float)[_settings browserRowHeight] bufferHeight: 4.0f];
	[_browser refreshFileView];
	
	//Update views, buttons and bars
	[_mainView transition: 2 toView: _browser];
	_activeView = _browser;
	[self applyStyles];
}

- (void) makeSettingsActive
{
	if (_activeView == _settings)
		return;
	
	//Update views, buttons and bars
	[_mainView transition: 1 toView: _settings];
	_activeView = _settings;
	[self applyStyles];
}

- (void) applyStyles
{
	//Apply bar styles by recreating them
	[self createNavigationBar];
	[self createFileOpBar];
	
	//Reset bar and button settings to appropriate setting for view type	
	if (_activeView == _browser)
	{
		//Set navBar state
		[_finderButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_settingsButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[self updateBackButton];
		[_appleButton setEnabled: TRUE];
		[_homeButton setEnabled: TRUE];
		
		//Set fileOp bar state
		[self resetFileOpButtons];
		
		//Update prompt
		[self updatePrompt];
	}
	else if (_activeView == _settings)
	{
		//Set navBar state
		[_finderButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[_settingsButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[self updateBackButton];
		[_appleButton setEnabled: FALSE];
		[_homeButton setEnabled: FALSE];
		
		//Set fileOp bar state
		[self resetFileOpButtons];
		[_deleteButton setEnabled: FALSE];
		[_moveButton setEnabled: FALSE];
		[_copyButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		[_specialButton setEnabled: FALSE];
		
		//Set prompt title for settings
		[_navBar setPrompt: @"Settings"];
	}
}

- (void) updateBackButton
{
	if (_activeView == _browser)
	{
		[_backButton setTitle: @"Up"];
		if ([[_browser currentDirectory] isEqualToString: @"/"] ||
			([_settings systemFileAccess] == FALSE && [[_browser currentDirectory] isEqualToString: @"/Applications"]))
		{
			[_backButton setEnabled: FALSE];
		}
		else
			[_backButton setEnabled: TRUE];
	}
	else //if (_activeView == _settings)
	{
		[_backButton setTitle: @"Back"];
	}
}

- (void) updatePrompt
{
	//Update nav bar prompt to reflect directory
	NSString* prompt;
	if (_launchingApplicationID == nil)
	{
		NSString* currentDirectory = [_browser currentDirectory];
		
		if ([_settings systemFileAccess] == FALSE && [currentDirectory isEqualToString: @"/Applications"])
			prompt = @"Applications - Enable System Access for /";
		else
			prompt = [currentDirectory stringByAbbreviatingWithTildeInPath];
	}
	else
	{
		prompt = [[[NSString string] 
			stringByAppendingString: @"Opening in: "]
			stringByAppendingString: _launchingApplicationID];
	}
	
	//TODO: Abbreviate prompt
	
	[_navBar setPrompt: prompt];
}

- (void) resetFileOpButtons
{
	if (_copyButton != nil)
	{
		[_copyButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[_copyButton setTitle: @"Copy"];
		[_copyButton setEnabled: TRUE];
	}
	if (_moveButton != nil)
	{
		[_moveButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[_moveButton setTitle: @"Move"];
		[_moveButton setEnabled: TRUE];
	}
	if (_deleteButton != nil)
	{
		[_deleteButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[_deleteButton setTitle: @"Delete"];
		[_deleteButton setEnabled: TRUE];
	}
	if (_newButton != nil)
	{
		[_newButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[_newButton setTitle: @"New"];
		[_newButton setEnabled: TRUE];
	}
	if (_specialButton != nil)
	{
		[_specialButton setNavBarButtonStyle: [_settings buttonInactiveStyle]];
		[_specialButton setTitle: @"Misc"];
		[_specialButton setEnabled: TRUE];
	}
}

- (void) copyButtonPressed
{
	if ([[_copyButton title] isEqualToString: @"Copy"] && [_browser currentSelectedPath] != nil)
	{ 
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_copyButton setTitle: @"Cancel"];
		[_moveButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_moveButton setTitle: @"Paste"];
		[_deleteButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		[_specialButton setEnabled: FALSE];
		
		[_pathSelectedForFileOp autorelease];
		_pathSelectedForFileOp = [[_browser currentSelectedPath] copy];
	}
	else if ([[_copyButton title] isEqualToString: @"Paste"])
	{
		[_browser 
			sendSrcPath: _pathSelectedForFileOp 
			toDstPath: [_browser currentDirectory]
			byFileOp: MFMoveFile];
		[self resetFileOpButtons];
	}
	else if ([[_copyButton title] isEqualToString: @"Delete"])
	{
		NSString* currentSelectedPath = [_browser currentSelectedPath];
		if (currentSelectedPath != nil)
		{
			if ([currentSelectedPath hasPrefix: _trashPath])
				[_browser deletePath: currentSelectedPath];
			else
			{
				//Ensure that the trash exists
				[_browser makeDirectoryAtPath: _trashPath];
				
				//Make path for destination in trash
				NSString* trashedPathPath = [_trashPath stringByAppendingPathComponent: [currentSelectedPath lastPathComponent]];
				
				//If there is already something in the trash with this name, rename destination
				while ([[NSFileManager defaultManager] fileExistsAtPath: trashedPathPath])
				{
					trashedPathPath = [trashedPathPath stringByAppendingString: @"_RemoveMe"];
				}
				
				//Send file to trash
				[_browser 
					sendSrcPath: currentSelectedPath 
					toDstPath: trashedPathPath
					byFileOp: MFMoveFile];
			}
		}
		[self resetFileOpButtons];
	}
	else if ([[_copyButton title] isEqualToString: @"File"])
	{
		[_browser makeFileAtPath: @"untitled file"];
		[self resetFileOpButtons];
	}
	else if ([[_copyButton title] isEqualToString: @"Info"] && [_browser currentSelectedPath] != nil)
	{
		[_browser makeFileInfoActive];
		[_backButton setEnabled: TRUE];
		[self resetFileOpButtons];
	}	
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) moveButtonPressed
{
	if ([[_moveButton title] isEqualToString: @"Move"] && [_browser currentSelectedPath] != nil)
	{ 
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_copyButton setTitle: @"Paste"];
		[_moveButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_moveButton setTitle: @"Cancel"];
		[_deleteButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		[_specialButton setEnabled: FALSE];
		
		[_pathSelectedForFileOp autorelease];
		_pathSelectedForFileOp = [[_browser currentSelectedPath] copy];
	}
	else if ([[_moveButton title] isEqualToString: @"Paste"])
	{
		[_browser 
			sendSrcPath: _pathSelectedForFileOp 
			toDstPath: [_browser currentDirectory]
			byFileOp: MFCopyFile];
		[self resetFileOpButtons];
	}
	else if ([[_moveButton title] isEqualToString: @"Folder"])
	{
		[_browser makeDirectoryAtPath: @"untitled folder"];
		[self resetFileOpButtons];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) deleteButtonPressed
{
	if ([[_deleteButton title] isEqualToString: @"Delete"] && [_browser currentSelectedPath] != nil)
	{
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_copyButton setTitle: @"Delete"];
		[_moveButton setEnabled: FALSE];
		[_deleteButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_deleteButton setTitle: @"Cancel"];
		[_newButton setEnabled: FALSE];
		[_specialButton setEnabled: FALSE];
	}
	else if ([[_deleteButton title] isEqualToString: @"Bookmark"] && [_browser currentSelectedPath] != nil)
	{
		[self resetFileOpButtons];
		
		//Ensure that the trash exists
		[_browser makeDirectoryAtPath: _bookmarksPath];
				
		//Build paths for link
		NSString* currentSelectedPath = [_browser currentSelectedPath];
		NSString* destPath = [_bookmarksPath stringByAppendingPathComponent: [currentSelectedPath lastPathComponent]];		
		while ([[NSFileManager defaultManager] fileExistsAtPath: destPath])
		{
			destPath = [destPath stringByAppendingString: @"_2"];
		}
		
		//Create link
		[_browser 
			sendSrcPath: currentSelectedPath 
			toDstPath: destPath
			byFileOp: MFLinkFile];
	}
	else if ([[_deleteButton title] isEqualToString: @"Sync"])
	{
		NSString* echoStatusCommand = [[[NSString string]
			stringByAppendingString: @"echo "]
			stringByAppendingString: @"'...'"];
		NSString* syncRemoteCommand = [[[[[[[[[NSString string]
			stringByAppendingString: @"/usr/bin/rsync -avz --progress "]
			stringByAppendingString: [_settings syncLocalPath]]
			stringByAppendingString: @"/ "]
			stringByAppendingString: [_settings syncUsername]]
			stringByAppendingString: @"\@"]
			stringByAppendingString: [_settings syncServerAddress]]
			stringByAppendingString: @":"]
			stringByAppendingString: [_settings syncRemotePath]];
		NSString* syncLocalCommand = [[[[[[[[[NSString string]
			stringByAppendingString: @"/usr/bin/rsync -avz --progress "]
			stringByAppendingString: [_settings syncUsername]]
			stringByAppendingString: @"\@"]
			stringByAppendingString: [_settings syncServerAddress]]
			stringByAppendingString: @":"]
			stringByAppendingString: [_settings syncRemotePath]]
			stringByAppendingString: @"/ "]
			stringByAppendingString: [_settings syncLocalPath]];
		[_browser launchApplication: @"com.googlecode.mobileterminal.Term-vt100" withArgs: [NSArray arrayWithObjects:
			@"echo 'MobileFinder is syncing...'",
			[@"echo " stringByAppendingString: [_browser quoteString: syncRemoteCommand]],
			syncRemoteCommand,
			[@"echo " stringByAppendingString: [_browser quoteString: syncLocalCommand]],
			syncLocalCommand,
			@"echo 'Sync completed. Exiting...'",
			@"sleep 4",
			@"exit",
			nil]];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) newButtonPressed
{
	if ([[_newButton title] isEqualToString: @"New"])
	{
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_copyButton setTitle: @"File"];
		[_moveButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_moveButton setTitle: @"Folder"];
		if ([_browser currentSelectedPath] != nil)
		{
			[_deleteButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
			[_deleteButton setTitle: @"Bookmark"];
		}
		else
		{
			[_deleteButton setEnabled: FALSE];
		}
		[_newButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_newButton setTitle: @"Cancel"];
		[_specialButton setEnabled: FALSE];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) infoButtonPressed
{
	if ([[_specialButton title] isEqualToString: @"Misc"])
	{
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_copyButton setTitle: @"Info"];
		[_moveButton setEnabled: FALSE];
		[_deleteButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_deleteButton setTitle: @"Sync"];
		[_newButton setEnabled: FALSE];
		[_specialButton setNavBarButtonStyle: [_settings buttonActiveStyle]];
		[_specialButton setTitle: @"Cancel"];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) browserCurrentDirectoryChanged: (MFBrowser*)browser toPath: (NSString*)path;
{
	[self updateBackButton];	
	[self updatePrompt];
}

- (void) browserCurrentHighlightedPathChanged: (MFBrowser*) browser toPath: (NSString*) path;
{
	
}

- (void) browserWillLaunchApplication: (NSString*)appID withArguments: (NSArray*)args
{
	[_settings setStartupPath: [_browser currentDirectory] forApplication: appID];
	[_settings writeSettings];
}

//Application delegate methods
- (void) applicationDidFinishLaunching: (id)unknown
{
	//Run Application
	if (_applicationID == nil)
	{
		[self runApplication];						
	}
	
	//Report successful launch
	[self reportAppLaunchFinished];
}
- (void) applicationSuspend: (id)unknown1 settings: (id)unknown2
{
	[self suspendApplication];
	[self applicationSuspended: nil];
}
- (void) animationWillStart: (id)unknown1 context: (id)unknown2
{
	[self resumeApplication];
}
- (void) applicationResume: (struct __GSEvent *)fp8 settings: (id)unknown2
{
	[self resumeApplication];
}
- (void) _finishResume
{
	[self resumeApplication];
	[super _finishResume];
}
- (void) _finishSuspension
{
	[self suspendApplication];
	[super _finishSuspension];
}
- (void) _finishSuspensionEventOnlyAnimation
{
	[self suspendApplication];
	[super _finishSuspensionEventOnlyAnimation];
}
- (void) deviceOrientationChanged: (struct __GSEvent*)event 
{
	//TODO: Make this do something!
	NSLog(@"Device orientation changed!");
}




//Overrides for UIApplication callbacks
- (void)applicationSuspend:(struct __GSEvent *)fp8
{
	[self suspendApplication];
	[super applicationSuspend:fp8];
}
- (void)applicationSuspended:(struct __GSEvent *)fp8
{
	[self suspendApplication];
	[super applicationSuspended:fp8];
}
- (void)applicationSuspendedSettingsUpdated:(struct __GSEvent *)fp8
{
	[self suspendApplication];
	[super applicationSuspendedSettingsUpdated:fp8];
}
- (void)applicationWillSuspend
{
	[self suspendApplication];
	[super applicationWillSuspend];
}
- (void)applicationWillSuspendForEventsOnly
{
	[self suspendApplication];
	[super applicationWillSuspendForEventsOnly];
}
- (void)applicationWillSuspendUnderLock
{
	[self suspendApplication];
	[super applicationWillSuspendUnderLock];
}
- (void)suspendWithAnimation:(BOOL)fp8
{
	[self suspendApplication];
	[super suspendWithAnimation:fp8];
}
- (void)applicationDidResume
{
	[self resumeApplication];
	[super applicationDidResume];
}
- (void)applicationDidResumeForEventsOnly
{
	[self resumeApplication];
	[super applicationDidResumeForEventsOnly];
}
- (void)applicationDidResumeFromUnderLock
{
	[self resumeApplication];
	[super applicationDidResumeFromUnderLock];
}
- (void)applicationResume:(struct __GSEvent *)fp8
{
	[self resumeApplication];
	[super applicationResume:fp8];
}
- (void)applicationResume:(struct __GSEvent *)fp8 withArguments:(id)fp12
{
	[self resumeApplication];
	[super applicationResume:fp8 withArguments:fp12];
}
- (void)applicationWillResume
{
	[self resumeApplication];
	[super applicationWillSuspend];
}
- (void)applicationWillTerminate
{
	[_settings writeSettings];
	[super applicationWillTerminate];
}


//These Methods track delegate calls made to the application
/*
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector 
{
	NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
	return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector 
{
	NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation 
{
	NSLog(@"Called from: %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
}
*/





//Overrides of all public application methods for detection of use
/*
- (void)acceleratedInX:(float)fp8 Y:(float)fp12 Z:(float)fp16
{
	NSLog(@"Got acceleratedInX:Y:Z:");
	[super acceleratedInX:fp8 Y:fp12 Z:fp16];
}

- (void)accessoryAvailabilityChanged:(struct __GSEvent *)fp8
{
	NSLog(@"Got accessoryAvailabilityChanged:");
	[super accessoryAvailabilityChanged:fp8];
}

- (void)accessoryEvent:(struct __GSEvent *)fp8
{
	NSLog(@"Got accessoryEvent:");
	[super accessoryEvent:fp8];
}

- (void)accessoryKeyStateChanged:(struct __GSEvent *)fp8
{
	NSLog(@"Got accessoryKeyStateChanged:");
	[super accessoryKeyStateChanged:fp8];
}

- (void)addStatusBarImageNamed:(id)fp8
{
	NSLog(@"Got addStatusBarImageNamed:");
	[super addStatusBarImageNamed:fp8];
}

- (void)addStatusBarImageNamed:(id)fp8 removeOnAbnormalExit:(BOOL)fp12
{
	NSLog(@"Got addStatusBarImageNamed:removeOnAbnormalExit:");
	[super addStatusBarImageNamed:fp8 removeOnAbnormalExit:fp12];
}

- (int)alertOrientation
{
	NSLog(@"Got alertOrientation");
	return [super alertOrientation];
}

- (BOOL)animateSuspensionReturningToLastApp:(double)fp8
{
	NSLog(@"Got animateSuspensionReturningToLastApp:");
	return [super animateSuspensionReturningToLastApp:fp8];
}

- (void)anotherApplicationFinishedLaunching:(struct __GSEvent *)fp8
{
	NSLog(@"Got anotherApplicationFinishedLaunching:");
	[super anotherApplicationFinishedLaunching:fp8];
}

- (int)applicationControlTint
{
	NSLog(@"Got applicationControlTint");
	return [super applicationControlTint];
}

- (void)applicationDidResume
{
	NSLog(@"Got applicationDidResume");
	[super applicationDidResume];
}

- (void)applicationDidResumeForEventsOnly
{
	NSLog(@"Got applicationDidResumeForEventsOnly");
	[super applicationDidResumeForEventsOnly];
}

- (void)applicationDidResumeFromUnderLock
{
	NSLog(@"Got applicationDidResumeFromUnderLock");
	[super applicationDidResumeFromUnderLock];
}

- (void)applicationExited:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationExited:");
	[super applicationExited:fp8];
}

- (BOOL)applicationIsReadyToSuspend
{
	NSLog(@"Got applicationIsReadyToSuspend");
	return [super applicationIsReadyToSuspend];
}

- (void)applicationOpenURL:(id)fp8
{
	NSLog(@"Got applicationOpenURL:");
	[super applicationOpenURL:fp8];
}

- (void)applicationOpenURL:(id)fp8 asPanel:(BOOL)fp12
{
	NSLog(@"Got applicationOpenURL:asPanel:");
	[super applicationOpenURL:fp8 asPanel:fp12];
}

- (void)applicationResume:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationResume:");
	[super applicationResume:fp8];
}

- (void)applicationResume:(struct __GSEvent *)fp8 withArguments:(id)fp12
{
	NSLog(@"Got applicationResume:withArguments:");
	[super applicationResume:fp8 withArguments:fp12];
}

- (void)applicationShowHideSettings:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationShowHideSettings:");
	[super applicationShowHideSettings:fp8];
}

- (struct CGRect)applicationSnapshotRectForOrientation:(int)fp8
{
	NSLog(@"Got applicationSnapshotRectForOrientation:");
	return [super applicationSnapshotRectForOrientation:fp8];
}

- (void)applicationStarted:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationStarted:");
	[super applicationStarted:fp8];
}

- (void)applicationSuspend:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationSuspend:");
	[super applicationSuspend:fp8];
}

- (void)applicationSuspended:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationSuspended:");
	[super applicationSuspended:fp8];
}

- (void)applicationSuspendedSettingsUpdated:(struct __GSEvent *)fp8
{
	NSLog(@"Got applicationSuspendedSettingsUpdated:");
	[super applicationSuspendedSettingsUpdated:fp8];
}

- (void)applicationWillSuspend
{
	NSLog(@"Got applicationWillSuspend");
	[super applicationWillSuspend];
}

- (void)applicationWillSuspendForEventsOnly
{
	NSLog(@"Got applicationWillSuspendForEventsOnly");
	[super applicationWillSuspendForEventsOnly];
}

- (void)applicationWillSuspendUnderLock
{
	NSLog(@"Got applicationWillSuspendUnderLock");
	[super applicationWillSuspendUnderLock];
}

- (void)applicationWillTerminate
{
	NSLog(@"Got applicationWillTerminate");
	[super applicationWillTerminate];
}

- (BOOL)canShowAlerts
{
	NSLog(@"Got canShowAlerts");
	return [super canShowAlerts];
}

- (struct CGImage *)createApplicationDefaultPNG
{
	NSLog(@"Got createApplicationDefaultPNG");
	[super createApplicationDefaultPNG];
}

- (void)deviceOrientationChanged:(struct __GSEvent *)fp8
{
	NSLog(@"Got deviceOrientationChanged:");
	[super deviceOrientationChanged:fp8];
}

- (void)didDismissMiniAlert
{
	NSLog(@"Got didDismissMiniAlert");
	[super didDismissMiniAlert];
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"Got didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
}

- (void)didReceiveUrgentMemoryWarning
{
	NSLog(@"Got didReceiveUrgentMemoryWarning");
	[super didReceiveUrgentMemoryWarning];
}

- (void)didWake
{
	NSLog(@"Got didWake");
	[super didWake];
}

- (id)displayIDForURLScheme:(id)fp8 isPublic:(BOOL)fp12
{
	NSLog(@"Got displayIDForURLScheme:isPublic:");
	return [super displayIDForURLScheme:fp8 isPublic:fp12];
}

- (id)displayIdentifier
{
	NSLog(@"Got displayIdentifier");
	return [super displayIdentifier];
}

- (BOOL)handleEvent:(struct __GSEvent *)fp8
{
	NSLog(@"Got handleEvent:");
	return [super handleEvent:fp8];
}

- (void)handleOutOfLineDataRequest:(struct __GSEvent *)fp8
{
	NSLog(@"Got handleOutOfLineDataRequest:");
	[super handleOutOfLineDataRequest:fp8];
}

- (void)handleOutOfLineDataResponse:(struct __GSEvent *)fp8
{
	NSLog(@"Got handleOutOfLineDataResponse:");
	[super handleOutOfLineDataResponse:fp8];
}

- (void)headsetButtonDown:(struct __GSEvent *)fp8
{
	NSLog(@"Got headsetButtonDown:");
	[super headsetButtonDown:fp8];
}

- (void)headsetButtonUp:(struct __GSEvent *)fp8
{
	NSLog(@"Got headsetButtonUp:");
	[super headsetButtonUp:fp8];
}

- (BOOL)ignoresInteractionEvents
{
	NSLog(@"Got ignoresInteractionEvents");
	return [super ignoresInteractionEvents];
}

- (BOOL)isLocked
{
	NSLog(@"Got isLocked");
	return [super isLocked];
}

- (BOOL)isPasscodeRequiredToUnlock
{
	NSLog(@"Got isPasscodeRequiredToUnlock");
	return [super isPasscodeRequiredToUnlock];
}

- (BOOL)isSuspended
{
	NSLog(@"Got isSuspended");
	return [super isSuspended];
}

- (BOOL)isSuspendedEventsOnly
{
	NSLog(@"Got isSuspendedEventsOnly");
	return [super isSuspendedEventsOnly];
}

- (BOOL)isSuspendedUnderLock
{
	NSLog(@"Got isSuspendedUnderLock");
	return [super isSuspendedUnderLock];
}

- (BOOL)launchApplicationWithIdentifier:(id)fp8 suspended:(BOOL)fp12
{
	NSLog(@"Got launchApplicationWithIdentifier:suspended:");
	return [super launchApplicationWithIdentifier:fp8 suspended:fp12];
}

- (void)lockButtonDown:(struct __GSEvent *)fp8
{
	NSLog(@"Got lockButtonDown:");
	[super lockButtonDown:fp8];
}

- (void)lockButtonUp:(struct __GSEvent *)fp8
{
	NSLog(@"Got lockButtonUp:");
	[super lockButtonUp:fp8];
}

- (void)lockDevice:(struct __GSEvent *)fp8
{
	NSLog(@"Got lockDevice:");
	[super lockDevice:fp8];
}

- (void)menuButtonDown:(struct __GSEvent *)fp8
{
	NSLog(@"Got menuButtonDown:");
	[super menuButtonDown:fp8];
}

- (void)menuButtonUp:(struct __GSEvent *)fp8
{
	NSLog(@"Got menuButtonUp:");
	[super menuButtonUp:fp8];
}

- (id)nameOfDefaultImageToUpdateAtSuspension
{
	NSLog(@"Got nameOfDefaultImageToUpdateAtSuspension");
	return [super nameOfDefaultImageToUpdateAtSuspension];
}

- (void)openURL:(id)fp8
{
	NSLog(@"Got openURL:");
	[super openURL:fp8];
}

- (void)openURL:(id)fp8 asPanel:(BOOL)fp12
{
	NSLog(@"Got openURL:asPanel:");
	[super openURL:fp8 asPanel:fp12];
}

- (int)orientation
{
	NSLog(@"Got orientation");
	return [super orientation];
}

- (void)otherApplicationWillSuspend:(struct __GSEvent *)fp8
{
	NSLog(@"Got otherApplicationWillSuspend:");
	[super otherApplicationWillSuspend:fp8];
}

- (void)performInitializationWithURL:(id)fp8
{
	NSLog(@"Got performInitializationWithURL:");
	[super performInitializationWithURL:fp8];
}

- (void)popRunLoopMode:(id)fp8
{
	NSLog(@"Got popRunLoopMode:");
	[super popRunLoopMode:fp8];
}

- (void)pushRunLoopMode:(id)fp8
{
	NSLog(@"Got pushRunLoopMode:");
	[super pushRunLoopMode:fp8];
}

- (void)quitTopApplication:(struct __GSEvent *)fp8
{
	NSLog(@"Got quitTopApplication:");
	[super quitTopApplication:fp8];
}

- (void)removeApplicationBadge
{
	NSLog(@"Got removeApplicationBadge");
	[super removeApplicationBadge];
}

- (void)removeDefaultImage:(id)fp8
{
	NSLog(@"Got removeDefaultImage:");
	[super removeDefaultImage:fp8];
}

- (void)removeStatusBarCustomText
{
	NSLog(@"Got removeStatusBarCustomText");
	[super removeStatusBarCustomText];
}

- (void)removeStatusBarImageNamed:(id)fp8
{
	NSLog(@"Got removeStatusBarImageNamed:");
	[super removeStatusBarImageNamed:fp8];
}

- (void)reportAppLaunchFinished
{
	NSLog(@"Got reportAppLaunchFinished");
	[super reportAppLaunchFinished];
}

- (void)requestDeviceUnlock
{
	NSLog(@"Got requestDeviceUnlock");
	[super requestDeviceUnlock];
}

- (void)resetIdleDuration:(double)fp8
{
	NSLog(@"Got resetIdleDuration:");
	[super resetIdleDuration:fp8];
}

- (void) resetIdleTimer
{
	NSLog(@"Got resetIdleTimer");
	[super resetIdleTimer];
}

- (void)ringerChanged:(int)fp8
{
	NSLog(@"Got ringerChanged:");
	[super ringerChanged:fp8];
}

- (id)roleID
{
	NSLog(@"Got roleID");
	return [super roleID];
}

- (void)run
{
	NSLog(@"Got run");
	[super run];
}

- (void)runModal:(id)fp8
{
	NSLog(@"Got runModal:");
	[super runModal:fp8];
}

- (void)runWithURL:(id)fp8
{
	NSLog(@"Got runWithURL:");
	[super runWithURL:fp8];
}

- (void)sendAction:(SEL)fp8 fromSender:(id)fp12 toTarget:(id)fp16 forEvent:(struct __GSEvent *)fp20
{
	NSLog(@"Got sendAction:fromSender:toTarget:forEvent:");
	[super sendAction:fp8 fromSender:fp12 toTarget:fp16 forEvent:fp20];
}

- (void)setApplicationBadge:(id)fp8
{
	NSLog(@"Got setApplicationBadge:");
	[super setApplicationBadge:fp8];
}

- (void)setBacklightFactor:(int)fp8
{
	NSLog(@"Got setBacklightFactor:");
	[super setBacklightFactor:fp8];
}

- (void)setBacklightLevel:(float)fp8
{
	NSLog(@"Got setBacklightLevel:");
	[super setBacklightLevel:fp8];
}

- (void)setExpectsFaceContact:(BOOL)fp8
{
	NSLog(@"Got setExpectsFaceContact:");
	[super setExpectsFaceContact:fp8];
}

- (void)setIgnoresInteractionEvents:(BOOL)fp8
{
	NSLog(@"Got setIgnoresInteractionEvents:");
	[super setIgnoresInteractionEvents:fp8];
}

- (void)setProximitySensorEnabled:(BOOL)fp8
{
	NSLog(@"Got setProximitySensorEnabled:");
	[super setProximitySensorEnabled:fp8];
}

- (void)setReceivesMemoryWarnings:(BOOL)fp8
{
	NSLog(@"Got setReceivesMemoryWarnings:");
	[super setReceivesMemoryWarnings:fp8];
}

- (void)setStatusBarCustomText:(id)fp8
{
	NSLog(@"Got setStatusBarCustomText:");
	[super setStatusBarCustomText:fp8];
}

- (void)setStatusBarMode:(int)fp8 duration:(float)fp12
{
	NSLog(@"Got setStatusBarMode:duration:");
	[super setStatusBarMode:fp8 duration:fp12];
}

- (void)setStatusBarMode:(int)fp8 orientation:(int)fp12 duration:(float)fp16
{
	NSLog(@"Got setStatusBarMode:orientation:duration:");
	[super setStatusBarMode:fp8 orientation:fp12 duration:fp16];
}

- (void)setStatusBarMode:(int)fp8 orientation:(int)fp12 duration:(float)fp16 fenceID:(int)fp20
{
	NSLog(@"Got setStatusBarMode:orientation:duration:fenceID:");
	[super setStatusBarMode:fp8 orientation:fp12 duration:fp16 fenceID:fp20];
}

- (void)setStatusBarMode:(int)fp8 orientation:(int)fp12 duration:(float)fp16 fenceID:(int)fp20 animation:(int)fp24
{
	NSLog(@"Got setStatusBarMode:orientation:duration:fenceID:animation:");
	[super setStatusBarMode:fp8 orientation:fp12 duration:fp16 fenceID:fp20 animation:fp24];
}

- (void)setStatusBarShowsProgress:(BOOL)fp8
{
	NSLog(@"Got setStatusBarShowsProgress:");
	[super setStatusBarShowsProgress:fp8];
}

- (void)setSystemVolumeHUDEnabled:(BOOL)fp8
{
	NSLog(@"Got setSystemVolumeHUDEnabled:");
	[super setSystemVolumeHUDEnabled:fp8];
}

- (void)setSystemVolumeHUDEnabled:(BOOL)fp8 forAudioCategory:(id)fp12
{
	NSLog(@"Got setSystemVolumeHUDEnabled:forAudioCategory:");
	[super setSystemVolumeHUDEnabled:fp8 forAudioCategory:fp12];
}

- (void)setUIOrientation:(int)fp8
{
	NSLog(@"Got setUIOrientation:");
	[super setUIOrientation:fp8];
}

- (void)setUseCompatibleSuspensionAnimation:(BOOL)fp8
{
	NSLog(@"Got setUseCompatibleSuspensionAnimation:");
	[super setUseCompatibleSuspensionAnimation:fp8];
}

- (BOOL)shouldLaunchSafe
{
	NSLog(@"Got shouldLaunchSafe");
	return [super shouldLaunchSafe];
}

- (BOOL)shouldShowPreferences
{
	NSLog(@"Got shouldShowPreferences");
	return [super shouldShowPreferences];
}

- (void)showNetworkPromptsIfNecessary:(BOOL)fp8
{
	NSLog(@"Got showNetworkPromptsIfNecessary:");
	[super showNetworkPromptsIfNecessary:fp8];
}

- (void)showTTYPromptForNumber:(id)fp8 withID:(int)fp12
{
	NSLog(@"Got showTTYPromptForNumber:withID:");
	[super showTTYPromptForNumber:fp8 withID:fp12];
}

- (void)significantTimeChange
{
	NSLog(@"Got significantTimeChange");
	[super significantTimeChange];
}

- (int)statusBarMode
{
	NSLog(@"Got statusBarMode");
	return [super statusBarMode];
}

- (void)statusBarMouseDown:(struct __GSEvent *)fp8
{
	NSLog(@"Got statusBarMouseDown:");
	[super statusBarMouseDown:fp8];
}

- (void)statusBarMouseDragged:(struct __GSEvent *)fp8
{
	NSLog(@"Got statusBarMouseDragged:");
	[super statusBarMouseDragged:fp8];
}

- (void)statusBarMouseUp:(struct __GSEvent *)fp8
{
	NSLog(@"Got statusBarMouseUp:");
	[super statusBarMouseUp:fp8];
}

- (struct CGRect)statusBarRect
{
	NSLog(@"Got statusBarRect");
	return [super statusBarRect];
}

- (void)statusBarWillAnimateToHeight:(float)fp8 duration:(double)fp12 fence:(int)fp20
{
	NSLog(@"Got statusBarWillAnimateToHeight:duration:fence:");
	[super statusBarWillAnimateToHeight:fp8 duration:fp12 fence:fp20];
}

- (void)stopModal
{
	NSLog(@"Got stopModal");
	[super stopModal];
}

- (int)suspendAnimationType
{
	NSLog(@"Got suspendAnimationType");
	return [super suspendAnimationType];
}

- (void)suspendWithAnimation:(BOOL)fp8
{
	NSLog(@"Got suspendWithAnimation:");
	[super suspendWithAnimation:fp8];
}

- (void)terminate
{
	NSLog(@"Got terminate");
	[super terminate];
}

- (void)terminateWithSuccess
{
	NSLog(@"Got terminateWithSuccess");
	[super terminateWithSuccess];
}

- (void)updateSuspendedSettings:(id)fp8
{
	NSLog(@"Got updateSuspendedSettings:");
	[super updateSuspendedSettings:fp8];
}

- (BOOL)useCompatibleSuspensionAnimation
{
	NSLog(@"Got useCompatibleSuspensionAnimation");
	return [super useCompatibleSuspensionAnimation];
}

- (void)userDefaultsDidChange:(id)fp8
{
	NSLog(@"Got userDefaultsDidChange:");
	[super userDefaultsDidChange:fp8];
}

- (id)userHomeDirectory
{
	NSLog(@"Got userHomeDirectory");
	return [super userHomeDirectory];
}

- (id)userLibraryDirectory
{
	NSLog(@"Got userLibraryDirectory");
	return [super userLibraryDirectory];
}

- (void)vibrateForDuration:(int)fp8
{
	NSLog(@"Got vibrateForDuration:");
	[super vibrateForDuration:fp8];
}

- (void)volumeChanged:(struct __GSEvent *)fp8
{
	NSLog(@"Got volumeChanged:");
	[super volumeChanged:fp8];
}

- (void)willDismissMiniAlert:(int *)fp8 andShowAnother:(BOOL)fp12
{
	NSLog(@"Got willDismissMiniAlert:andShowAnother:");
	[super willDismissMiniAlert:fp8 andShowAnother:fp12];
}

- (void)willDisplayMiniAlert:(int *)fp8
{
	NSLog(@"Got willDisplayMiniAlert:");
	[super willDisplayMiniAlert:fp8];
}

- (void)willSleep
{
	NSLog(@"Got willSleep");
	[super willSleep];
}
*/

/*
Application Selector Notes

2007-09-01 14:52:37.801 Finder[193:d03] Request for selector: applicationDidFinishLaunching:
2007-09-01 14:52:39.152 Finder[193:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-01 14:52:39.155 Finder[193:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-01 14:52:39.388 Finder[193:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-01 14:52:39.390 Finder[193:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-01 14:52:39.874 Finder[193:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-01 14:52:39.876 Finder[193:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-01 14:52:53.676 Finder[193:d03] Request for selector: navigationBar:buttonClicked:
2007-09-01 14:52:53.759 Finder[193:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-01 14:52:53.761 Finder[193:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-01 14:53:03.965 Finder[193:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-01 14:53:12.501 Finder[193:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-01 14:53:12.505 Finder[193:d03] Launching with app: com.google.code.MobileTextEdit arguments: /var/root/untitled.txt
2007-09-01 14:53:25.950 Finder[193:d03] Request for selector: applicationResume:settings:
2007-09-01 14:53:46.124 Finder[193:d03] Request for selector: animationWillStart:context:
2007-09-01 14:53:46.128 Finder[193:d03] Request for selector: animationWillStart:
2007-09-01 14:53:46.623 Finder[193:d03] Request for selector: _finishSuspension
2007-09-01 14:53:46.643 Finder[193:d03] Request for selector: applicationSuspend:settings:

2007-09-03 16:20:38.044 SpringBoard[102:d03] Couldn't register with bootstrap server unknown error code (0x44c); failing...
2007-09-03 16:20:38.119 SpringBoard[102:d03] lockdown says the device is: [Activated], state is 2
2007-09-03 16:20:38.135 SpringBoard[102:d03] lockdown says we've previously registered: [1], state is 1
2007-09-03 16:20:38.696 SpringBoard[102:d03] -[<LKLayer 0x149b80> display]: Ignoring bogus layer size (0.000000, 0.000000)
2007-09-03 16:21:03.881 Finder[108:d03] Request for selector: applicationDidFinishLaunching:
2007-09-03 16:21:05.010 Finder[108:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-03 16:21:05.012 Finder[108:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-03 16:21:05.519 Finder[108:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-03 16:21:05.521 Finder[108:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-03 16:21:05.564 Finder[108:d03] Request for selector: browserCurrentSelectedPathChanged:toPath:
2007-09-03 16:21:05.566 Finder[108:d03] Request for selector: browserCurrentDirectoryChanged:toPath:
2007-09-03 16:21:27.280 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:21:27.290 Finder[108:d03] Request for selector: animationWillStart:
LayerKit: timed out fence 2
2007-09-03 16:21:27.776 Finder[108:d03] Request for selector: _finishSuspensionEventOnlyAnimation
007-09-03 16:21:35.706 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:21:35.716 Finder[108:d03] Request for selector: animationWillStart:
2007-09-03 16:21:36.419 Finder[108:d03] Request for selector: _finishResume
2007-09-03 16:21:53.534 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:21:53.536 Finder[108:d03] Request for selector: animationWillStart:
LayerKit: timed out fence 2
2007-09-03 16:21:54.053 Finder[108:d03] Request for selector: _finishSuspensionEventOnlyAnimation
2007-09-03 16:21:57.061 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:21:57.063 Finder[108:d03] Request for selector: animationWillStart:
2007-09-03 16:21:57.768 Finder[108:d03] Request for selector: _finishResume
2007-09-03 16:22:35.290 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:22:35.292 Finder[108:d03] Request for selector: animationWillStart:
LayerKit: timed out fence 2
2007-09-03 16:22:35.790 Finder[108:d03] Request for selector: _finishSuspensionEventOnlyAnimation
2007-09-03 16:22:41.450 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:22:41.452 Finder[108:d03] Request for selector: animationWillStart:
2007-09-03 16:22:42.157 Finder[108:d03] Request for selector: _finishResume
2007-09-03 16:22:50.392 Finder[108:d03] Request for selector: animationWillStart:context:
2007-09-03 16:22:50.395 Finder[108:d03] Request for selector: animationWillStart:
2007-09-03 16:22:50.742 Finder[108:d03] Request for selector: _finishSuspension
2007-09-03 16:22:50.746 Finder[108:d03] Request for selector: applicationSuspend:settings:
^C2007-09-03 16:22:52.872 Finder[108:d03] Reacting to SpringBoard port death, exiting
2007-09-03 16:22:52.874 MobilePhone[104:d03] Reacting to SpringBoard port death, exiting
2007-09-03 16:22:52.937 MobileMail[105:d03] Reacting to SpringBoard port death, exiting
*/

@end

