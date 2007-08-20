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
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UITextField.h>
#import <UIKit/UIImage.h>
#import "MFSettings.h"

@implementation MFSettings : UIView

- (id) initWithFrame: (struct CGRect)rect
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	//Setup preferences table
	_prefsTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
	_prefsTableColumn = [[UITableColumn alloc] initWithTitle: @"Settings" identifier: @"Settings" width: rect.size.width];
	[_prefsTable addTableColumn: _prefsTableColumn]; 
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

	//Setup startup group
	_startGroup = [[UIPreferencesTableCell alloc] init];
	[_startGroup setTitle: @"Startup"];
	_startDirCell = [[UIPreferencesTextTableCell alloc] init];	
	[_startDirCell setTitle: @"Start Folder"];
	[[_startDirCell textField] setText: @"/Applications"];
	[_startDirCell setIcon: [UIImage applicationImageNamed: @"Folder_16x16.png"]];
		
	[self addSubview: _prefsTable];
	
	return self;
}

- (void) setDelegate: (id)delegate
{
	_delegate = delegate;
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 2;
}

- (int) preferencesTable: (UIPreferencesTable*)table 
	numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 0;
		case 1: return 1;
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
	cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _startGroup;
		case 1: return _startGroup;
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
		default: return TRUE;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
    cellForRow: (int)row 
    inGroup: (int)group 
{
	switch (group)
	{
		case 0: return _startGroup;
		case 1:
			switch (row)
			{
				case 0:	return _startDirCell;
			}
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table 
	heightForRow: (int)row 
	inGroup: (int)group 
	withProposedHeight: (float)proposed 
{
	float groupLabelBuffer = 12.0f;
	
	switch (group)
	{
		case 0: return proposed + groupLabelBuffer;
		default: return proposed;
	}
}

@end