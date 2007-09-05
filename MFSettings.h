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

@interface MFSettings : UIView
{
	UIPreferencesTable* _prefsTable;
	
	UIPreferencesTableCell* _filesystemGroup;
	UIPreferencesTextTableCell* _startupDirCell;
	UIPreferencesTableCell* _startupInLastPathCell;
	UIPreferencesTableCell* _showHiddenFilesCell;
	UIPreferencesTableCell* _launchApplicationsCell;
	UIPreferencesTableCell* _launchExecutablesCell;
	UIPreferencesTableCell* _protectSystemFilesCell;
	
	UIPreferencesTableCell* _appearenceGroup;
	UIPreferencesTableCell* _browserRowHeightCell;	
	
	UIPreferencesTableCell* _associationsGroup;
	NSMutableArray* _associationsCells;
	
	UISwitchControl* _startupInLastPathSwitch;
	UISwitchControl* _showHiddenFilesSwitch;
	UISwitchControl* _launchApplicationsSwitch;
	UISwitchControl* _launchExecutablesSwitch;
	UISwitchControl* _protectSystemFilesSwitch;
	UISliderControl* _browserRowHeightSlider;
	
	NSMutableDictionary* _applicationStartupPaths;
	
	NSString* _settingsPath;
	id _delegate;
}
- (id) initWithFrame: (struct CGRect)rect withSettingsPath: (NSString*)settingsPath;
- (void) dealloc;
- (id) delegate;
- (NSString*) startupPath;
- (BOOL) startupInLastPath;
- (BOOL) showHiddenFiles;
- (BOOL) launchApplications;
- (BOOL) launchExecutables;
- (BOOL) protectSystemFiles;
- (int) browserRowHeight;
- (NSArray*) fileTypeAssociations;
- (NSString*) startupPathForApplication: (NSString*)appID;
- (void) setDelegate: (id)delegate;
- (void) setStartupPath: (NSString*)startupPath;
- (void) setStartupInLastPath: (BOOL)startupInLastPath;
- (void) setShowHiddenFiles: (BOOL)showHiddenFiles;
- (void) setLaunchApplications: (BOOL)launchApplications;
- (void) setLaunchExecutables: (BOOL)launchExecutables;
- (void) setProtectSystemFiles: (BOOL)protectSystemFiles;
- (void) setBrowserRowHeight: (int)value;
- (void) setFileTypeAssociations: (NSArray*)fileTypeAssociations;
- (void) setStartupPath: (NSString*)path forApplication: (NSString*)appID;
- (void) readSettings;
- (void) writeSettings;

@end