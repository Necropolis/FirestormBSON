//
//  FSBsonSerializer.m
//  FirestormBSON
//
//  Created by Christopher Miller on 9/6/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import "FSBsonSerializer.h"

#define NAME_OR_ZERO(name) (name)?[name UTF8String]:"0"

@interface FSBsonSerializer() {
    NSNull * null;
    
    Class null_class;
    Class dictionary_class;
    Class array_class;
    Class string_class;
    Class number_class;
    Class value_class;
    Class date_class;
    Class data_class;
}

- (void)serializeWhatever:(id)whatever withName:(NSString *)name toBson:(bson *)bson;
- (void)serializeValue:(NSValue *)val withName:(NSString *)name toBson:(bson *)bson;

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
    //                  NULL
    if (whatever == nil)
        bson_append_null(bson, NAME_OR_ZERO(name));
    else if ([whatever isKindOfClass:self->null_class])
        bson_append_null(bson, NAME_OR_ZERO(name));
    //                  NUMBER
    else if ([whatever isKindOfClass:self->number_class]) {
        // rather shamelessly copied from NuBSON
        const char * objCType = [whatever objCType];
        switch (*objCType) {
            case 'd':
            case 'f':
                bson_append_double(bson, NAME_OR_ZERO(name), [whatever doubleValue]);
                break;
            case 'l':
            case 'L':
                bson_append_long(bson, NAME_OR_ZERO(name), [whatever longValue]);
                break;
            case 'q':
            case 'Q':
                bson_append_long(bson, NAME_OR_ZERO(name), [whatever longLongValue]);
                break;
            case 'B':
                bson_append_bool(bson, NAME_OR_ZERO(name), [whatever boolValue]);
                break;
            case 'c':
            case 'C':
            case 's':
            case 'S':
            case 'i':
            case 'I':                
            default:
                bson_append_int(bson, NAME_OR_ZERO(name), [whatever intValue]);
                break;
        }
    }
    //                  DICTIONARY
    else if ([whatever isKindOfClass:self->dictionary_class]) {
        bson_append_start_object(bson, NAME_OR_ZERO(name));
        NSArray * keys = [whatever allKeys];
        for (id key in keys)
            [self serializeWhatever:[whatever objectForKey:key] withName:[key description] toBson:bson];
        bson_append_finish_object(bson);
    }
    else if ([whatever isKindOfClass:self->array_class]) {
        bson_append_start_array(bson, NAME_OR_ZERO(name));
        for (id object in whatever)
            [self serializeWhatever:object withName:nil toBson:bson];
        bson_append_finish_array(bson);
    }
    else if ([whatever isKindOfClass:self->string_class])
        bson_append_string(bson, NAME_OR_ZERO(name), [whatever UTF8String]);
    else if ([whatever isKindOfClass:self->value_class])
        [self serializeValue:whatever withName:name toBson:bson];
    else if ([whatever isKindOfClass:self->date_class])
        bson_append_date(bson, NAME_OR_ZERO(name), [whatever timeIntervalSince1970]);
    else if ([whatever isKindOfClass:self->data_class])
        bson_append_binary(bson, NAME_OR_ZERO(name), 0, [whatever bytes], [whatever length]);
    else
        [NSException raise:@"Unknown Object Type" format:@"I don't know how to serialize this kind of a class. Please consider making it a pull request if you write a serializer for this class."];
    
}

- (void)serializeValue:(NSValue *)val withName:(NSString *)name toBson:(bson *)bson
{
    [NSException raise:@"Todo" format:@"I still need to write this!"];
}

- (id)init
{
    self = [super init];
    if (self) {
        null = [NSNull null];
        self->null_class = [NSNull class];
        self->dictionary_class = [NSDictionary class];
        self->array_class = [NSArray class];
        self->string_class = [NSString class];
        self->number_class = [NSNumber class];
        self->value_class = [NSValue class];
        self->date_class = [NSDate class];
        self->data_class = [NSData class];
    }
    
    return self;
}

@end
