/*
	MobileFinderBrowser.h
	
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

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIView.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>
#import <UIKit/UITable.h>
#import <UIKit/UITableColumn.h>
#import <UIKit/UINavigationBar.h>

@interface MobileFinderBrowser : UIView
{
	UITable* _fileviewTable;
	UITableColumn* _fileviewTableCol;
	NSFileManager* _fileManager;
    NSMutableArray* _fileviewCells;
	NSMutableArray* _fileviewCellFilenames;
	id _delegate;
	NSString* _selectedPath;
}
- (id) initWithFrame: (struct CGRect)rect;
- (NSString*) currentDirectory;
- (NSString*) currentSelectedPath;
- (void) setDelegate: (id)delegate;
- (void) refreshFileView;
- (void) openPath: (NSString*)path;
- (void) selectPath: (NSString*)path;
- (void) changeDirectoryToRoot;
- (void) changeDirectoryToLast;
- (void) changeDirectoryToHome;
- (void) sendSrcPath: (NSString*)srcPath ToDstPath: (NSString*)dstPath ByMoving: (BOOL)move;
- (UIImage*) determineFileIcon: (NSString*)path;
- (void) deletePath: path;

@end

//Protocol for browser state change notifications
@interface NSObject (MobileFinderBrowserStateChange)
- (void) browserCurrentDirectoryChanged: (MobileFinderBrowser*)browser ToPath: (NSString*)path;
- (void) browserCurrentSelectedPathChanged: (MobileFinderBrowser*) browser ToPath: (NSString*) path;
@end

