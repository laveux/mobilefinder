/*
	MobileFinderApp.m
	
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
#import "MobileFinderApp.h"

@implementation MobileFinderApp

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
	
	//Control placement values
	float navBarWidth = 320.0f;
	float navBarHeight = 74.0f;
	float navBarSouthBuffer = 5.0f;
	float moveButtonWidth = 56.0f;
	float copyButtonWidth = 56.0f;
	float deleteButtonWidth = 56.0;
	float buttonHeight = 32.0f;
	float buttonBuffer = 4.0f;
	  
	//Setup navigation var
	//CGSize navBarDefaultSize = [UINavigationBar defaultSizeWithPrompt];
	//TODO: Delete, New, and Copy buttons
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
	
	//Setup file operation buttons
	/*
		Button Styles
		0 - Dark Blue Rectangle
		1 - Dark Red Rectangle
		2 - Dark Blue Left Arrow
		3 - Light Blue Rectangle
	*/
	_copyButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		navBarWidth / 2.0f - moveButtonWidth / 2.0f - copyButtonWidth - buttonBuffer,
		navBarHeight - buttonHeight - navBarSouthBuffer, 
		copyButtonWidth, buttonHeight)];
	[_copyButton setAutosizesToFit: FALSE];
	[_copyButton addTarget: self action: @selector(copyButtonPressed) forEvents: 1];
	[self resetFileOpButtons];
	[_navBar addSubview: _copyButton];
	
	_moveButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		navBarWidth / 2.0f - copyButtonWidth / 2.0f, 
		navBarHeight - buttonHeight - navBarSouthBuffer, 
		moveButtonWidth, buttonHeight)];
	[_moveButton setAutosizesToFit: FALSE];
	[_moveButton addTarget: self action: @selector(moveButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_navBar addSubview: _moveButton];
	
	_deleteButton = [[UINavBarButton alloc] initWithFrame: CGRectMake(
		navBarWidth / 2.0f - deleteButtonWidth / 2.0f + copyButtonWidth + buttonBuffer, 
		navBarHeight - buttonHeight - navBarSouthBuffer, 
		deleteButtonWidth, buttonHeight)];
	[_deleteButton setAutosizesToFit: FALSE];
	[_deleteButton addTarget: self action: @selector(deleteButtonPressed) forEvents: 1];	
	[self resetFileOpButtons];
	[_navBar addSubview: _deleteButton];
	
	//Setup the file browser
	_browser = [[MobileFinderBrowser alloc] initWithFrame: CGRectMake(0.0f, 74.0f, 320.0f, 480.0f - 74.0f - 16.0f)];
	[_browser setDelegate: self];
	[_mainView addSubview: _browser];
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
			[_copyButton setNavBarButtonStyle: 1];
			[_copyButton setTitle: @"Cancel"];
			[_moveButton setNavBarButtonStyle: 1];
			[_moveButton setTitle: @"Paste"];
			[_deleteButton setEnabled: FALSE];
			_pathSelectedForFileOp = [[NSString alloc] initWithString: [_browser currentSelectedPath]];
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
			[_moveButton setNavBarButtonStyle: 1];
			[_moveButton setTitle: @"Cancel"];
			[_copyButton setEnabled: FALSE];
			[_deleteButton setNavBarButtonStyle: 1];
			[_deleteButton setTitle: @"Paste"];
			_pathSelectedForFileOp = [[NSString alloc] initWithString: [_browser currentSelectedPath]];
		}
		else if ([[_moveButton title] isEqualToString: @"Paste"])
		{
			//This is for when the copy button is pressed, and the move button turns to "Paste"
			[_browser 
				sendSrcPath: _pathSelectedForFileOp 
				ToDstPath: [_browser currentDirectory]
				ByMoving: FALSE];
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
			[_deleteButton setNavBarButtonStyle: 1];
			[_deleteButton setTitle: @"Cancel"];
			[_moveButton setEnabled: FALSE];
			[_copyButton setNavBarButtonStyle: 1];
			[_copyButton setTitle: @"Delete"];
		}
		else if ([[_deleteButton title] isEqualToString: @"Paste"])
		{
			//This is for when the move button is pressed, and the delete button turns to "Paste"
			[_browser 
				sendSrcPath: _pathSelectedForFileOp 
				ToDstPath: [_browser currentDirectory]
				ByMoving: TRUE];
			[self resetFileOpButtons];
		}
		else
		{
			[self resetFileOpButtons];
		}
	}
}

- (void) browserCurrentDirectoryChanged: (MobileFinderBrowser*)browser ToPath: (NSString*)path;
{
	[_navBar setPrompt: path];
}

- (void) browserCurrentSelectedPathChanged: (MobileFinderBrowser*) browser ToPath: (NSString*) path;
{
	//[self resetFileOpButtons];
}

- (void) applicationDidFinishLaunching: (id)unused
{
	//Init Application
	[self initApplication];    
}

@end //MobileFinderApp
