//
//  NSObject+Extension.swift
//  字典转模型
//
//  Created by 李坤坤 on 15/9/2.
//  Copyright © 2015年 李坤坤. All rights reserved.
//

import Foundation
extension NSObject{
    //把字典转换成模型
    class func objectWithKeyValues(keyValues:NSDictionary) -> AnyObject{
        let model = self.init()
        //获取所有的属性
        let properties = self.allProperties()
        model.setValuesForProperties(properties, keyValues: keyValues)
        return model
    }
    //把一个字典数组转成一个模型数组
    class func objectArrayWithKeyValuesArray(array:NSArray) -> [AnyObject]{
        var temp = Array<AnyObject>()
        let properties = self.allProperties()
        for(var i = 0;i < array.count;i++){
            let keyValues = array[i] as? NSDictionary
            if (keyValues != nil){
                let model = self.init()
                //为每个model赋值
                model.setValuesForProperties(properties, keyValues: keyValues!)
                temp.append(model)
            }
        }
        return temp
    }
    //把一个字典里的值赋给一个对象的值
    func setValuesForProperties(properties:[LKKProperty]?,keyValues:NSDictionary){
        //判断属性数组是否存在
        if let _ = properties{
            for property in properties!{
                //判断该属性是否属于Foundtation框架
                if property.propertyType.isFromFoundtion {
                    if let value = keyValues[property.key]{
                        //判断是否是数组，若是数组，判断数组里装的类是否是自定义类
                        if property.propertyType.isArray && property.propertyType.arrayClass != nil && value is NSArray{
                            //把字典数组转换成模型数组
                            let temp = property.propertyType.arrayClass!.objectArrayWithKeyValuesArray(value as! NSArray)
                            //为model类赋值
                            self.setValue(temp, forKey: property.propertyNmae as String)
                        }else{
                            //为model类赋值
                            self.setValue(value, forKey: property.propertyNmae as String)
                        }
                    }
                }else{
                    if let value = keyValues[property.key]{
                        if value is NSDictionary{
                            let subClass = property.propertyType.typeClass?.objectWithKeyValues(value as! NSDictionary)
                            //为model类赋值
                            self.setValue(subClass, forKey: property.propertyNmae as String)
                        }
                    }
                }
            }
        }
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
            let superM = (self.superclass() as! NSObject.Type) .allProperties()
            //let superM = self.superclass()?.allProperties()
            if let _ = superM{
                propertiesArray += superM!
            }
            //获取映射的字典
            let replacedDic = self.init().replacedKeyFromPropertyName()
            for var i = 0;i < Int(outCount);i++ {
                let property = LKKProperty(property: properties[i])
                //判断是否有映射
                if let key = replacedDic[property.propertyNmae as String] {
                    property.key = key
                    print(key)
                }
                //判断是否是数组
                if property.propertyType.isArray {
                    let objectArray = self.init().objectClassInArray()
                    //判断是否是自定义的类
                    if let objectName = objectArray[property.propertyNmae as String]{
                     
                        property.propertyType.arrayClass = getClassWitnClassNmae(objectName)
                    }
                }
                
                propertiesArray.append(property)
            }
            return propertiesArray
        }
    //子类重写这个方法，对字典里的key和类的属性进行映射
    func replacedKeyFromPropertyName() ->[String:String]{
        return ["":""]
    }
    //子类重写这个方法，说明数组里存放的数据类型
    func objectClassInArray() -> [String:String]{
        return ["":""]
    }
}
class LKKProperty{
    //属性名字
    var propertyNmae:NSString!
    //属性名字对应的key
    var key:String!
    //属性
    var property:objc_property_t
    //属性类型
    var propertyType:LKKType!
    init(property:objc_property_t){
        self.property = property
        self.propertyNmae = NSString(CString: property_getName(property), encoding: NSUTF8StringEncoding)
        key = self.propertyNmae as String
        //自定义的类的Types格式为T@"_TtC15字典转模型4Card",N,&,Vcard
        //T+@+"+..+工程的名字+数字+类名+"+,+其他,而我们想要的只是类名，所以要修改这个字符串
        var code: NSString = NSString(CString: property_getAttributes(property), encoding: NSUTF8StringEncoding)!
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
    //类名字
    var code:NSString
    //类的类型
    var typeClass:AnyClass?
    //是否属于Foundtation框架
    var isFromFoundtion:Bool = true
    //是否是数组
    var isArray:Bool = false
    //数组里面存放的类型
    var arrayClass:AnyClass?
    init(code:NSString){
        self.code = code
        //判断是否属于Foundtation框架
        if self.code.hasPrefix("NS"){
            self.typeClass = NSClassFromString(self.code as String)
            self.isFromFoundtion = true
            if self.code.hasPrefix("NSArray"){
                self.isArray = true
            }
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
