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

+ (void) launchApplication: (NSString*)appID
	withApplication: (UIApplication*)app
{
	//Actually launch application (Thanks Launcher.app dev team!)
	[app launchApplicationWithIdentifier: appID suspended: NO];
}

+ (void) launchApplication: (NSString*)appID 
	withLaunchingAppID: (NSString*)launchingAppID 
	withApplication: (UIApplication*)app
{
	NSArray* args = [[NSArray alloc] init];
	
	[MSAppLauncher launchApplication: appID
		withArguments: args 
		withLaunchingAppID: launchingAppID
		withApplication: app];
		
	[args release];
}

+ (void) launchApplication: (NSString*)appID 
	withArguments: (NSArray*)args 
	withLaunchingAppID: (NSString*)launchingAppID 
	withApplication: (UIApplication*)app 
{
	//Build launch info dictionary
	NSDictionary* plist = [[NSDictionary alloc] initWithObjectsAndKeys:
		launchingAppID, @"MSLaunchingAppIdentifier",
		appID, @"MSLaunchedAppIdentifier",
		args, @"MSLaunchedAppArguments",
		nil];
	
	//Serialize launch info dictionary
	NSString* error;
	NSData* rawPList = [NSPropertyListSerialization dataFromPropertyList: plist		
		format: NSPropertyListXMLFormat_v1_0
		errorDescription: &error];
	
	//Ensure exsistance of MobileStudio folder
	[[NSFileManager defaultManager] createDirectoryAtPath: [MSAppLauncher msDirPathWithApplication: app] attributes: nil];
			
	//Write launch info file
	NSString* launchPListPath = [MSAppLauncher launchInfoPathForAppID: appID withApplication: app];
	[rawPList writeToFile: launchPListPath atomically: YES];
	
	[plist release];
	
	//Actually launch application (Thanks Launcher.app dev team!)
	[MSAppLauncher launchApplication: appID withApplication: app];
}

+ (NSDictionary*) readLaunchInfoForAppID: (NSString*)appID withApplication: app deletingLaunchPList: (BOOL)deleteLaunchPList
{
	//Build the full path to the LaunchInfo.plist file
	NSString* plistPath = [MSAppLauncher launchInfoPathForAppID: appID withApplication: app];
	
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

+ (id) readLaunchInfoKey: (NSString*)key forAppID: (NSString*)appID withApplication: app deletingLaunchPList: (BOOL)deleteLaunchPList
{
	//Get the dictonary form of the launch info file
	NSDictionary* plistDict = [MSAppLauncher readLaunchInfoForAppID: appID 
		withApplication: app 
		deletingLaunchPList: deleteLaunchPList];
	if (plistDict == nil)
		return nil;
		
	//Linearly search for the key
	NSEnumerator* enumerator = [plistDict keyEnumerator];
	NSString* currKey;
	while (currKey = [enumerator nextObject]) 
	{					
		if ([currKey isEqualToString: key])
		{
			return [plistDict valueForKey: currKey];
		}
	}
	
	//Key not found, return nil
	return nil;
}

+ (NSArray*) readLaunchInfoArgumentsForAppID: (NSString*)appID withApplication: app deletingLaunchPList: (BOOL)deleteLaunchPList
{
	//Return the argument array from the launch info file
	return [MSAppLauncher readLaunchInfoKey: @"MSLaunchedAppArguments" 
		forAppID: appID 
		withApplication: app
		deletingLaunchPList: deleteLaunchPList];
}

+ (NSString*) readLaunchInfoArgumentForAppID: (NSString*)appID withApplication: app deletingLaunchPList: (BOOL)deleteLaunchPList
{
	//Return just the first argument from the launch info argument array
	NSArray* args = [MSAppLauncher readLaunchInfoArgumentsForAppID: appID 
		withApplication: app
		deletingLaunchPList: deleteLaunchPList];
	if (args == nil || [args count] == 0)
		return nil;
	else
		return [args objectAtIndex: 0];
}

+ (NSString*) msDirPathWithApplication: (UIApplication*)app
{
	return [[app userLibraryDirectory] stringByAppendingPathComponent: @"MobileStudio"];
}

+ (NSString*) launchInfoPathForAppID: (NSString*)appID withApplication: app
{
	return [[[MSAppLauncher msDirPathWithApplication: app] 
		stringByAppendingPathComponent: appID]
		stringByAppendingPathExtension: @"plist"];
}

@end
