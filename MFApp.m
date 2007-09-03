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
#import "MFApp.h"
#import "MFBrowser.h"
#import "MFSettings.h"
#import "MobileStudio/MSAppLauncher.h"

@implementation MFApp : UIApplication

- (void) runApplication
{   
	//Set applicationID
	_applicationID = @"com.googlecode.MobileFinder";
	
	//Initialize window
	_window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	[_window orderFront: self];
	[_window makeKey: self];
	[_window _setHidden: YES];
	
	//Setup main view
    struct CGRect screenRect = [UIHardware fullScreenApplicationContentRect];
    screenRect.origin.x = 0.0;
	screenRect.origin.y = 0.0f;
    _mainView = [[UIView alloc] initWithFrame: screenRect];
    [_window setContentView: _mainView];
	
	//Control sizes
	float navBarWidth = screenRect.size.width;
	float navBarHeight = 74.0f;
	float navBarButtonHeight = 32.0f;
	float navBarSouthBuffer = 5.0f;
	float navBarButtonBuffer = 4.0f;
	float finderButtonWidth = 80.0f;
	float settingsButtonWidth = 80.0f;
	float fileOpBarWidth = screenRect.size.width;
	float fileOpBarHeight = 46.0f;
	float fileOpBarNorthBuffer = 8.0f;
	float fileOpBarButtonHeight = 32.0f;
	float fileOpBarButtonBuffer = 2.0f;
	float fileOpBarButtonGroupBuffer = 4.0f;
	float moveButtonWidth = 60.0f;
	float copyButtonWidth = 60.0f;
	float deleteButtonWidth = 60.0f;
	float renameButtonWidth = 60.0f;
	float newButtonWidth = 60.0f;
		
	//Setup the settings pane (and load settings)
	NSString* settingsPath = [[[[self userLibraryDirectory] 
		stringByAppendingPathComponent: @"Preferences"]
		stringByAppendingPathComponent: _applicationID]
		stringByAppendingPathExtension: @"plist"];
	_settings = [[MFSettings alloc] initWithFrame: CGRectMake(
		0.0f, 
		navBarHeight, 
		screenRect.size.width, screenRect.size.height - navBarHeight)
		withSettingsPath: settingsPath];
	[_settings setDelegate: self];
	
	//Setup navigation bar
	_navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, navBarWidth, navBarHeight)];
	[_navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Home" leftBack: TRUE];
    [_navBar setBarStyle: 3];
	[_navBar setDelegate: self];
	[_mainView addSubview: _navBar];
	
	//Setup navigation bar buttons
	_finderButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		navBarWidth / 2.0f - finderButtonWidth - navBarButtonBuffer / 2.0f,
		navBarHeight - navBarButtonHeight - navBarSouthBuffer, 
		finderButtonWidth, navBarButtonHeight)];
	[_finderButton setAutosizesToFit: FALSE];
	[_finderButton setTitle: @"Finder"];
	[_finderButton addTarget: self action: @selector(makeBrowserActive) forEvents: 1];
	[_navBar addSubview: _finderButton];
	
	_settingsButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		navBarWidth / 2.0f + navBarButtonBuffer / 2.0f,
		navBarHeight - navBarButtonHeight - navBarSouthBuffer, 
		settingsButtonWidth, navBarButtonHeight)];
	[_settingsButton setAutosizesToFit: FALSE];
	[_settingsButton setTitle: @"Settings"];
	[_settingsButton addTarget: self action: @selector(makeSettingsActive) forEvents: 1];
	[_navBar addSubview: _settingsButton];		
	
	//Setup file operations bar
	_fileOpBar = [[UIGradientBar alloc] initWithFrame: CGRectMake(
		0.0f, 
		screenRect.size.height - fileOpBarHeight,
		fileOpBarWidth, fileOpBarHeight)];
		
	//Setup file operation buttons
	_copyButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f - deleteButtonWidth / 2.0f - moveButtonWidth - copyButtonWidth - fileOpBarButtonBuffer * 2.0 - fileOpBarButtonGroupBuffer,
		fileOpBarNorthBuffer, 
		copyButtonWidth, fileOpBarButtonHeight)];
	[_copyButton setAutosizesToFit: FALSE];
	[_copyButton addTarget: self action: @selector(copyButtonPressed) forEvents: 1];
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _copyButton];
	
	_moveButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f - deleteButtonWidth / 2.0f - moveButtonWidth - fileOpBarButtonBuffer * 1.0 - fileOpBarButtonGroupBuffer, 
		fileOpBarNorthBuffer, 
		moveButtonWidth, fileOpBarButtonHeight)];
	[_moveButton setAutosizesToFit: FALSE];
	[_moveButton addTarget: self action: @selector(moveButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _moveButton];
	
	_deleteButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f - deleteButtonWidth / 2.0, 
		fileOpBarNorthBuffer, 
		deleteButtonWidth, fileOpBarButtonHeight)];
	[_deleteButton setAutosizesToFit: FALSE];
	[_deleteButton addTarget: self action: @selector(deleteButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _deleteButton];
	
	_renameButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f + deleteButtonWidth / 2.0f + fileOpBarButtonBuffer * 1.0 + fileOpBarButtonGroupBuffer, 
		fileOpBarNorthBuffer, 
		renameButtonWidth, fileOpBarButtonHeight)];
	[_renameButton setAutosizesToFit: FALSE];
	[_renameButton addTarget: self action: @selector(renameButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _renameButton];
	
	_newButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f + deleteButtonWidth / 2.0f + renameButtonWidth + fileOpBarButtonBuffer * 2.0 + fileOpBarButtonGroupBuffer, 
		fileOpBarNorthBuffer, 
		newButtonWidth, fileOpBarButtonHeight)];
	[_newButton setAutosizesToFit: FALSE];
	[_newButton addTarget: self action: @selector(newButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _newButton];
		
	//Setup the file browser
	_browser = [[MFBrowser alloc] initWithApplication: self 
		withAppID: _applicationID
		withFrame: CGRectMake(
			0.0f, 
			navBarHeight, 
			screenRect.size.width, screenRect.size.height - navBarHeight - fileOpBarHeight)];
	[_browser setDelegate: self];
	
	//Make the browser active at start
	[self makeSettingsActive];
	[self makeBrowserActive];
	
	//Get launch information
	//If we were launched using another AppLauncher-aware program, enter the mandatory app launch mode
	NSDictionary* launchInfo = [MSAppLauncher readLaunchInfoForAppID: _applicationID
		withApplication: self
		deletingLaunchPList: TRUE];
	if (launchInfo != nil)
	{
		NSEnumerator* enumerator = [launchInfo keyEnumerator];
		NSString* currKey;
		while (currKey = [enumerator nextObject]) 
		{	
			if ([currKey isEqualToString: @"MSLaunchingAppIdentifier"])
			{
				//TODO: Need visual comment on mode of operation?
				NSString* launchingAppID = [launchInfo valueForKey: currKey];
				[_browser setMandatoryLaunchApplication: launchingAppID];
				[_browser openPath: [_settings startupPathForApplication: launchingAppID]];
			}
		}
	}
	else
	{
		//Open the default start directory
		[_browser openPath: [_settings startupPath]];
	}
}

