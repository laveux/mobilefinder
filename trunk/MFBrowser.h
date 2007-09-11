/*
	MFBrowser.h
	
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
#import <UIKit/UITransitionView.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UITextView.h>

@interface MFBrowser : UITransitionView
{
	//UI elements
	CGRect _fileviewTableRect;
	UITable* _fileviewTable;
	UITableColumn* _fileviewTableCol;
	NSMutableArray* _fileviewCells;
	NSMutableArray* _fileviewCellFilenames;
	
	//Communication
	UIApplication* _application;
	NSString* _applicationID;
	
	//State variables
	NSFileManager* _fileManager;
    NSString* _lastSelectedPath;
	
	//Settings
	BOOL _showHiddenFiles;
	BOOL _launchApplications;
	BOOL _launchExecutables;
	BOOL _protectSystemFiles;
	NSArray* _fileTypeAssociations;
	NSString* _mandatoryLaunchApplication;
	float _rowHeight;
	float _rowHeightBuffer;
}
- (id) initWithApplication: (UIApplication*)app withAppID: (NSString*)appID withFrame: (struct CGRect)rect;
- (void) dealloc;
- (NSString*) absolutePath: (NSString*) path;
- (NSString*) currentDirectory;
- (NSString*) currentSelectedPath;
- (BOOL) launchApplications;
- (BOOL) launchExecutables;
- (BOOL) showHiddenFiles;
- (BOOL) protectSystemFiles;
- (NSArray*) fileTypeAssociations;
- (NSString*) mandatoryLaunchApplication;
- (void) setDelegate: (id)delegate;
- (void) setLaunchApplications: (BOOL)launchApplications;
- (void) setLaunchExecutables: (BOOL)launchExecutables;
- (void) setShowHiddenFiles: (BOOL)showHiddenFiles;
- (void) setProtectSystemFiles: (BOOL)protectSystemFiles;
- (void) setFileTypeAssociations: (NSArray*)fileTypeAssociations;
- (void) setMandatoryLaunchApplication: (NSString*)appID;
- (void) setRowHeight: (int)rowHeight bufferHeight: (int)rowHeightBuffer;
- (void) refreshFileView;
- (void) selectPath: (NSString*)path;
- (void) selectRow: (int)row;
- (void) openPath: (NSString*)path;
- (UIImage*) determineFileIcon: (NSString*)absolutePath;
- (void) changeDirectoryToRoot;
- (void) changeDirectoryToLast;
- (void) changeDirectoryToHome;
- (void) changeDirectoryToApplications;
- (void) sendSrcPath: (NSString*)srcPath toDstPath: (NSString*)dstPath byMoving: (BOOL)move;
- (NSString*) quoteString: (NSString*)string;
- (void) makeDirectoryAtPath: (NSString*)path;
- (void) makeFileAtPath: (NSString*)path;
- (void) deletePath:(NSString*) path;

@end

//Protocol for browser state change notifications
@interface NSObject (MFBrowserStateChange)
- (void) browserCurrentDirectoryChanged: (MFBrowser*)browser toPath: (NSString*)path;
- (void) browserCurrentSelectedPathChanged: (MFBrowser*)browser toPath: (NSString*)path;
- (void) browserWillLaunchApplication: (NSString*)appID withArguments: (NSArray*)args;
@end

