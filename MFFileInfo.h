/*
	MFFileInfo.h
	
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
#import <UIKit/UIView.h>

@interface MFFileInfo : UIView
{
	UIPreferencesTable* _infoTable;
	
	UIPreferencesTableCell* _actionsGroup;	
	UIPreferencesTableCell* _saveCell;
	
	UIPreferencesTableCell* _fileInfoGroup;
	UIPreferencesTextTableCell* _filenameCell;
	UIPreferencesTableCell* _createdDateCell;
	UIPreferencesTableCell* _modifiedDateCell;
	
	UIPreferencesTableCell* _attributesGroup;
	UIPreferencesTableCell* _ownerAttribCell;
	UIPreferencesTableCell* _groupAttribCell;
	UIPreferencesTableCell* _allAttribCell;	
}
- (void) initWithFrame: (struct CGRect)frame;
- (void) dealloc;
@end