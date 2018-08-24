//
//  main.m
//  KVCDemo7
//
//  Created by Andy Ron on 2018/8/24.
//  Copyright © 2018年 Andy Ron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject

@end
@interface Address()

@property (nonatomic,copy)NSString* country;
@property (nonatomic,copy)NSString* province;
@property (nonatomic,copy)NSString* city;
@property (nonatomic,copy)NSString* district;

@end
@implementation Address

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        Address *address = [Address new];
        address.country = @"中国";
        address.province = @"上海";
        address.city = @"上海";
        address.district = @"浦东";
        
        
        NSArray* arr = @[@"country",@"province",@"district"];
        NSDictionary* dict = [address dictionaryWithValuesForKeys:arr]; //把对应key所有的属性全部取出来
        NSLog(@"%@",dict);
        
        NSDictionary* modifyDict = @{@"country":@"美国",@"province":@"加州",@"city":@"旧金山"};
        [address setValuesForKeysWithDictionary:modifyDict];            //修改的属性
        NSLog(@"country:%@  province:%@ city:%@",address.country, address.province, address.city);
        
    }
    return 0;
}
