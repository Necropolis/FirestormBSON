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

    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:[NSNumber numberWithInt:70] forKey:@"aNumber"];
    [dict setObject:[NSNumber numberWithDouble:3.141592654f] forKey:@"pi"];
    [dict setObject:[NSArray arrayWithObjects:@"String!", @"String?", nil] forKey:@"anArray"];
    [dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Value", @"Key", nil] forKey:@"dict"];
    
    FSBsonSerializer * serializer = [[FSBsonSerializer alloc] init];
    
    NSLog(@"Input: %@", dict);
    
    NSData * d = [serializer serialize:dict];
    
    NSLog(@"Data: %@", d);
    
    NSError * error = nil;
    id result = [FSBsonParser parseData:d error:&error];
    
    NSLog(@"Result: %@", result);
    
    [dict release];
    [serializer release];

    [pool drain];
    return 0;
}

