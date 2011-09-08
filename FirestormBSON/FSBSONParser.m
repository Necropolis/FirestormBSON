//
//  FSBSONParser.m
//  FSBSONParser
//
//  Created by Christopher Miller on 9/6/11.
//  Copyright 2011 FSDEV. All rights reserved.
//

#import "FSBsonParser.h"

#include "bson.h"

@interface FSBsonParser()
- (NSDictionary *)parseDict:(bson_iterator *)iter error:(NSError **)error;

- (NSArray *)parseArray:(bson_iterator *) iter error:(NSError **)error;
- (id)parseValue:(bson_iterator *)iter error:(NSError **)error;
@end

@implementation FSBsonParser

+ (id)parseData:(NSData *)data error:(NSError **)error
{
    FSBsonParser * parser = [[FSBsonParser alloc] initWithData:data];
    id retVal = [parser parse:error];
    [parser autorelease];
    return retVal;
}

-(id)initWithData:(NSData *)_data
{
    if (self = [self init]) {
        self->data = [_data retain];
    }
    
    return self;
}

-(id)parse:(NSError **)error
{
    bson b; bson_iterator iter;
    
    bson_init_finished_data(&b, (char *)[self->data bytes]);
    bson_iterator_init(&iter, &b);
    
    if (!bson_iterator_more(&iter))
        return nil;
    
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    while (bson_iterator_next(&iter)) {
        [dict setObject:[self parseValue:&iter error:error] forKey:[NSString stringWithUTF8String:bson_iterator_key(&iter)]];
    }
    
    return dict;
}

- (NSDictionary *)parseDict:(bson_iterator *)iter error:(NSError **)error
{
    bson_iterator sub;    
    bson_iterator_subiterator(iter, &sub);

    if (!bson_iterator_more(&sub))
        return [NSDictionary dictionary];

    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    while (bson_iterator_next(&sub)) {
        id newObject = [self parseValue:&sub error:error];
        [dict setObject:newObject forKey:[NSString stringWithUTF8String:bson_iterator_key(&sub)]];
    }
    
    NSDictionary * retDict = [NSDictionary dictionaryWithDictionary:dict]; [dict release];
    return retDict;
}

- (NSArray *)parseArray:(bson_iterator *)iter error:(NSError **)error
{
    bson_iterator sub;
    bson_iterator_subiterator(iter, &sub);

    if (!bson_iterator_more(&sub))
        return [NSArray array];

    NSMutableArray * arr = [[NSMutableArray alloc] init];
    
    while (bson_iterator_next(&sub)) {
        id value = [self parseValue:&sub error:error];
        [arr addObject:[self parseValue:&sub error:error]];
    }
    
    NSArray * retArr = [NSArray arrayWithArray:arr]; [arr release];
    return retArr;
}

- (id)parseValue:(bson_iterator *)iter error:(NSError **)error
{
    id retVal = nil;
    
    switch (bson_iterator_type(iter)) {
        case BSON_OBJECT:
        case BSON_EOO:
            retVal = [self parseDict:iter error:error];
            break;
        case BSON_ARRAY:
            retVal = [self parseArray:iter error:error];
            break;
        case BSON_DOUBLE:
            retVal = [NSNumber numberWithDouble:bson_iterator_double(iter)];
            break;
        case BSON_STRING:
            retVal = [NSString stringWithUTF8String:bson_iterator_string(iter)];
            break;
        case BSON_BINDATA:
            retVal = [NSData dataWithBytes:bson_iterator_bin_data(iter) length:bson_iterator_bin_len(iter)];
            break;
        case BSON_UNDEFINED:
            // TODO: Implement BSON undefined
            break;
        case BSON_OID:
            retVal = [NSValue value:bson_iterator_oid(iter) withObjCType:@encode(bson_oid_t)];
            break;
        case BSON_BOOL:
            retVal = [NSNumber numberWithBool:bson_iterator_bool_raw(iter)];
            break;
        case BSON_DATE:
            retVal = [NSDate dateWithTimeIntervalSince1970:bson_iterator_date(iter)];
            break;
        case BSON_NULL:
            retVal = null;
            break;
        case BSON_REGEX:
            retVal = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSString stringWithUTF8String:bson_iterator_regex(iter)],
                      @"regex",
                      [NSString stringWithUTF8String:bson_iterator_regex_opts(iter)],
                      @"regex opts"
                      , nil];
            break;
        case BSON_DBREF:
            // TODO: Implement BSON dbref
            break;
        case BSON_CODE:
            retVal = [NSString stringWithUTF8String:bson_iterator_code(iter)];
            break;
        case BSON_SYMBOL:
            // TODO: Implement BSON symbol
            break;
        case BSON_CODEWSCOPE:
            // TODO: Implement BSON codewscope
            break;
        case BSON_INT:
            retVal = [NSNumber numberWithInt:bson_iterator_int(iter)];
            break;
        case BSON_TIMESTAMP:
            // TODO: Implement BSON timestampage
            break;
        case BSON_LONG:
            retVal = [NSNumber numberWithLongLong:bson_iterator_long(iter)];
            break;
        default:
            // TODO: Throw a huge error
            break;
    }
    
    return retVal;
}

- (id)init
{
    if (self = [super init]) {
        null = [NSNull null];
    }
    
    return self;
}

- (void)dealloc
{
    [data release], data = nil;

    [super dealloc];
}

@end
