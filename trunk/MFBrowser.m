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
	[_fileviewTable reloadData];
	[self addSubview: _fileviewTable];
	
	//Set preference defaults
	_showHiddenFiles = FALSE;
	_launchApplications = TRUE;
	_protectSystemFiles = TRUE;
	_fileTypeAssociations = nil;
	
	//List root
	_fileManager = [NSFileManager defaultManager];
	[self changeDirectoryToApplications];
	
	return self;
}

- (NSString*) absolutePath: (NSString*)path
{
	NSString* straitPath = [path stringByStandardizingPath];	
	if ([straitPath isAbsolutePath] == FALSE)
	{
		straitPath = [[self currentDirectory] stringByAppendingPathComponent: path];
		straitPath = [path stringByStandardizingPath];
	}
	
	return straitPath;
}

- (NSString*) currentDirectory
{
	return [[_fileManager currentDirectoryPath] stringByStandardizingPath];
}

- (NSString*) currentSelectedPath
{
	return _selectedPath;
}

- (BOOL) launchApplications
{
	return _launchApplications;
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

- (void) setDelegate: (id)delegate;
{
	_delegate = delegate;
	
	[self openPath: [self currentDirectory]];
}

- (void) setLaunchApplications: (BOOL)launchApplications
{
	_launchApplications = launchApplications;
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
	//TODO: Ownership stuff.  Leaks!
	_fileTypeAssociations = [[NSArray alloc] initWithArray: fileTypeAssociations];
}

- (void) refreshFileView
{
	//Make sure we have a new, empty fileviewCells
	//TODO: Releases cells?
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
			//TODO: Nicer filename, or raw?
			UIImageAndTextTableCell* cell = [[UIImageAndTextTableCell alloc] init];
			[cell setTitle: filename];	
			[cell setImage: [self determineFileIcon: filename]];
					
			//Add filename and cell to collections
			//Cells and filenames are stored seperately to allow the displayed name to differ from the actual name
			//(eg. Calculator.app -> Calculator)
			//TODO: This
			[_fileviewCells addObject: cell];
			[_fileviewCellFilenames addObject: filename];
		}
	}
	
	//Refresh the fileview table
	[_fileviewTable reloadData];
}

- (void) selectPath: (NSString*)path
{
	_selectedPath = [[NSString alloc] initWithString: path];
	if ([_delegate respondsToSelector: @selector(browserCurrentSelectedPathChanged:toPath:)])	
		[_delegate browserCurrentSelectedPathChanged: self toPath: _selectedPath];
	
	//TODO: Select the table cell in the UI or make this function private
}

