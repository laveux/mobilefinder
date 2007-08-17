/*
	MobileFinderBrowser.m
	
	Finder file browser control.
	
	Copyright 2007 Matt Stoker
	Begun: Aug/10/2007
	
	Thanks: iPhone Dev Team
	Compilation Toolchain and Hello World Applicaiton
	
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

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSTask.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UIImage.h>
#import <UIKit/UIButtonBar.h>
#include <unistd.h>
#import "MobileFinderBrowser.h"

@implementation MobileFinderBrowser : UIView

- (id) initWithFrame: (struct CGRect)rect
{
	//Init view with frame rect
	[super initWithFrame: rect];
	
	//Setup fileview table
    _fileviewTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 0.0f, rect.size.width, rect.size.height)];
    _fileviewTableCol = [[UITableColumn alloc] initWithTitle: @"MobileFinder" identifier: @"Finder" width: rect.size.width];
	[_fileviewTable addTableColumn: _fileviewTableCol]; 
    [_fileviewTable setDataSource: self];
    [_fileviewTable setDelegate: self];
	[_fileviewTable setRowHeight: 64.0f];
	[_fileviewTable reloadData];
	[self addSubview: _fileviewTable];
	
	//List root
	_fileManager = [NSFileManager defaultManager];
	[self changeDirectoryToHome];
	
	return self;
}

- (NSString*) absolutePath: (NSString*) path
{
	NSString* absolutePath;
	if ([path isAbsolutePath])
		absolutePath = [[NSString alloc] initWithString: path];
	else
		absolutePath = [[NSString alloc] initWithString: [
			[_fileManager currentDirectoryPath] stringByAppendingPathComponent: path]];		
}

- (NSString*) currentDirectory
{
	return [_fileManager currentDirectoryPath];
}

- (NSString*) currentSelectedPath
{
	return _selectedPath;
}

- (void) setApplication: (UIApplication*)app
{
	_application = app;
}

- (void) setDelegate: (id)delegate;
{
	_delegate = delegate;
	
	//TODO: Better way to initialize this?
	//Notify delegate of current statuses	
	[_delegate browserCurrentDirectoryChanged: self ToPath: [_fileManager currentDirectoryPath]];
	if (_selectedPath != nil)
		[_delegate browserCurrentSelectedPathChanged: self ToPath: _selectedPath];
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
	NSDirectoryEnumerator* dirEnumerator = [_fileManager enumeratorAtPath: [_fileManager currentDirectoryPath]];
	
	//Create table cells for each file in the directory, and add them and their paths to the appropriate collections
	NSString* filename;
	while (filename = [dirEnumerator nextObject]) 
	{
		//Don't decend into directories
		[dirEnumerator skipDescendents];	
		
		//Create table cell for filename
			//TODO: Nicer filename, or raw?
		UIImageAndTextTableCell* cell = [[UIImageAndTextTableCell alloc] init];
		[cell setTitle: filename];	
		[cell setImage: [self determineFileIcon: filename]];
					
		//Add filename and cell to collections
		//Cells and filenames are stored seperately to allow the displayed name to differ from the actual name
		//(eg. Calculator.app -> Calculator)
		[_fileviewCells addObject: cell];
		[_fileviewCellFilenames addObject: filename];
	}
	
	//Refresh the fileview table
	[_fileviewTable reloadData];
}

- (void) selectPath: (NSString*)path
{
	_selectedPath = [[NSString alloc] initWithString: path];
	[_delegate browserCurrentSelectedPathChanged: self ToPath: _selectedPath];
	
	//TODO: Select the table cell in the UI or make this function private
}

- (void) openPath: (NSString*)path
{		
	//Get path extension and absolute path
	NSString* extension = [path pathExtension];
	NSString* absolutePath = [self absolutePath: path];		
	
	//Change to the specified path, if it is a directory
	if ([_fileManager changeCurrentDirectoryPath: path])
	{
		//Refresh the fileview table
		[self refreshFileView];		
	
		//Let delegate know of directory change
		[_delegate browserCurrentDirectoryChanged: self ToPath: [_fileManager currentDirectoryPath]];
		
		//Execute application if this is an application
		//TODO: Need to save current position in finder before execute
		if ([extension isEqualToString: @"app"] && _application != nil)
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
				int i = 0;
				while ((key = [enumerator nextObject])) 
				{					
					if ([key isEqualToString: @"CFBundleIdentifier"])
					{
						[_delegate browserCurrentDirectoryChanged: self ToPath: key];
						appID = [plistDict valueForKey: key];
					}
				}				
				
				//Launch application (Thanks Launcher.app dev team!)
				if (appID != nil)
					[_application launchApplicationWithIdentifier:appID suspended:NO];
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
			system([absolutePath fileSystemRepresentation]);
		}		
		else if ([extension isEqualToString: @"txt"])
		{
			//TODO: Dynamic prefs for strings
			[_application launchApplicationWithIdentifier:@"com.port21.iphone.TextEdit" suspended: NO];
		}
	}
}

- (void) changeDirectoryToRoot
{
	[self openPath: @"/"];
}

- (void) changeDirectoryToLast
{
	[self openPath: @"../"];
}

- (void) changeDirectoryToHome
{
	[self openPath: NSHomeDirectory()];
}

- (void) sendSrcPath: (NSString*)srcPath ToDstPath: (NSString*)dstPath ByMoving: (BOOL)move;
{
	//Ensure absolute paths
	//TODO: Files in root are interprated as non-absolute (eg: /Test).  This should be fixed to allow
	//relative paths to be moved/copied
	//if ([srcPath isAbsolutePath] == FALSE && [srcPath isEqualToString: @"/"] == FALSE);
	//	srcPath = [[_fileManager currentDirectoryPath] stringByAppendingPathComponent: srcPath]; 
	//if ([dstPath isAbsolutePath] == FALSE && [dstPath isEqualToString: @"/"] == FALSE)
	//	dstPath = [[_fileManager currentDirectoryPath] stringByAppendingPathComponent: dstPath];
		
	//Get source file attributes
	BOOL srcPathIsDirectory;
	BOOL srcPathExsists = [_fileManager fileExistsAtPath: srcPath isDirectory: &srcPathIsDirectory];
	BOOL srcPathIsReadable = [_fileManager isReadableFileAtPath: srcPath];
	
	//Get destination file attributes
	BOOL dstPathIsDirectory;
	BOOL dstPathExsists = [_fileManager fileExistsAtPath: dstPath isDirectory: &dstPathIsDirectory];	
	//If the destination path isn't a directory, get it's parent
	NSString* dstDirPath;
	if (dstPathIsDirectory)
	{
		dstDirPath = [[NSString alloc] initWithString: dstPath];
		dstPath = [dstDirPath stringByAppendingPathComponent: [srcPath lastPathComponent]];
	}
	else
	{
		dstDirPath = [dstPath stringByDeletingLastPathComponent];
		dstPathExsists = FALSE;	
	}
	BOOL dstPathIsWritable = [_fileManager isReadableFileAtPath: dstPath];
	BOOL dstPathIsDeletable = [_fileManager isDeletableFileAtPath: dstPath];	
	BOOL dstDirIsDirectory;
	BOOL dstDirExsists = [_fileManager fileExistsAtPath: dstDirPath isDirectory: &dstDirIsDirectory];	
	BOOL dstDirIsWritable = [_fileManager isWritableFileAtPath: dstDirPath];
	
	//TODO: error needed
	if (dstDirIsDirectory == FALSE || dstDirExsists == FALSE || dstDirIsWritable == FALSE)
		return;
	
	//TODO: dstPathExsists seems to always be true!	
	//if (dstPathExsists)
	//{
		//TODO: Implement this!
				
	//}
	//else
	//{
		BOOL operationSuccess;
		if (move == TRUE)
		{
			//operationSuccess = [_fileManager movePath: srcPath toPath: dstPath handler: nil];
			//[[NSFileManager defaultManager] movePath: @"/Test" toPath: @"/System/Test" handler: nil];
			
			//HACK: Above statements crash program.  Use system call to move file
			NSString* moveCommand = [[[[[NSString string]
				stringByAppendingString: @"/bin/mv "] 
				stringByAppendingString: srcPath]
				stringByAppendingString: @" "]
				stringByAppendingString: dstDirPath];
			system([moveCommand UTF8String]);
			usleep(10);	
		}
		else
		{
			//operationSuccess = [_fileManager copyPath: srcPath toPath: dstPath handler: nil];
			
			//HACK: Above statement crashes program.  Use system call to copy file
			NSString* copyCommand = [[[[[NSString string]
				stringByAppendingString: @"/bin/cp -R "] 
				stringByAppendingString: srcPath]
				stringByAppendingString: @" "]
				stringByAppendingString: dstDirPath];
			system([copyCommand UTF8String]);
			usleep(10);	
		}
		
		//TODO: error on failed operation
		[self refreshFileView];
	//}
}

- (void) deletePath: path
{
	BOOL operationSuccess = [_fileManager removeFileAtPath: path handler: nil];
	//TODO: error on failed deletion
	[self refreshFileView];
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
		//TODO: Could use any of these from UIImage to load path. Which will work most often?
		//+ (id)applicationImageNamed:(id)fp8;	// IMP=0x323bbdbc
		//+ (id)defaultDesktopImage;	// IMP=0x323bc1f4
		//+ (id)imageAtPath:(id)fp8;	// IMP=0x323bbda4
		//+ (id)imageFromAlbumArtData:(id)fp8 height:(int)fp12 width:(int)fp16 cache:(BOOL)fp20;	// IMP=0x323bc3d8
		//+ (id)imageNamed:(id)fp8;	// IMP=0x323bbd54
		//+ (id)imageNamed:(id)fp8 inBundle:(id)fp12;	// IMP=0x323bbd8c
		NSString* absolutePath = [[NSString alloc] initWithString: path];
		if ([absolutePath isAbsolutePath] == FALSE)
			absolutePath = [[_fileManager currentDirectoryPath] stringByAppendingPathComponent: path];
		NSString* appIconPath = [absolutePath stringByAppendingPathComponent: @"icon.png"];
			
		if ([_fileManager isReadableFileAtPath: appIconPath])
			return [UIImage imageAtPath: appIconPath];
		else
			return [UIImage applicationImageNamed: @"Application.png"];
	}
	
	//Check if file is a directory
	if (isDirectory == TRUE)
		return [UIImage applicationImageNamed: @"Folder.png"];
	
	//Executables
	if (isExecutable)
		return [UIImage applicationImageNamed: @"Executable.png"];	
	
	//TODO: More icons!
		
	//Special icon for file not found.  Return default.
	return [UIImage applicationImageNamed: @"File.png"];
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
	if (table == _fileviewTable)
		return [_fileviewCells count];
	else
		return 0;
}

- (void) tableRowSelected: (NSNotification*) notification 
{
	//Get selected cell and filename
	UIImageAndTextTableCell* selectedCell = [_fileviewCells objectAtIndex: [_fileviewTable selectedRow]];
	NSString* selectedCellFilename = [_fileviewCellFilenames objectAtIndex: [_fileviewTable selectedRow]];
	NSString* selectedPath = [[_fileManager currentDirectoryPath] stringByAppendingPathComponent: selectedCellFilename];
	
	if (_selectedPath != nil && [selectedPath isEqualToString: _selectedPath])
		[self openPath: selectedPath];
	else
		[self selectPath: selectedPath];
}

@end
