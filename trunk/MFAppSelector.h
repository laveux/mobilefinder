/*
	MFAppSelector.h
	
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
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIView.h>
#import <UIKit/CDStructures.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTableCell.h>
#import <UIKit/UINavBarButton.h>

@interface MFAppSelector : UIView
{
	UIPreferencesTable* _appTable;
	
	UIPreferencesTableCell* _appGroup;
	UINavBarButton* _cancelButton;
	NSMutableArray* _appCells;
	NSMutableArray* _appIDs;
	
	id _target;
	SEL _selector;
}

- (id) initWithFrame: (struct CGRect)frame;
- (void) dealloc;
- (SEL) setTarget: (id)target selector: (SEL)selector;

@end
