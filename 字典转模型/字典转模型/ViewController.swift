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
        let dic:NSDictionary = ["name":"lkk","age":22,"score":99,"number":"110","card":["ID":"411424xxxxxxxxxx6214"]]
        let stu = Student.objectWithKeyValues(dic) as! Student
        print("age = \(stu.age),name = \(stu.name),number = \(stu.number),score = \(stu.score),card = \(stu.card?.ID)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

