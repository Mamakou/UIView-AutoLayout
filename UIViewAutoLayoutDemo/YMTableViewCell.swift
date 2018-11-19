//
//  YMTableViewCell.swift
//  UIViewAutoLayoutDemo
//
//  Created by goviewtech on 2018/11/19.
//  Copyright © 2018 goviewtech. All rights reserved.
//

import UIKit

class YMTableViewCell: UITableViewCell {

    class func cellWithTableView(tableView: UITableView) ->YMTableViewCell {
        let cellId = "YMTableViewCellCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = YMTableViewCell.init(style: .default, reuseIdentifier: cellId)
        }
        return cell as! YMTableViewCell
    }
    
    

}
