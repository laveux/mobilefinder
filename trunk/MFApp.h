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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import "MFBrowser.h"

@interface MFApp : UIApplication 
{
	UIWindow* _window;
	UIView* _mainView;
	MFBrowser* _browser;
	UINavigationBar* _navBar;
	UINavBarButton* _moveButton;
	UINavBarButton* _copyButton;
	UINavBarButton* _deleteButton;
	//UIButtonBar* _buttonBar;
	//UIButtonBarTextButton* _settingsButton;
	NSString* _pathSelectedForFileOp;
}
- (void) initApplication;
- (void) navigationBar: (UINavigationBar*)navbar buttonClicked: (int)button;
- (void) resetFileOpButtons;
- (void) copyButtonPressed;
- (void) moveButtonPressed;
- (void) deleteButtonPressed;
- (void) browserCurrentDirectoryChanged: (MFBrowser*)browser ToPath: (NSString*)path;
- (void) browserCurrentSelectedPathChanged: (MFBrowser*) browser ToPath: (NSString*) path;
@end

