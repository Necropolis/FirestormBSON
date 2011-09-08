//
//  FSBsonSerializer.h
//  FirestormBSON
//
//  Created by Christopher Miller on 9/6/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "bson.h"

@interface FSBsonSerializer : NSObject

/**
 * Turn this object graph into BSON data. Valid objects include:
 *
 * - NSDictionary
 * - NSArray
 * - NSNumber
 * - NSValue
 * - NSDate
 * - NSNull
 */
+ (NSData *)serialize:(id)object;

/**
 * Turn this object graph into BSON data.
 */
- (NSData *)serialize:(id)object;

@end
