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
	UIPreferencesTableCell* _showHiddenFilesCell;
	UIPreferencesTableCell* _launchApplicationsCell;
	UIPreferencesTableCell* _protectSystemFilesCell;
	
	UIPreferencesTableCell* _styleGroup;
	UIPreferencesTableCell* _barStyleCell;
	UIPreferencesTableCell* _buttonStyleCell;
	UIPreferencesTableCell* _browserBackgroundCell;
	UIPreferencesTableCell* _iconSizeCell;
	
	UISwitchControl* _showHiddenFilesSwitch;
	UISwitchControl* _launchApplicationsSwitch;
	UISwitchControl* _protectSystemFilesSwitch;
	
	NSString* _settingsPath;
	id _delegate;
}
- (id) initWithFrame: (struct CGRect)rect
	withSettingsPath: (NSString*)settingsPath;
- (NSString*) startupDirPath;
- (BOOL) showHiddenFiles;
- (BOOL) launchApplications;
- (BOOL) protectSystemFiles;
- (void) setDelegate: (id)delegate;
- (void) readSettings;
- (void) writeSettings;

@end