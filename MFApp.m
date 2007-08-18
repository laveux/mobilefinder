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

@implementation MFApp : UIApplication

- (void) initApplication
{   
	//int screenOrientation = [UIHardware deviceOrientation: YES];
	
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
	float moveButtonWidth = 60.0f;
	float copyButtonWidth = 60.0f;
	float deleteButtonWidth = 60.0f;
	float makeDirButtonWidth = 60.0f;
	float makeFileButtonWidth = 60.0f;
	  
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
		fileOpBarWidth / 2.0f - deleteButtonWidth / 2.0f - moveButtonWidth - copyButtonWidth - fileOpBarButtonBuffer * 2.0,
		fileOpBarNorthBuffer, 
		copyButtonWidth, fileOpBarButtonHeight)];
	[_copyButton setAutosizesToFit: FALSE];
	[_copyButton addTarget: self action: @selector(copyButtonPressed) forEvents: 1];
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _copyButton];
	
	_moveButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f - deleteButtonWidth / 2.0f - moveButtonWidth - fileOpBarButtonBuffer * 1.0, 
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
	
	_makeDirButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f + deleteButtonWidth / 2.0f + fileOpBarButtonBuffer * 1.0, 
		fileOpBarNorthBuffer, 
		makeDirButtonWidth, fileOpBarButtonHeight)];
	[_makeDirButton setAutosizesToFit: FALSE];
	//[_makeDirButton setTitleFont: [UIButtonBarButton _defaultLabelFont]];
	[_makeDirButton addTarget: self action: @selector(makeDirButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _makeDirButton];
	
	_makeFileButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		fileOpBarWidth / 2.0f + deleteButtonWidth / 2.0f + makeDirButtonWidth + fileOpBarButtonBuffer * 2.0, 
		fileOpBarNorthBuffer, 
		makeFileButtonWidth, fileOpBarButtonHeight)];
	[_makeFileButton setAutosizesToFit: FALSE];
	[_makeFileButton addTarget: self action: @selector(makeFileButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_fileOpBar addSubview: _makeFileButton];
		
	//Setup the file browser
	_browser = [[MFBrowser alloc] initWithApplication: self andFrame: CGRectMake(
		0.0f, 
		navBarHeight, 
		screenRect.size.width, screenRect.size.height - navBarHeight - fileOpBarHeight)];
	[_browser setDelegate: self];
	[_browser changeDirectoryToApplications];
	
	//Setup the settings pane
	_settings = [[MFSettings alloc] initWithFrame: CGRectMake(
		0.0f, 
		navBarHeight, 
		screenRect.size.width, screenRect.size.height - navBarHeight)];
	[_settings setDelegate: self];
	
	//Make the browser active at start
	[self makeBrowserActive];
}

- (void) makeBrowserActive
{
	[_settings removeFromSuperview];
	[_mainView addSubview: _browser];
	[_mainView addSubview: _fileOpBar];
	[_finderButton setNavBarButtonStyle: 3];
	[_settingsButton setNavBarButtonStyle: 0];
}

- (void) makeSettingsActive
{
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
	if (_makeDirButton != nil)
	{
		[_makeDirButton setNavBarButtonStyle: 0];
		[_makeDirButton setTitle: @"MK Dir"];
		[_makeDirButton setEnabled: TRUE];
	}
	if (_makeFileButton != nil)
	{
		[_makeFileButton setNavBarButtonStyle: 0];
		[_makeFileButton setTitle: @"MK File"];
		[_makeFileButton setEnabled: TRUE];
	}
}

- (void) copyButtonPressed
{
	if ([_browser currentSelectedPath] == nil)
	{
		[self resetFileOpButtons];
	}
	else
	{
		if ([[_copyButton title] isEqualToString: @"Copy"] && [_browser currentSelectedPath] != nil)
		{ 
			[self resetFileOpButtons];
			[_copyButton setNavBarButtonStyle: 3];
			[_copyButton setTitle: @"Cancel"];
			[_moveButton setNavBarButtonStyle: 3];
			[_moveButton setTitle: @"Paste"];
			[_deleteButton setEnabled: FALSE];
			[_makeDirButton setEnabled: FALSE];
			[_makeFileButton setEnabled: FALSE];
			_pathSelectedForFileOp = [[NSString alloc] initWithString: [_browser currentSelectedPath]];
		}
		else if ([[_deleteButton title] isEqualToString: @"Paste"])
		{
			//This is for when the move button is pressed, and the copy button turns to "Paste"
			[_browser 
				sendSrcPath: _pathSelectedForFileOp 
				toDstPath: [_browser currentDirectory]
				byMoving: TRUE];
			[self resetFileOpButtons];
		}
		else if ([[_copyButton title] isEqualToString: @"Delete"])
		{
			//This is for when the delete button is pressed, and the copy button turns to "Delete"
			[_browser deletePath: [_browser currentSelectedPath]];
			[self resetFileOpButtons];
		}
		else
		{
			[self resetFileOpButtons];
		}
	}
}

