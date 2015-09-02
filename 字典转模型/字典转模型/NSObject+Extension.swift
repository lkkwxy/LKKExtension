//
//  NSObject+Extension.swift
//  字典转模型
//
//  Created by 李坤坤 on 15/9/2.
//  Copyright © 2015年 李坤坤. All rights reserved.
//

import Foundation
extension NSObject{
    class func objectWithKeyValues(keyValues:NSDictionary) -> AnyObject{
        let model = self.init()
        //获取所有的属性
        let properties = self.allProperties()
        if let _ = properties{
            for property in properties!{
                if property.propertyType.isFromFoundtion {
                    if let value = keyValues[property.propertyNmae]{
                        //为model类赋值
                        model.setValue(value, forKey: property.propertyNmae as String)
                    }
                }else{
                    if let value = keyValues[property.propertyNmae]{
                        if value is NSDictionary{
                            let subClass = property.propertyType.typeClass?.objectWithKeyValues(value as! NSDictionary)
                            //为model类赋值
                            model.setValue(subClass, forKey: property.propertyNmae as String)
                        }
                    }
                }
            }
        }
        return model
    }
    class func allProperties() -> [LKKProperty]?{
        let className = NSString(CString: class_getName(self), encoding: NSUTF8StringEncoding)
            if let _ = NSString(CString: class_getName(self), encoding: NSUTF8StringEncoding){
                //不用为NSObject的属性赋值
                if className!.isEqualToString("NSObject"){
                    return nil
                }
            }else{
                return nil
            }
            var outCount:UInt32 = 0
            //所有属性LKKProperty里面放着存放这个属性
            var propertiesArray = [LKKProperty]()
            let properties = class_copyPropertyList(self.classForCoder(),&outCount)
            //获取父类的所有属性
            let superM = self.superclass()?.allProperties()
            if let _ = superM{
                propertiesArray += superM!
            }
            for var i = 0;i < Int(outCount);i++ {
                let property = LKKProperty(property: properties[i])
                propertiesArray.append(property)
            }
            return propertiesArray
        }
}
class LKKProperty{
    var propertyNmae:NSString!
    var property:objc_property_t
    var propertyType:LKKType!
    init(property:objc_property_t){
        self.property = property
        self.propertyNmae = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)
        //自定义的类的Types格式为T@"_TtC15字典转模型4Card",N,&,Vcard
        //T+@+"+..+工程的名字+数字+类名+"+,+其他,而我们想要的只是类名，所以要修改这个字符串
        var code: NSString = NSString(CString: property_getAttributes(property), encoding: NSUTF8StringEncoding)!
        print(code)
        print(propertyNmae)
        //直接取出""中间的内容
        code = code.componentsSeparatedByString("\"")[1]
        let bundlePath = getBundleName()
        let range = code.rangeOfString(bundlePath)
        if range.length > 0{
            //去掉工程名字之前的内容
            code = code.substringFromIndex(range.length + range.location)
        }
        //在去掉剩下的数字
        var number:String = ""
        for char in (code as String).characters{
            if char <= "9" && char >= "0"{
                number += String(char)
            }else{
                break
            }
        }
        let numberRange = code.rangeOfString(number)
        if numberRange.length > 0{
            //得到类名
            code = code.substringFromIndex(numberRange.length + numberRange.location)
        }

        self.propertyType = LKKType(code: code)
    }
}
class LKKType {
    var code:NSString
    var typeClass:AnyClass?
    var isFromFoundtion:Bool = true
    init(code:NSString){
        self.code = code
        //判断是否属于Foundtation框架
        if self.code.hasPrefix("NS"){
            self.typeClass = NSClassFromString(self.code as String)
            self.isFromFoundtion = true
        }else{
            //如果是自定义的类NSClassFromString这个方法传得字符串是工程的名字+类名
            self.typeClass = getClassWitnClassNmae(self.code as String)
            self.isFromFoundtion = false
        }
    }
}
//获取工程的名字
func getBundleName() -> String{
    var bundlePath = NSBundle.mainBundle().bundlePath
    bundlePath = bundlePath.componentsSeparatedByString("/").last!
    bundlePath = bundlePath.componentsSeparatedByString(".").first!
    return bundlePath
}
//通过类名返回一个AnyClass
func getClassWitnClassNmae(name:String) ->AnyClass?{
    let type = getBundleName() + "." + name
    return NSClassFromString(type)
}