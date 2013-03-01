#NyaruDB
###(」・ω・)」うー！(／・ω・)／にゃー！

Kelp http://kelp.phate.org/ <br/>
[MIT License][mit]
[MIT]: http://www.opensource.org/licenses/mit-license.php


NyaruDB is a simple NoSQL database in Objective-C. It could be run on iOS.  
It is a key-document NoSQL database. You could search data by a field of the document.

##Feature
* More quickly than sqlite.  
NyaruDB use <a href="https://github.com/johnezang/JSONKit">JSONKit</a> to serialize/deserialize documents.  
And use memory cache, <a href="https://developer.apple.com/technologies/mac/core.html#grand-central" target="_blank">GCD</a> and binary tree to optimize performance.
```
NoSQL with SQL:  
NyaruDB: NSDictionary <-- JSONKit --> File  
sqlite: NSDictionary <-- converter --> SQL <-- sqlite3 function --> File  
```
  　  |  NyaruDB  |  sqlite  
:---------:|:---------:|:---------:
insert 1k documents | 15,800 ms <br/> 300 ms (async) | 36,500 ms
fetch 1k documents | 50 ms | 300 ms
search in 1k documents <br/> for 10 times | 15.5 ms | 40 ms
(this test is on iPhone4)  
<br/>
NyaruDB use GCD to write/read documents, **all accesses would be processed in a same dispatch**.  
Write: process with async GCD.  
Read: process with sync GCD.  
If you written documents to database, it will be processed in a async dispatch. So your code would not wait for writing documents. CPU will process the next command.  
If you written documents to database, then rode that on the next command. Your code would wait for writing done.  


* Clean query syntax.  
```objective-c
// where type == 1 order by update
NSArray *documents = [[[collection where:@"type" equalTo:@1] orderBy:@"update"] fetch];
```




##Collection
Collection is like Table of sql database.  



##Index
When you want to search data by a field, you should create a index.  
If you want to search data by 'email', you should create a 'email' index before searching.  



##Document
Document is data in the collection.

There is a member named 'key' in the document. Key is unique and datatype is NSString.  
If the document has no 'key' when inserted, it will be automatically generated.  

+ Normal Field Datatype: `NSNull`, `NSNumber`, `NSDate`, `NSString`, `NSArray`, `NSDictionary`  
+ Index Field Datatype: `NSNull`, `NSNumber`, `NSDate`, `NSString`  



##Create Collection
```objective-c
NyaruDB *db = [NyaruDB instance];
NyaruCollection *collectioin = [db collectionForName:@"collectionName"];
```


##Create Index
```objective-c
NyaruDB *db = [NyaruDB instance];

NyaruCollection *collection = [db collectionForName:@"collectionName"];
[collection createIndex:@"email"];
[collection createIndex:@"number"];
[collection createIndex:@"date"];
```


##Insert Data
```objective-c
NyaruDB *db = [NyaruDB instance];

NyaruCollection *collection = [db collectionForName:@"collectionName"];
NSDictionary *document = @{ @"email": @"kelp@phate.org",
    @"name": @"Kelp",
    @"phone": @"0123456789",
    @"date": [NSDate date],
    @"text": @"(」・ω・)」うー！(／・ω・)／にゃー！",
    @"number": @100 };
[collection insert:document];
```


##Query    
The field of the document which is `key` or `index` supports search.  
`key` supports `equalTo`.  
`index` supports `equalTo`, `notEqualTo`, `lessThan`, `lessEqualThan`, `greaterThan`, `greaterEqualThan` and `likeTo`.  

You could use `and`(Intersection) or `union` to append query.  


```objective-c
// search the document the 'key' is equal to 'IjkhMGIT752091136'
NyaruDB *db = [NyaruDB instance];

NyaruCollection *co = [db collectionForName:@"collectionName"];
NSArray *documents = [[co where:@"key" equalTo:@"IjkhMGIT752091136"] fetch];
for (NSMutableDictionary *document in documents) {
    NSLog(@"%@", document);
}
```


```objective-c
// search documents the 'date' is greater than now, and sort by date with DESC
NyaruDB *db = [NyaruDB instance];

NyaruCollection *co = [db collectionForName:@"collectionName"];
NSDate *date = [NSDate date];
NSArray *documents = [[[co where:@"date" greaterThan:date] orderByDESC:@"date"] fetch];
for (NSMutableDictionary *document in documents) {
    NSLog(@"%@", document);
}
```


```objective-c
// search documents the 'date' is greater than now, and 'type' is equal to 2
// then sort by date with ASC
NyaruDB *db = [NyaruDB instance];

NyaruCollection *co = [db collectionForName:@"collectionName"];
NSDate *date = [NSDate date];
NSArray *documents = [[[[co where:@"date" greaterThan:date] and:@"type" equalTo:@2] orderBy:@"date"] fetch];
for (NSMutableDictionary *document in documents) {
    NSLog(@"%@", document);
}
```


