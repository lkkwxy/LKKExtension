//
//  Person.swift
//  字典转模型
//
//  Created by 李坤坤 on 15/9/2.
//  Copyright © 2015年 李坤坤. All rights reserved.
//

import Foundation

class Person:NSObject {
    var name:String?
    var age:NSNumber?
    var ID:String?
    var card:Card?
    var persons:NSArray?
    override func replacedKeyFromPropertyName() ->[String:String]{
        return ["ID":"id"]
    }
    override func objectClassInArray() -> [String:String]{
        return ["persons":"Person"]
    }
    override var description: String {
        return "name = \(name),age = \(age)"
    }
}
class Student:Person{
    var number:String?
    var score:NSNumber?
    var scores:NSArray?
}
class Card:NSObject {
    var ID:String?
}