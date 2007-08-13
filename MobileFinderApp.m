/*
	MobileFinderApp.m
	
	Finder application UI.
	
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
#import <UIKit/CDStructures.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UIThreePartButton.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIView-Hierarchy.h>
#import <UIKit/UIHardware.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UITableColumn.h>
#import "MobileFinderApp.h"
#include <unistd.h>

@implementation MobileFinderApp

- (void) initApplication
{   
	//int screenOrientation = [UIHardware deviceOrientation: YES];
	
	//Initialize window
	_window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
    [_window orderFront: self];
    [_window makeKey: self];
    [_window _setHidden: NO];
	
	//Setup main view
    struct CGRect rect = [UIHardware fullScreenApplicationContentRect];
    rect.origin.x = rect.origin.y = 0.0f;
    _mainView = [[UIView alloc] initWithFrame: rect];
    [_window setContentView: _mainView];
	  
	//Setup navigation var
	//CGSize navBarDefaultSize = [UINavigationBar defaultSizeWithPrompt];
	//TODO: Delete, New, and Copy buttons
	_navBar = [[UINavigationBar alloc] initWithFrame: CGRectMake(0.0f, 0.0f, 320.0f, 74.0f)];
	[_navBar showButtonsWithLeftTitle: @"Back" rightTitle: @"Root" leftBack: YES];
    [_navBar setBarStyle: 5];
	[_navBar setDelegate: self];
	[_mainView addSubview: _navBar];
    		  
    //Setup fileview table
    _fileviewTable = [[UITable alloc] initWithFrame: CGRectMake(0.0f, 74.0f, 320.0f, 480.0f - 74.0f - 16.0f)];
    _fileviewTableCol = [[UITableColumn alloc] initWithTitle: @"MobileFinder" identifier: @"Finder" width: 320.0f];
	[_fileviewTable addTableColumn: _fileviewTableCol]; 
    [_fileviewTable setDataSource: self];
    [_fileviewTable setDelegate: self];
    [_fileviewTable reloadData];
	[_mainView addSubview: _fileviewTable];
	
	//List root
	_fileManager = [NSFileManager defaultManager];
	[self changeDirectoryToRoot];
}

- (void) changeDirectory: (NSString*)path
{		
	//Change to the specified path
	if ([_fileManager changeCurrentDirectoryPath: path] == FALSE)
	{
		//The path specified is not a directory
		//Get the full path
		NSString* exeFilename;
		if ([path isAbsolutePath] == TRUE)
			exeFilename = [[NSString alloc] initWithString: path];
		else
			exeFilename = [[_fileManager currentDirectoryPath] stringByAppendingPathComponent: path];		
		
		//If the file is an executable, execute it
		//TODO: This isn't really a "changeDirectory" sort of thing...
		if ([_fileManager isExecutableFileAtPath: exeFilename])
		{
			//WARNING: This executes apps, but they never return!  You have to reboot!
			//system([exeFilename fileSystemRepresentation]);
		}
		
		//Don't decend into the dir, as it isn't one
		return;
	}
	
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
		[cell setImage: [self chooseFileIcon: filename]];
		
		//Add filename and cell to collections
		[_fileviewCells addObject: cell];
		[_fileviewCellFilenames addObject: filename];
	}
	
	//Refresh the fileview table
	[_fileviewTable reloadData];
		
	//Update navigation bar with new current directory
	//TODO: Make "..." appear at end instead of beginning of path
	[_navBar setPrompt: [_fileManager currentDirectoryPath]];
}

- (void) changeDirectoryToRoot
{
	[self changeDirectory: @"/"];
}

- (void) changeDirectoryToLast
{
	[self changeDirectory: @"../"];
}

- (UIImage*) chooseFileIcon: (NSString*) path
{
	//Get file attributes
	BOOL isDirectory;
	BOOL fileExsists = [_fileManager fileExistsAtPath: path isDirectory: &isDirectory];
	BOOL isReadable = [_fileManager isReadableFileAtPath: path];
	BOOL isWritable = [_fileManager isWritableFileAtPath: path];
	BOOL isExecutable = [_fileManager isExecutableFileAtPath: path];
	BOOL isDeletable = [_fileManager isDeletableFileAtPath: path];
	NSString* extension = [path pathExtension];
	
	//Check if file is a directory
	if (isDirectory == TRUE)
		return [UIImage applicationImageNamed: @"Folder.png"];
	
	//Executables
	if (isExecutable)
	{
		return [UIImage applicationImageNamed: @"Executable.png"];
	}
	
	//TODO: More icons!
		
	//Special icon for file not found.  Return default.
	return [UIImage applicationImageNamed: @"File.png"];
}

- (void) navigationBar: (UINavigationBar*)navbar buttonClicked: (int)button 
{
	switch (button) 
	{
		case 0: //Right button
			[self changeDirectoryToRoot];
			break;
		case 1:	//Left button
			[self changeDirectoryToLast];
			break;
	}
}

- (void) applicationDidFinishLaunching: (id)unused
{
	//Init Application
	[self initApplication];    
}

- (UITableCell*) table: (UITable*)table cellForRow: (int)row column: (int)col
{
	return [_fileviewCells objectAtIndex: row];
}

- (UITableCell*) table: (UITable*)table cellForRow: (int)row column: (int)col
    reusing: (BOOL) reusing
{
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
	NSString* selectedFilename = [_fileviewCellFilenames objectAtIndex: [_fileviewTable selectedRow]];
	
	[self changeDirectory: selectedFilename];
}

@end //MobileFinderApp

