/*
	MFAppSelector.m
	
	Finder application selector control
	
	Copyright 2007 Matt Stoker
	Begun: Aug/10/2007
	
	Thanks: iPhone Dev Team
	Compilation Toolchain and Hello World Applicaiton
	
	Thanks: Launcher.app Dev Team
	Basic idea for application launch
	
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
#import "MFAppSelector.h"
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UIControl.h>

@implementation MFAppSelector : UIView

- (id) initWithFrame: (struct CGRect)frame
{
	//Init view with frame rect
	self = [super initWithFrame: frame];
	
	//Setup preferences table
	_appTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
	[_appTable setDataSource: self];
    [_appTable setDelegate: self];
	[_appTable setResusesTableCells: FALSE];
	
	//Setup file attributes group
	_appGroup = [[UIPreferencesTableCell alloc] init];
	[_appGroup setTitle: @"Applications"];
	[_appGroup setIcon: [UIImage applicationImageNamed: @"Finder_32x32.png"]];
	
	//Setup cancel button
	CGRect buttonRect = CGRectMake(frame.size.width - 84.0f, 9.0f, 60.0f, 32.0f);
	_cancelButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_cancelButton setAutosizesToFit: FALSE];
	[_cancelButton setNavBarButtonStyle: 0];
	[_cancelButton setTitle: @"Cancel"];
	[_cancelButton addTarget: self action: @selector(cancelButtonPressed) forEvents: 1];
	[_appGroup addSubview: _cancelButton];
	
	//Get all application ids and build list
	NSArray* applications = [[NSFileManager defaultManager] directoryContentsAtPath: @"/Applications"];
	_appIDs = [[NSMutableArray alloc] initWithCapacity: [applications count]];
	_appCells = [[NSMutableArray alloc] initWithCapacity: [applications count]];
	NSEnumerator* enumerator = [applications objectEnumerator];
	NSString* application;
	NSString* appPath;
	NSString* appPListPath;
	NSString* appIconPath;
	NSString* appID;
	UIPreferencesTableCell* appCell;
	while (application = [enumerator nextObject])
	{
		//Build paths to files of interest
		appPath = [@"/Applications" stringByAppendingPathComponent: application];
		appPListPath = [appPath stringByAppendingPathComponent: @"Info.plist"];
		appIconPath = [appPath stringByAppendingPathComponent: @"icon.png"];
		
		//Read plist file to determine application information
		if ([[NSFileManager defaultManager] isReadableFileAtPath: appPListPath])
		{
			NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfFile: appPListPath];
			appID = [plistDict objectForKey: @"CFBundleIdentifier"];
			if (appID != nil)
			{
				//Add the app id to the appID array
				[_appIDs addObject: appID];
				
				//Build a preference table cell to represent the application
				appCell = [[UIPreferencesTableCell alloc] init];
				[appCell setTitle: application];
				if ([[NSFileManager defaultManager] isReadableFileAtPath: appIconPath])
					[appCell setImage: [UIImage imageAtPath: appIconPath]];
				else
					[appCell setImage: [UIImage applicationImageNamed: @"Application_64x64.png"]];
				[appCell setTarget: self];
				[appCell setAction: @selector(cellSelected)];
				[[appCell iconImageView] setFrame: CGRectMake(0.0, 0.0, 40.0f, 40.0f)];
				
				//Add the cell to the appCells array and release it
				[_appCells addObject: appCell];
				[appCell release];
			}
		}
	}
	
	//Reload pref table data and display
	[_appTable reloadData];
	[self addSubview: _appTable];
	
	return self;
}

- (void) dealloc
{
	[_appGroup release];
	[_appCells release];
	[_appIDs release];
	
	[_target release];
	
	[super dealloc];
}

- (SEL) setTarget: (id)target selector: (SEL)selector
{
	[_target autorelease];
	_target = target;
	[_target retain];
	
	_selector = selector;
}

- (void) cellSelected 
{
	//Get selected row and perform sanity check
	//HACK: The - 2 is artificial. The app table seems to count groups as rows
	int selectedRow = [_appTable selectedRow] - 2;
	if (selectedRow < 0 || selectedRow > [_appIDs count])
		return;
	
	//Call selector for target specified
	if (_target != nil && [_target respondsToSelector: _selector])
		[_target performSelector: _selector withObject: [_appIDs objectAtIndex: selectedRow]];
}

- (void) cancelButtonPressed
{
	//Call selector with nil app
	if (_target != nil && [_target respondsToSelector: _selector])
		[_target performSelector: _selector withObject: nil];
}

- (void) tableRowSelected: (int)row
{
	[self cellSelected];
}

- (int) numberOfGroupsInPreferencesTable: (UIPreferencesTable*)table 
{
	return 2;
}

- (int) preferencesTable: (UIPreferencesTable*)table numberOfRowsInGroup: (int)group 
{
    switch (group) 
	{ 
        case 0: return 0;
		case 1: return [_appCells count];
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _appGroup;
		case 1: return _appGroup;
		default: return nil;
	}
} 
- (BOOL) preferencesTable: (UIPreferencesTable*)table isLabelGroup: (int)group 
{
    switch (group)
	{
		case 0: return TRUE;
		case 1: return FALSE;
		default: return TRUE;
	}
}

- (float) preferencesTable: (UIPreferencesTable*)table heightForRow: (int)row inGroup: (int)group withProposedHeight: (float)proposed 
{
	float groupLabelSize = 32.0f;
	
	switch (group)
	{
		case 0: return groupLabelSize;
		default: return proposed;
	}
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table cellForRow: (int)row inGroup: (int)group 
{
	switch (group)
	{
		case 0: return _appGroup;
		case 1: return [_appCells objectAtIndex: row];
		default: return nil;
	}
}

//These Methods track delegate calls made to the application
/*
- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector 
{
	NSLog(@"Requested method for selector: %@", NSStringFromSelector(selector));
	return [super methodSignatureForSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)aSelector 
{
	NSLog(@"Request for selector: %@", NSStringFromSelector(aSelector));
	return [super respondsToSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation 
{
	NSLog(@"Called from: %@", NSStringFromSelector([anInvocation selector]));
	[super forwardInvocation:anInvocation];
}
*/
@end