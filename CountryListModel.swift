//
//  CountryListModel.swift
//  yinuo
//
//  Created by 吴承炽 on 2018/9/10.
//  Copyright © 2018年 yinuo. All rights reserved.
//

import ObjectMapper
import HandyJSON

class CountryListModel: HandyJSON {
    
    var ct_ename: String?
    
    var ct_code: String?
    
    var ct_name: String?
    
    var ct_3code: String?
    
    var ct_scancode: String?
    
    var letter: String?
    
//    "ct_ename":"英文名称",
//    "ct_code":"二字代码",
//    "ct_name":"中文名称",
//    "ct_3code":"三字代码",
//    "ct_scancode":""
    
    required init() {}
    
}
