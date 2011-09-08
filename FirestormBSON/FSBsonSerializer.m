//
//  FSBsonSerializer.m
//  FirestormBSON
//
//  Created by Christopher Miller on 9/6/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import "FSBsonSerializer.h"

#define NAME_OR_ZERO(name) (name)?[name UTF8String]:"0"
#ifdef __LP64__
    #define bson_append_nsinteger(bson, name, value) bson_append_long(bson, name, value)
    #define bson_append_nsuinteger(bson, name, value) bson_append_long(bson, name, value)
#else
    #define bson_append_nsinteger(bson, name, value) bson_append_int(bson, name, value)
    #define bson_append_nsuinteger(bson, name, value) bson_append_int(bson, name, value)
#endif

@interface FSBsonSerializer() {
    NSNull * null;
}

- (void)serializeWhatever:(id)whatever withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeDictionary:(NSDictionary *)dict withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeArray:(NSArray *)arr withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeString:(NSString *)string withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeValue:(NSValue *)val withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeNumber:(NSNumber *)num withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeDate:(NSDate *)date withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeData:(NSData *)data withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeNullWithName:(NSString *)name toBson:(bson *)bson;

@end

@implementation FSBsonSerializer

+ (NSData *)serialize:(id)object
{
    FSBsonSerializer * serializer = [[FSBsonSerializer alloc] init];
    NSData * data = [serializer serialize:object];
    [serializer release];
    return data;
}

- (NSData *)serialize:(id)object
{
    bson b;
    bson_init(&b);
    
    for (id key in [object allKeys])
        [self serializeWhatever:[object objectForKey:key] withName:[key description] toBson:&b];
    
    bson_finish(&b);
    
    NSData * d = [NSData dataWithBytes:bson_data(&b) length:b.dataSize];
    
    bson_destroy(&b);
    
    return d;
}

- (void)serializeWhatever:(id)whatever withName:(NSString *)name toBson:(bson *)bson
{
         if (whatever == nil)
        [self serializeNullWithName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSNull class]])
        [self serializeNullWithName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSDictionary class]])
        [self serializeDictionary:whatever withName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSArray class]])
        [self serializeArray:whatever withName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSString class]])
        bson_append_string(bson, NAME_OR_ZERO(name), [whatever UTF8String]);
    else if ([whatever isKindOfClass:[NSNumber class]])
        [self serializeNumber:whatever withName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSValue class]])
        [self serializeValue:whatever withName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSDate class]])
        [self serializeDate:whatever withName:name toBson:bson];
    else if ([whatever isKindOfClass:[NSData class]])
        [self serializeData:whatever withName:name toBson:bson];
    else
        [NSException raise:@"Unknown Object Type" format:@"I don't know how to serialize this kind of a class. Please consider making it a pull request if you write a serializer for this class."];
    
}

- (void)serializeDictionary:(NSDictionary *)dict withName:(NSString *)name toBson:(bson *)bson
{
    bson_append_start_object(bson, NAME_OR_ZERO(name));
    
    NSArray * keys = [dict allKeys];
    for (id key in keys)
        [self serializeWhatever:[dict objectForKey:key] withName:[key description] toBson:bson];
    
    bson_append_finish_object(bson);
}

- (void)serializeArray:(NSArray *)arr withName:(NSString *)name toBson:(bson *)bson
{
    bson_append_start_array(bson, NAME_OR_ZERO(name));
    
    for (id object in arr)
        [self serializeWhatever:object withName:nil toBson:bson];
    
    bson_append_finish_object(bson);
}

- (void)serializeString:(NSString *)string withName:(NSString *)name toBson:(bson *)bson
{
    
}

- (void)serializeValue:(NSValue *)val withName:(NSString *)name toBson:(bson *)bson
{

}

- (void)serializeNumber:(NSNumber *)num withName:(NSString *)name toBson:(bson *)bson
{
    const char * type = [num objCType];                 const char * _name = NAME_OR_ZERO(name);
         if (strcmp(type, @encode(int)))                bson_append_int(        bson, _name, [num intValue]                     );
    else if (strcmp(type, @encode(unsigned int)))       bson_append_int(        bson, _name, [num unsignedIntValue]             );
    else if (strcmp(type, @encode(long)))               bson_append_long(       bson, _name, [num longValue]                    );
    else if (strcmp(type, @encode(unsigned long)))      bson_append_long(       bson, _name, [num unsignedLongValue]            );
    else if (strcmp(type, @encode(NSUInteger)))         bson_append_nsuinteger( bson, _name, [num unsignedIntegerValue]         );
    else if (strcmp(type, @encode(NSInteger)))          bson_append_nsinteger(  bson, _name, [num integerValue]                 );
    else if (strcmp(type, @encode(float)))              bson_append_double(     bson, _name, (double)[num floatValue]           );
    else if (strcmp(type, @encode(double)))             bson_append_double(     bson, _name, [num doubleValue]                  );
    else [NSException raise:@"Unknown Data Type" format:@"Please write a case for %s in FSBsonSerializer.m; please consider making it a pull request back so that NSError can add it to the main repository.", __PRETTY_FUNCTION__];
}

- (void)serializeDate:(NSDate *)date withName:(NSString *)name toBson:(bson *)bson
{
    bson_append_date(bson, NAME_OR_ZERO(name), [date timeIntervalSince1970]);
}

- (void)serializeData:(NSData *)data withName:(NSString *)name toBson:(bson *)bson
{
    
}

- (void)serializeNullWithName:(NSString *)name toBson:(bson *)bson
{
    bson_append_null(bson, NAME_OR_ZERO(name));
}

- (id)init
{
    self = [super init];
    if (self) {
        null = [NSNull null];
    }
    
    return self;
}

@end
