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
	
	//Create colors for controls
	//CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
    //float whiteComponents[4] = {1, 1, 1, 1};
    //float transparentComponents[4] = {0, 0, 0, 0};
    //float grayComponents[4] = {0.85, 0.85, 0.85, 1};
    //float blueComponents[4] = {0.208, 0.482, 0.859, 1};

	CGRect switchRect = CGRectMake(200.0f, 9.0f, 320.0f - 200.0f, 32.0f);//[_prefsTable rowHeight]);
	
	//Setup filesystem group
	_filesystemGroup = [[UIPreferencesTableCell alloc] init];
	[_filesystemGroup setTitle: @"File System"];
	[_filesystemGroup setIcon: [UIImage applicationImageNamed: @"Folder_32x32.png"]];	
	_startupDirCell = [[UIPreferencesTextTableCell alloc] init];	
	[_startupDirCell setTitle: @"Startup"];
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
	[_styleGroup setIcon: [UIImage applicationImageNamed: @"Finder_32x32.png"]];	
	_barStyleCell = [[UIPreferencesTableCell alloc] init];
	[_barStyleCell setTitle: @"Bar Style"];
	_buttonStyleCell = [[UIPreferencesTableCell alloc] init];
	[_buttonStyleCell setTitle: @"Button Style"];
	_browserBackgroundCell = [[UIPreferencesTableCell alloc] init];
	[_browserBackgroundCell setTitle: @"Background"];
	_iconSizeCell = [[UIPreferencesTableCell alloc] init];
	[_iconSizeCell setTitle: @"Icon Size"];
	
	//Setup file associations group
	_associationsGroup = [[UIPreferencesTableCell alloc] init];
	[_associationsGroup setTitle: @"File Associations"];
	[_associationsGroup setIcon: [UIImage applicationImageNamed: @"File_32x32.png"]];
	_associationsDescription = [[UIPreferencesTableCell alloc] init];
	[_associationsDescription setTitle: @"Associates a file type with an application\nEg: \"txt:com.google.code.MobileTextEdit\""];
	[_associationsDescription sizeToFit];
		
	//Read in settings from settings plist
	_settingsPath = [[NSString alloc] initWithString: settingsPath];
	[self readSettings];

	//Put prefs table into settings pane
	[self addSubview: _prefsTable];
		
	return self;
}

- (NSString*) startupDirPath
{
	return [[_startupDirCell textField] text];
}

- (BOOL) showHiddenFiles
{
	return [_showHiddenFilesSwitch value] != 0;
}

- (BOOL) launchApplications
{
	return [_launchApplicationsSwitch value] != 0;
}

- (BOOL) protectSystemFiles
{
	return [_protectSystemFilesSwitch value] != 0;
}

- (NSArray*) fileTypeAssociations
{
	NSMutableArray* fileTypeAssociations = [[NSMutableArray alloc] init];
	NSEnumerator *enumerator = [_associationsCells objectEnumerator];
	UIPreferencesTextTableCell* cell;
	while (cell = [enumerator nextObject])
	{
		NSString* fileTypeAssociation = [[cell textField] text];
		//TODO: Check filetype association for validity
		if (fileTypeAssociation != nil && [fileTypeAssociation isEqualToString: @""] == FALSE)
		{
			[fileTypeAssociations addObject: [[NSString alloc] initWithString: fileTypeAssociation]];
		}
	}
	[fileTypeAssociations autorelease];
	
	return [NSArray arrayWithArray: fileTypeAssociations];
}

- (void) setDelegate: (id)delegate
{
	_delegate = delegate;
}

