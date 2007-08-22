/*
	MFSettings.m
	
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
#import <UIKit/CDStructures.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UITable.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UITextField.h>
#import <UIKit/UIImage.h>
#import <UIKit/UISliderControl.h>
#import <UIKit/UISwitchControl.h>
#import "MFSettings.h"

@implementation MFSettings : UIView

- (id) initWithFrame: (struct CGRect)rect
	withSettingsPath: (NSString*)settingsPath
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	//Setup preferences table
	_prefsTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
	[_prefsTable setDataSource: self];
    [_prefsTable setDelegate: self];
	//[_prefsTable setRowHeight: 64.0f];
	[_prefsTable reloadData];

	//Create colors for controls
	//CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
    //float whiteComponents[4] = {1, 1, 1, 1};
    //float transparentComponents[4] = {0, 0, 0, 0};
    //float grayComponents[4] = {0.85, 0.85, 0.85, 1};
    //float blueComponents[4] = {0.208, 0.482, 0.859, 1};

	CGRect switchRect = CGRectMake(200.0f, 9.0f, 320.0f - 200.0f, 32.0f);//[_prefsTable rowHeight]);
	
	//Setup filesystem group
	_filesystemGroup = [[UIPreferencesTableCell alloc] init];
	[_filesystemGroup setTitle: @"Filesystem"];
	_startupDirCell = [[UIPreferencesTextTableCell alloc] init];	
	[_startupDirCell setTitle: @"Startup"];
	[_startupDirCell setIcon: [UIImage applicationImageNamed: @"Folder_32x32.png"]];	
	_showHiddenFilesCell = [[UIPreferencesTableCell alloc] init];
	[_showHiddenFilesCell setTitle: @"Show Hidden Files"];
	_showHiddenFilesSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_showHiddenFilesCell addSubview: _showHiddenFilesSwitch];
	_launchApplicationsCell = [[UIPreferencesTableCell alloc] init];
	[_launchApplicationsCell setTitle: @"Application Launch"];
	_launchApplicationsSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_launchApplicationsCell addSubview: _launchApplicationsSwitch];
	_protectSystemFilesCell = [[UIPreferencesTableCell alloc] init];
	[_protectSystemFilesCell setTitle: @"Protect System Files"];
	_protectSystemFilesSwitch = [[UISwitchControl alloc] initWithFrame: switchRect];
	[_protectSystemFilesCell addSubview: _protectSystemFilesSwitch];
	
	//Setup styles group
	_styleGroup = [[UIPreferencesTableCell alloc] init];
	[_styleGroup setTitle: @"Visuals"];	
	_barStyleCell = [[UIPreferencesTableCell alloc] init];
	[_barStyleCell setTitle: @"Bar Style"];
	_buttonStyleCell = [[UIPreferencesTableCell alloc] init];
	[_buttonStyleCell setTitle: @"Button Style"];
	_browserBackgroundCell = [[UIPreferencesTableCell alloc] init];
	[_browserBackgroundCell setTitle: @"Background"];
	_iconSizeCell = [[UIPreferencesTableCell alloc] init];
	[_iconSizeCell setTitle: @"Icon Size"];
	
	//TODO: Show hidden files toggle
	//TODO: Color settings
	//TODO: Filetype associations
	
	[self addSubview: _prefsTable];
	
	//Read in settings from Settings.plist
	_settingsPath = [[NSString alloc] initWithString: settingsPath];
	[self readSettings];
	
	return self;
}

- (NSString*) startupDirPath
{
	return [[_startupDirCell textField] text];
}

- (BOOL) showHiddenFiles
{
	return [_showHiddenFilesSwitch value] == 1;
}

- (BOOL) launchApplications
{
	return TRUE;//[_launchApplicationsSwitch value] == 1;
}

- (BOOL) protectSystemFiles
{
	return TRUE;//[_protectSystemFilesSwitch value] == 1;
}

- (void) setDelegate: (id)delegate
{
	_delegate = delegate;
}

- (void) readSettings
{
	//Set defaults
	[[_startupDirCell textField] setText: @"/Applications"];
	[_showHiddenFilesSwitch setValue: 0];
	[_launchApplicationsSwitch setValue: 1];
	[_protectSystemFilesSwitch setValue: 1];
	
	//Read in settings to replace defaults
	NSLog(@"Reading settings from %@", _settingsPath);	
	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath] == FALSE)
	{
		NSLog(@"Read from %@ failed!  Using defaults.", _settingsPath);
	}
	else
	{
		NSDictionary* settingsDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
		NSEnumerator* enumerator = [settingsDict keyEnumerator];
		NSString* currKey;
		while (currKey = [enumerator nextObject]) 
		{					
			if ([currKey isEqualToString: @"MFStartupDir"])
			{
				[[_startupDirCell textField] setText: [settingsDict valueForKey: currKey]];
			}
		}
	}
}

- (void) writeSettings
{
	NSLog(@"Writing settings to %@", _settingsPath);
	
	//Verify settings
	//TODO: Error message on invalid setting
	BOOL startDirIsDirectory;	
	NSString* startDir = [[_startupDirCell textField] text];
	if ([[NSFileManager defaultManager] fileExistsAtPath: startDir isDirectory: &startDirIsDirectory] == FALSE || 
		startDirIsDirectory == FALSE)
	{
		NSLog(@"Path for start dir \"%@\" is invalid. Using \"/Applications\"", startDir);
		startDir = [[NSString alloc] initWithString: @"/Applications"]; 
	}
	else
		NSLog(@"Start dir: \"%@\"", startDir);
	
	//Build settings dictionary
	NSDictionary* settingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		startDir, @"MFStartupDir",
		nil];
	
	//Seralize settings dictionary
	NSString* error;
	NSData* rawPList = [NSPropertyListSerialization dataFromPropertyList: settingsDict		
		format: NSPropertyListXMLFormat_v1_0
		errorDescription: &error];
	
	//Write settings plist file
	[rawPList writeToFile: _settingsPath atomically: YES];
	NSLog(@"Settings written to %@", _settingsPath);
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 4;
}

- (int) preferencesTable: (UIPreferencesTable*)table 
	numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 0;
		case 1: return 4;
		case 2: return 0;
		case 3: return 4;
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
	cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _filesystemGroup;
		case 1: return _filesystemGroup;
		case 2: return _styleGroup;
		case 3: return _styleGroup;
		default: return nil;
	}
} 

- (BOOL) preferencesTable: (UIPreferencesTable*)table 
    isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return TRUE;
		case 1: return FALSE;
		case 2: return TRUE;
		case 3: return FALSE;
		default: return TRUE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
    cellForRow: (int)row 
    inGroup: (int)group 
{
	switch (group)
	{
		case 0: return _filesystemGroup;
		case 1:
			switch (row)
			{
				case 0:	return _startupDirCell;
				case 1: return _showHiddenFilesCell;
				case 2: return _launchApplicationsCell;
				case 3: return _protectSystemFilesCell;
			}
		case 2: return _styleGroup;
		case 3:
			switch (row)
			{
				case 0:	return _barStyleCell;
				case 1:	return _buttonStyleCell;
				case 2:	return _browserBackgroundCell;
				case 3:	return _iconSizeCell;
			}
		default: return nil;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table 
	heightForRow: (int)row 
	inGroup: (int)group 
	withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 16.0f;
	
	switch (group)
	{
		case 0: return proposed + groupLabelBuffer;
		case 2:	return proposed + groupLabelBuffer;
		default: return proposed;
	}
}

@end