- (void) dealloc
{
	[_window release];
	[_mainView release];
	[_browser release];
	[_settings release];
	[_navBar release];
	[_finderButton release];
	[_settingsButton release];
	[_fileOpBar release];
	[_moveButton release];
	[_copyButton release];
	[_deleteButton release];
	[_renameButton release];
	[_newButton release];
	
	[_pathSelectedForFileOp release];
	
	NSLog(@"Dealloc called on MFApp");
	
	[super dealloc];
}

- (void) makeBrowserActive
{
	if ([_mainView containsView: _browser])
		return;
	
	//Enable navBar buttons
	[_navBar setButton: 0 enabled: TRUE];
	[_navBar setButton:	1 enabled: TRUE];
	
	//Switch views
	[_settings removeFromSuperview];
	[_mainView addSubview: _browser];
	[_mainView addSubview: _fileOpBar];
	[_finderButton setNavBarButtonStyle: 3];
	[_settingsButton setNavBarButtonStyle: 0];
	
	//Update settings
	[_settings writeSettings];
	[_browser setShowHiddenFiles: [_settings showHiddenFiles]];
	[_browser setLaunchApplications: [_settings launchApplications]];
	[_browser setLaunchExecutables: [_settings launchExecutables]];
	[_browser setProtectSystemFiles: [_settings protectSystemFiles]];
	[_browser setFileTypeAssociations: [_settings fileTypeAssociations]];
}