- (void) readSettings
{
	//Set defaults for simple settings
	[[_startupDirCell textField] setText: @"/Applications"];
	[_showHiddenFilesSwitch setValue: 0];
	[_launchApplicationsSwitch setValue: 1];
	[_protectSystemFilesSwitch setValue: 1];
	
	//Ensure we have a clean filetype cell array
	if (_associationsCells != nil)
		[_associationsCells makeObjectsPerformSelector: @selector(release)];
	[_associationsCells release];				
	_associationsCells = [[NSMutableArray alloc] init];
	
	//Create a cell for adding a filetype
	[_associationsCells addObject: [[UIPreferencesTextTableCell alloc] init]];
		
	//Read in settings to replace defaults
	if ([[NSFileManager defaultManager] isReadableFileAtPath: _settingsPath])
	{
		NSDictionary* settingsDict = [NSDictionary dictionaryWithContentsOfFile: _settingsPath];
		NSEnumerator* enumerator = [settingsDict keyEnumerator];
		NSString* currKey;
		while (currKey = [enumerator nextObject]) 
		{					
			if ([currKey isEqualToString: @"MFStartupDir"])
			{
				[[_startupDirCell textField] setText: [[settingsDict valueForKey: currKey] stringByAbbreviatingWithTildeInPath]];
			}
			if ([currKey isEqualToString: @"MFShowHiddenFiles"])
			{
				[_showHiddenFilesSwitch setValue: [[settingsDict valueForKey: currKey] intValue]];
			}
			if ([currKey isEqualToString: @"MFLaunchApplications"])
			{
				[_launchApplicationsSwitch setValue: [[settingsDict valueForKey: currKey] intValue]];
			}
			if ([currKey isEqualToString: @"MFProtectSystemFiles"])
			{
				[_protectSystemFilesSwitch setValue: [[settingsDict valueForKey: currKey] intValue]];
			}
			if ([currKey isEqualToString: @"MFFileTypeAssociations"])
			{
				//Get filetype associations and create cells for them, inserting behind the empty cell
				NSArray* fileTypeAssociations = [settingsDict objectForKey: currKey];
				if (fileTypeAssociations != nil && [fileTypeAssociations count] > 0)
				{
					NSEnumerator* enumerator = [fileTypeAssociations objectEnumerator];
					NSString* fileTypeAssociation;
					while (fileTypeAssociation = [enumerator nextObject])
					{					
						UIPreferencesTextTableCell* cell = [[UIPreferencesTextTableCell alloc] init];
						[_associationsCells insertObject: cell 
							atIndex: [_associationsCells count] - 1];
						[[cell textField] setText: fileTypeAssociation];
					}
				}
			}
		}		
	}
	
	[_prefsTable reloadData];
}

- (void) writeSettings
{
	//Verify settings
	//TODO: Error message on invalid setting
	BOOL startDirIsDirectory;	
	NSString* startDir = [[_startupDirCell textField] text];
	startDir = [startDir stringByStandardizingPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath: startDir isDirectory: &startDirIsDirectory] == FALSE || 
		startDirIsDirectory == FALSE)
	{
		startDir = [[NSString alloc] initWithString: @"/Applications"]; 
	}
	startDir = [startDir stringByAbbreviatingWithTildeInPath];
	NSString* showHiddenFilesValue = [_showHiddenFilesSwitch value] == 0 ? @"0" : @"1";
	NSString* launchApplicationsValue = [_launchApplicationsSwitch value] == 0 ? @"0" : @"1";
	NSString* protectSystemFilesValue = [_protectSystemFilesSwitch value] == 0 ? @"0" : @"1";
	NSArray* fileTypeAssociations = [self fileTypeAssociations];
	
	//Build settings dictionary
	NSDictionary* settingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
		startDir, @"MFStartupDir",
		showHiddenFilesValue, @"MFShowHiddenFiles",
		launchApplicationsValue, @"MFLaunchApplications",
		protectSystemFilesValue, @"MFProtectSystemFiles",
		fileTypeAssociations, @"MFFileTypeAssociations",
		nil];
	
	//Seralize settings dictionary
	NSString* error;
	NSData* rawPList = [NSPropertyListSerialization dataFromPropertyList: settingsDict		
		format: NSPropertyListXMLFormat_v1_0
		errorDescription: &error];
	
	//Write settings plist file
	[rawPList writeToFile: _settingsPath atomically: YES];
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 6;
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
		case 4: return 2;
		case 5: return [_associationsCells count];
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
		case 4: return _associationsGroup;
		case 5: return _associationsGroup;
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
		case 4: return TRUE;
		case 5: return FALSE;
		default: return TRUE;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table 
	heightForRow: (int)row 
	inGroup: (int)group 
	withProposedHeight: (float)proposed 
{
	float groupLabelSize = 32.0f;
	
	switch (group)
	{
		case 0: return groupLabelSize;
		case 2:	return groupLabelSize;
		case 4:	
			switch (row)
			{
				case 0: return groupLabelSize;
				case 1: return proposed;
			}
		default: return proposed;
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
		case 4: 
			switch (row)
			{
				case 0: return _associationsGroup;
				case 1: return _associationsDescription;
			}
		case 5: return [_associationsCells objectAtIndex: row];		
		default: return nil;
	}
}

@end