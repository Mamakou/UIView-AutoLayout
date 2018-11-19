//
//  ViewController.swift
//  UIViewAutoLayoutDemo
//
//  Created by goviewtech on 2018/11/19.
//  Copyright © 2018 goviewtech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var functionArray : Array<String> = []
    var secondViewHeightConstraint : NSLayoutConstraint!
    var secondView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.title = "各种约束展示"
        
        let firstView = UIView()
        firstView.backgroundColor = UIColor.red
        self.view.addSubview(firstView)
        firstView.ym_autoCenterInSuperview()
        firstView.ym_autoSetDimensionsToSize(size: CGSize(width: 100, height: 100))
        
        let firstViewLabel = UILabel()
        firstViewLabel.text = "firstViewLabel"
        firstViewLabel.numberOfLines = 0
        firstView.addSubview(firstViewLabel)
        //左右两边距离父控件各为12，且垂直居中
        firstViewLabel.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeft, inset: 12)
        firstViewLabel.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeRight, inset: 12)
        firstViewLabel.ym_autoAlignAxisToSuperviewAxis(axis: .ALAxisVertical)
        //不设置高度会自动布局
        firstViewLabel.ym_autoSetDimensionToSize(dimension: .ALDimensionHeight, size: 20)
        
        let fisrtViewLabel2 = UILabel()
        fisrtViewLabel2.text = "第二个label2"
        fisrtViewLabel2.textColor = UIColor.green
        firstView.addSubview(fisrtViewLabel2)
        //fisrtViewLabel2的宽度与firstViewLabel的宽度一样，高度是firstViewLabel的1.2倍，并且再同一垂直线上,顶部距离firstViewLabel的底部距离为5
        fisrtViewLabel2.ym_autoMatchDimensionToDimensionOfView(dimension: .ALDimensionWidth, toDimension: .ALDimensionWidth, peerView: firstViewLabel)
        fisrtViewLabel2.ym_autoMatchDimensionToDimensionOfViewWithMultiplier(dimension: .ALDimensionHeight, toDimension: .ALDimensionHeight, peerView: firstViewLabel, multiplier: 1.2)
        fisrtViewLabel2.ym_autoAlignAxisToSameAxisOfView(axis: .ALAxisVertical, peerView: firstViewLabel)
        fisrtViewLabel2.ym_autoPinEdgeToEdgeOfViewWithOffset(edge: .ALEdgeTop, toEdge: .ALEdgeBottom, peerView: firstViewLabel, offset: 5)
        
        
        var secondView = UIView()
        self.secondView = secondView
        secondView.backgroundColor = UIColor.purple
        self.view.addSubview(secondView)
        self.secondViewHeightConstraint = secondView.ym_autoSetDimensionToSize(dimension: .ALDimensionHeight, size: 200)
        secondView.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeft, inset: 0)
        secondView.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeRight, inset: 0)
        secondView.ym_autoPinEdgeToEdgeOfViewWithOffset(edge: .ALEdgeTop, toEdge: .ALEdgeBottom, peerView: firstView, offset: 10)
        
        let subView1 = UIButton()
        subView1.setTitle("点击改变约束", for: .normal)
        subView1.setTitleColor(UIColor.black, for: .normal)
        secondView.addSubview(subView1)
        
        subView1.ym_autoPinEdgesToSuperviewEdgesWithInsetsExcludingEdge(insets: UIEdgeInsets(top: 0, left: 50, bottom: 0, right: 50), edge: .ALEdgeBottom)
        subView1.ym_autoSetDimensionToSize(dimension: .ALDimensionHeight, size: 30)
        let tapGester = UITapGestureRecognizer.init(target: self, action: #selector(clickTapAction))
        subView1.addGestureRecognizer(tapGester)
        
        let subLabel1 = UILabel()
        subLabel1.text = "1"
        subLabel1.backgroundColor = UIColor.yellow
        secondView.addSubview(subLabel1)
        subLabel1.ym_autoPinEdgeToEdgeOfViewWithOffset(edge: .ALEdgeTop, toEdge: .ALEdgeBottom, peerView: subView1, offset: 0)
        subLabel1.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeft, inset: 0)
        subLabel1.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeRight, inset: 0)
        
        let subLabel2 = UILabel()
        subLabel2.text = "2"
        subLabel2.backgroundColor = UIColor.blue
        secondView.addSubview(subLabel2)
        subLabel2 .ym_autoMatchDimensionToDimensionOfView(dimension: .ALDimensionWidth, toDimension: .ALDimensionWidth, peerView: subLabel1)
        subLabel2.ym_autoMatchDimensionToDimensionOfView(dimension: .ALDimensionHeight, toDimension: .ALDimensionHeight, peerView: subLabel1)
        subLabel2.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeBottom, inset: 0)
        subLabel2.ym_autoPinEdgeToEdgeOfView(edge: .ALEdgeTop, toEdge: .ALEdgeBottom, peerView: subLabel1)
        
        
    }

    @objc func clickTapAction () {
        UIView.animate(withDuration: 2.0, delay: 2.5, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.secondViewHeightConstraint.constant = 120
        }) { (complete:Bool) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.5, execute: {
                self.secondViewHeightConstraint.constant = 200
            })
        }
    }
    

}

