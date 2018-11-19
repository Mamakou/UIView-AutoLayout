//
//  UIView+AutoLayout.swift
//  MySwiftLearn
//
//  Created by goviewtech on 2018/11/16.
//  Copyright © 2018 goviewtech. All rights reserved.
//

import Foundation
import UIKit

var ym_globalConstraintPriority = UILayoutPriority.required
var ym_isExecutingConstraintsBlock = false
typealias YM_ALConstraintsBlock = ()->Void

//MARK: 将系统的attribute进行分类，便于区分
public enum YM_ALEdge : Int {
    
    case ALEdgeLeft = 0
    case ALEdgeRight
    case ALEdgeTop
    case ALEdgeBottom
    case ALEdgeLeading
    case ALEdgeTrailing
}

public enum YM_ALDimension : Int {
    case ALDimensionWidth = 6
    case ALDimensionHeight = 7
}

public enum YM_ALAxis : Int {
    case ALAxisVertical = 8
    case ALAxisHorizontal = 9
    case ALAxisBaseline = 10
}




extension UIView {
    
    class func ym_newAutoLayoutView() -> UIView {
        let view = self.init()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func initForAutoLayout() -> UIView {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    class func ym_autoSetPriorityForConstraints(priority:UILayoutPriority,block:YM_ALConstraintsBlock) {
        ym_globalConstraintPriority = priority
        ym_isExecutingConstraintsBlock = true
        block()
        ym_isExecutingConstraintsBlock = false
        ym_globalConstraintPriority = UILayoutPriority.required
    }
    
    
    
   
    //MARK:Remove Constraints
    
    
    /// 移除指定约束
    ///
    /// - Parameter constraint: 约束
    class func ym_autoRemoveConstraint(constraint:NSLayoutConstraint) {
        if constraint.secondItem != nil {
            let firstItem = constraint.firstItem as! UIView
            var commonSuperview:UIView!
             commonSuperview = firstItem.ym_al_commonSuperviewWithView(peerView: (constraint.secondItem as! UIView))
            while (commonSuperview != nil) {
                if commonSuperview.constraints.contains(constraint) {
                    commonSuperview.removeConstraint(constraint)
                    return
                }
                commonSuperview = commonSuperview.superview!
            }
        }else {
            constraint.firstItem?.removeConstraint(constraint)
            return
        }
    }
    
    
    /// 移除约束数组
    ///
    /// - Parameter constraints: 约束数组
    class func ym_autoRemoveConstraints(constraints:Array<NSLayoutConstraint>) {
        for object in constraints {
            if object.isKind(of: NSLayoutConstraint.self) {
                self.ym_autoRemoveConstraint(constraint: object)
            }
        }
    }
    
    
    /// 删除当前view的所有约束,不包括隐式约束
    public func ym_autoRemoveConstraintsAffectingView() {
        self.ym_autoRemoveConstraintsAffectingViewIncludingImplicitConstraints(shouldRemoveImplicitConstraints: false)
        
    }
    
    
    /// 带有条件的删除view的约束
    ///
    /// - Parameter shouldRemoveImplicitConstraints: 是否全部删除
    public func ym_autoRemoveConstraintsAffectingViewIncludingImplicitConstraints(shouldRemoveImplicitConstraints:Bool) {
        var constraintsToRemove : Array<NSLayoutConstraint> = []
        var startView : UIView!
        startView = self
        repeat {
            for constraint in startView.constraints {
                let constaintClassName = NSStringFromClass(constraint.classForCoder)
                let isImplicitConstraint = constaintClassName.elementsEqual("NSContentSizeLayoutConstraint")
                if shouldRemoveImplicitConstraints || isImplicitConstraint == false {
                    let firstItem = constraint.firstItem as! UIView
                    let secondItem = constraint.secondItem as! UIView
                    if (firstItem != nil && firstItem == self) || (secondItem != nil && secondItem == self) {
                        constraintsToRemove.append(constraint)
                    }
                }
            }
            startView = startView.superview
        }while (startView != nil) ;
        UIView.ym_autoRemoveConstraints(constraints: constraintsToRemove)
    }
    
    
    /// 移除自身和subviews的约束
    public func ym_autoRemoveConstraintsAffectingViewAndSubviews(){
        self.ym_autoRemoveConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints(shouldRemoveImplicitConstraints: false)
    }
    /// 移除自身和subviews的约束
    public func ym_autoRemoveConstraintsAffectingViewAndSubviewsIncludingImplicitConstraints(shouldRemoveImplicitConstraints:Bool){
        self.ym_autoRemoveConstraintsAffectingViewIncludingImplicitConstraints(shouldRemoveImplicitConstraints: shouldRemoveImplicitConstraints)
        for subView in self.subviews {
            subView.ym_autoRemoveConstraintsAffectingViewIncludingImplicitConstraints(shouldRemoveImplicitConstraints: shouldRemoveImplicitConstraints)
        }
        
    }
    
    
    //MARK: Center in Superview
   @discardableResult func ym_autoCenterInSuperview() -> Array<NSLayoutConstraint> {
        var constraints : Array<NSLayoutConstraint> = []
        let horizontalConstraint = self.ym_autoAlignAxisToSuperviewAxis(axis: .ALAxisHorizontal)
        let verticalConstraint = self.ym_autoAlignAxisToSuperviewAxis(axis: .ALAxisVertical)
        if horizontalConstraint != nil {
            constraints.append(horizontalConstraint!)
        }
        if verticalConstraint != nil {
            constraints.append(verticalConstraint!)
        }
        return constraints
    }
    
    /// 相对于父视图的中心位置的约束
    ///
    /// - Parameter axis: 具体参数
    @discardableResult public func ym_autoAlignAxisToSuperviewAxis(axis:YM_ALAxis) ->NSLayoutConstraint! {
        self.translatesAutoresizingMaskIntoConstraints = false
        if self.superview == nil {
            print("error:父视图不存在")
            return nil
        }
        let attribute = UIView.ym_al_attributeForAxis(axis: axis)
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: self.superview, attribute: attribute, multiplier: 1.0, constant: 0)
        
        constraint.ym_autoInstall()
        return constraint
    }
    
