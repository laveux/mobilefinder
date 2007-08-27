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

- (void) initApplication
{   
	//Set applicationID
	_applicationID = @"com.googlecode.MobileFinder";
	
	//Initialize window
	_window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
    [_window orderFront: self];
    [_window makeKey: self];
    [_window _setHidden: NO];
	
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
	
	//Get LaunchInfo argument, if any
	NSDictionary* launchInfo = [MSAppLauncher readLaunchInfoForAppID: _applicationID
		withApplication: self
		deletingLaunchPList: TRUE];
	if (launchInfo != nil)
	{
		
	}		
	
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
	/*
		Navigation Bar Styles
		0 - Dark Blue
		1 - Black
	*/
	_navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, navBarWidth, navBarHeight)];
	[_navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Home" leftBack: TRUE];
    [_navBar setBarStyle: 3];
	[_navBar setDelegate: self];
	[_mainView addSubview: _navBar];
	
	//Setup navigation bar buttons
	/*
		Button Styles
		0 - Dark Blue Rectangle
		1 - Dark Red Rectangle
		2 - Dark Blue Left Arrow
		3 - Light Blue Rectangle
	*/
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
	//[_renameButton setTitleFont: [UIButtonBarButton _defaultLabelFont]];
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
	[_browser openPath: [_settings startupDirPath]];
			
	//Make the browser active at start
	[self makeBrowserActive];
}

- (void) makeBrowserActive
{
	if ([_mainView containsView: _browser])
		return;
		
	[_settings removeFromSuperview];
	[_mainView addSubview: _browser];
	[_mainView addSubview: _fileOpBar];
	[_finderButton setNavBarButtonStyle: 3];
	[_settingsButton setNavBarButtonStyle: 0];
	
	//Update settings
	//TODO: This should be done here?
	//TODO: See UIControl addTarget:action:forEvents:
	[_settings writeSettings];
	[_browser setShowHiddenFiles: [_settings showHiddenFiles]];
	[_browser setLaunchApplications: [_settings launchApplications]];
	[_browser setProtectSystemFiles: [_settings protectSystemFiles]];
	[_browser setFileTypeAssociations: [_settings fileTypeAssociations]];
}

- (void) makeSettingsActive
{
	if ([_mainView containsView: _settings])
		return;
		
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
	if ([[_copyButton title] isEqualToString: @"Copy"] && [_browser currentHighlightedPath] != nil)
	{ 
		[self resetFileOpButtons];
		[_copyButton setNavBarButtonStyle: 3];
		[_copyButton setTitle: @"Cancel"];
		[_moveButton setNavBarButtonStyle: 3];
		[_moveButton setTitle: @"Paste"];
		[_deleteButton setEnabled: FALSE];
		[_renameButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		_pathSelectedForFileOp = [[NSString alloc] initWithString: [_browser currentHighlightedPath]];
	}
	else if ([[_copyButton title] isEqualToString: @"Paste"])
	{
		[_browser 
			sendSrcPath: _pathSelectedForFileOp 
			toDstPath: [_browser currentDirectory]
			byMoving: TRUE];
		[self resetFileOpButtons];
	}
	else if ([[_copyButton title] isEqualToString: @"Delete"])
	{
		NSString* currentHighlightedPath = [_browser currentHighlightedPath];
		if (currentHighlightedPath != nil)
			[_browser deletePath: currentHighlightedPath];
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
	if ([[_moveButton title] isEqualToString: @"Move"] && [_browser currentHighlightedPath] != nil)
	{ 
		[self resetFileOpButtons];
		[_moveButton setNavBarButtonStyle: 3];
		[_moveButton setTitle: @"Cancel"];
		[_copyButton setNavBarButtonStyle: 3];
		[_copyButton setTitle: @"Paste"];
		[_deleteButton setEnabled: FALSE];
		[_renameButton setEnabled: FALSE];
		[_newButton setEnabled: FALSE];
		_pathSelectedForFileOp = [[NSString alloc] initWithString: [_browser currentHighlightedPath]];
	}
	else if ([[_moveButton title] isEqualToString: @"Paste"])
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
	if ([[_deleteButton title] isEqualToString: @"Delete"] && [_browser currentHighlightedPath] != nil)
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
	if ([[_renameButton title] isEqualToString: @"Rename"] && [_browser currentHighlightedPath] != nil)
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
		[_browser beginRenamePath: [_browser currentHighlightedPath]];
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

- (void) applicationDidFinishLaunching: (id)unused
{
	//Init Application
	[self initApplication];    
}

@end //MFApp

