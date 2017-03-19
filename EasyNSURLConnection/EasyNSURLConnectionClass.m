//
//  EasyNSURLConnectionClass.m
//
//  Created by Nanoha Takamachi on 2014/11/25.
//  Copyright (c) 2014年 Atelier Shiori. Licensed under MIT License.
//
//  This class allows easy creation of synchronous request using NSURLSession
//

#import "EasyNSURLConnection.h"
#import "EasyNSURLResponse.h"

@implementation EasyNSURLConnection
@synthesize error;
@synthesize response;

#pragma Post Methods Constants
NSString * const EasyNSURLPostMethod = @"POST";
NSString * const EasyNSURLPutMethod = @"PUT";
NSString * const EasyNSURLPatchMethod = @"PATCH";
NSString * const EasyNSURLDeleteMethod = @"DELETE";

#pragma constructors
-(id)init{
    // Set Default User Agent
    useragent =[NSString stringWithFormat:@"%@ %@ (Macintosh; Mac OS X %@; %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"], [[NSLocale currentLocale] localeIdentifier]];
    return [super init];
}
-(id)initWithURL:(NSURL *)address{
    URL = address;
    return [self init];
}
#pragma getters
-(NSData *)getResponseData{
    return responsedata;
}
-(NSString *)getResponseDataString{
    NSString * datastring = [[NSString alloc] initWithData:responsedata encoding:NSUTF8StringEncoding];
    return datastring;
}
-(id)getResponseDataJsonParsed{
    return [NSJSONSerialization JSONObjectWithData:responsedata options:0 error:nil];
}
-(long)getStatusCode{
    return response.statusCode;
}
-(NSError *)getError{
    return error;
}
#pragma mutators
-(void)addHeader:(id)object
          forKey:(NSString *)key{
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    if (formdata == nil) {
        //Initalize Header Data Array
        headers = [[NSMutableArray alloc] init];
    }
    [headers addObject:[NSDictionary dictionaryWithObjectsAndKeys:object,key, nil]];
    [lock unlock]; //Finished operation, unlock
}
-(void)addFormData:(id)object
            forKey:(NSString *)key{
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    if (formdata == nil) {
        //Initalize Form Data Array
        formdata = [[NSMutableArray alloc] init];
    }
    [formdata addObject:[NSDictionary dictionaryWithObjectsAndKeys:object,key, nil]];
    [lock unlock]; //Finished operation, unlock
}
-(void)setUserAgent:(NSString *)string{
    useragent = [NSString stringWithFormat:@"%@",string];
}
-(void)setUseCookies:(BOOL)choice{
    usecookies = choice;
}
-(void)setURL:(NSURL *)address{
    URL = address;
}
-(void)setPostMethod:(NSString *)method{
    postmethod = method;
}
#pragma request functions
-(void)startRequest{
    // Send a synchronous request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    // Do not use Cookies
    [request setHTTPShouldHandleCookies:usecookies];
    // Set Timeout
    [request setTimeoutInterval:15];
    // Set User Agent
    [request setValue:useragent forHTTPHeaderField:@"User-Agent"];
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    // Set Other headers, if any
    if (headers != nil) {
        for (NSDictionary *d in headers ) {
            //Set any headers
            [request setValue:[[d allValues] objectAtIndex:0]forHTTPHeaderField:[[d allKeys] objectAtIndex:0]];
        }
    }
    [lock unlock];
    // Send Request
    EasyNSURLResponse * urlsessionresponse = [self performNSURLSessionRequest:request];
    responsedata = [urlsessionresponse getData];
    error = [urlsessionresponse getError];
    response = [urlsessionresponse getResponse];
}
-(void)startFormRequest{
    // Send a synchronous request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    // Set Method
    if (postmethod.length != 0) {
        [request setHTTPMethod:postmethod];
    }
    else
        [request setHTTPMethod:@"POST"];
    // Set content type to form data
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    // Do not use Cookies
    [request setHTTPShouldHandleCookies:usecookies];
    // Set User Agent
    [request setValue:useragent forHTTPHeaderField:@"User-Agent"];
    // Set Timeout
    [request setTimeoutInterval:15];
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    //Set Post Data
    [request setHTTPBody:[self encodeArraywithDictionaries:formdata]];
    // Set Other headers, if any
    if (headers != nil) {
        for (NSDictionary *d in headers ) {
            //Set any headers
            [request setValue:[[d allValues] objectAtIndex:0]forHTTPHeaderField:[[d allKeys] objectAtIndex:0]];
        }
    }
    [lock unlock];
    // Send Request
    EasyNSURLResponse * urlsessionresponse = [self performNSURLSessionRequest:request];
    responsedata = [urlsessionresponse getData];
    error = [urlsessionresponse getError];
    response = [urlsessionresponse getResponse];
}
-(void)startJSONRequest:(NSString *)body type:(int)bodytype{
    // Send a synchronous request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    // Set Method
    if (postmethod.length != 0) {
        [request setHTTPMethod:postmethod];
    }
    else
        [request setHTTPMethod:@"POST"];
    // Set content type to form data
    switch (bodytype){
        case 0:
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case 1:
            [request setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    // Do not use Cookies
    [request setHTTPShouldHandleCookies:usecookies];
    // Set User Agent
    [request setValue:useragent forHTTPHeaderField:@"User-Agent"];
    // Set Timeout
    [request setTimeoutInterval:5];
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    //Set Post Data
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    // Set Other headers, if any
    if (headers != nil) {
        for (NSDictionary *d in headers ) {
            //Set any headers
            [request setValue:[[d allValues] objectAtIndex:0]forHTTPHeaderField:[[d allKeys] objectAtIndex:0]];
        }
    }
    [lock unlock];
    // Send Request
    EasyNSURLResponse * urlsessionresponse = [self performNSURLSessionRequest:request];
    responsedata = [urlsessionresponse getData];
    error = [urlsessionresponse getError];
    response = [urlsessionresponse getResponse];
}
-(void)startJSONFormRequest:(int)bodytype{
    // Send a synchronous request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:URL];
    // Set Method
    if (postmethod.length != 0) {
        [request setHTTPMethod:postmethod];
    }
    else
        [request setHTTPMethod:@"POST"];
    // Set content type to form data
    switch (bodytype){
        case 0:
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            break;
        case 1:
            [request setValue:@"application/vnd.api+json" forHTTPHeaderField:@"Content-Type"];
            break;
    }
    // Do not use Cookies
    request.HTTPShouldHandleCookies = usecookies;
    // Set User Agent
    [request setValue:useragent forHTTPHeaderField:@"User-Agent"];
    // Set Timeout
    request.timeoutInterval = 5;
    NSLock * lock = [NSLock new]; // NSMutableArray is not Thread Safe, lock before performing operation
    [lock lock];
    //Set Post Data
    NSError *jerror;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self arraytodictionary:formdata] options:0 error:&jerror];
    if (!jsonData) {}
    else{
        NSString *JSONString = [[NSString alloc] initWithBytes:jsonData.bytes length:jsonData.length encoding:NSUTF8StringEncoding];
        request.HTTPBody = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    }
    // Set Other headers, if any
    if (headers != nil) {
        for (NSDictionary *d in headers ) {
            //Set any headers
            [request setValue:d.allValues[0]forHTTPHeaderField:d.allKeys[0]];
        }
    }
    [lock unlock];
    // Send Request
    EasyNSURLResponse * urlsessionresponse = [self performNSURLSessionRequest:request];
    responsedata = [urlsessionresponse getData];
    error = [urlsessionresponse getError];
    response = [urlsessionresponse getResponse];
}

