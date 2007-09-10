/*
	MFFileInfo.m
	
	Finder file information control.
	
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
#import "MFFileInfo.h"

@implementation MFFileInfo : UIView

#define ownerReadMask 0x0100
#define ownerWriteMask 0x0080
#define ownerExecuteMask 0x0040
#define groupReadMask 0x0020
#define groupWriteMask 0x0010
#define groupExecuteMask 0x0008
#define allReadMask 0x0004
#define allWriteMask 0x0002
#define allExecuteMask 0x0001

- (id) initWithFrame: (struct CGRect)frame
{
	//Init view with frame rect
	self = [super initWithFrame: frame];
	
	//Set private data
	_fileManager = [NSFileManager defaultManager];
	[_fileManager retain];
	_buttonInactiveStyle = 0;
	_buttonActiveStyle = 3;	
	
	//Setup preferences table
	_infoTable = [[UIPreferencesTable alloc] initWithFrame: CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
	[_infoTable setDataSource: self];
    [_infoTable setDelegate: self];
	
	//Setup control layout
	CGRect labelRect = CGRectMake(frame.size.width - 224.0f, 12.0f, 176.0f, 32.0f);//[_infoTable rowHeight]);
	CGRect fileInfoLabelRect = CGRectMake(20.0f, 4.0f, frame.size.width - 34.0f, 340.0f);
	float buttonBuffer = 4.0f;
	CGRect buttonRect = CGRectMake(frame.size.width - 84.0f, 9.0f, 60.0f, 32.0f);//[_infoTable rowHeight]);
	CGRect buttonRect2 = buttonRect;
	buttonRect2.origin.x = buttonRect.origin.x - buttonRect.size.width - buttonBuffer;
	CGRect buttonRect3 = buttonRect;
	buttonRect3.origin.x = buttonRect.origin.x - buttonRect.size.width * 2.0 - buttonBuffer * 2.0f;
	
	//Setup file attributes group
	_attributesGroup = [[UIPreferencesTableCell alloc] init];
	[_attributesGroup setTitle: @"File Attributes"];
	[_attributesGroup setIcon: [UIImage applicationImageNamed: @"Finder_32x32.png"]];	
	_filenameCell = [[UIPreferencesTextTableCell alloc] init];	
	[_filenameCell setTitle: @"Filename"];
	
	_ownerAttribCell = [[UIPreferencesTableCell alloc] init];	
	[_ownerAttribCell setTitle: @"Owner"];
	_ownerAttribReadButton = [[UINavBarButton alloc] initWithFrame: buttonRect3];
	[_ownerAttribReadButton setAutosizesToFit: FALSE];
	[_ownerAttribReadButton setNavBarButtonStyle: 0];
	[_ownerAttribReadButton setTitle: @"Read"];
	[_ownerAttribReadButton addTarget: self action: @selector(ownerAttribReadButtonPressed) forEvents: 1];
	[_ownerAttribCell addSubview: _ownerAttribReadButton];
	_ownerAttribWriteButton = [[UINavBarButton alloc] initWithFrame: buttonRect2];
	[_ownerAttribWriteButton setAutosizesToFit: FALSE];
	[_ownerAttribWriteButton setNavBarButtonStyle: 0];
	[_ownerAttribWriteButton setTitle: @"Write"];
	[_ownerAttribWriteButton addTarget: self action: @selector(ownerAttribWriteButtonPressed) forEvents: 1];
	[_ownerAttribCell addSubview: _ownerAttribWriteButton];
	_ownerAttribExecuteButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_ownerAttribExecuteButton setAutosizesToFit: FALSE];
	[_ownerAttribExecuteButton setNavBarButtonStyle: 0];
	[_ownerAttribExecuteButton setTitle: @"Exec"];
	[_ownerAttribExecuteButton addTarget: self action: @selector(ownerAttribExecuteButtonPressed) forEvents: 1];
	[_ownerAttribCell addSubview: _ownerAttribExecuteButton];
	
	_groupAttribCell = [[UIPreferencesTableCell alloc] init];	
	[_groupAttribCell setTitle: @"Group"];
	_groupAttribReadButton = [[UINavBarButton alloc] initWithFrame: buttonRect3];
	[_groupAttribReadButton setAutosizesToFit: FALSE];
	[_groupAttribReadButton setNavBarButtonStyle: 0];
	[_groupAttribReadButton setTitle: @"Read"];
	[_groupAttribReadButton addTarget: self action: @selector(groupAttribReadButtonPressed) forEvents: 1];
	[_groupAttribCell addSubview: _groupAttribReadButton];
	_groupAttribWriteButton = [[UINavBarButton alloc] initWithFrame: buttonRect2];
	[_groupAttribWriteButton setAutosizesToFit: FALSE];
	[_groupAttribWriteButton setNavBarButtonStyle: 0];
	[_groupAttribWriteButton setTitle: @"Write"];
	[_groupAttribWriteButton addTarget: self action: @selector(groupAttribWriteButtonPressed) forEvents: 1];
	[_groupAttribCell addSubview: _groupAttribWriteButton];
	_groupAttribExecuteButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_groupAttribExecuteButton setAutosizesToFit: FALSE];
	[_groupAttribExecuteButton setNavBarButtonStyle: 0];
	[_groupAttribExecuteButton setTitle: @"Exec"];
	[_groupAttribExecuteButton addTarget: self action: @selector(groupAttribExecuteButtonPressed) forEvents: 1];
	[_groupAttribCell addSubview: _groupAttribExecuteButton];
	
	_allAttribCell = [[UIPreferencesTableCell alloc] init];	
	[_allAttribCell setTitle: @"Everyone"];
	_allAttribReadButton = [[UINavBarButton alloc] initWithFrame: buttonRect3];
	[_allAttribReadButton setAutosizesToFit: FALSE];
	[_allAttribReadButton setNavBarButtonStyle: 0];
	[_allAttribReadButton setTitle: @"Read"];
	[_allAttribReadButton addTarget: self action: @selector(allAttribReadButtonPressed) forEvents: 1];
	[_allAttribCell addSubview: _allAttribReadButton];
	_allAttribWriteButton = [[UINavBarButton alloc] initWithFrame: buttonRect2];
	[_allAttribWriteButton setAutosizesToFit: FALSE];
	[_allAttribWriteButton setNavBarButtonStyle: 0];
	[_allAttribWriteButton setTitle: @"Write"];
	[_allAttribWriteButton addTarget: self action: @selector(allAttribWriteButtonPressed) forEvents: 1];
	[_allAttribCell addSubview: _allAttribWriteButton];
	_allAttribExecuteButton = [[UINavBarButton alloc] initWithFrame: buttonRect];
	[_allAttribExecuteButton setAutosizesToFit: FALSE];
	[_allAttribExecuteButton setNavBarButtonStyle: 0];
	[_allAttribExecuteButton setTitle: @"Exec"];
	[_allAttribExecuteButton addTarget: self action: @selector(allAttribExecuteButtonPressed) forEvents: 1];
	[_allAttribCell addSubview: _allAttribExecuteButton];
	
	//Setup file information group
	_fileInfoGroup = [[UIPreferencesTableCell alloc] init];
	[_fileInfoGroup setTitle: @"File Properties"];
	[_fileInfoGroup setIcon: [UIImage applicationImageNamed: @"File_32x32.png"]];	
	_fileInfoCell = [[UIPreferencesTableCell alloc] init];	
	[_fileInfoCell setTitle: @""];
	_fileInfoLabel = [[UITextLabel alloc] initWithFrame: fileInfoLabelRect];
	[_fileInfoLabel setWrapsText: TRUE];
	[_fileInfoCell addSubview: _fileInfoLabel];
	
	//Fill controls with data for root path
	[self fillWithFile: @"/"];
	
	//Put info table into file info pane
	[self addSubview: _infoTable];
	
	return self;
}

- (void) dealloc
{
	[_infoTable release];
	
	[_attributesGroup release];
	[_filenameCell release];
	[_ownerAttribCell release];
	[_groupAttribCell release];
	[_allAttribCell release];
	
	[_fileInfoGroup release];
	[_fileInfoCell release];
	
	[_ownerAttribReadButton release];
	[_ownerAttribWriteButton release];
	[_ownerAttribExecuteButton release];
	[_groupAttribReadButton release];
	[_groupAttribWriteButton release];
	[_groupAttribExecuteButton release];
	[_allAttribReadButton release];
	[_allAttribWriteButton release];
	[_allAttribExecuteButton release];
	[_fileInfoLabel release];
	
	[_absolutePath release];
	[_fileManager release];
	
	[super dealloc];
}

- (void) fillWithFile: (NSString*)absolutePath
{
	//Get file information
	NSDictionary* fileAttribs = [_fileManager fileAttributesAtPath: absolutePath traverseLink: FALSE];
	if (fileAttribs == nil)
		return;
		
	//Fill in filename
	[_absolutePath autorelease];
	_absolutePath = [absolutePath copy];
	[[_filenameCell textField] setText: [_absolutePath lastPathComponent]];
	
	//Fill in permissions
	_permissions = [[fileAttribs valueForKey: NSFilePosixPermissions] longValue];
	[self updatePermissionsButtons];
	
	//Fill in file info values
	NSString* fileSize = [self stringFromFileSize: [fileAttribs valueForKey: NSFileSize]];
	NSString* permissions = [[fileAttribs valueForKey: NSFilePosixPermissions] stringValue];
	NSString* fileType = [fileAttribs valueForKey: NSFileType];
	NSString* createdDate = [[fileAttribs valueForKey: NSFileCreationDate] descriptionWithCalendarFormat: nil timeZone: nil locale: nil];
	NSString* modifiedDate = [[fileAttribs valueForKey: NSFileModificationDate] descriptionWithCalendarFormat: nil timeZone: nil locale: nil];
	NSString* ownerName = [fileAttribs valueForKey: NSFileOwnerAccountName];
	NSString* groupName = [fileAttribs valueForKey: NSFileGroupOwnerAccountName];
	NSString* ownerID = [[fileAttribs valueForKey: NSFileOwnerAccountID] stringValue];
	NSString* groupID = [[fileAttribs valueForKey: NSFileGroupOwnerAccountID] stringValue];
	NSString* referenceCount = [[fileAttribs valueForKey: NSFileReferenceCount] stringValue];
	NSString* deviceIdentifier = [fileAttribs valueForKey: NSFileDeviceIdentifier];
	NSString* fileSystemFileNumber = [[fileAttribs valueForKey: NSFileSystemFileNumber] stringValue];
	NSString* hfsCreatorCode = [fileAttribs valueForKey: NSFileHFSCreatorCode];
	NSString* hfsTypeCode = [fileAttribs valueForKey: NSFileHFSTypeCode];
	NSString* extensionHidden = [[[fileAttribs valueForKey: NSFileExtensionHidden] stringValue] isEqualToString: @"0"] ? @"True" : @"False";
	NSString* immutable = [[[fileAttribs valueForKey: NSFileImmutable] stringValue] isEqualToString: @"0"] ? @"True" : @"False";
	NSString* appendOnly = [[[fileAttribs valueForKey: NSFileAppendOnly] stringValue] isEqualToString: @"0"] ? @"True" : @"False";
	NSString* fileInfo = [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[NSString string]
		stringByAppendingString: @"Size: "]
		stringByAppendingString: fileSize == nil ? @"" : fileSize]
		stringByAppendingString: @"\nPermissions: "]
		stringByAppendingString: permissions == nil ? @"" : permissions]
		stringByAppendingString: @"\nType: "]
		stringByAppendingString: fileType == nil ? @"" : fileType]
		stringByAppendingString: @"\nCreated: "]
		stringByAppendingString: createdDate == nil ? @"" : createdDate]
		stringByAppendingString: @"\nModified: "]
		stringByAppendingString: modifiedDate == nil ? @"" : modifiedDate]
		stringByAppendingString: @"\nOwner: "]
		stringByAppendingString: ownerName == nil ? @"" : ownerName]
		stringByAppendingString: @"\nGroup: "]
		stringByAppendingString: groupName == nil ? @"" : groupName]
		stringByAppendingString: @"\nOwner ID:"]
		stringByAppendingString: ownerID == nil ? @"" : ownerID]
		stringByAppendingString: @"\nGroup ID: "]
		stringByAppendingString: groupID == nil ? @"" : groupID]
		stringByAppendingString: @"\nReference Count:"]
		stringByAppendingString: referenceCount == nil ? @"" : referenceCount]
		stringByAppendingString: @"\nDevice ID: "]
		stringByAppendingString: deviceIdentifier == nil ? @"" : deviceIdentifier]
		stringByAppendingString: @"\nFS Number: "]
		stringByAppendingString: fileSystemFileNumber == nil ? @"" : fileSystemFileNumber]
		stringByAppendingString: @"\nCreator Code: "]
		stringByAppendingString: hfsCreatorCode == nil ? @"" : hfsCreatorCode]
		stringByAppendingString: @"\nHFS Type: "]
		stringByAppendingString: hfsTypeCode == nil ? @"" : hfsTypeCode]
		stringByAppendingString: @"\nExtension Hidden: "]
		stringByAppendingString: extensionHidden == nil ? @"" : extensionHidden]
		stringByAppendingString: @"\nImmutable: "]
		stringByAppendingString: immutable == nil ? @"" : immutable]
		stringByAppendingString: @"\nAppendOnly: "]
		stringByAppendingString: appendOnly == nil ? @"" : appendOnly];
	[_fileInfoLabel setText: fileInfo];
		
	//Refresh table view
	[_infoTable reloadData];
}

- (NSString*) stringFromFileSize: (NSNumber*)size
{
	if (size == nil)
		return nil;
		
	float floatSize = (float)[size intValue];	
	if (floatSize < 1000.0f)
		return([NSString stringWithFormat:@"%1.0f bytes",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1000.0f)
		return([NSString stringWithFormat:@"%1.1f KB",floatSize]);
	floatSize = floatSize / 1024;
	if (floatSize < 1000.0f)
		return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
	floatSize = floatSize / 1024;
		return([NSString stringWithFormat:@"%1.1f GB",floatSize]);
}

- (NSString*) quoteString: (NSString*)string
{
	//TODO: Copied form MFBrowser.m  Put into subclass?
	NSMutableString* safeSrcPath = [[NSMutableString alloc] initWithCapacity: 1024];
	[safeSrcPath setString: string];
		
	[safeSrcPath replaceOccurrencesOfString: @"'"
		withString: @"'\\''" 
		options: NSLiteralSearch 
		range: NSMakeRange(0, [safeSrcPath length])];
		
	[safeSrcPath insertString: @"'" atIndex: 0];
	[safeSrcPath insertString: @"'" atIndex: [safeSrcPath length]];	
		
	return [safeSrcPath autorelease];
}

- (void) updatePermissionsButtons
{
	[_ownerAttribReadButton setNavBarButtonStyle: _permissions & ownerReadMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_ownerAttribWriteButton setNavBarButtonStyle: _permissions & ownerWriteMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_ownerAttribExecuteButton setNavBarButtonStyle: _permissions & ownerExecuteMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_groupAttribReadButton setNavBarButtonStyle: _permissions & groupReadMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_groupAttribWriteButton setNavBarButtonStyle: _permissions & groupWriteMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_groupAttribExecuteButton setNavBarButtonStyle: _permissions & groupExecuteMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_allAttribReadButton setNavBarButtonStyle: _permissions & allReadMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_allAttribWriteButton setNavBarButtonStyle: _permissions & allWriteMask ? _buttonActiveStyle : _buttonInactiveStyle];
	[_allAttribExecuteButton setNavBarButtonStyle: _permissions & allExecuteMask ? _buttonActiveStyle : _buttonInactiveStyle];
}

- (void) saveChanges;
{
	//Check filename
	NSString* filename = [[_filenameCell textField] text];
	if ([filename isEqualToString: @""])
		return;
	
	//Change filename
	NSString* absoluteDstPath = [[_absolutePath stringByDeletingLastPathComponent] stringByAppendingPathComponent: filename];
	//operationSuccess = [_fileManager movePath: srcPath toPath: dstPath handler: nil];
	//HACK: It seems that Apple removed the NSFileManager movePath:toPath:handler selector. Use system command.
	//TODO: Copied form MFBrowser.m  Put into subclass?
	if ([_absolutePath isEqualToString: absoluteDstPath] == FALSE)
	{
		NSString* moveCommand = [[[[[NSString string]
			stringByAppendingString: @"/bin/mv "] 
			stringByAppendingString: [self quoteString: _absolutePath]]
			stringByAppendingString: @" "]
			stringByAppendingString: [self quoteString: absoluteDstPath]];
		NSLog(@"%@", moveCommand);
		system([moveCommand UTF8String]);
		usleep(10);	
	}
		
	//Change permissions
	NSDictionary* fileAttribs = [NSDictionary dictionaryWithObjectsAndKeys: 
		[NSNumber numberWithUnsignedLong: _permissions], NSFilePosixPermissions,
		nil];	
	[_fileManager changeFileAttributes: fileAttribs atPath: _absolutePath];
	
	//Update after saving of changes
	[self fillWithFile: _absolutePath];
}

- (void) buttonPressed: (UINavBarButton*)button
{
	if (button == _ownerAttribReadButton)
		_permissions ^= ownerReadMask;
	else if (button == _ownerAttribWriteButton)
		_permissions ^= ownerWriteMask;
	else if (button == _ownerAttribExecuteButton)
		_permissions ^= ownerExecuteMask;
	else if (button == _groupAttribReadButton)
		_permissions ^= groupReadMask;
	else if (button == _groupAttribWriteButton)
		_permissions ^= groupWriteMask;
	else if (button == _groupAttribExecuteButton)
		_permissions ^= groupExecuteMask;
	else if (button == _allAttribReadButton)
		_permissions ^= allReadMask;
	else if (button == _allAttribWriteButton)
		_permissions ^= allWriteMask;
	else if (button == _allAttribExecuteButton)
		_permissions ^= allExecuteMask;
		
	[self updatePermissionsButtons];
}
- (void) ownerAttribReadButtonPressed { [self buttonPressed: _ownerAttribReadButton]; }
- (void) ownerAttribWriteButtonPressed { [self buttonPressed: _ownerAttribWriteButton]; }
- (void) ownerAttribExecuteButtonPressed { [self buttonPressed: _ownerAttribExecuteButton]; }
- (void) groupAttribReadButtonPressed { [self buttonPressed: _groupAttribReadButton]; }
- (void) groupAttribWriteButtonPressed { [self buttonPressed: _groupAttribWriteButton]; }
- (void) groupAttribExecuteButtonPressed { [self buttonPressed: _groupAttribExecuteButton]; }
- (void) allAttribReadButtonPressed { [self buttonPressed: _allAttribReadButton]; }
- (void) allAttribWriteButtonPressed { [self buttonPressed: _allAttribWriteButton]; }
- (void) allAttribExecuteButtonPressed { [self buttonPressed: _allAttribExecuteButton]; }

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
		case 3: return 1;
		default: return 0;
    }
}

- (UIPreferencesTableCell*) preferencesTable: (UIPreferencesTable*)table 
	cellForGroup: (int)group 
{
	switch (group)
	{
		case 0: return _attributesGroup;
		case 1: return _attributesGroup;
		case 2: return _fileInfoGroup;
		case 3: return _fileInfoGroup;
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

- (float) preferencesTable: (UIPreferencesTable*)table 
	heightForRow: (int)row 
	inGroup: (int)group 
	withProposedHeight: (float)proposed 
{
	float groupLabelSize = 32.0f;
	
	switch (group)
	{
		case 0: return groupLabelSize;
		case 2: return groupLabelSize;			
		case 3:
			switch(row)
			{
				case 0: return 354.0f;
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
		case 0: return _attributesGroup;
		case 1:
			switch (row)
			{
				case 0:	return _filenameCell;
				case 1:	return _ownerAttribCell;
				case 2:	return _groupAttribCell;
				case 3:	return _allAttribCell;
			}
		case 2: return _fileInfoGroup;
		case 3:
			switch (row)
			{
				case 0: return _fileInfoCell;
			}
		default: return nil;
	}
}

@end