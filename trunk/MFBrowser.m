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
#import <ApplicationServices/ApplicationServices.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIView-Geometry.h>
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

int sortFilesByKind(id obj1, id obj2, void* context)
{
	//Type inputs
	NSString* str1 = (NSString*)obj1;
	NSString* str2 = (NSString*)obj2;
	NSFileManager* fileManager = (NSFileManager*)context;	 
	
	//Sort directories to the top
	BOOL isDirectory1;
	BOOL isDirectory2;
	if ([fileManager fileExistsAtPath: str1 isDirectory: &isDirectory1] == FALSE)
		NSLog(@"Sorting file that doesn't exsist!");
	if ([fileManager fileExistsAtPath: str2 isDirectory: &isDirectory2] == FALSE)
		NSLog(@"Sorting file that doesn't exsist!");
		
	if (isDirectory1 && isDirectory2)
		return [str1 localizedCompare: str2];
	else if (isDirectory1)
		return NSOrderedAscending;
	else if (isDirectory2)
		return NSOrderedDescending;
	else
	{
		//Neither is directory, so compare extensions.  If extensions are same, compare filenames
		int extensionCompare = [[str1 pathExtension] caseInsensitiveCompare: [str2 pathExtension]];
		if (extensionCompare == NSOrderedSame)
			return [str1 localizedCompare: str2];
		else
			return extensionCompare;
	}
}

@implementation MFBrowser : UITransitionView

- (id) initWithApplication: (UIApplication*)app withAppID: (NSString*)appID withFrame: (struct CGRect)rect
{
	//Init view with frame rect
	self = [super initWithFrame: rect];
	
	//Save application object for launching other apps
	_application = app;
	_applicationID = appID;
	
	//Initialize state variables
	_fileManager = [NSFileManager defaultManager];
	_lastSelectedPath = nil;
	
	//Set reasonable preference defaults
	_showHiddenFiles = FALSE;
	_showDotDotRow = TRUE;
	_sortFiles = TRUE;
	_launchApplications = TRUE;
	_launchExecutables = TRUE;
	_protectSystemFiles = TRUE;
	_fileTypeAssociations = nil;
	_executableLaunchProgram = @"com.googlecode.mobileterminal.Term-vt100";
	_mandatoryLaunchApplication = nil;
	_rowHeight = 48.0f;
	_rowHeightBuffer = 2.0f;
	[self setRowHeight: _rowHeight bufferHeight: _rowHeightBuffer];
	
	//Setup fileview table
	_fileviewTableRect = CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height);
    _fileviewTable = [[UITable alloc] initWithFrame: _fileviewTableRect];
    _fileviewTableCol = [[UITableColumn alloc] initWithTitle: @"MobileFinder" identifier: @"Finder" width: rect.size.width];
	[_fileviewTable addTableColumn: _fileviewTableCol]; 
    [_fileviewTable setDataSource: self];
    [_fileviewTable setDelegate: self];
	[_fileviewTable setResusesTableCells: FALSE];
	[_fileviewTable reloadData];
	
	//Setup the file info viewer
	_fileInfo = [[MFFileInfo alloc] initWithDoneSelector: nil/*@selector(makeFileviewTableActive)*/ withFrame: _fileviewTableRect];
	
	//Make the fileview table the active view
	[self makeFileviewTableActive];	
	
	return self;
}