- (void) makeSettingsActive
{
	if ([_mainView containsView: _settings])
		return;
	
	//Disable navBar buttons
	[_navBar setButton: 0 enabled: FALSE];
	[_navBar setButton:	1 enabled: FALSE];
	
	//Switch views
	[_settings readSettings];
	[_browser removeFromSuperview];
	[_fileOpBar removeFromSuperview];
	[_mainView addSubview: _settings];
	[_finderButton setNavBarButtonStyle: 0];
	[_settingsButton setNavBarButtonStyle: 3];
}

- (void) resetFileOpButtons
{
	if (_copyButton != nil)
	{
		[_copyButton setNavBarButtonStyle: 0];
		[_copyButton setTitle: @"Copy"];
		[_copyButton setEnabled: TRUE];
	}
	if (_moveButton != nil)
	{
		[_moveButton setNavBarButtonStyle: 0];
		[_moveButton setTitle: @"Move"];
		[_moveButton setEnabled: TRUE];
	}
	if (_deleteButton != nil)
	{
		[_deleteButton setNavBarButtonStyle: 0];
		[_deleteButton setTitle: @"Delete"];
		[_deleteButton setEnabled: TRUE];
	}
	if (_renameButton != nil)
	{
		[_renameButton setNavBarButtonStyle: 0];
		[_renameButton setTitle: @"Rename"];
		[_renameButton setEnabled: TRUE];
	}
	if (_newButton != nil)
	{
		[_newButton setNavBarButtonStyle: 0];
		[_newButton setTitle: @"New"];
		[_newButton setEnabled: TRUE];
	}
}

