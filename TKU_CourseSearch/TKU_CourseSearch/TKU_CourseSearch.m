//
//  TKU_CourseSearch.m
//  TKU_CourseSearch
//
//  Created by Peterlee on 3/29/14.
//  Copyright (c) 2014 Peterlee. All rights reserved.
//

#import "TKU_CourseSearch.h"
#import "TKU_CourseModel.h"
#import "HTMLParser.h"

@implementation TKU_CourseSearch
{
    NSMutableDictionary *tempDict;
    NSMutableArray *tempArray;
    NSMutableArray *courseArray;
    NSString *funcPar;
    NSString *courseString;
    NSHTTPCookie *cookie;
}

+(instancetype) shareInstance
{
    static TKU_CourseSearch *_shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[TKU_CourseSearch alloc] init];
    });
    return _shareInstance;
}

-(void) searchCourse:(NSString *) stuid WithPassword:(NSString *) password block:(SearchCourseCompleteHandler) completeblock
{
    tempDict=[[NSMutableDictionary alloc] init];
    tempArray=[[NSMutableArray alloc] init];
    courseArray=[[NSMutableArray alloc] init];
    
    NSMutableURLRequest *firstrequest=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://esquery.tku.edu.tw/acad/cookie_loadmis.asp"]];
    [firstrequest setHTTPMethod:@"GET"];
    [NSURLConnection sendAsynchronousRequest:firstrequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
        
        
        
        HTMLParser *parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:data encoding:big5] error:nil];
        
        HTMLNode *bodyNode = [parser body];
        
        
        NSArray *spanNodes = [bodyNode findChildTags:@"input"];
        [spanNodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            HTMLNode *spanNode=obj;
            if ([[spanNode getAttributeNamed:@"type"] isEqualToString:@"hidden"]) {
                funcPar=[spanNode rawContents];
                
                
                NSRange replaceRange1 = [funcPar rangeOfString:@"<input type=\"hidden\" name=\"func\" value=\""];
                if (replaceRange1.location != NSNotFound){
                    funcPar = [funcPar stringByReplacingCharactersInRange:replaceRange1 withString:@""];
                }
                
                
                NSRange replaceRange2 = [funcPar rangeOfString:@"\">"];
                if (replaceRange2.location != NSNotFound){
                    funcPar = [funcPar stringByReplacingCharactersInRange:replaceRange2 withString:@""];
                }
//                NSLog(@"%@",funcString);
                
                NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://esquery.tku.edu.tw/acad/cookie_loadmis.asp"]];
                [request setHTTPMethod:@"POST"];
    
                NSString *postString =[NSString stringWithFormat:@"s_id=%@&passwd=%@&func=%@",stuid,password,funcPar];
                [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    
                        // NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
                        //NSLog(@"%@",[[NSString alloc] initWithData:data encoding:big5]);
                    
                    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                    cookie =[cookieJar cookies][0];
                    
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    
                    
                    NSMutableURLRequest *getrequest=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://esquery.tku.edu.tw/acad/query_print.asp"]];
                    [getrequest setHTTPMethod:@"GET"];
                    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:
                                              [cookieJar cookies]];
                    [getrequest setAllHTTPHeaderFields:headers];
                    
                        //    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
                    [NSURLConnection sendAsynchronousRequest:getrequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                            //            NSLog(@"%@",response);
                        NSStringEncoding big5 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5_HKSCS_1999);
                        courseString=[[NSString alloc] initWithData:data encoding:big5];
                  
                        NSError *error;
                        HTMLParser *parser = [[HTMLParser alloc] initWithString:courseString error:&error];
                        
                        if (error) {
                            NSLog(@"Error: %@", error);
                            return;
                        }
                        
                        
                        
                        HTMLNode *bodyNode = [parser body];
                        
                        
                        NSArray *spanNodes = [bodyNode findChildTags:@"font"];
                        [spanNodes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            if(idx<10)
                                return ;
                            
                            HTMLNode *spanNode=obj;
                            if ([[spanNode getAttributeNamed:@"color"] isEqualToString:@"blue"]) {
                                
                                
                                NSString *res=[[spanNode rawContents] substringFromIndex:19];
                                NSRange range1 = [res rangeOfString:@"DD0080" options:NSCaseInsensitiveSearch];
                                if (range1.location != NSNotFound ) {
                                    return;
                                }
                                NSRange range2 = [res rangeOfString:@"<font color=" options:NSCaseInsensitiveSearch];
                                if (range2.location != NSNotFound ) {
                                    return;
                                }
                                if([res integerValue]>1)
                                    return;
                                
                                
                                NSRange replaceRange1 = [res rangeOfString:@"</font>"];
                                if (replaceRange1.location != NSNotFound){
                                    res = [res stringByReplacingCharactersInRange:replaceRange1 withString:@""];
                                }
                                
                                NSRange replaceRange3 = [res rangeOfString:@"<p align=\"left\">"];
                                if (replaceRange3.location != NSNotFound){
                                    res = [res stringByReplacingCharactersInRange:replaceRange3 withString:@""];
                                }
                                
                                NSRange replaceRange2 = [res rangeOfString:@"　"];
                                if (replaceRange2.location != NSNotFound){
                                    res = [res stringByReplacingCharactersInRange:replaceRange2 withString:@""];
                                }
                                
                                
                                res = [res stringByReplacingOccurrencesOfString:@" " withString:@""];
                                
                                if([res isEqualToString:@"</p>"])
                                    return;
                                
                                if(![res isEqualToString:@"◎"])
                                    {
                                    
                                    [tempArray addObject:res];
                                    
                                    }
                            }
                            
                            
                        }];
                        
                        __block NSUInteger numberOfClass=0;
                        NSString *lastString=[tempArray lastObject];
                        NSRange range1 = [lastString rangeOfString:@"共 0 筆資料" options:NSCaseInsensitiveSearch];
                        if (range1.location != NSNotFound ) {
                            if(completeblock)
                            {
                                NSError *error= [[NSError alloc] init];
                                completeblock(nil,error);
                            }
                        }
                        
                        
                        [tempArray removeLastObject];
                        [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSString *name=obj;
                            
                            NSRange replaceRange2 = [name rangeOfString:@"</p>"];
                            if (replaceRange2.location == NSNotFound){
                                numberOfClass++;
                                
                                if(idx==0)
                                {
                                    tempDict[@"name"]=name;
                                }
                                else
                                {
                                    [courseArray addObject:tempDict];
                                    tempDict=[[NSMutableDictionary alloc] init];
                                    tempDict[@"name"]=name;
                                }
                            }
                            else
                            {
                                
                                    NSRange replaceRange2 = [name rangeOfString:@"</p>"];
                                    if (replaceRange2.location != NSNotFound){
                                        name = [name stringByReplacingCharactersInRange:replaceRange2 withString:@""];
                                    }
                                
                                
                                
                                NSArray *subArr = [name componentsSeparatedByCharactersInSet:
                                                   [NSCharacterSet characterSetWithCharactersInString:@"/"]];
                                
                                
                                if(tempDict[@"day1"])
                                {
                                    tempDict[@"day2"]=subArr[0];
                                    tempDict[@"time2"]=subArr[1];
                                    tempDict[@"room2"]=subArr[2];
                                    tempDict[@"twotime"]=@"YES";
                                }
                                else
                                {
                                    tempDict[@"day1"]=subArr[0];
                                    tempDict[@"time1"]=subArr[1];
                                    tempDict[@"room1"]=subArr[2];
                                }
                                
                                if(idx==tempArray.count-1)
                                    [courseArray addObject:tempDict];
                            }
                            
                        }];
                        
                        tempArray = courseArray;
                        courseArray = [[NSMutableArray alloc] init];
                        [tempArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSDictionary *dict=(NSDictionary *)obj;
                            if(dict[@"twotime"])
                            {
                                TKU_CourseModel *model = [[TKU_CourseModel alloc] init];
                                model.hasTwoTime = YES;
                                model.courseName = dict[@"name"];
                                model.day1 = dict[@"day1"];
                                model.time1 = dict[@"time1"];
                                model.room1 = dict[@"room1"];
                                model.day2 = dict[@"day2"];
                                model.time2 = dict[@"time2"];
                                model.room2 = dict[@"room2"];
                                [courseArray addObject:model];
                            }
                            else
                            {
                                TKU_CourseModel *model = [[TKU_CourseModel alloc] init];
                                model.hasTwoTime = NO;
                                model.courseName = dict[@"name"];
                                model.day1 = dict[@"day1"];
                                model.time1 = dict[@"time1"];
                                model.room1 = dict[@"room1"];
                                [courseArray addObject:model];
                                
                            }
                            
                        }];
                            if(completeblock)
                                completeblock(courseArray,nil);
                    }];
                    
                }];
                
                
                
                
            }
        }];
        
    }];
    
}


@end