    //MARK: pin edges tp superview
    
   @discardableResult func ym_autoPinEdgeToSuperviewEdge(edge:YM_ALEdge,inset:CGFloat) ->NSLayoutConstraint {
        return self.ym_autoPinEdgeToSuperviewEdgeRelation(edge: edge, inset: inset, relation: .equal)
    }
    
    func ym_autoPinEdgeToSuperviewEdgeRelation(edge:YM_ALEdge,inset:CGFloat,relation:NSLayoutConstraint.Relation) ->NSLayoutConstraint! {
        self.translatesAutoresizingMaskIntoConstraints = false
        if self.superview == nil {
            print("error:父视图不存在")
            return nil;
        }
        var theInset = inset
        var theRelation = relation
        if edge == .ALEdgeBottom || edge == .ALEdgeRight || edge == .ALEdgeTrailing {
            theInset = -theInset
            if theRelation == .lessThanOrEqual {
                theRelation = .greaterThanOrEqual
            }else if theRelation == .greaterThanOrEqual {
                theRelation = .lessThanOrEqual
            }
        }
        return self.ym_autoPinEdgeToEdgeOfViewWithOffsetRelation(edge: edge, toEdge: edge, peerView: self.superview!, offset: theInset, relation: theRelation)
    }
    
    
    /// 约束四边
    ///
    /// - Parameter insets: insets
    /// - Returns: 约束数组
    @discardableResult func ym_autoPinEdgesToSuperviewEdgesWithInsets(insets:UIEdgeInsets) ->Array<NSLayoutConstraint> {
        var constaints : Array<NSLayoutConstraint> = []
        let top = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeTop, inset: insets.top)
        let leading = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeading, inset: insets.left)
        let bottom = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeBottom, inset: insets.bottom)
        let trailing = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeTrailing, inset: insets.right)
        constaints.append(top)
        constaints.append(leading)
        constaints.append(bottom)
        constaints.append(trailing)
        return constaints
    }
    
    @discardableResult func ym_autoPinEdgesToSuperviewEdgesWithInsetsExcludingEdge(insets:UIEdgeInsets,edge:YM_ALEdge) -> Array<NSLayoutConstraint> {
        var constaints : Array<NSLayoutConstraint> = []
        if edge != .ALEdgeTop {
            let top = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeTop, inset: insets.top)
            constaints.append(top)
        }
        if edge != .ALEdgeLeading && edge != .ALEdgeLeft {
            let leading = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeading, inset: insets.left)
            constaints.append(leading)
        }
        if edge != .ALEdgeBottom {
            let bottom = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeBottom, inset: insets.bottom)
            constaints.append(bottom)
        }
        if edge != .ALEdgeRight && edge != .ALEdgeTrailing {
            let trailing = self.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeTrailing, inset: insets.right)
            constaints.append(trailing)
        }
        return constaints
    }
    
    
    //MARK:pin edges
    
    @discardableResult func ym_autoPinEdgeToEdgeOfView(edge:YM_ALEdge,toEdge:YM_ALEdge,peerView:UIView) -> NSLayoutConstraint {
        return self.ym_autoPinEdgeToEdgeOfViewWithOffset(edge: edge, toEdge: toEdge, peerView: peerView, offset: 0)
    }
    
    @discardableResult func ym_autoPinEdgeToEdgeOfViewWithOffset(edge:YM_ALEdge,toEdge:YM_ALEdge,peerView:UIView,offset:CGFloat) ->NSLayoutConstraint {
        return self.ym_autoPinEdgeToEdgeOfViewWithOffsetRelation(edge: edge, toEdge: toEdge, peerView: peerView, offset: offset, relation: .equal)
    }
    
    
    
    /// 相对哪个view添加什么约束
    ///
    /// - Parameters:
    ///   - edge: 位置
    ///   - toEdge: 位置
    ///   - peerView: 目标view
    ///   - offset: 距离
    ///   - relation: 相对值
    /// - Returns: 约束
    @discardableResult func ym_autoPinEdgeToEdgeOfViewWithOffsetRelation(edge:YM_ALEdge,toEdge:YM_ALEdge,peerView:UIView,offset:CGFloat,relation:NSLayoutConstraint.Relation) -> NSLayoutConstraint {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let attribute = UIView.ym_al_attributeForEdge(edge: edge)
        let toAttribute = UIView.ym_al_attributeForEdge(edge: toEdge)
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: peerView, attribute: toAttribute, multiplier: 1.0, constant: offset)
        constraint.ym_autoInstall()
        return constraint
    }
    
    
    //MARK: Align Axes
    @discardableResult func ym_autoAlignAxisToSameAxisOfView(axis:YM_ALAxis,peerView:UIView) ->NSLayoutConstraint {
        return self.ym_autoAlignAxisToSameAxisOfViewWithOffset(axis: axis, peerView: peerView, offset: 0)
    }
    
    @discardableResult func ym_autoAlignAxisToSameAxisOfViewWithOffset(axis:YM_ALAxis,peerView:UIView,offset:CGFloat) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let attribute = UIView.ym_al_attributeForAxis(axis: axis)
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .equal, toItem: peerView, attribute: attribute, multiplier: 1.0, constant: offset)
        constraint.ym_autoInstall()
        return constraint
    }
    
    
    //MARK:Match Dimensions
    @discardableResult func ym_autoMatchDimensionToDimensionOfView(dimension:YM_ALDimension,toDimension:YM_ALDimension,peerView:UIView) ->NSLayoutConstraint {
        return self.ym_autoMatchDimensionToDimensionOfViewWithOffset(dimension: dimension, toDimension: toDimension, peerView: peerView, offset: 0.0)
    }
    
    
    @discardableResult func ym_autoMatchDimensionToDimensionOfViewWithOffset(dimension:YM_ALDimension,toDimension:YM_ALDimension,peerView:UIView,offset:CGFloat) ->NSLayoutConstraint {
        
        return self.ym_autoMatchDimensionToDimensionOfViewWithOffsetRelation(dimension: dimension, toDimension: toDimension, peerView: peerView, offset: offset, relation: .equal)
    }
    
    
    @discardableResult func ym_autoMatchDimensionToDimensionOfViewWithOffsetRelation(dimension:YM_ALDimension,toDimension:YM_ALDimension,peerView:UIView,offset:CGFloat,relation:NSLayoutConstraint.Relation) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let arrtibute = UIView.ym_al_attributeForDimension(dimension: dimension)
        let toArrtibute = UIView.ym_al_attributeForDimension(dimension: toDimension)
        let constraint = NSLayoutConstraint(item: self, attribute: arrtibute, relatedBy: relation, toItem: peerView, attribute: toArrtibute, multiplier: 1.0, constant: offset)
        constraint.ym_autoInstall()
        
        return constraint
        
    }
    
    @discardableResult func ym_autoMatchDimensionToDimensionOfViewWithMultiplier(dimension:YM_ALDimension,toDimension:YM_ALDimension,peerView:UIView,multiplier:CGFloat) ->NSLayoutConstraint {
        
        return self.ym_autoMatchDimensionToDimensionOfViewWithMultiplierRelation(dimension: dimension, toDimension: toDimension, peerView: peerView, multiplier: multiplier, relation: .equal)
    }
    
    
    @discardableResult func ym_autoMatchDimensionToDimensionOfViewWithMultiplierRelation(dimension:YM_ALDimension,toDimension:YM_ALDimension,peerView:UIView,multiplier:CGFloat,relation:NSLayoutConstraint.Relation) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let arrtibute = UIView.ym_al_attributeForDimension(dimension: dimension)
        let toArrtibute = UIView.ym_al_attributeForDimension(dimension: toDimension)
        let constraint = NSLayoutConstraint(item: self, attribute: arrtibute, relatedBy: relation, toItem: peerView, attribute: toArrtibute, multiplier: multiplier, constant: 0.0)
        constraint.ym_autoInstall()
        
        return constraint
    }
    
    //MARK: Set Dimensions
   @discardableResult func ym_autoSetDimensionsToSize(size:CGSize)->Array<NSLayoutConstraint> {
        var constraints : Array<NSLayoutConstraint> = []
        let widthConstraint = self.ym_autoSetDimensionToSize(dimension: .ALDimensionWidth, size: size.width)
        let heightConstraint = self.ym_autoSetDimensionToSize(dimension: .ALDimensionHeight, size: size.height)
        constraints.append(widthConstraint)
        constraints.append(heightConstraint)
        return constraints
    }
    
    
    @discardableResult func ym_autoSetDimensionToSize(dimension:YM_ALDimension,size:CGFloat) ->NSLayoutConstraint {
        return self.ym_autoSetDimensionToSizeRelation(dimension: dimension, size: size, relation: .equal)
    }
    
    @discardableResult func ym_autoSetDimensionToSizeRelation(dimension:YM_ALDimension,size:CGFloat,relation:NSLayoutConstraint.Relation) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let arrtibute = UIView.ym_al_attributeForDimension(dimension: dimension)
        let constraint = NSLayoutConstraint(item: self, attribute: arrtibute, relatedBy: relation, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 0.0, constant: size)
        constraint.ym_autoInstall()
        return constraint
    }
    
    
    //MARK:Set Content Compression Resistance & Hugging
    func ym_autoSetContentCompressionResistancePriorityForAxis(axis:YM_ALAxis) {
        if ym_isExecutingConstraintsBlock == false {
            print("should only be called from within the block passed into the method")
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let attribute = UIView.ym_al_constraintAxisForAxis(axis: axis)
        self.setContentCompressionResistancePriority(ym_globalConstraintPriority, for:attribute)
    }
    
    func ym_autoSetContentHuggingPriorityForAxis(axis:YM_ALAxis) {
        if ym_isExecutingConstraintsBlock == false {
            print("should only be called from within the block passed into the method")
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        let attribute = UIView.ym_al_constraintAxisForAxis(axis: axis)
        self.setContentHuggingPriority(ym_globalConstraintPriority, for: attribute)
        
    }
    
    //MARK:Constrain Any Attributes
    
    @discardableResult func ym_autoConstrainAttributeToAttributeOfView(ALAttribute:Int,toALAttribute:Int,peerView:UIView) -> NSLayoutConstraint{
        
        return self.ym_autoConstrainAttributeToAttributeOfViewWithOffset(ALAttribute: ALAttribute, toALAttribute: toALAttribute, peerView: peerView, offset: 0.0)
    }
    
    @discardableResult func ym_autoConstrainAttributeToAttributeOfViewWithOffset(ALAttribute:Int,toALAttribute:Int,peerView:UIView,offset:CGFloat) ->NSLayoutConstraint {
        
        return self.ym_autoConstrainAttributeToAttributeOfViewWithOffsetRelation(ALAttribute: ALAttribute, toALAttribute: toALAttribute, peerView: peerView, offset: offset, relation: .equal)
    }
    
    
    @discardableResult func ym_autoConstrainAttributeToAttributeOfViewWithOffsetRelation(ALAttribute:Int,toALAttribute:Int,peerView:UIView,offset:CGFloat,relation:NSLayoutConstraint.Relation) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let attribute = UIView.ym_al_attributeForALAttribute(ALAttribute: ALAttribute)
        let toAttribute = UIView.ym_al_attributeForALAttribute(ALAttribute: toALAttribute)
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: peerView, attribute: toAttribute, multiplier: 1.0, constant: offset)
        constraint.ym_autoInstall()
        return constraint
    }
    
    @discardableResult func ym_autoConstrainAttributeToALAttributeOfViewWithMultiplier(ALAttribute:Int,toALAttribute:Int,peerView:UIView,multiplier:CGFloat) ->NSLayoutConstraint {
        
        return self.ym_autoConstrainAttributeToALAttributeOfViewWithMultiplierRelation(ALAttribute: ALAttribute, toALAttribute: toALAttribute, peerView: peerView, multiplier: multiplier, relation: .equal)
    }
    
    @discardableResult func ym_autoConstrainAttributeToALAttributeOfViewWithMultiplierRelation(ALAttribute:Int,toALAttribute:Int,peerView:UIView,multiplier:CGFloat,relation:NSLayoutConstraint.Relation) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let attribute = UIView.ym_al_attributeForALAttribute(ALAttribute: ALAttribute)
        let toAttribute = UIView.ym_al_attributeForALAttribute(ALAttribute: toALAttribute)
        let constraint = NSLayoutConstraint(item: self, attribute: attribute, relatedBy: relation, toItem: peerView, attribute: toAttribute, multiplier: multiplier, constant: 0.0)
        constraint.ym_autoInstall()
        return constraint
    }
    
    //MARK:Pin to Layout Guides
    @discardableResult func ym_autoPinToTopLayoutGuideOfViewControllerWithInset(viewController:UIViewController,inset:CGFloat) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        var achor : Any!
        achor = viewController.topLayoutGuide
       
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: achor, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: inset)
       viewController.view.ym_al_addConstraintUsingGlobalPriority(constraint: constraint)
        return constraint
    }
    
    @discardableResult func ym_autoPinToBottomLayoutGuideOfViewControllerWithInset(viewController:UIViewController,inset:CGFloat) ->NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        var achor : Any!
        achor = viewController.bottomLayoutGuide
        
        let constraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: achor, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: -inset)
        viewController.view.ym_al_addConstraintUsingGlobalPriority(constraint: constraint)
        return constraint
    }
    
    
    //MARK:Internal Helper Methods
    
    /// 添加约束
    ///
    /// - Parameter constraint: 约束
    func ym_al_addConstraintUsingGlobalPriority(constraint:NSLayoutConstraint) {
        constraint.priority = ym_globalConstraintPriority
        self.addConstraint(constraint)
    }
    
    
    /// 返回当前view和peerView的父view
    ///
    /// - Parameter peerView: peerView
    /// - Returns: 父view
    func ym_al_commonSuperviewWithView(peerView:UIView!) -> UIView {
        var commonSuperview:UIView!
        var startView :UIView!
        startView = self
        
        repeat {
            if peerView.isDescendant(of: startView) {
                commonSuperview = startView
            }
            if startView.superview != nil {
                startView = startView.superview
            }else {
                startView = nil
            }
        } while (commonSuperview == nil && startView != nil)
        //NSAssert(commonSuperview, @"Can't constrain two views that do not share a common superview. Make sure that both views have been added into the same view hierarchy.");
        return commonSuperview
    }
    
    
    /// 根据传入的center值，返回系统自带的value值
    ///
    /// - Parameter axis: axis
    /// - Returns: NSLayoutAttribute
    class func ym_al_attributeForAxis(axis:YM_ALAxis) ->NSLayoutConstraint.Attribute {
        var attribute = NSLayoutConstraint.Attribute.notAnAttribute
        
        switch axis {
        case .ALAxisVertical:
            attribute = NSLayoutConstraint.Attribute.centerX
        case .ALAxisHorizontal:
            attribute = NSLayoutConstraint.Attribute.centerY
        case .ALAxisBaseline:
            attribute = NSLayoutConstraint.Attribute.lastBaseline
        }
            
        return attribute
    }
    ///边距约束参数
    class func ym_al_attributeForEdge(edge:YM_ALEdge) ->NSLayoutConstraint.Attribute {
        var attribute = NSLayoutConstraint.Attribute.notAnAttribute
        switch edge {
        case .ALEdgeLeft:
            attribute = NSLayoutConstraint.Attribute.left
        case .ALEdgeRight:
            attribute = NSLayoutConstraint.Attribute.right
        case .ALEdgeTop:
            attribute = NSLayoutConstraint.Attribute.top
        case .ALEdgeBottom:
            attribute = NSLayoutConstraint.Attribute.bottom
        case .ALEdgeLeading:
            attribute = NSLayoutConstraint.Attribute.leading
        case .ALEdgeTrailing:
            attribute = NSLayoutConstraint.Attribute.trailing
        }
        return attribute
    }
    
    ///宽度和高度的参数
    class func ym_al_attributeForDimension(dimension:YM_ALDimension) ->NSLayoutConstraint.Attribute {
        var attribute = NSLayoutConstraint.Attribute.notAnAttribute
        switch dimension {
        case .ALDimensionHeight:
            attribute = NSLayoutConstraint.Attribute.height
        case.ALDimensionWidth:
            attribute = NSLayoutConstraint.Attribute.width
        }
        return attribute
    }
    
    class func ym_al_constraintAxisForAxis(axis:YM_ALAxis) ->NSLayoutConstraint.Axis {
        var attribute = NSLayoutConstraint.Axis.vertical
        if axis == .ALAxisHorizontal || axis == .ALAxisBaseline {
            attribute = NSLayoutConstraint.Axis.horizontal
        }
        return attribute
    }
    
    class func ym_al_attributeForALAttribute(ALAttribute:Int) ->NSLayoutConstraint.Attribute {
        var attribute = NSLayoutConstraint.Attribute.notAnAttribute
        if ALAttribute == 0 {
            attribute = NSLayoutConstraint.Attribute.left
        }else if ALAttribute == 1 {
            attribute = NSLayoutConstraint.Attribute.right
        }else if ALAttribute == 2 {
            attribute = NSLayoutConstraint.Attribute.top
        }else if ALAttribute == 3 {
            attribute = NSLayoutConstraint.Attribute.bottom
        }else if ALAttribute == 4 {
            attribute = NSLayoutConstraint.Attribute.leading
        }else if ALAttribute == 5 {
            attribute = NSLayoutConstraint.Attribute.trailing
        }else if ALAttribute == 6 {
            attribute = NSLayoutConstraint.Attribute.width
        }else if ALAttribute == 7 {
            attribute = NSLayoutConstraint.Attribute.height
        }else if ALAttribute == 8 {
            attribute = NSLayoutConstraint.Attribute.centerX
        }else if ALAttribute == 9 {
            attribute = NSLayoutConstraint.Attribute.centerY
        }else if ALAttribute == 10 {
            attribute = NSLayoutConstraint.Attribute.lastBaseline
        }
        return attribute
    }
    
    
    
    
}