- (void) copyButtonPressed
{
	if ([[_copyButton title] isEqualToString: @"Copy"] && [_browser currentSelectedPath] != nil)
	{ 
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: 3];
		[_copyButton setTitle: @"Cancel"];
		[_moveButton setNavBarButtonStyle: 3];
		[_moveButton setTitle: @"Copy"];
		[_deleteButton setEnabled: FALSE];
		[_renameButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		
		[_pathSelectedForFileOp autorelease];
		_pathSelectedForFileOp = [[_browser currentSelectedPath] copy];
	}
	else if ([[_copyButton title] isEqualToString: @"Move"])
	{
		[_browser 
			sendSrcPath: _pathSelectedForFileOp 
			toDstPath: [_browser currentDirectory]
			byMoving: TRUE];
		[self resetFileOpButtons];
	}
	else if ([[_copyButton title] isEqualToString: @"Delete"])
	{
		NSString* currentSelectedPath = [_browser currentSelectedPath];
		if (currentSelectedPath != nil)
			[_browser deletePath: currentSelectedPath];
		[self resetFileOpButtons];
	}
	else if ([[_copyButton title] isEqualToString: @"File"])
	{
		[_browser makeFileAtPath: @"untitled file"];
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
		[_moveButton setNavBarButtonStyle: 3];
		[_moveButton setTitle: @"Cancel"];
		[_copyButton setNavBarButtonStyle: 3];
		[_copyButton setTitle: @"Move"];
		[_deleteButton setEnabled: FALSE];
		[_renameButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		
		[_pathSelectedForFileOp autorelease];
		_pathSelectedForFileOp = [[_browser currentSelectedPath] copy];
	}
	else if ([[_moveButton title] isEqualToString: @"Copy"])
	{
		[_browser 
			sendSrcPath: _pathSelectedForFileOp 
			toDstPath: [_browser currentDirectory]
			byMoving: FALSE];
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
		[_deleteButton setNavBarButtonStyle: 3];
		[_deleteButton setTitle: @"Cancel"];
		[_moveButton setEnabled: FALSE];
		[_copyButton setNavBarButtonStyle: 3];
		[_copyButton setTitle: @"Delete"];
		[_renameButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) renameButtonPressed
{
	if ([[_renameButton title] isEqualToString: @"Rename"] && [_browser currentSelectedPath] != nil)
	{
		[self resetFileOpButtons];
		[_moveButton setEnabled: FALSE];
		[_copyButton setEnabled: FALSE];
		[_deleteButton setEnabled: FALSE];
		[_renameButton setNavBarButtonStyle: 3];
		[_renameButton setTitle: @"Cancel"];
		[_newButton setNavBarButtonStyle: 3];
		[_newButton setTitle: @"Rename"];
	}
	else if ([[_renameButton title] isEqualToString: @"Cancel"])
	{
		[_browser endRenameSaving: FALSE];
		[self resetFileOpButtons];
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
		[_moveButton setNavBarButtonStyle: 3];
		[_moveButton setTitle: @"Folder"];
		[_copyButton setNavBarButtonStyle: 3];
		[_copyButton setTitle: @"File"];
		[_deleteButton setEnabled: FALSE];
		[_renameButton setEnabled: FALSE];
		[_newButton setNavBarButtonStyle: 3];
		[_newButton setTitle: @"Cancel"];
	}
	else if ([[_newButton title] isEqualToString: @"Rename"])
	{
		[_newButton setTitle: @"Done"];
		[_browser beginRenamePath: [_browser currentSelectedPath]];
	}
	else if ([[_newButton title] isEqualToString: @"Done"])
	{
		[_browser endRenameSaving: TRUE];
		[self resetFileOpButtons];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) navigationBar: (UINavigationBar*)navbar buttonClicked: (int)button 
{
	switch (button) 
	{
		case 0: //Right button
			[_browser changeDirectoryToHome];
			break;
		case 1:	//Left button
			[_browser changeDirectoryToLast];
			break;
	}
}

- (void) browserCurrentDirectoryChanged: (MFBrowser*)browser toPath: (NSString*)path;
{
	[_navBar setPrompt: [path stringByAbbreviatingWithTildeInPath]];
}

- (void) browserCurrentHighlightedPathChanged: (MFBrowser*) browser toPath: (NSString*) path;
{
	
}

- (void) browserWillLaunchApplication: (NSString*)appID withArguments: (NSArray*)args
{
	NSLog(@"Can set startup path for %@ to %@?", appID, [_browser currentDirectory]);
	//Save startup path for application
	if ([_browser mandatoryLaunchApplication] != nil)
	{
		[_settings setStartupPath: [_browser currentDirectory] 
			forApplication: [_browser mandatoryLaunchApplication]];
		[_settings writeSettings];
		NSLog(@"Set startup path for %@ to %@", appID, [_browser currentDirectory]);
	}
	[self suspendWithAnimation: FALSE];
}

- (void) applicationDidFinishLaunching: (id)unknown
{
	//Run Application
	if (_applicationID == nil)
	{
		[self runApplication];						
	}
	
	[_window _setHidden: NO];
	[self reportAppLaunchFinished];	
}

- (void) applicationSuspend: (id)unknown1 settings: (id)unknown2
{
	if ([_settings startupInLastPath] == TRUE)
	{
		[_settings setStartupPath: [_browser currentDirectory]];
	}
	[self applicationSuspended: nil];
}

- (void) applicationResume: (struct __GSEvent *)unknown
{
	[self applicationDidResume];
}

//These Methods track delegate calls made to the application
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

- (void) applicationDidFinishLaunchingSuspended: (id) unknown
{
	//Run Application
	if (_applicationID == nil)
	{
		[self runApplicationSuspended: TRUE];		
	}
	
	[_window _setHidden: YES];
	[self reportAppLaunchFinished];
}

- (void) animationWillStart: (id)unknown1 context: (id)unknown2
{

}

- (void) animationWillStart: (id)unknown
{

}

- (void) applicationResume: (struct __GSEvent *)unknown
{
	[_window _setHidden: NO];
}

- (void) applicationResume: (struct __GSEvent *)unknown1 withArguments:(id)unknown2
{
	[_window _setHidden: NO];
}

- (void)deviceOrientationChanged:(GSEvent *)event {
	textView = [[UITextView alloc] initWithFrame: CGRectMake(0.0f, 40.0f, 320.0f, 245.0f - 40.0f)];
	[_mainView addSubview:textView];
	
	[textView setText: test];
}
*/

@end