- (void) dealloc
{
	//UI elements
	[_fileviewCellFilenames release];
	[_fileviewCells release];
	[_fileviewTableCol release];
	[_fileviewTable release];
	[_fileInfo release];
	
	//Communication
	[_application release];
	[_applicationID release];
	
	//State variables
	[_lastSelectedPath release];
	
	//Settings
	[_fileTypeAssociations release];
	[_executableLaunchProgram release];
	[_mandatoryLaunchApplication release];
	
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
	{
		NSString* selectedPath = [_fileviewCellFilenames objectAtIndex: selectedRow];
		if ([selectedPath isEqualToString: @".."])
			return [[self currentDirectory] stringByAppendingPathComponent: @".."];
		else
			return [self absolutePath: selectedPath];
	}
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

- (NSString*) executableLaunchProgram;
{
	return _executableLaunchProgram;
}

- (BOOL) showHiddenFiles
{
	return _showHiddenFiles;
}

- (BOOL) showDotDotRow
{
	return _showDotDotRow;
}

- (BOOL) sortFiles
{
	return _sortFiles;
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
	[super setDelegate: delegate];
		
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

- (void) setExecutableLaunchProgram: (NSString*)exeLaunchAppID;
{
	_executableLaunchProgram = [exeLaunchAppID copy];
}

- (void) setShowHiddenFiles: (BOOL)showHiddenFiles
{
	_showHiddenFiles = showHiddenFiles;
}

- (void) setShowDotDotRow: (BOOL)showDotDotRow
{
	_showDotDotRow = showDotDotRow;
}

- (void) setSortFiles: (BOOL)sortFiles
{
	_sortFiles = sortFiles;
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

- (void) setRowHeight: (int)rowHeight bufferHeight: (int)rowHeightBuffer
{
	_rowHeight = rowHeight;
	_rowHeightBuffer = rowHeightBuffer;
	
	[_fileviewTable setRowHeight: _rowHeight + _rowHeightBuffer];
}

- (void) makeFileviewTableActive
{
	if (_activeView == _fileviewTable)
		return;
	
	//Save any changes made in file info
	[_fileInfo saveChanges];
	[self refreshFileView];
	
	//Switch to fileview table
	[self transition: 2 toView: _fileviewTable];
	_activeView = _fileviewTable;
}

- (void) makeFileInfoActive
{
	if (_activeView == _fileInfo)
		return;
	
	//Fill file info controls with data from current selected file	
	[_fileInfo fillWithFile: [self currentSelectedPath]];
	
	//Switch to file info view
	[self transition: 1 toView: _fileInfo];
	_activeView = _fileInfo;
}

- (void) refreshFileView
{
	//Create snapshot of current setup for transition
	//CGImageRef oldViewCGImage = [_fileviewTable createSnapshotWithRect: _fileviewTableRect];
	//UIImage* oldViewImage = [[UIImage alloc] initWithImageRef: oldViewCGImage];
	//UIImageView* oldView = [[UIImageView alloc] initWithImage: oldViewImage];
	//[oldView setFrame: _fileviewTableRect];
	
	//Make sure we have new, empty fileviewCells and fileviewCellFilenames
	[_fileviewCells release];				
	_fileviewCells = [[NSMutableArray alloc] init];
	[_fileviewCellFilenames release];
	_fileviewCellFilenames = [[NSMutableArray alloc] init];
	
	//Get the directory listing for the specified path
	NSMutableArray* fileList = [[NSMutableArray alloc] initWithCapacity: 16];
	[fileList setArray: [_fileManager directoryContentsAtPath: [self currentDirectory]]];
	if (_sortFiles == TRUE)
		[fileList sortUsingFunction: sortFilesByKind context: _fileManager];
	[fileList insertObject: @".." atIndex: 0];
	NSEnumerator* enumerator = [fileList objectEnumerator];
	
	//Create table cells for each file in the directory, and add them and their paths to the appropriate collections
	NSString* filename;
	while (filename = [enumerator nextObject]) 
	{
		if (_showHiddenFiles == TRUE || [filename characterAtIndex: 0] != '.' ||
			(_showDotDotRow == TRUE && [filename isEqualToString: @".."] && ![[self currentDirectory] isEqualToString: @"/"] &&
				(![[self currentDirectory] isEqualToString: @"/Applications"] || _protectSystemFiles == FALSE)))
		{
			//Create table cell for filename
			UIImageAndTextTableCell* cell = [[UIImageAndTextTableCell alloc] init];
			[cell setTitle: filename];	
			
			//Setup image view, preserving image aspect ratio (_rowHeight is used for both width and height)
			UIImage* icon = [self determineFileIcon: filename];
			UIImageView* iconImageView = [cell iconImageView];
			[iconImageView setImage: icon];
			CGRect imageRect = [[cell iconImageView] frame];
			/*
			if (imageRect.size.width > _rowHeight || imageRect.size.height > _rowHeight)
			{
				float imageAspect = imageRect.size.width / imageRect.size.height;
				
				imageRect.size.height = _rowHeight;
				imageRect.size.width = imageRect.size.height * imageAspect;
				if (imageRect.size.width > _rowHeight)
				{
					imageRect.size.width = _rowHeight;
					imageRect.size.height = imageRect.size.width / imageAspect;					
				}
			}
			imageRect.origin.x = imageRect.origin.x + 
				_rowHeight * 0.5f - imageRect.size.width * 0.5f;
			imageRect.origin.y = imageRect.origin.y + 
				_rowHeight * 0.5f - imageRect.size.height * 0.5f;
			*/
			//Stretch image instead of preserving aspect, as it makes the text on the row skewed
			imageRect.size.width = _rowHeight;
			imageRect.size.height = _rowHeight;
			[iconImageView setFrame: imageRect];
					
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
	
	//[self transition: 1 fromView: oldView toView: _fileviewTable];
	//[oldView autorelease];
	//[oldViewImage autorelease];
	//TODO: Need to release this big image!
	//CGImageRelease(oldViewCGImage);
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
	
	//Execute application if this is an application
	NSString* lastPath = [self currentDirectory];
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
			{
				//Launch application without arguments
				[self launchApplication: appID withArgs: nil];
			}
		}
	}	
	//Change to the specified path, if it is a directory
	else if ([_fileManager changeCurrentDirectoryPath: path])
	{
		//Refresh the fileview table
		[self refreshFileView];
		
		//Make sure that the fileview table is visible
		[self makeFileviewTableActive];
				
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
	}
	else
	{
		//The tapped cell was not a directory
		//Open the file using the appropriate applicaiton or execute the file if it is executable	
		
		//Open file in mandatory application, if set
		if (_mandatoryLaunchApplication != nil)
		{
			NSLog(@"Launching with mandatory app: %@", _mandatoryLaunchApplication);
			
			//Launch application with file as argument
			[self launchApplication: _mandatoryLaunchApplication withArgs: [NSArray arrayWithObjects: absolutePath, nil]];
			
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
					
					//Launch application with file as argument
					[self launchApplication: associationAppID withArgs: [NSArray arrayWithObjects: absolutePath, nil]];
										
					return;
				}
			}
		}
		
		//If the file is an executable, execute it
		if (_launchExecutables == TRUE && [_fileManager isExecutableFileAtPath: absolutePath])
		{
			//Execute using terminal program
			//TODO: Chooseable terminal program
			[self launchApplication: _executableLaunchProgram withArgs: [NSArray arrayWithObjects: absolutePath, nil]];
			
			return;
		}
		
		//File couldn't be opened by anything, so open it with the file info browser
		[self makeFileInfoActive];
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
	NSString* imageSuffix;
	if (_rowHeight <= 32.0f)
		imageSuffix = @"_32x32.png";
	else
		imageSuffix = @"_64x64.png";
	
	//Applications
	if ([extension isEqualToString: @"app"])
	{
		NSString* absolutePath = [self absolutePath: path];
		NSString* appIconPath = [absolutePath stringByAppendingPathComponent: @"icon.png"];
			
		if ([_fileManager isReadableFileAtPath: appIconPath])
			return [UIImage imageAtPath: appIconPath];
		else
			return [UIImage applicationImageNamed: [@"Application" stringByAppendingString: imageSuffix]];
	}
	
	//Check if file is a directory
	if (isDirectory == TRUE)
		return [UIImage applicationImageNamed: [@"Folder" stringByAppendingString: imageSuffix]];	
	
	//Check if the file is a preview-supported image
	if ([extension isEqualToString: @"png"] ||
		[extension isEqualToString: @"jpg"] ||
		[extension isEqualToString: @"jpeg"] ||
		[extension isEqualToString: @"gif"] ||
		[extension isEqualToString: @"tiff"])
	{
		return [UIImage imageAtPath: path];
	}
	
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

- (void) changeDirectoryToLast
{
	if (_activeView == _fileInfo)
		[self makeFileviewTableActive];
	else
	{
		if (_protectSystemFiles == TRUE && [[self currentDirectory] isEqualToString: NSHomeDirectory()])
			[self changeDirectoryToApplications];
		else if (_protectSystemFiles == TRUE && [[self currentDirectory] isEqualToString: @"/Applications"])
			[self changeDirectoryToApplications];
		else
			[self openPath: @".."];
	}
}

- (void) changeDirectoryToRoot
{
	[self openPath: @"/"];
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
	
	//Dont allow src operations on ".."
	if ([[srcPath lastPathComponent] isEqualToString: @".."])
		return;
	
	//Ensure absolute paths
	NSString* absoluteSrcPath = [self absolutePath: srcPath];
	NSString* absoluteDstPath = [self absolutePath: dstPath];
	
	BOOL operationSuccess;
	if (move == TRUE)
	{
		//operationSuccess = [_fileManager movePath: srcPath toPath: dstPath handler: nil];
		//HACK: It seems that Apple removed the NSFileManager movePath:toPath:handler selector. Use system command.
		NSString* moveCommand = [[[[[NSString string]
			stringByAppendingString: @"/bin/mv "] 
			stringByAppendingString: [self quoteString: absoluteSrcPath]]
			stringByAppendingString: @" "]
			stringByAppendingString: [self quoteString: absoluteDstPath]];
		[self executeSystemCommand: moveCommand withSleepTime: 50];
	}
	else
	{
		//operationSuccess = [_fileManager copyPath: srcPath toPath: dstPath handler: nil];
		//HACK: It seems that Apple removed the NSFileManager copyPath:toPath:handler selector. Use system command.
		NSString* copyCommand = [[[[[NSString string]
			stringByAppendingString: @"/bin/cp -R "] 
			stringByAppendingString: [self quoteString: absoluteSrcPath]]
			stringByAppendingString: @" "]
			stringByAppendingString: [self quoteString: absoluteDstPath]];
		[self executeSystemCommand: copyCommand withSleepTime: 50];
	}
	
	[self refreshFileView];
}

- (NSString*) quoteString: (NSString*)string
{
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

- (void) makeDirectoryAtPath: (NSString*)path
{
	//Dont allow operations on ".."
	if ([[path lastPathComponent] isEqualToString: @".."])
		return;
		
	BOOL operationSuccess = [_fileManager createDirectoryAtPath: path attributes: nil];
	[self refreshFileView];
}

- (void) makeFileAtPath: (NSString*)path
{
	//Dont allow operations on ".."
	if ([[path lastPathComponent] isEqualToString: @".."])
		return;
		
	BOOL operationSuccess = [_fileManager createFileAtPath: path contents: nil attributes:nil];
	[self refreshFileView];
}

- (void) deletePath: (NSString*)path
{
	//Dont allow operations on ".."
	if ([[path lastPathComponent] isEqualToString: @".."])
		return;
		
	BOOL operationSuccess = [_fileManager removeFileAtPath: path handler: nil];
	[self refreshFileView];
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
		if ([selectedCellFilename isEqualToString: @".."])
			[self changeDirectoryToLast];
		else
			[self openPath: selectedAbsolutePath];
	}
		
	//Save last selected path
	[_lastSelectedPath autorelease];
	_lastSelectedPath = [[NSString alloc] initWithString: selectedAbsolutePath];
}

- (void) executeSystemCommand: (NSString*)command withSleepTime: (int)sleepTime
{
	NSLog(@"%@", command);
	system([command UTF8String]);
	usleep(sleepTime);
}

- (void) launchApplication: (NSString*) appID withArgs: (NSArray*)args
{
	//HACK: This puts args into the user's .profile so that they are executed when mobileterminal starts
	if ([appID isEqualToString: _executableLaunchProgram])
	{
		//Build paths to profile, a temp profile location, and the script to be executed
		NSString* profile = [[_application userHomeDirectory] 
			stringByAppendingPathComponent: @".profile"];
		NSString* tempProfile = [profile 
			stringByAppendingPathExtension: @"tmp"];
		NSString* mobileTerminalScript = [[[_application userLibraryDirectory] 
			stringByAppendingPathComponent: @"MobileFinder"]
			stringByAppendingPathComponent: @"MobileFinderProfile"];
		
		//Determine if the profile already exsists
		BOOL profileExists = [_fileManager fileExistsAtPath: profile];
				
		//Create a copy of the user's profile
		if (profileExists)
		{
			int tries = 0;
			while ([_fileManager fileExistsAtPath: tempProfile] == FALSE)
			{
				NSString* moveProfileCommand = [[[@"/bin/cp " 
					stringByAppendingString: [self quoteString: profile]]
					stringByAppendingString: @" "]
					stringByAppendingString: [self quoteString: tempProfile]];
				[self executeSystemCommand: moveProfileCommand withSleepTime: 100];
			
				//Try this a few times if the file doesn't exist
				if (tries > 5)
					break;
				tries++;
			}
		}
		
		//Add the script to the bottom of the user's profile
		NSString* addScriptCommand = [[[@"/bin/echo "
			stringByAppendingString: [self quoteString: [@". " stringByAppendingString: mobileTerminalScript ]]]
			stringByAppendingString: @" >> "]
			stringByAppendingString: profile];
		[self executeSystemCommand: addScriptCommand withSleepTime: 20];
		
		//Make script to be executed
		NSMutableData* commands = [[NSMutableData alloc] initWithCapacity: 0];
		NSString* arg;
		NSString* command;
		BOOL isDirectory;
		int i;
		for (i = 0; i < [args count]; i++)
		{
			arg = [args objectAtIndex: i];
			
			if ([_fileManager fileExistsAtPath: arg isDirectory: &isDirectory] && isDirectory)
				command = [[@"cd " 
					stringByAppendingString: [self quoteString: arg]]
					stringByAppendingString: @"\n"];				
			else if ([_fileManager isExecutableFileAtPath: arg])
				command = [arg stringByAppendingString: @"\n"];	
			else
				continue;
			
			[commands appendBytes: [command UTF8String] length: [command length]];
		}
		
		//Add a command to either replace the user's profile after execution, or remove the profile if none existed
		NSString* cleanupProfileCommand;
		if (profileExists)
			cleanupProfileCommand = [[[[@"/bin/mv " 
			stringByAppendingString: [self quoteString: tempProfile]]
			stringByAppendingString: @" "]
			stringByAppendingString: [self quoteString: profile]]
			stringByAppendingString: @"\n"];
		else
			cleanupProfileCommand = [[@"/bin/rm " 
			stringByAppendingString: [self quoteString: profile]]
			stringByAppendingString: @"\n"];
			
		[commands appendBytes: [cleanupProfileCommand UTF8String] length: [cleanupProfileCommand length]];
		
		//Write the script
		[commands writeToFile: mobileTerminalScript atomically: YES];
	}
	
	//Let delegate know that we will launch an application
	if ([_delegate respondsToSelector: @selector(browserWillLaunchApplication:withArguments:)])
		[_delegate browserWillLaunchApplication: appID withArguments: args];
	
	//Launch the application
	if (args == nil)
	{
		[MSAppLauncher launchApplication: appID 
			withLaunchingAppID: _applicationID
			withApplication: _application];
	}
	else
	{
		[MSAppLauncher launchApplication: appID 
			withArguments: args
			withLaunchingAppID: _applicationID
			withApplication: _application];
	}
}

/*
- (IBAction)sendHTTPPost:(id)sender {
	
	//creating the url request:
	NSURL *cgiUrl = [NSURL URLWithString:@"http://www.myserver.com/webToEmail.cgi"];
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:cgiUrl];
	
	//adding header information:
	[postRequest setHTTPMethod:@"POST"];
	
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[postRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	
	//setting up the body:
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"realname\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Joe Doe"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"joe.doe@company.biz"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"uploadFile\"; filename=\"test.txt\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithContentsOfFile:@"/test.txt"]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postRequest setHTTPBody:postBody];
	
	//sending the request via the 'htmlView' WebView:
        [[htmlView mainFrame] loadRequest:postRequest];
}

//Also note
[postRequest setHTTPBodyStream:[NSInputStream inputStreamWithFileAtPath:filePath]];
*/

@end
