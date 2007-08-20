/*
	MSAppLauncher.m
	
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
#import "MSAppLauncher.h"

@implementation MSAppLauncher : NSObject

+ (void) launchApplication: (NSString*)appID withApplication: (UIApplication*)app
{
	//Regular app launch method: launch with no LaunchInfo.plist (Thanks Launcher.app dev team!)
	[app launchApplicationWithIdentifier: appID suspended: NO];
}

+ (void) launchApplication: (NSString*)appID 
	withAppBundlePath: (NSString*)appBundlePath 
	withArguments: (NSArray*)args 
	withApplication: (UIApplication*)app 
	withLaunchingAppID: (NSString*)launchingAppID 
	withLaunchingAppBundlePath: (NSString*)launchingAppBundlePath
{
	//Build LaunchInfo.plist dictionary
	NSDictionary* plist = [[NSDictionary alloc] initWithObjectsAndKeys:
		launchingAppID, @"MSLaunchingAppIdentifier",
		launchingAppBundlePath, @"MSLaunchingAppBundlePath",
		appID, @"MSLaunchedAppIdentifier",
		appBundlePath, @"MSLaunchedAppBundlePath",		
		args, @"MSLaunchedAppArguments",
		nil];
	
	//Seralize LaunchInfo.plist dictionary
	NSString* error;
	NSData* rawPList = [NSPropertyListSerialization dataFromPropertyList: plist		
		format: NSPropertyListXMLFormat_v1_0
		errorDescription: &error];
	
	//Write LaunchInfo.plist file
	NSString* path = [appBundlePath stringByAppendingPathComponent: @"LaunchInfo.plist"];
	[rawPList writeToFile: path atomically: YES];

	//Actually launch application
	[MSAppLauncher launchApplication: appID withApplication: app];
}

+ (NSDictionary*) readLaunchInfoFromBundlePath: (NSString*)bundlePath deletingLaunchPList: (BOOL)deleteLaunchPList
{
	//Build the full path to the LaunchInfo.plist file
	NSString* plistPath = [bundlePath stringByAppendingPathComponent: @"LaunchInfo.plist"];
	
	//Open the plist and find the application's identifier
	//TODO: file errors
	if ([[NSFileManager defaultManager] isReadableFileAtPath: plistPath])
	{
		NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfFile: plistPath];
		if (deleteLaunchPList)
			[[NSFileManager defaultManager] removeFileAtPath: plistPath handler: nil];
		return plistDict;
	}
	
	//Property list not found, return nil
	return nil;
}

+ (id) readLaunchInfoKey: (NSString*)key fromBundlePath: (NSString*)bundlePath deletingLaunchPList: (BOOL)deleteLaunchPList
{
	NSDictionary* plistDict = [MSAppLauncher readLaunchInfoFromBundlePath: bundlePath deletingLaunchPList: deleteLaunchPList];
	if (plistDict == nil)
		return nil;
		
	NSEnumerator* enumerator = [plistDict keyEnumerator];
	NSString* currKey;
	while (currKey = [enumerator nextObject]) 
	{					
		if ([currKey isEqualToString: key])
		{
			return [plistDict valueForKey: currKey];
		}
	}
}

+ (NSArray*) readLaunchInfoArgumentsFromBundlePath: (NSString*)bundlePath deletingLaunchPList: (BOOL)deleteLaunchPList
{
	//Return the argument array from the launch info file
	return [MSAppLauncher readLaunchInfoKey: @"MSLaunchedAppArguments" 
		fromBundlePath: bundlePath 
		deletingLaunchPList: deleteLaunchPList];
}

+ (NSString*) readLaunchInfoArgumentFromBundlePath: (NSString*)bundlePath deleteingLaunchPList: (BOOL)deleteLaunchPList
{
	//Return just the first argument from the launch info argument array
	NSArray* args = [MSAppLauncher readLaunchInfoArgumentsFromBundlePath: bundlePath deletingLaunchPList: deleteLaunchPList];
	if (args == nil)
		return nil;
	else
		return [args objectAtIndex: 0];
}

@end
