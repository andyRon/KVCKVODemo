//: Playground - noun: a place where people can play

import UIKit

var count: UInt32 = 0
let ivars = class_copyIvarList(UITextField.self, &count)

for i in 0 ..< count {
    let ivar = ivars![Int(i)]
    let name = ivar_getName(ivar)
    print(String(cString: name!))
}
free(ivars)

