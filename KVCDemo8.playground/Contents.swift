//: Playground - noun: a place where people can play

import UIKit

let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
textField.placeholder = "Andy KVC的测试例子"
textField.backgroundColor = .gray

textField.setValue(UIColor.blue, forKeyPath: "_placeholderLabel.textColor")

textField.setValue(UIFont.boldSystemFont(ofSize: 30), forKeyPath: "_placeholderLabel.font")



