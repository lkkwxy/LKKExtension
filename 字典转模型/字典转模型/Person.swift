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
    var card:Card?
}
class Student:Person{
    var number:String?
    var score:NSNumber?
}
class Card:NSObject {
    var ID:String?
}