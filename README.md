# UIView-AutoLayout
swift版本的UIView+AutoLayout，简单方便，拖拽入项目即完成导入

如何使用。用过oc版的UIView+AutoLayout 肯定也不少，其实这个是仿照它写的，主要是为了学习大神的代码思想，顺便熟悉下swift语法，不喜勿喷哈！

功能上和写法上几乎与oc版保存一致，满足广大oc朋友哈。笔记学swift挺不容易的。

demo:

水平、垂直方向与父view居中，并设置大小

let firstView = UIView()

firstView.backgroundColor = UIColor.red

self.view.addSubview(firstView)
 
 firstView.ym_autoCenterInSuperview()
 
 firstView.ym_autoSetDimensionsToSize(size: CGSize(width: 100, height: 100))

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
其他
其他的大家可以看看demo，使用起来真的很简单哈！
