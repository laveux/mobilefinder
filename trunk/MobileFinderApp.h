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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIPushButton.h>
#import <UIKit/UITableCell.h>
#import <UIKit/UIImageAndTextTableCell.h>

@interface MobileFinderApp : UIApplication 
{
	UIWindow* _window;
	UIView* _mainView;
	UINavigationBar* _navBar;
	UITable* _fileviewTable;
	UITableColumn* _fileviewTableCol;
	NSFileManager* _fileManager;
    NSMutableArray* _fileviewCells;
	NSMutableArray* _fileviewCellFilenames;
}
- (void) initApplication;
- (void) changeDirectory: (NSString*)path;
- (void) changeDirectoryToRoot;
- (void) changeDirectoryToLast;
- (UIImage*) chooseFileIcon: (NSString*) path;
- (void) navigationBar: (UINavigationBar*)navbar buttonClicked: (int)button;

@end

