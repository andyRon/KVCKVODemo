//
//  main.m
//  KVCDemo2
//
//  Created by andyron<http://andyron.com> on 2018/6/10.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dog : NSObject
@end
@implementation Dog
{
    NSString* toSetName;
    NSString* isName;
    NSString* _name;
    NSString* _isName;
}
 -(void)setName:(NSString*)name{
     toSetName = name;
 }
-(NSString*)getName{
    return toSetName;
}
+(BOOL)accessInstanceVariablesDirectly{
    return NO;
}
-(id)valueForUndefinedKey:(NSString *)key{
    NSLog(@"取值出现异常，key为：%@的变量不存在",key);
    return nil;
}
-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"设置值出现异常，key为：%@的变量不存在",key);
}
@end
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Dog* dog = [Dog new];
        [dog setValue:@"newNameValue" forKey:@"name"];
        NSString* name = [dog valueForKey:@"name"];
        NSLog(@"%@",name);
        
    }
    return 0;
}
