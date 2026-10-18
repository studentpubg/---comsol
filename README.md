# 关于Creutz梯子当中耦合系数的计算方法步骤和matlab代码展示


![Creutz Ladder](<Creutz Ladder.png>)


上图是我展示的Creutz Ladder图片。


> [!IMPORTANT]
> 文档分为两个步骤，分别是在comsol当中建立2D的仿真和在matlab当中编写代码计算耦合系数，下面将分别介绍


## 1. Comsol当中2D仿真建模和怎么提取有效折射率
comsol里面仿真比较简单，也是为了方便理解计算和提取有效折射率，可以按照我下面步骤跟着操作<br>

下图是我的耦合波导模型


ncore=1.548[um]--纤芯折射率<br>
nclad=1.540[um]--包层折射率<br>
lda=700[nm]--波长<br>
r=1.9[um]--波导半径，这里面我设置了两个波导,两个波导都是一样的半径<br>
