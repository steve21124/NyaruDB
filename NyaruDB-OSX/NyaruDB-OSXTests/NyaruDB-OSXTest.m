//
//  NyaruDB-OSXTest.m
//  NyaruDB-OSX
//
//  Created by Kelp on 2013/03/27.
//
//

#import "NyaruDB-OSXTest.h"
#import "NyaruDB.h"

#define PATH @"/tmp/NyaruDB"


@implementation NyaruDB_OSXTest

- (void)testInit
{
    NyaruDB *db = [[NyaruDB alloc] initWithPath:PATH];
    NyaruCollection *co = [db collectionForName:@"init"];
    [co removeAll];
    
    [db close];
}

- (void)test07ReadWrite
{
    NyaruDB *db = [[NyaruDB alloc] initWithPath:PATH];
    [db removeCollection:@"07"];
    NyaruCollection *co = [db collectionForName:@"07"];
    
    NSDictionary *subDict = @{@"sub": @"data", @"empty": @""};
    NSArray *array = @[@"A", @-1, [NSNull null], @""];
    NSDictionary *doc = @{@"key": @"a",
                          @"number": @100,
                          @"double": @1000.00002,
                          @"date": [NSDate dateWithTimeIntervalSince1970:100],
                          @"null": [NSNull null],
                          @"sub": subDict,
                          @"array": array};
    [co insert:doc];
    [co clearCache];
    NSDictionary *check = co.all.fetch.lastObject;
    STAssertEqualObjects([check objectForKey:@"key"], [doc objectForKey:@"key"], nil);
    STAssertEqualObjects([check objectForKey:@"number"], [doc objectForKey:@"number"], nil);
    STAssertEqualObjects([check objectForKey:@"double"], [doc objectForKey:@"double"], nil);
    STAssertEqualObjects([check objectForKey:@"date"], [doc objectForKey:@"date"], nil);
    STAssertEqualObjects([check objectForKey:@"null"], [doc objectForKey:@"null"], nil);
    STAssertEqualObjects([[check objectForKey:@"sub"] objectForKey:@"sub"], [subDict objectForKey:@"sub"], nil);
    STAssertEqualObjects([[check objectForKey:@"sub"] objectForKey:@"empty"], [subDict objectForKey:@"empty"], nil);
    STAssertEqualObjects([[check objectForKey:@"array"] objectAtIndex:0], [array objectAtIndex:0], nil);
    STAssertEqualObjects([[check objectForKey:@"array"] objectAtIndex:1], [array objectAtIndex:1], nil);
    STAssertEqualObjects([[check objectForKey:@"array"] objectAtIndex:2], [array objectAtIndex:2], nil);
    STAssertEqualObjects([[check objectForKey:@"array"] objectAtIndex:3], [array objectAtIndex:3], nil);
    
    [db close];
}

@end