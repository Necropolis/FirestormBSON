//
//  FSBsonSerializable.h
//  FirestormBSON
//
//  Created by Christopher Miller on 9/7/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSBsonSerializable <NSObject>

/**
 * Return a valid object (NSArray, NSDictionary, NSNumber, NSValue, NSNull) for serialization. The object cannot adopt this protocol or the universe will explode.
 */
- (id)fs_bsonSerialize;

@end
