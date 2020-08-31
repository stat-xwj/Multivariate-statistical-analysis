#  高维数据可视化
对于低维数据而言，可视化方法一般有以下几种：柱状图、散点图、饼图、折线图、直方图、密度图、箱线图、热力图、地图等。高维数据可视化的思路分为以下三种：
- 单个维度独立展示；
- 多个维度交互展示；
- 将多维数据映射到低维数据；
## 0. 数据集及数据说明
本文基于R语言对uci机器学习网站(https://archive.ics.uci.edu/ml/index.php)中葡萄酒数据进行可视化分析，主要用到ggplot2、GGally等包，完整数据及代码见文末。该数据共分为红葡萄酒和白葡萄酒两类共6497条样本，均包含二氧化硫浓度、PH值、葡萄酒品质等12个变量。
```R
winedata = read.csv('D:wine_data.csv', head=TRUE)
winedata = winedata[sample(length(winedata[, 1])), ]
head(winedata)
summary(winedata)
```

## 1 单个维度独立展示
### 1.1 柱状图
对所有样本品质(quality)作柱状图查看其分布情况：
```R
fig = ggplot(data = winedata, 
             mapping = aes(x = quality))
fig+geom_bar( )
```
![葡萄酒的品质大多集中在中间5、6、7，大致呈现正态分布](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861155408-柱状图.png)


### 1.2 直方图
类似于柱状图，直方图能更加清晰地呈现数据的分布情况，同样对所有样本的挥发性酸度(volatile.acidity)作直方图同时加上密度估计：
```R
fig = ggplot(data = winedata, 
             mapping = aes(x=volatile.acidity))
fig+geom_histogram()

# 密度估计
fig + geom_histogram(mapping = aes(y = ..density..), alpha = 0.6)+
  geom_line(stat = 'density', size = 1.1, color = 'red')
```
![volatile.acidity变量呈现明显左偏分布](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861229669-直方图.png)


### 1.3 饼图
饼图通常能直观地反映离散数据的类别占比情况，对所有样本的种类(type)作饼图可得：
```R
# ggplot2 中饼图是先做出条形图，再极坐标变换得到的
fig = ggplot(data = winedata, 
             mapping = aes(x = "type", fill = type))
fig = fig + geom_bar(stat = 'count', position = 'stack')
# 去除标签
fig = fig + coord_polar(theta = 'y')+ labs(x = '', y = '', title = '') +
  theme(axis.text = element_blank())

# 添加数值
fig + geom_text(stat="count",aes(label = scales::percent(..count../length(winedata$type))), 
                size=5, position=position_stack(vjust = 0.5))
```

![数据不均衡，白葡萄酒的数量更多，做分类时应该考虑这种不均衡情况](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861261781-饼图.png)


## 2. 多个维度交互展示
### 2.1 散点图(二维)
对所有样本的固定酸度(fixed.acidity)和挥发酸度(volatile.acidity)作交互散点图可得：

```R
fig = ggplot(data = winedata, 
             mapping = aes(x = fixed.acidity, 
             y = volatile.acidity))
fig + geom_point(size = 1.5)
```




![大多数据点都集中在fixed.acidity和volatile.acidity均较小的位置，且fixed.acidity的离散程度更高](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861360300-二维散点.png)

### 2.2 分组柱状图(二维)
分类(type)查看葡萄酒的品质(quality)，有三种不同的展现方式：
```R
df = winedata %>%
  select(type, quality) %>%
  group_by(type, quality) %>%
  summarise(n = n()) %>%
  mutate(ratio = n / sum(n)) %>%
  ungroup()
names(df) = c('type', 'quality', 'Frec', 'Ratio')

fig = ggplot(data = df,aes(x = quality, y = Ratio, fill = type))
# 第一种
fig + geom_bar(position="dodge",stat="identity")

# 第二种
fig + geom_col()

# 第三种
fig + geom_col(position = "fill") + labs(y = NULL)
```

![](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861345233-分组柱状1.png)

![](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861345235-分组柱状2.png)

![红葡萄酒的品质较低，白葡萄酒品质较高](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861372574-分组柱状3.png)

### 2.3 分组直方图(二维)
作出两种葡萄酒下样本的PH值分布情况：


```R
fig = ggplot(data = winedata, 
             mapping = aes(x = pH, fill = type))
fig + geom_histogram() 
```


![二者PH的峰值类似，红葡萄酒PH值偏大](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861550601-分组直方图.png)

同时，作出不同品质(quality)的葡萄酒固定酸度(fixed.acidity)的分布情况：


```R
fig = ggplot(data = winedata, 
             mapping = aes(x = fixed.acidity, color = as.factor(quality)))
fig + geom_line(size = 1.2, stat = "density")
```


![随着品质增高，分布曲线逐渐具有厚尾现象，品质最高的一类酒具有双峰](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861559442-分组直方图2.png)

### 2.4 箱线图(二维)
对全体样本不同品质(quality)下作其固定酸度(fixed.adidity)的箱线图:

```R
fig = ggplot(data = winedata, 
             mapping = aes(x = quality, y = fixed.acidity, color = as.factor(quality)))
fig + geom_boxplot()
```

![品质越低的葡萄酒固定酸度含量越高，品质越高的葡萄酒固定酸度离散度越高](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/箱线图.png)


### 2.5 分组散点图(三维)
对不同类型(type)的葡萄酒固定酸度(fixed.acidity)和挥发酸度(volatile.acidity)作交互散点图可得：

```R
fig = ggplot(data = winedata, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, color = type))
fig + geom_point(size = 2)
```


![红葡萄酒的散点分布明显位于更右上侧，两种酸度的含量更高](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861661653-分组散点.png)

### 2.6 分组箱线(三维)
作出两种类别(type)下不同品质(quality)的葡萄酒固定酸度(fixed.acidity)的箱线图：


```R
fig = ggplot(data = winedata_quality_factor, 
             mapping = aes(x = quality, y = fixed.acidity, color = type))
fig + geom_boxplot()
```



![红葡萄酒在各个品质下的fixed.acidity均更高，红葡萄酒品质越高fixed.acidity越高，而白葡萄酒恰好相反](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/1598861649243-分组箱线.png)

提供一种更加优雅的做法，整合多个图形，利用'GGally'包中的'ggpairs'函数，作出12个变量与type变量之间的相互关系矩阵：

```R
ggpairs(data = winedata, columns=7:12, aes(color=type))
```

![](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/ggpair1.png)

![更加快速直观](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/ggpair2.png)

### 2.7 空间散点图(三维)
'ggplot2'包不支持三维图形渲染，采用'plotly'包中的'plot_ly'函数，作出所有样本固定酸度(fixed.acidity)、挥发酸度(volatile.acidity)、柠檬酸(citric.acid)之间的散点图：

```
plot_ly(data = winedata, size = 1, x = ~fixed.acidity, 
        y = ~ volatile.acidity, z = ~citric.acid, 
        type = "scatter3d", mode = "markers")
```

![数据分布较为集中，近似分布在一个斜面上，在citric.acid轴上离散程度最高](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/空间散点.png)

### 2.8 气泡图(三维)
三维的图像较为抽象，用气泡图作出上述三变量的关系，气泡大小代表柠檬酸(citric.acid)的大小：

```R
df = winedata[sample(1000), ]
fig = ggplot(data = df, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, size = citric.acid))
fig + geom_point(shape = 21, color = "black", fill = "cornsilk")
```

![citric.acid较小的点主要分布在fixed.acidity较小且volatile.acidity较大的区域](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/气泡图.png)

**Q:**
如何考虑更高维度的数据呢？

**A:**
为气泡增加更多的维度例如大小、颜色、形状等，以及将气泡运用到空间坐标中

### 2.9 四维数据
分数据的type作出其固定酸度(fixed.acidity)、挥发酸度(volatile.acidity)、柠檬酸(citric.acid)三者之间的气泡图，与2.8的差别在于增加了葡萄酒类型这一变量：

**平面坐标+气泡图大小+气泡颜色**

```R
fig = ggplot(data = df, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, 
                           size = citric.acid, color = as.numeric(type)))
fig + geom_point() +scale_color_gradient(low="lightblue",high ="darkblue")
```

![红葡萄酒的数据分布整体靠右，且离散程度更高，同样citric.acid较小的点在fixed.acidity较小的区域](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/二维坐标气泡大小颜色.png)

**空间坐标+气泡颜色**

```R
plot_ly(data = winedata, size = 1, color = ~type, x = ~fixed.acidity, 
        y = ~volatile.acidity, z = ~citric.acid, 
        type = "scatter3d", mode = "markers")
```

![数据在citric.acid上的分布较为一致，红葡萄酒的fixed.acidity较大](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/分类空间散点.png)

### 2.10 五维数据

**空间坐标+气泡颜色+气泡大小**

分数据的type作出其固定酸度(fixed.acidity)、挥发酸度(volatile.acidity)、柠檬酸(citric.acid)三者之间的气泡图，气泡的大小代表了氯化物浓度(chlorides):

```R
plot_ly(data = df, color = ~type, 
        x = ~fixed.acidity, y = ~volatile.acidity, z = ~citric.acid, 
        type = "scatter3d", marker = list(size = ~chlorides*50))
```

![chlorides主要分布在fixed.acidity及volatile.acidity较大的地方](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/三维坐标气泡大小气泡颜色大小.png)

**二维坐标+气泡图大小+气泡颜色+气泡形状**

分数据的type作出其固定酸度(fixed.acidity)、挥发酸度(volatile.acidity)的气泡图，气泡大小表示柠檬酸(citric.acid)的浓度，气泡的颜色代表了氯化物浓度(chlorides)，气泡形状表示两种类型的葡萄酒：

```R
fig = ggplot(data = df, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, 
                           size = citric.acid, color = chlorides, shape = type))
fig + geom_point() + 
  scale_color_gradient(low="lightblue",high ="darkblue") + 
  scale_shape_manual(values = c(21,22)) 
```

![白葡萄酒的citric.acid普遍偏高，较低的chlorides分布比较均匀，较大的chlorides大多分布在fixed.acidity和volatile.acidity较小的位置(仅sample了1000个点)](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/二维气泡全家桶.png)

### 2.11 六维数据

**三维坐标+气泡颜色+气泡大小+气泡形状**

作出样本固定酸度(fixed.acidity)、挥发酸度(volatile.acidity)、柠檬酸(citric.acid)三者之间的气泡图，气泡的大小代表了氯化物浓度(chlorides)，气泡颜色代表品质(quality), 气泡形状代表类别(type):

```R
plot_ly(data = df, color = ~quality, x = ~fixed.acidity, 
        y = ~volatile.acidity, z = ~citric.acid,
        symbol = ~type ,  symbols = c('x', 'o'),
        type = "scatter3d", marker = list(size = ~chlorides*50))
```

![图片较为杂乱，看不出太多有用信息](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/六维.png)

### 2.12 平行坐标图
图中横轴为各个特征，图中每条线代表一个样本点，不同颜色代表不同分类：

```R
ggparcoord(data = df, groupColumn = 13) + geom_line()
```

![很明显红葡萄酒在第1.2.8.9.10个变量取值较大，白葡萄酒在第3.4.5.6.7.11个变量的取值较大](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/平行坐标图.png)


### 2.13 热力图

将各变量之间的相关稀疏矩阵可视化为图形，图中颜色越红代表相关系数越大：

```R
# 可视化各变量之间的相关性
winedata_type_numeric = winedata
winedata_type_numeric$type = as.numeric(winedata$type)

# 获得相关矩阵的上三角元素
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}
cormat = round(cor(winedata_type_numeric),2)
upper_tri = get_upper_tri(cormat)

melted_cormat = melt(upper_tri, na.rm = TRUE)

ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()


```

![total.sulfur.dioxide(总二氧化硫浓度)、free.sulfur.dioxide(游离二氧化硫浓度)与type的相关系数最大](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/热力图.png)

## 3. 将多维数据映射到低维数据
### 3.1 PCA
利用PCA将高维数据降维到低维数据，最终选择两个主成分，观察主成分表达式可以得出这两个主成分分别代表游离二氧化硫和总二氧化硫的浓度、游离二氧化硫相对于总二氧化硫的浓度，这也与上述热力图的结果一致，分别作出两个type下作出两个主成分的散点图：

```R
df = winedata[, -13]
df_pca = princomp(x = df, cor = FALSE)
summary(df_pca, loadings = TRUE)
screeplot(df_pca, type="lines")

# 由碎石图可以看到 选择两个主成分比较好
new_df = data.frame(predict(df_pca)[, 1:2])
new_df$type = winedata$type
names(new_df)
# 第一个主成分表示游离二氧化硫和总二氧化硫的浓度
# 第二个主成分代表游离二氧化硫相对于总二氧化硫的浓度
# 说明white red 的差别主要在这两个方面，最主要在第一个方面


# 作图观察结果
fig = ggplot(data = new_df, 
             mapping = aes(x = Comp.1, y = Comp.2, color = type))
fig + geom_point(size = 2)
```

![两种葡萄酒在两个主成分下的分布差异明显，红葡萄酒二氧化硫浓度更高且集中](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/主成分.png)

### 3.2 t-SNE
t-SNE将数据点之间的相似度转换为概率，不仅关注局部信息，也关注全局信息，是一种高效的聚类和可视化方法：

```R
set.seed(1)

df = winedata[, -13]
tsne_result = Rtsne(df, check_duplicates = FALSE)
new_df = data.frame(tsne_result$Y, winedata$type)
fig = ggplot(data = new_df, 
             mapping = aes(x = X1, y = X2, color = winedata$type))
fig + geom_point(size = 2)
```

![两类数据被很好地分开，有少部分误差](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-8-31/tSne.png)

### 3.3 其他
还有一些其他的可视化方法，例如有监督的LDA、纯优化的方法等也可以取得很好的效果，参考https://zhuanlan.zhihu.com/p/36648647。



完整代码及数据见：https://github.com/stat-xwj/Multivariate-statistical-analysis/tree/master/visualization