- (void) openPath: (NSString*)path
{
	//Get path extension and absolute path
	NSString* extension = [path pathExtension];
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
	if ([_fileManager changeCurrentDirectoryPath: path])
	{
		//Refresh the fileview table
		[self refreshFileView];		
	
		//Let delegate know of directory change
		if ([_delegate respondsToSelector: @selector(browserCurrentDirectoryChanged:toPath:)])
			[_delegate browserCurrentDirectoryChanged: self 
				toPath: [[self currentDirectory] stringByStandardizingPath]];
		
		//Execute application if this is an application
		//TODO: Need to save current position in finder before execute
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
			
		//If the file is an executable, execute it
		if ([_fileManager isExecutableFileAtPath: absolutePath])
		{
			//WARNING: This executes GUI apps, but they never return!  You have to reboot!
			//Should only execute executables that eventually end
			//TODO: Allow cancelation of execution
			//TODO: Make execution of these a setting
			system([absolutePath fileSystemRepresentation]);
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
				//TODO: Should be case sensitive?
				if ([extension isEqualToString: associationExtension])
				{
					//Launch application with file as argument
					[MSAppLauncher launchApplication: associationAppID 
						withArguments: [[NSArray alloc] initWithObjects: absolutePath, nil]
						withLaunchingAppID: _applicationID
						withApplication: _application];	
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
	NSString* extension = [path pathExtension];
	
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
		return [UIImage applicationImageNamed: @"Folder_64x64.png"];
	
	//Check file extensions for an image match
	if ([extension isEqualToString: @"txt"])
		return [UIImage applicationImageNamed: @"Text_64x64.png"];
	if ([extension isEqualToString: @"xml"])
		return [UIImage applicationImageNamed: @"XML_64x64.png"];
	if ([extension isEqualToString: @"png"])
		return [UIImage applicationImageNamed: @"PNG_64x64.png"];
	if ([extension isEqualToString: @"plist"])
		return [UIImage applicationImageNamed: @"XML_64x64.png"];
	
	//Executables
	if (isExecutable)
		return [UIImage applicationImageNamed: @"Executable_64x64.png"];	
	
	//TODO: More icons!
		
	//Special icon for file not found.  Return default.
	return [UIImage applicationImageNamed: @"File_64x64.png"];
}

- (void) changeDirectoryToRoot
{
	[self openPath: @"/"];
}

- (void) changeDirectoryToLast
{
	//TODO: Select cell that contains current path
	if (_protectSystemFiles == TRUE && [[self currentDirectory] isEqualToString: NSHomeDirectory()])
		[self changeDirectoryToApplications];
	else if (_protectSystemFiles == TRUE && [[self currentDirectory] isEqualToString: @"/Applications"])
		[self changeDirectoryToApplications];
	else
		[self openPath: @"../"];
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
	//Ensure absolute paths
	NSString* absoluteSrcPath = [self absolutePath: srcPath];
	NSString* absoluteDstPath = [self absolutePath: dstPath];
	
	//TODO: Test this well
	BOOL operationSuccess;
	if (move == TRUE)
	{
		//operationSuccess = [_fileManager movePath: srcPath toPath: dstPath handler: nil];
		//[[NSFileManager defaultManager] movePath: @"/Test" toPath: @"/System/Test" handler: nil];
		
		//HACK: Above statements crash program.  Use system call to move file
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
	
	//TODO: error on failed operation
	[self refreshFileView];
}

- (void) makeDirectoryAtPath: (NSString*)path
{
	BOOL operationSuccess = [_fileManager createDirectoryAtPath: path attributes: nil];
	//TODO: error on failed deletion
	[self refreshFileView];
}

- (void) makeFileAtPath: (NSString*)path
{
	BOOL operationSuccess = [_fileManager createFileAtPath: path contents: nil attributes:nil];
	//TODO: error on failed deletion
	[self refreshFileView];
}

- (void) deletePath: (NSString*)path
{
	BOOL operationSuccess = [_fileManager removeFileAtPath: path handler: nil];
	//TODO: error on failed deletion
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
	
	//Create keyboard to rename file with
	//TODO: Make return button finish filename
	CGRect kbRect;
	kbRect.size = CGSizeMake(_fileviewTableRect.size.width, 216.0f);//[UIKeyboard defaultSize];
	kbRect.origin.x = _fileviewTableRect.origin.y;
	kbRect.origin.y = _fileviewTableRect.origin.y + _fileviewTableRect.size.height - kbRect.size.height;
	_keyboard = [[UIKeyboard alloc] initWithFrame: kbRect];
	[_keyboard hideSuggestionBar];
	
	//Create text box with icon to rename the file with
	CGRect textFieldRect = _fileviewTableRect;
	textFieldRect.size.height = _fileviewTableRect.size.height - kbRect.size.height;
	_filenameTextField = [[UITextView alloc] initWithFrame: textFieldRect];
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

- (UITableCell*) table: (UITable*)table cellForRow: (int)row column: (int)col
    reusing: (BOOL) reusing
{
	//What does this message do?
    return nil;
}

- (int) numberOfRowsInTable: (UITable*)table
{
	return [_fileviewCells count];
}

- (void) tableRowSelected: (NSNotification*) notification 
{
	//Get selected cell and filename
	UIImageAndTextTableCell* selectedCell = [_fileviewCells objectAtIndex: [_fileviewTable selectedRow]];
	NSString* selectedCellFilename = [_fileviewCellFilenames objectAtIndex: [_fileviewTable selectedRow]];
	NSString* selectedPath = [[self currentDirectory] stringByAppendingPathComponent: selectedCellFilename];
	
	if (_selectedPath != nil && [selectedPath isEqualToString: _selectedPath])
		[self openPath: selectedPath];
	else
		[self selectPath: selectedPath];
}

@end
