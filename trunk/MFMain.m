/*
	MFMain.m
	
	Main file for MobileFinder.  Creates an instance of the app and runs it.
	
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

#import </usr/include/objc/objc-class.h>
#import <UIKit/UIKit.h>
#import "MFApp.h"

int main(int argc, char** argv)
{
	//Allocate autorelease pool and run application
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	
	int appReturn = UIApplicationMain(argc, argv, [MFApp class]);	
	
	//Free all memory and return result of application's run
	[pool release];
	return appReturn;
}

//Takes the place of automatically generated objc function until the toolchain is fixed for this function
double objc_msgSend_fpret(id self, SEL op, ...) 
{
	Method method = class_getInstanceMethod(self->isa, op);
	int numArgs = method_getNumberOfArguments(method);
	
	if(numArgs == 2) {
		double (*imp)(id, SEL);
		imp = (double (*)(id, SEL))method->method_imp;
		return imp(self, op);
	} else if(numArgs == 3) {
		// FIXME: this code assumes the 3rd arg is 4 bytes
		va_list ap;
		va_start(ap, op);
		double (*imp)(id, SEL, void *);
		imp = (double (*)(id, SEL, void *))method->method_imp;
		return imp(self, op, va_arg(ap, void *));
	}
	
	// FIXME: need to work with multiple arguments/types
	fprintf(stderr, "ERROR: objc_msgSend_fpret, called on <%s %p> with selector %s, had to return 0.0\n", object_getClassName(self), self, sel_getName(op));
	return 0.0;	
}