#pragma helpers
- (NSData*)encodeArraywithDictionaries:(NSArray*)array {
    NSMutableArray *parts = [[NSMutableArray alloc] init];
    for (NSDictionary * d in array) {
        NSString *encodedValue = [[d objectForKey:[[d allKeys] objectAtIndex:0]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *encodedKey = [[[d allKeys] objectAtIndex:0] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject:part];
    }
    NSString *encodedDictionary = [parts componentsJoinedByString:@"&"];
    return [encodedDictionary dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSDictionary *)arraytodictionary:(NSArray *)array{
    NSMutableDictionary * doutput = [NSMutableDictionary new];
    for (NSDictionary * d in array) {
        NSString * akey = d.allKeys[0];
        NSString *acontent = d[d.allKeys[0]];
        doutput[akey] = acontent;
    }
    return doutput;
}
-(EasyNSURLResponse *)performNSURLSessionRequest:(NSURLRequest *)request
{
    // Based on http://demianturner.com/2016/08/synchronous-nsurlsession-in-obj-c/
    __block NSHTTPURLResponse *urlresponse = nil;
    __block NSData *data = nil;
    __block NSError * error2 = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *taskData, NSURLResponse *rresponse, NSError *eerror) {
        data = taskData;
        urlresponse = (NSHTTPURLResponse *)rresponse;
        error2 = eerror;
        dispatch_semaphore_signal(semaphore);
        
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return [[EasyNSURLResponse alloc] initWithData:data withResponse:urlresponse withError:error2];
}
@end