- (void) moveButtonPressed
{
	if ([_browser currentSelectedPath] == nil)
	{
		[self resetFileOpButtons];
	}
	else
	{
		if ([[_moveButton title] isEqualToString: @"Move"] && [_browser currentSelectedPath] != nil)
		{ 
			[self resetFileOpButtons];
			[_moveButton setNavBarButtonStyle: 3];
			[_moveButton setTitle: @"Cancel"];
			[_copyButton setNavBarButtonStyle: 3];
			[_copyButton setTitle: @"Paste"];
			[_deleteButton setEnabled: FALSE];
			[_makeDirButton setEnabled: FALSE];
			[_makeFileButton setEnabled: FALSE];
			_pathSelectedForFileOp = [[NSString alloc] initWithString: [_browser currentSelectedPath]];
		}
		else if ([[_moveButton title] isEqualToString: @"Paste"])
		{
			//This is for when the copy button is pressed, and the move button turns to "Paste"
			[_browser 
				sendSrcPath: _pathSelectedForFileOp 
				toDstPath: [_browser currentDirectory]
				byMoving: FALSE];
			[self resetFileOpButtons];
		}
		else
		{
			[self resetFileOpButtons];
		}
	}
}

- (void) deleteButtonPressed
{
	if ([_browser currentSelectedPath] == nil)
	{
		[self resetFileOpButtons];
	}
	else
	{
		if ([[_deleteButton title] isEqualToString: @"Delete"])
		{
			[self resetFileOpButtons];
			[_deleteButton setNavBarButtonStyle: 3];
			[_deleteButton setTitle: @"Cancel"];
			[_moveButton setEnabled: FALSE];
			[_copyButton setNavBarButtonStyle: 3];
			[_copyButton setTitle: @"Delete"];
			[_makeDirButton setEnabled: FALSE];
			[_makeFileButton setEnabled: FALSE];
		}
		else
		{
			[self resetFileOpButtons];
		}
	}
}

- (void) makeDirButtonPressed
{
	if ([[_makeDirButton title] isEqualToString: @"MK Dir"])
	{
		[self resetFileOpButtons];
		[_moveButton setEnabled: FALSE];
		[_copyButton setEnabled: FALSE];
		[_deleteButton setEnabled: FALSE];
		[_makeDirButton setNavBarButtonStyle: 3];
		[_makeDirButton setTitle: @"Cancel"];
		[_makeFileButton setNavBarButtonStyle: 3];
		[_makeFileButton setTitle: @"MK Dir"];
	}
	else if ([[_makeDirButton title] isEqualToString: @"MK File"])
	{
		//This is for when the make file button is pressed, and the make directory button turns to "MK File"
		[_browser makeFileAtPath: @"untitled file"];
		[self resetFileOpButtons];
	}
	else
	{
		[self resetFileOpButtons];
	}
}

- (void) makeFileButtonPressed
{
	if ([[_makeFileButton title] isEqualToString: @"MK File"])
	{
		[self resetFileOpButtons];
		[_moveButton setEnabled: FALSE];
		[_copyButton setEnabled: FALSE];
		[_deleteButton setEnabled: FALSE];
		[_makeDirButton setNavBarButtonStyle: 3];
		[_makeDirButton setTitle: @"MK File"];
		[_makeFileButton setNavBarButtonStyle: 3];
		[_makeFileButton setTitle: @"Cancel"];
	}
	else if ([[_makeFileButton title] isEqualToString: @"MK Dir"])
	{
		//This is for when the make file button is pressed, and the make directory button turns to "MK File"
		[_browser makeDirectoryAtPath: @"untitled folder"];
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
	[_navBar setPrompt: path];
}

- (void) browserCurrentSelectedPathChanged: (MFBrowser*) browser toPath: (NSString*) path;
{
	//[self resetFileOpButtons];
}

- (void) applicationDidFinishLaunching: (id)unused
{
	//Init Application
	[self initApplication];    
}

@end //MFApp

