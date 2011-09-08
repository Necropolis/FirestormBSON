//
//  FSBSONParser.h
//  FSBSONParser
//
//  Created by Christopher Miller on 9/6/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

// lovingly pilfered from NextiveJSON
#ifdef __clang__
    #define NOTNULL(...) __attribute__((nonnull (__VA_ARGS__)))
    #define NORETURN __attribute__((analyzer_noreturn))
#else
    #define NOTNULL(...) 
    #define NORETURN 
#endif

@interface FSBsonParser : NSObject {
@protected
    NSData * data;
    NSNull * null;
}

/**
 * Parse a bunch of BSON and get back an object. It's probably an NSDictionary.
 *
 * @param data The data. This could be from a URL, file, random bits you type into your keyboard...
 * @param error Check this for bad stuff.
 */
+ (id)parseData:(NSData *)data error:(NSError **)error;

-(id)initWithData:(NSData *)data NOTNULL(1);

-(id)parse:(NSError **)error;

@end
