//
//  main.m
//  KVCDemo4
//
//  Created by andyron<http://andyron.com> on 2018/6/10.
//  Copyright © 2018年 andyron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwoTimesArray : NSObject

-(void)incrementCount;
-(NSUInteger)countOfNumbers;
-(id)objectInNumbersAtIndex:(NSUInteger)index;

@end


@interface TwoTimesArray()

@property (nonatomic,readwrite,assign) NSUInteger count;
@property (nonatomic,copy) NSString* arrName;

@end

@implementation TwoTimesArray
-(void)incrementCount{
    self.count ++;
}
-(NSUInteger)countOfNumbers{
    return self.count;
}
-(id)objectInNumbersAtIndex:(NSUInteger)index{     //当key使用numbers时，KVC会找到这两个方法。
    return @(index * 2);
}
-(NSInteger)getNum{                 //第一个,自己一个一个注释试
    return 10;
}
-(NSInteger)num{                       //第二个
    return 11;
}
-(NSInteger)isNum{                    //第三个
    return 12;
}
@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        TwoTimesArray* arr = [TwoTimesArray new];
        NSNumber* num =   [arr valueForKey:@"num"];
        NSLog(@"%@",num);
        
        id ar = [arr valueForKey:@"numbers"];
        NSLog(@"%@",NSStringFromClass([ar class]));
        NSLog(@"0:%@     1:%@     2:%@     3:%@",ar[0],ar[1],ar[2],ar[3]);
        
        [arr incrementCount];                                                                            //count加1
        NSLog(@"%lu",(unsigned long)[ar count]);                                                         //打印出1
        [arr incrementCount];                                                                            //count再加1
        NSLog(@"%lu",(unsigned long)[ar count]);                                                         //打印出2
        
        [arr setValue:@"newName" forKey:@"arrName"];
        NSString* name = [arr valueForKey:@"arrName"];
        NSLog(@"%@",name);
        
    }
    return 0;
}
    
