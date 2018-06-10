//
//  main.m
//  KVCDemo5
//
//  Created by andyron<http://andyron.com> on 2018/6/10.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@end
@interface Address()
@property (nonatomic,copy)NSString* country;
@end
@implementation Address

-(BOOL)validateCountry:(id *)value error:(out NSError * _Nullable __autoreleasing *)outError{  //在implementation里面加这个方法，它会验证是否设了非法的value
    NSString* country = *value;
    country = country.capitalizedString;
    if ([country isEqualToString:@"Japan"]) {
        return NO;                                                                             //如果国家是日本，就返回NO，这里省略了错误提示，
    }
    return YES;
}


@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Address * add = [Address new];
        add.country = @"China";
        
        NSError* error;
        id value = @"japan";
        NSString* key = @"country";
        BOOL result = [add validateValue:&value forKey:key error:&error]; //如果没有重写-(BOOL)-validate<Key>:error:，默认返回Yes
        if (result) {
            NSLog(@"键值匹配");
            [add setValue:value forKey:key];
        }
        else{
            NSLog(@"键值不匹配"); //不能设为日本，基他国家都行
        }
        NSString* country = [add valueForKey:@"country"];
        NSLog(@"country:%@",country);
        
    }
    return 0;
}
