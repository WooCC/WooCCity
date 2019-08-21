//
//  CountryListSelectVC.swift
//  yinuo
//
//  Created by 吴承炽 on 2018/10/5.
//  Copyright © 2018年 yinuo. All rights reserved.
//

import UIKit
import MJRefresh
import Moya
import RxSwift
import SVProgressHUD
import ObjectMapper

typealias areaBlock = (_ str: String,_ areaCode:String) -> Void

class CountryListSelectVC: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    

    var SettingTableView = UITableView()
    let disposeBag = DisposeBag()
    var pageNum = 0
    var orderListArr = [ProblemProductListModel]()
    var countryArr = [CountryListModel]()
    
    var dataArray = NSMutableArray()
    var metterDict = NSMutableDictionary()
    
    var searchView = UISearchBar()
    
    //回调闭包
    var callBack: areaBlock?
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yinuoViewBackgroundColor()
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupCountryData()
    }
}

extension CountryListSelectVC {
    
    private func setupView() {
        self.title = "国家列表"
        
        self.view.backgroundColor = UIColor.yinuoViewBackgroundColor()
        
        searchView.delegate = self
        searchView.placeholder = "搜索国家"
        searchView.backgroundColor = UIColor.white
        searchView.tintColor = UIColor.yinuoTextBlueColor()
        searchView.frame = CGRect(x: 0, y: NavigationBarHeight + 5, width: SCREEN_WIDTH, height: 50)
        self.view.addSubview(searchView)
        
        
        self.view.addSubview(SettingTableView)
        
        SettingTableView.registerClassOf(CountryListCell.self)
        
        SettingTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        SettingTableView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        SettingTableView.backgroundColor = UIColor.clear
        SettingTableView.dataSource = self
        SettingTableView.delegate = self
        SettingTableView.hideTableViewExtraCellLineHidden(tableView: SettingTableView)
        SettingTableView.tag = 1
        
        SettingTableView.snp.makeConstraints { (make) in
            make.centerX.width.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
            make.height.equalTo(SCREEN_HEIGHT - NavigationBarHeight - 50)
        }
        
        // 索引
        // 设置索引值颜色
        SettingTableView.sectionIndexColor = UIColor.yinuoTextBlueColor()
        // 设置选中时的索引背景颜色
        SettingTableView.sectionIndexTrackingBackgroundColor = UIColor.white
        // 设置索引的背景颜色
        SettingTableView.sectionIndexBackgroundColor = .clear
      
    }
    
}

extension CountryListSelectVC {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40 * UI_SCALE
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
        
        let keys = self.getAllCityKey()
        return keys.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return countryArr.count
        let keys = self.getAllCityKey()
        let keyStr = keys[section]
        let values = metterDict.object(forKey: keyStr)
        return ((values as AnyObject).count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryListCell", for: indexPath) as! CountryListCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
//        let model = countryArr[indexPath.row]
        
//        cell.titleL.text = model.ct_name
        
        let keys = self.getAllCityKey()//所有的key值
        let keyStr = keys[indexPath.section]//选择的是哪一组
        let values = metterDict.object(forKey: keyStr) as! NSArray//获取该组下面的所有行
        let info = values[indexPath.row] as! CountryListModel//获取选中的行
        
//        cell.textLabel?.text = info.name
        cell.titleL.text = info.ct_name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
        
        return cell;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let model = countryArr[indexPath.row]
//        let countryName = model.ct_name ?? ""
//        let countryCode = model.ct_code ?? ""
        
        let keys = self.getAllCityKey()//所有的key值
        let keyStr = keys[indexPath.section]//选择的是哪一组
        let values = metterDict.object(forKey: keyStr) as! NSArray//获取该组下面的所有行
        let info = values[indexPath.row] as! CountryListModel//获取选中的行
        
        let countryName = info.ct_name ?? ""
        let countryCode = info.ct_code ?? ""
        
        self.callBack!(countryName,countryCode)
        self.navigationController?.popViewController(animated: true)
    }
  
    // 遵守UITableViewDelegate, UITableViewDataSource协议
    
 
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return dataSource as? [String]
        let keys = self.getAllCityKey() as! [String]
        return keys
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keys = self.getAllCityKey() as! [String]
        //判断keys是否为空
        if keys.count > 0 {
            return keys[section]
        }else{
            return nil
        }
        
    }
   
    