```objective-c
// search documents 'type' == 1 or 'type' == 3
NyaruDB *db = [NyaruDB instance];

NyaruCollection *co = [db collectionForName:@"collectionName"];
NSArray *documents = [[[co where:@"type" equalTo:@1] union:@"type" equalTo:@3] fetch];
for (NSMutableDictionary *document in documents) {
    NSLog(@"%@", document);
}
```


```objective-c
// count documents 'type' == 1
NyaruDB *db = [NyaruDB instance];

NyaruCollection *co = [db collectionForName:@"collectionName"];
NSUInteger count = [[co where:@"type" equalTo:@1] count];
NSLog(@"%u", count);
```




##Delete Data
```objective-c
// delete data by key
NyaruDB *db = [NyaruDB instance];
// create collection
NyaruCollection *co = [db collectionForName:@"collectionName"];
[co createIndex:@"number"];
[co insert:@{@"number" : @100}];
[co insert:@{@"number" : @200}];
[co insert:@{@"number" : @10}];

// remove by query
[[co where:@"number" equalTo:@10] remove];
// remove all
[[co all] remove];
```


**NyaruDB interface**
```Objective-C
+ (id)instance;
+ (void)reset;

- (NSArray *)collections;
- (NyaruCollection *)collectionForName:(NSString *)name;

- (void)removeCollection:(NSString *)name;
- (void)removeAllCollections;
```


**NyaruCollection interface**
```Objective-C
#pragma mark - Index
- (NSArray *)allIndexes;
- (void)createIndex:(NSString *)indexName;
- (void)removeIndex:(NSString *)indexName;
- (void)removeAllindexes;

#pragma mark - Document
// insert document
- (NSMutableDictionary *)insert:(NSDictionary *)document;
// remove all documents (directly remove files)
- (void)removeAll;
// waiting for data writing
- (void)waiteForWriting;

#pragma mark - Query
- (NyaruQuery *)all;
- (NyaruQuery *)where:(NSString *)indexName equalTo:(id)value;
- (NyaruQuery *)where:(NSString *)indexName notEqualTo:(id)value;
- (NyaruQuery *)where:(NSString *)indexName lessThan:(id)value;
- (NyaruQuery *)where:(NSString *)indexName lessEqualThan:(id)value;
- (NyaruQuery *)where:(NSString *)indexName greaterThan:(id)value;
- (NyaruQuery *)where:(NSString *)indexName greaterEqualThan:(id)value;
- (NyaruQuery *)where:(NSString *)indexName likeTo:(NSString *)value;

#pragma mark - Count
- (NSUInteger)count;
```


**NyaruQuery interface**
```Objective-C
#pragma mark - Intersection
- (NyaruQuery *)and:(NSString *)indexName equalTo:(id)value;
- (NyaruQuery *)and:(NSString *)indexName notEqualTo:(id)value;
- (NyaruQuery *)and:(NSString *)indexName lessThan:(id)value;
- (NyaruQuery *)and:(NSString *)indexName lessEqualThan:(id)value;
- (NyaruQuery *)and:(NSString *)indexName greaterThan:(id)value;
- (NyaruQuery *)and:(NSString *)indexName greaterEqualThan:(id)value;
- (NyaruQuery *)and:(NSString *)indexName likeTo:(NSString *)value;

#pragma mark - Union
- (NyaruQuery *)union:(NSString *)indexName equalTo:(id)value;
- (NyaruQuery *)union:(NSString *)indexName notEqualTo:(id)value;
- (NyaruQuery *)union:(NSString *)indexName lessThan:(id)value;
- (NyaruQuery *)union:(NSString *)indexName lessEqualThan:(id)value;
- (NyaruQuery *)union:(NSString *)indexName greaterThan:(id)value;
- (NyaruQuery *)union:(NSString *)indexName greaterEqualThan:(id)value;
- (NyaruQuery *)union:(NSString *)indexName likeTo:(NSString *)value;

#pragma mark - Order By
- (NyaruQuery *)orderBy:(NSString *)indexName;
- (NyaruQuery *)orderByDESC:(NSString *)indexName;

#pragma mark - Count
- (NSUInteger)count;

#pragma mark - Fetch
- (NSArray *)fetch;
- (NSArray *)fetch:(NSUInteger)limit;
- (NSArray *)fetch:(NSUInteger)limit skip:(NSUInteger)skip;

#pragma mark - Remove
- (void)remove;
```



##Attention
+ limit length of field name is 255
+ limit of documents is 4,294,967,295
+ limit of document file size is 4G
+ key is unique and it is NSString
+ key only provides `equalTo` search
+ key is case sensitive
+ index is case insensitive
+ a field of the document should be same data type which is index
+ sort query allow only one
