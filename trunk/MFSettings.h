/*
	MFSettings.h
	
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
#import <UIKit/UIView.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UINavBarButton.h>

@class MFApp;

@interface MFSettings : UIView
{
	MFApp* _app;
	
	UIPreferencesTable* _prefsTable;
	
	UIPreferencesTableCell* _filesystemGroup;
	UIPreferencesTextTableCell* _startupDirCell;
	UIPreferencesTableCell* _startupInLastPathCell;
	UIPreferencesTableCell* _showHiddenFilesCell;
	UIPreferencesTableCell* _showDotDotCell;
	UIPreferencesTableCell* _sortFilesCell;
	UIPreferencesTableCell* _launchApplicationsCell;
	UIPreferencesTableCell* _launchExecutablesCell;
	UIPreferencesTableCell* _protectSystemFilesCell;
	UIPreferencesTableCell* _closeAppCell;
	
	UIPreferencesTableCell* _appearenceGroup;
	UIPreferencesTableCell* _browserRowHeightCell;	
	UIPreferencesTableCell* _buttonStylesCell;	
	UIPreferencesTableCell* _barStylesCell;
	
	UIPreferencesTableCell* _associationsGroup;
	NSMutableArray* _associationsCells;
	
	UISwitchControl* _startupInLastPathSwitch;
	UISwitchControl* _showHiddenFilesSwitch;
	UISwitchControl* _showDotDotSwitch;
	UISwitchControl* _sortFilesSwitch;
	UISwitchControl* _launchApplicationsSwitch;
	UISwitchControl* _launchExecutablesSwitch;
	UISwitchControl* _protectSystemFilesSwitch;
	UISliderControl* _browserRowHeightSlider;
	UINavBarButton* _closeAppButton;
	UINavBarButton* _buttonStyleBlueButton;
	UINavBarButton* _buttonStyleRedButton;
	UINavBarButton* _barStyleBlueButton;
	UINavBarButton* _barStyleBlackButton;
	
	NSMutableDictionary* _applicationStartupPaths;
	int _buttonInactiveStyle;
	int _buttonActiveStyle;
	int _buttonBackStyle;
	int _barStyle;
	
	NSString* _settingsPath;
	id _delegate;
}
- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath withMFApp: (MFApp*)app;
- (void) dealloc;
- (id) delegate;
- (NSString*) startupPath;
- (BOOL) startupInLastPath;
- (BOOL) showHiddenFiles;
- (BOOL) showDotDot;
- (BOOL) sortFiles;
- (BOOL) launchApplications;
- (BOOL) launchExecutables;
- (BOOL) protectSystemFiles;
- (int) browserRowHeight;
- (int) buttonInactiveStyle;
- (int) buttonActiveStyle;
- (int) buttonBackStyle;
- (int) barStyle;
- (NSArray*) fileTypeAssociations;
- (NSString*) startupPathForApplication: (NSString*)appID;
- (void) setDelegate: (id)delegate;
- (void) setStartupPath: (NSString*)startupPath;
- (void) setStartupInLastPath: (BOOL)startupInLastPath;
- (void) setShowHiddenFiles: (BOOL)showHiddenFiles;
- (void) setShowDotDot: (BOOL)showDotDot;
- (void) setSortFiles: (BOOL)sortFiles;
- (void) setLaunchApplications: (BOOL)launchApplications;
- (void) setLaunchExecutables: (BOOL)launchExecutables;
- (void) setProtectSystemFiles: (BOOL)protectSystemFiles;
- (void) setBrowserRowHeight: (int)value;
- (void) setButtonInactiveStyle: (int)style;
- (void) setButtonActiveStyle: (int)style;
- (void) setButtonBackStyle: (int)style;
- (void) setButtonStyleBlue;
- (void) setButtonStyleRed;
- (void) setBarStyle: (int)style;
- (void) setBarStyleBlue;
- (void) setBarStyleBlack;
- (void) setFileTypeAssociations: (NSArray*)fileTypeAssociations;
- (void) setStartupPath: (NSString*)path forApplication: (NSString*)appID;
- (void) readSettings;
- (void) writeSettings;

@end