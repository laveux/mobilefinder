/*
	MSAppLauncher.h
	
	MobileStudio standard application launcher
	
	Copyright 2007 Matt Stoker
	Begun: Aug/17/2007
	
	Thanks: iPhone Dev Team for Compilation Toolchain
	
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

@interface MSAppLauncher : NSObject
{
}

+ (void) launchApplication: (NSString*)appID withApplication: (UIApplication*)app;
+ (void) launchApplication: (NSString*)appID withAppBundlePath: (NSString*)appBundlePath withArguments: (NSArray*)args withApplication: (UIApplication*)app withLaunchingAppID: (NSString*)launchingAppID withLaunchingAppBundlePath: (NSString*)launchingAppBundlePath;
+ (NSArray*) readLaunchInfoArgumentsFromBundlePath: (NSString*)plistPath;
+ (NSString*) readLaunchInfoArgumentFromBundlePath: (NSString*)plistPath;

@end