extension NSLayoutConstraint {
    
    /**
     添加约束
     */
    func ym_autoInstall () {
        if self.firstItem == nil && self.secondItem == nil {
            print("error:添加约束需要两个item都满足")
            return
        }
        if self.firstItem != nil {
            if self.secondItem != nil {
                let firstItem = self.firstItem as! UIView
                let secondItem = self.secondItem as! UIView
                if firstItem.isKind(of: UIView.self) == false {
                    print("error:约束对象必须是UIView")
                    return
                }
                if secondItem.isKind(of: UIView.self) == false {
                    print("error:约束对象必须是UIView")
                    return
                }
                let commonSuperView = firstItem.ym_al_commonSuperviewWithView(peerView: secondItem)
                if commonSuperView == nil {
                    print(String(format: "%@必须先添加superView", firstItem))
                    return;
                }
                commonSuperView.ym_al_addConstraintUsingGlobalPriority(constraint: self)
            }else{
                let firstItem = self.firstItem as! UIView
                if firstItem.isKind(of: UIView.self) == false {
                    print("error:约束对象必须是UIView")
                    return
                }
                firstItem.ym_al_addConstraintUsingGlobalPriority(constraint: self)
            }
        }else {
            let secondItem = self.secondItem as! UIView
            if secondItem.isKind(of: UIView.self) == false {
                print("error:约束对象必须是UIView")
                return
            }
            secondItem.ym_al_addConstraintUsingGlobalPriority(constraint: self)
        }
    }
    
    
    /// 移除约束
    func ym_autoRemove() {
        UIView.ym_autoRemoveConstraint(constraint: self)
    }
    
    
    
}



