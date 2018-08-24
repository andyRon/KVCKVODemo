
## OC中的键/值编码(KVC)


### 1. KVC 的定义
**键/值编码(Key-value coding，KVC)** 可以允许开发者通过Key名访问对象的属性或给对象的属性赋值, 而不需要调用明确的存取方法，并有一组api供开发者使用，像操作字典一样操作对象属性/成员变量/关联对象。  
这样就可以在 *运行时动态地访问和修改* 对象的属性。而不是在编译时确定。这种机制不属于Objective-C语言的特性，而是Cocoa提供的一种特性。


通过定义一个`NSObject`的类别`NSKeyValueCoding `来实现KVC功能。因此所有继承了`NSObject`的类都支持KVC。
`NSKeyValueCoding `的四个重要方法：
```
- (nullable id)valueForKey:(NSString *)key;                          //直接通过Key来取值
- (void)setValue:(nullable id)value forKey:(NSString *)key;          //通过Key来设值
- (nullable id)valueForKeyPath:(NSString *)keyPath;                  //通过KeyPath来取值
- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath;  //通过KeyPath来设值
```

`NSKeyValueCoding`还有其它许多方法，我列举一些，详细可查看官方文档 [**NSKeyValueCoding**](https://developer.apple.com/documentation/foundation/object_runtime/nskeyvaluecoding?language=objc)：
```
+ (BOOL)accessInstanceVariablesDirectly;
//默认返回YES，表示如果没有找到set<Key>方法的话，会按照_<key>，_isKey，key，isKey的顺序搜索成员，设置成NO就不这样搜索

- (BOOL)validateValue:(inout id __nullable * __nonnull)ioValue forKey:(NSString *)inKey error:(out NSError **)outError;
//KVC提供属性值正确性验证的API，它可以用来检查set的值是否正确、为不正确的值做一个替换值或者拒绝设置新值并返回错误原因。

- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;
//这是集合操作的API，里面还有一系列这样的API，如果属性是一个NSMutableArray，那么可以用这个方法来返回。

- (nullable id)valueForUndefinedKey:(NSString *)key;
//在取值时，如果Key不存在，且KVC无法搜索到任何和Key有关的字段或者属性(或者+ (BOOL)accessInstanceVariablesDirectly;方法返回NO时)，则会调用这个方法，默认是抛出 NSUndefinedKeyException异常。

- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;
//和上一个方法相对应，这个方法是用来设值。

- (void)setNilValueForKey:(NSString *)key;
//如果你在SetValue方法时面给Value传nil，则会调用这个方法

- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
//输入一组key,返回该组key对应的Value，再转成字典返回，用于将Model转到字典。
```

### 2 KVC是如何寻找Key

#### 2.1 设置值

当调用`setValue:forKey:`方法来设置属性值时，执行机制如下：  

1. 先调用**setter**方法`set<Key>：属性值`
2. 如果没有找到**setter**方法，KVC就会检测`+ (BOOL)accessInstanceVariablesDirectly`的返回值，是默认值`YES`,就按照`_<key>`，`_isKey`，`key`，`isKey`的顺序一一查找。只要存在`_<key>`，无论该变量是在类接口处定义，还是在类实现处定义，也不管是什么访问修饰符，KVC都可以对其访问。
3. 如果没有**setter**方法，也没找到`_<key>`，`_isKey`，`key`，`isKey`中的任何一个，KVC就会执行方法`- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;`，默认是抛出异常。


代码示例（[**andyRon/KVCDemo1**](https://github.com/andyRon/KVCKVODemo)）：
```
@interface Dog : NSObject
@end
@implementation Dog
{
    NSString* toSetName;
    NSString* isName;
    NSString* name;
    NSString* _name;
    NSString* _isName;
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
        // insert code here...
        Dog* dog = [Dog new];
        [dog setValue:@"newNameValue" forKey:@"name"];
        NSString* toSetName = [dog valueForKey:@"toSetName"];
        NSLog(@"%@",toSetName);
        
    }
    return 0;
}
```

打印结果：
```
KVCDemo1[5107:12399654] 设置值出现异常，key为：name的变量不存在
KVCDemo1[5107:12399654] 取值出现异常，key为：toSetName的变量不存在
KVCDemo1[5107:12399654] (null)
```

 重写`+(BOOL)accessInstanceVariablesDirectly`方法让其返回NO后,KVC机制就不会实现，就直接调用`- (nullable id)valueForUndefinedKey:(NSString *)key;`或`- (void)setValue:(nullable id)value forUndefinedKey:(NSString *)key;`

稍微修改以下代码，看示例（[**andyRon/KVCDemo2**](https://github.com/andyRon/KVCKVODemo)）：
```
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
```
打印结果：
```
KVCDemo2[5323:12426199] newNameValue
```
虽然`+(BOOL)accessInstanceVariablesDirectly`方法结果还是NO，但因为有了setter和getter方法就不会出现异常了。
当`+(BOOL)accessInstanceVariablesDirectly`结果为YES，的🌰代码我就不列出了，可查看[**andyRon/KVCDemo3**](https://github.com/andyRon/KVCKVODemo)。

#### 2.2 KVC取值
对于取值方法`valueForKey:`, KVC对`key`的查询方式不同于`setValue:forKey:`,如下：

- 首先按`get<Key>`,`<key>`,`is<Key>`的顺序方法查找**getter**方法，找到的话会直接调用。如果是`BOOL`或者`Int`等值类型， 会将其包装成一个`NSNumber`对象。

- 如果**getter**没有找到，KVC则会查找`countOf<Key>`,`objectIn<Key>AtIndex`或`<Key>AtIndexes`格式的方法。如果有一个被找到，那么就会返回一个可以响应NSArray所有方法的代理集合(它是`NSKeyValueArray`，是`NSArray`的子类)，调用这个代理集合的方法，或者说给这个代理集合发送属于`NSArray`的方法，就会以`countOf<Key>`,`objectIn<Key>AtIndex`或`<Key>AtIndexes`这几个方法组合的形式调用。还有一个可选的`get<Key>:range:`方法。所以你想重新定义KVC的一些功能，你可以添加这些方法，需要注意的是你的方法名要符合KVC的标准命名方法，包括方法签名。

- 如果上面的方法没有找到，那么会同时查找`countOf<Key>`，`enumeratorOf<Key>`,`memberOf<Key>`格式的方法。如果这三个方法都找到，那么就返回一个可以响应NSSet所的方法的代理集合，和上面一样，给这个代理集合发NSSet的消息，就会以`countOf<Key>`，`enumeratorOf<Key>`,`memberOf<Key>`组合的形式调用。

> 在类自定义了KVC的实现，并且实现了上面的方法，就可以将返回的对象当数组(NSArray)用了

- 如果还没有找到，再检查类方法`+ (BOOL)accessInstanceVariablesDirectly`,如果返回YES(默认行为)，那么和先前的设值一样，会按_<key>,_is<Key>,<key>,is<Key>的顺序搜索成员变量名，这里不推荐这么做，因为这样直接访问实例变量破坏了封装性，使代码更脆弱。如果重写了类方法+ (BOOL)accessInstanceVariablesDirectly返回NO的话，那么会直接调用`valueForUndefinedKey:`

示例代码（[**andyRon/KVCDemo4**](https://github.com/andyRon/KVCKVODemo)）：
```
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
```

结果：
```
KVCDemo4[25723:3947658] 10
KVCDemo4[25723:3947658] NSKeyValueArray
KVCDemo4[25723:3947658] 0:0     1:2     2:4     3:6
KVCDemo4[25723:3947658] 1
KVCDemo4[25723:3947658] 2
KVCDemo4[25723:3947658] newName
```


### 3 KVC中使用keyPath

一个类的属性可能是另外一个类，可以通过keyPath方式获取或设置这种**多层**中属性，这种解决方式也是通过`NSKeyValueCoding`中的方法来实现的。
```
//通过KeyPath来取值
- (nullable id)valueForKeyPath:(NSString *)keyPath;                  
 //通过KeyPath来设值
- (void)setValue:(nullable id)value forKeyPath:(NSString *)keyPath; 
```
来看看具体代码例子（[KVCKeyPathDemo](https://github.com/andyRon/KVCKVODemo)）：
```
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
```
打印结果：
```
KVCKeyPathDemo[6330:12568821] country1:China   country2:China
KVCKeyPathDemo[6330:12568821] country1:USA   country2:USA   city:city
```
keyPath中，key之间用`.`分隔，当keyPath出现错误时，就会调用`valueForUndefinedKey:key`方法。

### 4 KVC的异常处理

两种情况，一种是`key`或`keyPath`错误，上面也都提到过，就是调用`valueForUndefinedKey:key`方法。

另一种情况是在使用`setValue:forKey:`方法时值设置为`nil`了，这是不被允许的，会调用`setNilValueForKey:`方法。
```
@implementation People

-(void)setNilValueForKey:(NSString *)key{
    NSLog(@"不能将%@设成nil",key);
}

@end
```

```
[people setValue:nil forKey:@"age"];
```

### 5 KVC处理非对象和自定义对象

`valueForKey:`总是返回一个id对象，如果原本的变量类型是值类型或者结构体，返回值会封装成`NSNumber`或者`NSValue`对象。这两个类会处理从数字，布尔值到指针和结构体任何类型。然后开以者需要手动转换成原来的类型。尽管valueForKey：会自动将值类型封装成对象，但是`setValue:forKey:`却不行。你必须手动将值类型转换成NSNumber或者NSValue类型，才能传递过去。

对于自定义对象，KVC也会正确地设值和取值。因为传递进去和取出来的都是id类型，所以需要开发者自己担保类型的正确性，运行时Objective-C在发送消息的会检查类型，如果错误会直接抛出异常。


### 6 KVC和容器类

对象的属性可以是一对一的，也可以是一对多的。一对多的属性要么是有序的(数组)，要么是无序的(集合)。

不可变的有序容器属性(NSArray)和无序容器属性(NSSet)一般可以使用`valueForKey:`来获取。但也可以利用更灵活的方法来管理，比如：
`- (NSMutableArray *)mutableArrayValueForKey:(NSString *)key;`
实例代码（[**KVCDemo6**](https://github.com/andyRon/KVCKVODemo)）:
```
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
```
结果：
```
KVCDemo6[11393:3534594] (
    addItem,
    addItemObserver
)
KVCDemo6[11393:3534594] (
    addItem
)

```
当只是普通地调用`[_arr addObject:@"addItem"];`时，Observer并不会回调，只有`[[self mutableArrayValueForKey:@"arr"] addObject:@"addItemObserver"];`这样写时才能正确地触发KVO。

对于无序容器属性(NSSet)有对应的方法：
`- (NSMutableSet *)mutableSetValueForKey:(NSString *)key;`

另外还有对应的`keyPath`方法：
```
- (NSMutableArray *)mutableArrayValueForKeyPath:(NSString *)keyPath;
- (NSMutableSet *)mutableSetValueForKeyPath:(NSString *)keyPath;
```

### 7 KVC和字典 
KVC与字典相关的方法：
```
- (NSDictionary<NSString *, id> *)dictionaryWithValuesForKeys:(NSArray<NSString *> *)keys;
- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *, id> *)keyedValues;
```
示例代码（[KVCDemo7](https://github.com/andyRon/KVCKVODemo)）：
```
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
```
结果：
```
KVCDemo7[14135:3606256] {
    country = "\U4e2d\U56fd";
    district = "\U6d66\U4e1c";
    province = "\U4e0a\U6d77";
}
KVCDemo7[14135:3606256] country:美国  province:加州 city:旧金山
Program ended with exit code: 0
```

### 8 KVC的应用场景

- 动态取值和设值

- 用KVC来访问和修改私有变量

- Model和字典转换

- 修改一些控件的内部属性
有的时候可以通过KVC修改一些苹果官方没有公开的属性，比如`UITextField`中的`placeHolderText`。这个时候用**playground**能很方便的演示（[**KVCDemo8**](https://github.com/andyRon/KVCKVODemo)）：
![修改`placeHolderText`](https://upload-images.jianshu.io/upload_images/1678135-0c31060c1d609437.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没有公开的属性可通过[runtime](http://andyron.com/2018/ios-runtime-begin)的方式获取([**KVCDemo9**](https://github.com/andyRon/KVCKVODemo)):
```
import UIKit

var count: UInt32 = 0
let ivars = class_copyIvarList(UITextField.self, &count)
for i in 0 ..< count {
    let ivar = ivars![Int(i)]
    let name = ivar_getName(ivar)
    print(String(cString: name!))
}
free(ivars)
```
- 操作集合

- 用KVC实现高阶消息传递

- 用KVC中的函数操作集合


### 最后
参照前辈的文章 [**iOS开发技巧系列---详解KVC(我告诉你KVC的一切)**](http://www.jianshu.com/p/45cbd324ea65)
学习KVC，动手写了各种简单的示例加深理解，由于目前KVC实际项目中运用的还不是很多，有很多地方理解的还不够透彻。



> 示例代码： [**andyRon/KVCDemo**](https://github.com/andyRon/KVCKVODemo)




> 参考：
[iOS开发技巧系列---详解KVC(我告诉你KVC的一切)](http://www.jianshu.com/p/45cbd324ea65)
[Key-Value Coding Programming Guide - Apple Developer](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/KeyValueCoding/index.html)
