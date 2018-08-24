//
//  main.m
//  KVCKeyPathDemo
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

- (id)valueForUndefinedKey:(NSString *)key {
    return key;
}

@end

@interface People : NSObject
@end
@interface People()
@property (nonatomic,copy) NSString* name;
@property (nonatomic,strong) Address* address;
@property (nonatomic,assign) NSInteger age;
@end
@implementation People



@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        People* people1 = [People new];
        Address* add = [Address new];
        add.country = @"China";
        people1.address = add;
        NSString* country1 = people1.address.country;
        NSString * country2 = [people1 valueForKeyPath:@"address.country"];
        NSLog(@"country1:%@   country2:%@",country1,country2);
        
        [people1 setValue:@"USA" forKeyPath:@"address.country"];
        country1 = people1.address.country;
        country2 = [people1 valueForKeyPath:@"address.country"];
        NSString* city = [people1 valueForKeyPath:@"address.city"];
        NSLog(@"country1:%@   country2:%@  city:%@",country1, country2, city);
    }
    return 0;
}

