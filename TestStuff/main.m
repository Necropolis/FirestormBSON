//
//  main.m
//  TestStuff
//
//  Created by Christopher Miller on 9/7/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSBsonParser.h"
#import "FSBsonSerializer.h"

#include <math.h>

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:70] forKey:@"aNumber"];
	[dict setObject:[NSNumber numberWithDouble:3.1415926532f] forKey:@"pi"];
	[dict setObject:[NSArray arrayWithObjects:@"String!", @"String?", nil] forKey:@"anArray"];
	[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Value", @"Key", nil] forKey:@"dict"];
    
	NSLog(@"Input: %@", dict);
    
	NSData * data = [FSBsonSerializer serialize:dict];
    
	
	NSError * error = nil;
	id result = [FSBsonParser parseData:data error:&error];

    NSLog(@"Result: %@", result);
    
    [pool drain];
    return 0;
}

