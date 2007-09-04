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
#import <UIKit/UIGradientBar.h>
#import "MFBrowser.h"
#import "MFSettings.h"

@interface MFApp : UIApplication
{
	NSString* _applicationID;
	NSString* _launchingApplicationID;
	UIWindow* _window;
	UIView* _mainView;
	MFBrowser* _browser;
	MFSettings* _settings;
	UINavigationBar* _navBar;
	UINavBarButton* _finderButton;
	UINavBarButton* _settingsButton;
	UIGradientBar* _fileOpBar;
	UINavBarButton* _moveButton;
	UINavBarButton* _copyButton;
	UINavBarButton* _deleteButton;
	UINavBarButton* _renameButton;
	UINavBarButton* _newButton;
		
	NSString* _pathSelectedForFileOp;
}
- (void) runApplication;
- (void) dealloc;
- (void) resumeApplication;
- (void) suspendApplication;
- (void) getLaunchInfo;
- (void) makeBrowserActive;
- (void) makeSettingsActive;
- (void) resetFileOpButtons;
- (void) copyButtonPressed;
- (void) moveButtonPressed;
- (void) deleteButtonPressed;
- (void) renameButtonPressed;
- (void) newButtonPressed;
- (void) navigationBar: (UINavigationBar*)navbar buttonClicked: (int)button;
- (void) browserCurrentDirectoryChanged: (MFBrowser*)browser toPath: (NSString*)path;
- (void) browserCurrentHighlightedPathChanged: (MFBrowser*) browser toPath: (NSString*) path;
@end