//    //点击索引，移动TableView的组位置
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String,
                            atIndex index: Int) -> Int {
        var tpIndex:Int = 0
         let keys = self.getAllCityKey() as! [String]
        //遍历索引值
        for character in keys{
            //判断索引值和组名称相等，返回组坐标
            if character as! String == title{
                return tpIndex
            }
            tpIndex += 1
        }
        return 0
    }
    
    
    // UITableViewDataSource协议中的方法，该方法的返回值决定指定分区的头部
//    func tableView(tableView:UITableView, titleForHeaderInSection
//        section:Int)->String?
//    {
//        return dataSource[section] as? String;
//    }
    
  
}
extension CountryListSelectVC {
    private func setupCountryData() {
        
        let customer_id_str = UserDefaults.standard.value(forKey: "customer_id")
        //        set(customer_id, forKey: "customer_id")
        let customer_id = Int("\(customer_id_str ?? "0")")
        //        print(customer_id)
        YiNuoHUD.showWithBlackMask()
        YiNuoNetWorkingTool.getCountryList(customerId: customer_id!) { (countryArr, errorStr) in
//            self.countryArr = countryArr
//            self.SettingTableView.reloadData()
            YiNuoEndLoading()
            guard countryArr.count != 0 else {
                return
            }
            
            for model in countryArr {
                model.letter = self.getFirCharactor(str: model.ct_name!)
            }
            //这个是搜索控制器用的数组
            self.countryArr = countryArr
            //这个是原本的控制器用的数组
            self.dataArray.setArray(countryArr)
            
            //首字母升序排列
            self.getAllCityMetter()
            
            self.SettingTableView.reloadData()
           
        }
        
    }
    
    //获得所有的key值并排序，并返回排好序的数组
    func getAllCityKey()->NSArray{
        let keys = metterDict.allKeys as NSArray
        return keys.sortedArray(using: #selector(NSNumber.compare(_:))) as NSArray
    }
    
    //首字母相同的放在一起
    func getAllCityMetter(){
        for cityInfo in self.dataArray {
            let info = cityInfo as! CountryListModel
            let s = metterDict[info.letter ?? ""]
            if s == nil {
                var letterArr: NSMutableArray
                letterArr = NSMutableArray()
                metterDict.setObject(letterArr, forKey: info.letter! as NSCopying)
                letterArr.add(info)
            }else{
                let m_letterArr = metterDict[info.letter ?? ""] as! NSMutableArray
                m_letterArr.add(info)
            }
        }
    }
    
    func getFirCharactor(str: String) -> String {
        
        let mString = NSMutableString(string: str)
        CFStringTransform(mString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false)
        let string = mString.capitalized
        return string.substring(to: string.index(string.startIndex, offsetBy: 1))
    }
    
    
}

extension CountryListSelectVC {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        print("searchBar: \(searchBar.text)")
        var searchStr = String()
        
        if let len = searchBar.text?.count , len > 0{
            searchStr = searchBar.text!
        }else {
            //            searchStr = ""
            YiNuoInform("搜索内容不能为空")
            return
        }
//        print("searchBar: \(searchStr)")
        var newArr = [CountryListModel]()
        for model in countryArr {
            if model.ct_name!.contains(searchStr) {
//                print(model.ct_name)
                newArr.append(model)
            }
        }
        
        guard newArr.count != 0 else {
            YiNuoInform("未搜索到相关内容")
            return
        }
        self.dataArray.removeAllObjects()
        self.metterDict.removeAllObjects()
        
        for model in newArr {
            model.letter = self.getFirCharactor(str: model.ct_name!)
        }
        //这个是原本的控制器用的数组
        self.dataArray.setArray(newArr)
//        print(self.dataArray.count)
        //首字母升序排列
        self.getAllCityMetter()
        self.view.endEditing(true)
        self.SettingTableView.reloadData()
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("aaa")
        self.dataArray.removeAllObjects()
        self.metterDict.removeAllObjects()
        setupCountryData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let len = searchBar.text?.count
        if len == 0{
            self.dataArray.removeAllObjects()
            self.metterDict.removeAllObjects()
            setupCountryData()
        }
    }
}

extension CountryListSelectVC {
    func callBackBlock(_ block: @escaping areaBlock) {
        
        callBack = block
    }
}

