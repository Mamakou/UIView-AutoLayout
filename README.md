# UIView-AutoLayout
# swift版本的UIView+AutoLayout，简单方便，拖拽入项目即完成导入，绝对比snapKit好用。不信你试一试就知道了。

### 前言
- 再写swift项目的时候难免会用到自动布局，但是相信不少开发者肯定是从oc转过来的吧，在oc中有一个比较有名的UIView+AutoLayout库，非常的轻量级，使用非常简单，个人感觉用起来比Masonry更加亲和，更加方便。UIView的extension就搞定了。为了满足各位小伙伴，再者原作者没用更新，再加上现在snapKit存在bug，这才下定决心，主要是为了swift的学习和熟悉下swift语法，顺便学习下大神的代码思想，不喜勿喷哈！

### 如何使用
1、将UIView+AutoLayout.swift文件拖入项目即可完成导入。

2、必须先将view添加到父视图中

### 代码演示

- 水平、垂直方向与父view居中，并设置大小
```
let firstView = UIView()
firstView.backgroundColor = UIColor.red
self.view.addSubview(firstView)
firstView.ym_autoCenterInSuperview()
firstView.ym_autoSetDimensionsToSize(size: CGSize(width: 100, height: 100))
```
- 左右两边距离父控件各为12，且垂直居中
```
firstViewLabel.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeft, inset: 12)
firstViewLabel.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeRight, inset: 12)
firstViewLabel.ym_autoAlignAxisToSuperviewAxis(axis: .ALAxisVertical)
//不设置高度会自动布局
firstViewLabel.ym_autoSetDimensionToSize(dimension: .ALDimensionHeight, size: 20)
```

- 高宽匹配
```
let fisrtViewLabel2 = UILabel()
fisrtViewLabel2.text = "第二个label2"
fisrtViewLabel2.textColor = UIColor.green
firstView.addSubview(fisrtViewLabel2)
//fisrtViewLabel2的宽度与firstViewLabel的宽度一样，高度是firstViewLabel的1.2倍，并且再同一垂直线上,顶部距离firstViewLabel的底部距离为5
fisrtViewLabel2.ym_autoMatchDimensionToDimensionOfView(dimension: .ALDimensionWidth, toDimension: .ALDimensionWidth, peerView: firstViewLabel)
fisrtViewLabel2.ym_autoMatchDimensionToDimensionOfViewWithMultiplier(dimension: .ALDimensionHeight, toDimension: .ALDimensionHeight, peerView: firstViewLabel, multiplier: 1.2)
fisrtViewLabel2.ym_autoAlignAxisToSameAxisOfView(axis: .ALAxisVertical, peerView: firstViewLabel)
fisrtViewLabel2.ym_autoPinEdgeToEdgeOfViewWithOffset(edge: .ALEdgeTop, toEdge: .ALEdgeBottom, peerView: firstViewLabel, offset: 5)
```
- 约束对象持有
```
let secondView = UIView()
self.secondView = secondView
secondView.backgroundColor = UIColor.purple
self.view.addSubview(secondView)
///约束持有，后期动画改变secondView的高度
self.secondViewHeightConstraint = secondView.ym_autoSetDimensionToSize(dimension: .ALDimensionHeight, size: 200)
secondView.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeLeft, inset: 0)
secondView.ym_autoPinEdgeToSuperviewEdge(edge: .ALEdgeRight, inset: 0)
secondView.ym_autoPinEdgeToEdgeOfViewWithOffset(edge: .ALEdgeTop, toEdge: .ALEdgeBottom, peerView: firstView, offset: 10)
```
- 其他用法大家可自行看API中进行自己书写哈，就不一一列出来了。

#### 再次申明，只是对oc版的UIView+AutoLayout进行swift翻版的，纯属学习，如果您喜欢，记得点个赞哈。
#### 🌟🌟是我的动力哦，下次有好东西，第一个发布哈！！！

#### [这个是简书链接](https://www.jianshu.com/p/7bbfa046a9ef)，谢谢支持！！！




