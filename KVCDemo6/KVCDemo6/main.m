//
//  main.m
//  KVCDemo6
//
//  Created by Andy Ron on 2018/8/24.
//  Copyright © 2018年 Andy Ron. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Demo : NSObject
@property (nonatomic,strong) NSMutableArray* arr;
@end

@implementation Demo
-(id)init{
    if (self == [super init]){
        _arr = [NSMutableArray new];
        [self addObserver:self forKeyPath:@"arr" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}
// Informs the observing object when the value at the specified key path relative to the observed object has changed.
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    NSLog(@"%@", self.arr);
}

-(void)dealloc{
    [self removeObserver:self forKeyPath:@"arr"]; //一定要在dealloc里面移除观察
}
-(void)addItem{
    [_arr addObject:@"addItem"];
}
-(void)addItemObserver{
    [[self mutableArrayValueForKey:@"arr"] addObject:@"addItemObserver"];
}
-(void)removeItemObserver{
    [[self mutableArrayValueForKey:@"arr"] removeLastObject];
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Demo* d = [Demo new];
        [d addItem];
        [d addItemObserver];
        [d removeItemObserver];
    }
    return 0;
}
