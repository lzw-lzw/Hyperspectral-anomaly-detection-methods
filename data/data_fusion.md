# 数据融合数据集信息

## 2023数据融合比赛(DFC23)数据
DFC23建立了一个大规模、细粒度、多模态的建筑屋顶类型分类数据集，该比赛包括两个赛道，研究光学和SAR数据的融合，track1和track2分别侧重于屋顶类型分类和建筑物高度估计。根据屋顶的几何形状，有十二种细粒度的屋顶类型。

DFC23数据集的图像来自SuperView-1、高分二号和高分三号卫星，空间分辨率分别为0.5m、0.8m和1m。Track2中供参考的归一化数字表面模型(nDSM)是根据高分七号卫星和WorldView1和2拍摄的立体图像生成的，地面采样距离(GSD)约为2 m。数据是从六大洲的十七个城市收集的，以提供关于地貌、建筑和建筑类型的大量且具有高度多样性的代表性数据集。 

具体细节可参考[https://ieee-dataport.org/competitions/2023-ieee-grss-data-fusion-contest-large-scale-fine-grained-building-classification](https://ieee-dataport.org/competitions/2023-ieee-grss-data-fusion-contest-large-scale-fine-grained-building-classification)
```
|--DFC23 
  |-- track1:   用于屋顶类型分类的数据集
    |--root_fine_train.json
    |--train
      |--rgb
      |--sar
    |--val
      |--rgb
      |--sar    
  ├── track2:   用于建筑物高度估计的数据集
    |--buildings_only_train.json
    |--train
      |--rgb
      |--sar
      |--dsm
    |--val
      |--rgb
      |--sar
```

## 2022数据融合比赛数据
2022年IEEE GRSS数据融合大赛由图像分析与数据融合技术委员会组织，旨在促进半监督学习的研究。总体目标是构建能够利用大量未标记数据的模型，同时只需要少量带注释的训练样本。

MiniFrance-dfc22(MF-DFC22)数据集扩展和修改了MiniFrance数据集，用于训练用于土地利用/土地覆盖测绘的半监督语义分割模型。多模态的MF-DFC22包含了法国不同地区19个城市及其周边地区对应的航空图像、高程模型和土地利用/土地覆盖地图。它包括城市和乡村场景:居民区、工业和商业区，也有田野、森林、海岸和低矮的山脉。它从三个来源收集数据:

VHR航拍图像数据来自法国国家地理与森林信息研究所(IGN)BDORTHO数据库。

数字高程模型(DEM)数据来自IGN RGE ALTI数据库。DEM数据给出了地球地形表面的表示。

来自UrbanAtlas 2012数据库的标记类引用。考虑了14种土地使用类别，原始数据在欧洲哥白尼计划网站上作为矢量图像公开提供。

具体细节可参考[https://ieee-dataport.org/competitions/data-fusion-contest-2022-dfc2022](https://ieee-dataport.org/competitions/data-fusion-contest-2022-dfc2022)
```
|--labeled_train    带标记的数据集，下一级的不同文件夹代表不同城市
  |--Nantes_Saint-Nazaire   
    |--BDORTHO
    |--RGEALTI
    |--UrbanAtlas   带标记数据集的标记
  |--Nice                  
  
|--unlabeled_train  未标记数据集，下一级的不同文件夹代表不同城市
  |--Brest
    |--BDORTHO
    |--RGEALTI
  |--Caen
  |--Calais_Dunkerque
  |--LeMans
  |--Lorient
  |--Saint-Brieuc
```

## 2021数据融合比赛数据
2021年IEEE GRSS数据融合大赛无电住区检测挑战赛道(track DSE)旨在促进利用多模态和多时间遥感数据自动检测无电人类住区的研究。

竞赛数据集由98个800×800像素的tile组成，训练集、验证集和测试集各60、19和19，每个tile包括98个channel。

Sentinel-1极化SAR数据: 4张图片各2个channel，分别对应VV和VH极化的强度值，文件名后缀为“S1A_IW_GRDH_*.tif”

Sentinel-2多光谱数据: 4张图片的12通道反射率数据，覆盖VNIR和SWIR范围，文件名后缀为“L2A_*.tif”，

Landsat 8多光谱数据: 3张图片的11通道反射率数据，涵盖VNIR、SWIR和TIR范围，文件名后缀为“LC08_L1TP_*.tif”

Suomi可见光红外成像辐射计套件(VIIRS)夜间数据:VIIRS(可见红外成像辐射计套件)的昼夜波段(DNB)传感器在一个通道上提供全球夜间可见光和近红外(NIR)光的每日测量,共给出9张图片，文件名后缀为“DNB_VNP46A1_*.tif”

此外还为每个tile提供参考信息('groundTruth.tif '文件)，参考文件(' groundTruth.tif ')大小为16×16个像素，一个额外的参考文件('groundTruthRGB.png ')以10m分辨率的RGB格式提供，以便于可视化。

具体细节可参考[https://ieee-dataport.org/competitions/2021-ieee-grss-data-fusion-contest-track-dse](https://ieee-dataport.org/competitions/2021-ieee-grss-data-fusion-contest-track-dse)
```
|--dfc2021_dse_train
  |--Tile1
    |--S1A_IW_GRDH_*.tif
    |--L2A_*.tif
    |--LC08_L1TP_*.tif
    |--DNB_VNP46A1_*.tif
    |--groundTruth.tif
  ...
  ...
  ...
  |--Tile60
```
