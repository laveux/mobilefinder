/*
	MFBrowser.m
	
	Finder file browser control.
	
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
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIButtonBar.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIKeyboard.h>
#include <unistd.h>
#import "MFBrowser.h"
#import "MobileStudio/MSAppLauncher.h"

@implementation MFBrowser : UIView

- (id) initWithApplication: (UIApplication*)app withAppID: (NSString*)appID withFrame: (struct CGRect)rect
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	//Save application object for launching other apps
	_application = app;
	_applicationID = appID;
	
	//Setup fileview table
	_fileviewTableRect = CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
    _fileviewTable = [[UITable alloc] initWithFrame: _fileviewTableRect];
    _fileviewTableCol = [[UITableColumn alloc] initWithTitle: @"MobileFinder" identifier: @"Finder" width: rect.size.width];
	[_fileviewTable addTableColumn: _fileviewTableCol]; 
    [_fileviewTable setDataSource: self];
    [_fileviewTable setDelegate: self];
	[_fileviewTable setRowHeight: 64.0f];
	[_fileviewTable setResusesTableCells: FALSE];
	[_fileviewTable reloadData];
	[self addSubview: _fileviewTable];
	
	//Set preference defaults
	_showHiddenFiles = FALSE;
	_launchApplications = TRUE;
	_launchExecutables = TRUE;
	_protectSystemFiles = TRUE;
	_fileTypeAssociations = nil;
	_mandatoryLaunchApplication = nil;
	//TODO: Variable image sizes fully implemented
	_imageSize = 64;
	
	//Initialize state variables
	_lastSelectedPath = nil;
	
	//Create keyboard with which to rename files
	//TODO: Make return button finish filename
	CGRect kbRect;
	kbRect.size = CGSizeMake(_fileviewTableRect.size.width, 216.0f);//[UIKeyboard defaultSize];
	kbRect.origin.x = _fileviewTableRect.origin.y;
	kbRect.origin.y = _fileviewTableRect.origin.y + _fileviewTableRect.size.height - kbRect.size.height;
	_keyboard = [[UIKeyboard alloc] initWithFrame: kbRect];
	
	//Create text box with icon to rename the file with
	CGRect textFieldRect = _fileviewTableRect;
	textFieldRect.size.height = _fileviewTableRect.size.height - kbRect.size.height;
	_filenameTextField = [[UITextView alloc] initWithFrame: textFieldRect];
		
	//List root
	_fileManager = [NSFileManager defaultManager];
	[self changeDirectoryToApplications];
	
	return self;
}

- (void) dealloc
{
	//UI elements
	[_fileviewCellFilenames release];
	[_fileviewCells release];
	[_fileviewTableCol release];
	[_fileviewTable release];
	
	//Communication
	[_application release];
	[_applicationID release];
	
	//Settings
	[_fileTypeAssociations release];
	[_mandatoryLaunchApplication release];
	
	//Rename feature
	[_keyboard release];
	[_filenameTextField release];
	[_renamingFilename release];
	[_lastSelectedPath release];
	
	[super dealloc];
}

- (NSString*) absolutePath: (NSString*)path
{
	NSString* straitPath = [path stringByStandardizingPath];	
	if ([straitPath isAbsolutePath] == FALSE)
	{
		straitPath = [[self currentDirectory] stringByAppendingPathComponent: path];
		straitPath = [straitPath stringByStandardizingPath];
	}
	
	return straitPath;
}

- (NSString*) currentDirectory
{
	return [self absolutePath: [_fileManager currentDirectoryPath]];
}

- (NSString*) currentSelectedPath
{
	int selectedRow = [_fileviewTable selectedRow];
	if (selectedRow >= 0 && selectedRow < [_fileviewCellFilenames count])
		return [self absolutePath: [_fileviewCellFilenames objectAtIndex: selectedRow]];
	else
		return nil;
}

- (BOOL) launchApplications
{
	return _launchApplications;
}

- (BOOL) launchExecutables
{
	_launchExecutables;
}

- (BOOL) showHiddenFiles
{
	return _showHiddenFiles;
}

- (BOOL) protectSystemFiles
{
	return _protectSystemFiles;
}

- (NSArray*) fileTypeAssociations
{
	return _fileTypeAssociations;
}

- (NSString*) mandatoryLaunchApplication
{
	return _mandatoryLaunchApplication;
}

- (void) setDelegate: (id)delegate;
{
	[_delegate autorelease];	
	_delegate = [delegate retain];
		
	[self openPath: [self currentDirectory]];
}

- (void) setLaunchApplications: (BOOL)launchApplications
{
	_launchApplications = launchApplications;
}

- (void) setLaunchExecutables: (BOOL)launchExecutables
{
	_launchExecutables = launchExecutables;
}

- (void) setShowHiddenFiles: (BOOL)showHiddenFiles
{
	_showHiddenFiles = showHiddenFiles;
	
	[self refreshFileView];
}

- (void) setProtectSystemFiles: (BOOL)protectSystemFiles
{
	_protectSystemFiles = protectSystemFiles;
	
	[self openPath: [self currentDirectory]];
}

- (void) setFileTypeAssociations: (NSArray*)fileTypeAssociations
{
	[_fileTypeAssociations autorelease];
	_fileTypeAssociations = [[NSArray alloc] initWithArray: fileTypeAssociations copyItems: TRUE];
}

- (void) setMandatoryLaunchApplication: (NSString*)appID
{
	[_mandatoryLaunchApplication autorelease];
	_mandatoryLaunchApplication = [appID copy];
}

- (void) refreshFileView
{
	//Make sure we have new, empty fileviewCells and fileviewCellFilenames
	[_fileviewCells release];				
	_fileviewCells = [[NSMutableArray alloc] init];
	[_fileviewCellFilenames release];
	_fileviewCellFilenames = [[NSMutableArray alloc] init];
	
	//Get the directory listing for the specified path
	NSDirectoryEnumerator* dirEnumerator = [_fileManager enumeratorAtPath: [self currentDirectory]];
	
	//Create table cells for each file in the directory, and add them and their paths to the appropriate collections
	NSString* filename;
	while (filename = [dirEnumerator nextObject]) 
	{
		//Don't decend into directories
		[dirEnumerator skipDescendents];	
		
		if (_showHiddenFiles == TRUE || [filename characterAtIndex: 0] != '.')
		{
			//Create table cell for filename
			UIImageAndTextTableCell* cell = [[UIImageAndTextTableCell alloc] init];
			[cell setTitle: filename];	
			[cell setImage: [self determineFileIcon: filename]];
					
			//Add filename and cell to collections
			//Cells and filenames are stored seperately to allow the displayed name to differ from the actual name
			//(eg. Calculator.app -> Calculator)
			[_fileviewCellFilenames addObject: filename];
			[_fileviewCells addObject: cell];
			[cell release];
		}
	}
	
	//Refresh the fileview table
	[_fileviewTable reloadData];
}

- (void) selectPath: (NSString*)path
{
	//Make sure that the path exsists
	if ([_fileManager fileExistsAtPath: path] == FALSE)
		return;
		
	//Determine the path's nature
	NSString* absolutePath = [self absolutePath: path];
	NSString* parentDirectory = [absolutePath stringByDeletingLastPathComponent];
	NSString* relativePath = [absolutePath lastPathComponent];
	
	//If the parent directory of the path is not currently displayed, switch to that directory
	if ([[_fileManager currentDirectoryPath] isEqualToString: parentDirectory] == FALSE)
	{
		[self openPath: parentDirectory];
	}
	
	//Find the path in the listing and select it
	NSEnumerator* enumerator = [_fileviewCellFilenames objectEnumerator];
	NSString* currPath;
	while (currPath = [enumerator nextObject])
	{
		if ([currPath isEqualToString: relativePath])
		{
			int selecteeCellRow = [_fileviewCellFilenames indexOfObject: currPath];
			[self selectRow: selecteeCellRow];
			return;
		}
	}
}

- (void) selectRow: (int)row
{
	//Reset last selected row so we dont trigger a double-tap
	[_lastSelectedPath release];
	_lastSelectedPath = nil;
	
	//Select and select the row
	[_fileviewTable highlightRow: row];
	[_fileviewTable scrollRowToVisible: row];
	[_fileviewTable selectHighlightedRow];
}

- (void) openPath: (NSString*)path
{
	//Get path extension and absolute path
	NSString* extension = [[path pathExtension] lowercaseString];
	NSString* absolutePath = [self absolutePath: path];
	
	//Ensure that we are not entering a protected system file
	if (_protectSystemFiles == TRUE)
	{
		if ([absolutePath hasPrefix: @"/Applications"] == FALSE &&
			[absolutePath hasPrefix: NSHomeDirectory()] == FALSE)
		{
			[self openPath: NSHomeDirectory()];
			return;
		}
	}	
	
	//Change to the specified path, if it is a directory
	NSString* lastPath = [self currentDirectory];
	if ([_fileManager changeCurrentDirectoryPath: path])
	{
		//Refresh the fileview table
		[self refreshFileView];	
		
		//If moving to a path that is a parent of the last path, select the child in the current directory
		//that is part of the last path
		NSString* currentDirectory = [self currentDirectory];
		if ([lastPath isEqualToString: currentDirectory] == FALSE &&
			[lastPath hasPrefix: currentDirectory])
		{
			NSArray* currentPathComponents = [currentDirectory pathComponents];
			NSArray* lastPathComponents = [lastPath pathComponents];
			if ([lastPathComponents count] > [currentPathComponents count])
			{
				NSString* lastFilename = [lastPathComponents objectAtIndex: [currentPathComponents count]];		
				[self selectPath: lastFilename];
			}
		}
		else
		{
			//HACK: There is no "unselectRow", so this at least keeps us in the know about which is selected
			[self selectRow: 0];
		}
			
		//Let delegate know of directory change
		if ([_delegate respondsToSelector: @selector(browserCurrentDirectoryChanged:toPath:)])
			[_delegate browserCurrentDirectoryChanged: self 
				toPath: [[self currentDirectory] stringByStandardizingPath]];
		
		//Execute application if this is an application
		if (_launchApplications == TRUE && [extension isEqualToString: @"app"])
		{
			//Check to see if the application directory has an Info.plist
			NSString* infoPListPath = [path stringByAppendingPathComponent: @"Info.plist"];
			if ([_fileManager isReadableFileAtPath: path])
			{
				//Open the plist and find the application's identifier
				NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfFile: infoPListPath];
				NSEnumerator* enumerator = [plistDict keyEnumerator];
				NSString* key;
				NSString* appID;
				while (key = [enumerator nextObject]) 
				{					
					if ([key isEqualToString: @"CFBundleIdentifier"])
					{
						appID = [plistDict valueForKey: key];
						break;
					}
				}				
				
				//Launch application by the regular method
				if (appID != nil)
					[_application launchApplicationWithIdentifier: appID suspended: NO];
			}
		}
	}
	else
	{
		//The tapped cell was not a directory
		//Open the file using the appropriate applicaiton or execute the file if it is executable	
		
		//Open file in mandatory application, if set
		if (_mandatoryLaunchApplication != nil)
		{
			NSLog(@"Launching with mandatory app: %@", _mandatoryLaunchApplication);
			//Prepare arguments
			NSArray* args = [[NSArray alloc] initWithObjects: absolutePath, nil];
			
			//Launch application with file as argument
			[MSAppLauncher launchApplication: _mandatoryLaunchApplication 
				withArguments: args
				withLaunchingAppID: _applicationID
				withApplication: _application];
			
			//Release args
			[args release];
			
			return;
		}
		
		//If the file is an executable, execute it
		if (_launchExecutables == TRUE && [_fileManager isExecutableFileAtPath: absolutePath])
		{
			//WARNING: This executes GUI apps, but they never return!  You have to reboot!
			//Should only execute executables that eventually end
			system([absolutePath fileSystemRepresentation]);
			
			return;
		}
		
		//Check extension against file type associations
		NSEnumerator* enumerator = [_fileTypeAssociations objectEnumerator];
		NSString* fileTypeAssociation;
		while (fileTypeAssociation = [enumerator nextObject])
		{
			//Separate the extension and application ID parts of the file association
			NSArray* associationParts = [fileTypeAssociation componentsSeparatedByString: @":"];
			if (associationParts != nil && [associationParts count] == 2)
			{
				NSString* associationExtension = [associationParts objectAtIndex: 0];
				NSString* associationAppID = [associationParts objectAtIndex: 1];
				
				//Check for matches
				if ([extension isEqualToString: associationExtension])
				{
					NSLog(@"Launching with app: %@ arguments: %@", associationAppID, absolutePath);
					
					//Prepare arguments
					NSArray* args = [[NSArray alloc] initWithObjects: absolutePath, nil];
					
					//Launch application with file as argument
					[MSAppLauncher launchApplication: associationAppID 
						withArguments: args
						withLaunchingAppID: _applicationID
						withApplication: _application];	
					
					//Release args	
					[args release];
					
					return;
				}
			}
		}
	}
}

- (UIImage*) determineFileIcon: (NSString*) path
{
	//Get file attributes
	BOOL isDirectory;
	BOOL fileExsists = [_fileManager fileExistsAtPath: path isDirectory: &isDirectory];
	BOOL isReadable = [_fileManager isReadableFileAtPath: path];
	BOOL isWritable = [_fileManager isWritableFileAtPath: path];
	BOOL isExecutable = [_fileManager isExecutableFileAtPath: path];
	BOOL isDeletable = [_fileManager isDeletableFileAtPath: path];
	NSString* extension = [[path pathExtension] lowercaseString];
	
	//Build image name from extension and image size
	NSString* imageSuffix = [[[[[[NSString string]
		stringByAppendingString: @"_"]
		stringByAppendingString: [[NSNumber numberWithInt: _imageSize] stringValue]]
		stringByAppendingString: @"x"]
		stringByAppendingString: [[NSNumber numberWithInt: _imageSize] stringValue]]
		stringByAppendingString: @".png"];
	
	//Applications
	if ([extension isEqualToString: @"app"])
	{
		NSString* absolutePath = [self absolutePath: path];
		NSString* appIconPath = [absolutePath stringByAppendingPathComponent: @"icon.png"];
			
		if ([_fileManager isReadableFileAtPath: appIconPath])
			return [UIImage imageAtPath: appIconPath];
		else
			return [UIImage applicationImageNamed: @"Application_64x64.png"];
	}
	
	//Check if file is a directory
	if (isDirectory == TRUE)
		return [UIImage applicationImageNamed: [@"Folder" stringByAppendingString: imageSuffix]];	
	
	//Check for an image match
	UIImage* extensionImage = [UIImage applicationImageNamed: [extension stringByAppendingString: imageSuffix]];
	if (extensionImage != nil)
		return extensionImage;
	else
	{
		if (isExecutable)
			return [UIImage applicationImageNamed: [@"Executable" stringByAppendingString: imageSuffix]];
		else
			return [UIImage applicationImageNamed: [@"File" stringByAppendingString: imageSuffix]];
	}
}

- (void) changeDirectoryToRoot
{
	[self openPath: @"/"];
}

- (void) changeDirectoryToLast
{
	if (_protectSystemFiles == TRUE && [[self currentDirectory] isEqualToString: NSHomeDirectory()])
		[self changeDirectoryToApplications];
	else if (_protectSystemFiles == TRUE && [[self currentDirectory] isEqualToString: @"/Applications"])
		[self changeDirectoryToApplications];
	else
	{
		[self openPath: @"../"];
	}
}

- (void) changeDirectoryToHome
{
	[self openPath: NSHomeDirectory()];
}

- (void) changeDirectoryToApplications
{
	[self openPath: @"/Applications"];
}

- (void) sendSrcPath: (NSString*)srcPath toDstPath: (NSString*)dstPath byMoving: (BOOL)move;
{
	//Sanity check args
	if (srcPath == nil || dstPath == nil)
		return;
	
	//Ensure absolute paths
	NSString* absoluteSrcPath = [self absolutePath: srcPath];
	NSString* absoluteDstPath = [self absolutePath: dstPath];
	
	BOOL operationSuccess;
	if (move == TRUE)
	{
		//operationSuccess = [_fileManager movePath: srcPath toPath: dstPath handler: nil];
		//[[NSFileManager defaultManager] movePath: @"/Test" toPath: @"/System/Test" handler: nil];
		
		//HACK: Above statements crash program.  Use system call to move file
		//TODO: Shell characters in path mess up command
		NSString* moveCommand = [[[[[[NSString string]
			stringByAppendingString: @"/bin/mv \'"] 
			stringByAppendingString: absoluteSrcPath]
			stringByAppendingString: @"\' \'"]
			stringByAppendingString: absoluteDstPath]
			stringByAppendingString: @"\'"];
		NSLog(@"%@", moveCommand);
		system([moveCommand UTF8String]);
		usleep(10);	
	}
	else
	{
		//operationSuccess = [_fileManager copyPath: srcPath toPath: dstPath handler: nil];
		
		//HACK: Above statement crashes program.  Use system call to copy file
		//TODO: Shell characters in path mess up command
		NSString* copyCommand = [[[[[[NSString string]
			stringByAppendingString: @"/bin/cp -R \'"] 
			stringByAppendingString: absoluteSrcPath]
			stringByAppendingString: @"\' \'"]
			stringByAppendingString: absoluteDstPath]
			stringByAppendingString: @"\'"];
		NSLog(@"%@", copyCommand);
		system([copyCommand UTF8String]);
		usleep(10);	
	}
	
	[self refreshFileView];
}

- (void) makeDirectoryAtPath: (NSString*)path
{
	BOOL operationSuccess = [_fileManager createDirectoryAtPath: path attributes: nil];
	[self refreshFileView];
}

- (void) makeFileAtPath: (NSString*)path
{
	BOOL operationSuccess = [_fileManager createFileAtPath: path contents: nil attributes:nil];
	[self refreshFileView];
}

- (void) deletePath: (NSString*)path
{
	BOOL operationSuccess = [_fileManager removeFileAtPath: path handler: nil];
	[self refreshFileView];
}

- (void) beginRenamePath: (NSString*)path
{
	//TODO: select cell for path if not already selected (not needed for MobileFinder, but would be needed for other apps)
	
	//Get selected cell
	UIImageAndTextTableCell* selectedCell = [_fileviewCells objectAtIndex: [_fileviewTable selectedRow]];
	if (selectedCell == nil)
		return;
	NSString* selectedFilename = [_fileviewCellFilenames objectAtIndex: [_fileviewTable selectedRow]];
	_renamingFilename = selectedFilename;
	
	//Setup the text field with the file's current name
	[_filenameTextField setText: selectedFilename];
	
	//Add to view
	[self addSubview: _filenameTextField];
	[self addSubview: _keyboard];
	[_fileviewTable removeFromSuperview];
}

- (void) endRenameSaving: (BOOL)save
{
	//Save file
	if (save)
	{
		//Verify typed filename
		NSString* newFilename = [[[_filenameTextField text] componentsSeparatedByString: @"\n"] lastObject];
		[self sendSrcPath: _renamingFilename toDstPath: newFilename byMoving: TRUE];
	}
	
	//Remove keyboard and filename textview
	[_keyboard removeFromSuperview];
	[_filenameTextField removeFromSuperview];
	[self addSubview: _fileviewTable];
}

- (UITableCell*) table: (UITable*)table cellForRow: (int)row column: (int)col
{
	return [_fileviewCells objectAtIndex: row];
}

- (int) numberOfRowsInTable: (UITable*)table
{
	return [_fileviewCells count];
}

- (void) tableRowSelected: (NSNotification*) notification 
{
	//Get selected row and perform sanity check
	int selectedRow = [_fileviewTable selectedRow];
	if (selectedRow < 0 || selectedRow > [_fileviewCellFilenames count])
		return;
		
	//Get selected cell and filename
	NSString* selectedCellFilename = [_fileviewCellFilenames objectAtIndex: selectedRow];
	NSString* selectedAbsolutePath = [self absolutePath: selectedCellFilename];
	
	//Inform delegate in change in selected path
	if ([_delegate respondsToSelector: @selector(browserCurrentSelectedPathChanged:toPath:)])	
		[_delegate browserCurrentSelectedPathChanged: self toPath: selectedAbsolutePath];
	
	//If the cell is being re-selected, open it
	if (_lastSelectedPath != nil && [selectedAbsolutePath isEqualToString: _lastSelectedPath])
	{
		[self openPath: selectedAbsolutePath];
	}
		
	//Save last selected path
	[_lastSelectedPath autorelease];
	_lastSelectedPath = [[NSString alloc] initWithString: selectedAbsolutePath];
}

@end
