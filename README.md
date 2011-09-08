# FirestormBSON

An Objective-C wrapper for the [Binary JSON](http://bsonspec.org/#/specification) [MongoDB C Driver](https://github.com/mongodb/mongo-c-driver) built to behave quite a lot like [NextiveJSON](https://github.com/nextive/NextiveJson).

As of this writing, it's still very new and there are a ton of bugs and performance improvements possible. Forks/pull requests, trouble tickets, and general suggestions are welcome!

## Example

``` objc
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSNumber numberWithInt:70] forKey:@"aNumber"];
	[dict setObject:[NSNumber numberWithDouble:3.1415926532f] forKey:@"pi"];
	[dict setObject:[NSArray arrayWithObjects:@"String!", @"String?", nil] forKey:@"anArray"];
	[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Value", @"Key", nil] forKey:@"dict"];

	/*
	dict = {
	    aNumber = 70;
	    anArray =     (
	        "String!",
	        "String?"
	    );
	    dict =     {
	        Key = Value;
	    };
	    pi = "3.141592741012573";
	}
	*/
	
	NSData * data = [FSBsonSerializer serialize:dict];

	NSError * error = nil;
	id result = [FSBsonParser parseData:data error:&error];

	/*
	result = {
	    aNumber = 70;
	    anArray =     (
	        "String!",
	        "String?"
	    );
	    dict =     {
	        Key = Value;
	    };
	    pi = 3; // known bug
	}
	*/
```

## Legal

This software is licensed under the [FDOSL](http://fsdev.net/fdosl/); please see the file `COPYING.md` for more information.