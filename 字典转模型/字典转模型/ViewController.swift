//
//  ViewController.swift
//  字典转模型
//
//  Created by 李坤坤 on 15/9/2.
//  Copyright © 2015年 李坤坤. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //测试代码，结构如下
        /**
         * Student继承自Person
         * perosn有以下属性
         * var name:String?  名字 字典里的key是name
         * var age:NSNumber? 年龄  。。。。。。age
         * var ID:String?    ID   。。。。key是id
         * var card:Card?    card 类型是Card自定义类型
         * var persons:Person? 数组 key是persons 里面装的类型是Person
         * Student有以下属性
         * var number:String? 学号 key是number
         * var score:NSNumber? 成绩 key是score
         * var scores:NSArray? 所有成绩 数组里面装的是字符串 key是scores

         */
        let dic:NSDictionary =
            ["name":"lkk",
             "age":22,
             "score":99,
             "number":"110",
             //对应的是字典
             "card":["ID":"411424xxxxxxxxxx6214"],
             "id":"123",
             //对应的是字典数组
             "persons":[["name":"lkkwww","age":22]],
             //对应的是数组
             "scores":[88,99,100]]
        let stu = Student.objectWithKeyValues(dic) as! Student
        print("age = \(stu.age),name = \(stu.name),number = \(stu.number),score = \(stu.score),card = \(stu.card?.ID),id = \(stu.ID),scores = \(stu.scores?.firstObject),persons = \(stu.persons?.firstObject)")
    }
}

