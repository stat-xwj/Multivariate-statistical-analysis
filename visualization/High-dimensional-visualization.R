# -----------------------------------------
# ---- Theme: 多维数据可视化 --------------
# ---- Author：xiawenjun ------------------
# -----Main Packages: ggplot2+GGally ------
#------Date:2020-8-29----------------------
# -----------------------------------------


# 从一维到多维
# 一维或者二维常见的可视化方法：
#       1. 柱状图
#       2. 散点图
#       3. 饼图 环形图
#       4. 折线图
#       5. 直方图，密度图
#       6. 箱线图
#       7. 热力图地图等
# 
# 多维的思路：
#       1. 单个维度或者两个维度展示 ---不交互
#       2. 多个维度直接展示 -----------有交互
#       3. 采用一些方法使多维映射到二维(to be continue...)

# ---------------------------------------------------------------
# ---------------------------------------------------------------

library(ggplot2)
library(reshape2)
library(GGally)
library(dplyr)
library(RColorBrewer)
library(plotly)
library(Rtsne)

winedata = read.csv('C:\\Users\\xiawenjun\\Desktop\\助教\\wine_data.csv', head=TRUE)
winedata = winedata[sample(length(winedata[, 1])), ]

head(winedata)
summary(winedata)

# 一、 单个变量独立展示
# 1.1 柱状图
# 对葡萄酒质量画柱状图 --离散
fig = ggplot(data = winedata, 
             mapping = aes(x = quality))
fig+geom_bar( )

# 1.2 直方图
fig = ggplot(data = winedata, 
             mapping = aes(x=volatile.acidity))
fig+geom_histogram()

# 密度估计
fig + geom_histogram(mapping = aes(y = ..density..), alpha = 0.6)+
  geom_line(stat = 'density', size = 1.1, color = 'red')


# 1.3 饼图
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


# 折线图 ---略过


# 二、两个及以上变量交互展示
# 2.1 散点图 -----------二维
# 两变量散点图
fig = ggplot(data = winedata, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity))
fig + geom_point(size = 1.5)

# 2.2 分组柱状图 -------二维
# 重新整理数据

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

# 2.3 箱线图 ---------------二维
fig = ggplot(data = winedata, 
             mapping = aes(x = quality, y = fixed.acidity, 
                           color = as.factor(quality)))
fig + geom_boxplot()

# 2.4 分组直方图 -----------二维
fig = ggplot(data = winedata, 
             mapping = aes(x = pH, fill = type))
fig + geom_histogram() 

# 另一方面，查看不同质量的酒不同物质的分布
fig = ggplot(data = winedata, 
             mapping = aes(x = fixed.acidity, color = as.factor(quality)))
fig + geom_line(size = 1.2, stat = "density")


# 2.5 分组散点图 -----------三维
fig = ggplot(data = winedata, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, color = type))
fig + geom_point(size = 2)

# 2.6 分组箱线图 ----------三维
fig = ggplot(data = winedata_quality_factor, 
             mapping = aes(x = quality, y = fixed.acidity, color = type))
fig + geom_boxplot()



# 更优雅的做法
# 散点图矩阵
pairs(winedata[, 1:5])

# 更好看的：
ggpairs(data = winedata, columns=7:12, aes(color=type))

# 2.7 空间散点
# 散点
plot_ly(data = winedata, size = 1, x = ~fixed.acidity, 
        y = ~ volatile.acidity, z = ~citric.acid, 
        type = "scatter3d", mode = "markers")
# 缺点：不够直观，有视觉误差

# 2.8 气泡图(三维)
df = winedata[sample(1000), ]
fig = ggplot(data = df, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, size = citric.acid))
fig + geom_point(shape = 21, color = "black", fill = "cornsilk")


# 2.8 四维数据
# 二维坐标+气泡图大小+气泡颜色
fig = ggplot(data = df, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, 
                           size = citric.acid, color = as.numeric(type)))
fig + geom_point() +scale_color_gradient(low="lightblue",high ="darkblue")


# 分类三维 坐标----------
plot_ly(data = winedata, size = 1, color = ~type, x = ~fixed.acidity, 
        y = ~volatile.acidity, z = ~citric.acid, 
        type = "scatter3d", mode = "markers")


# 2.9 五维数据
# 三维坐标+气泡颜色+气泡大小
plot_ly(data = df, color = ~type, 
        x = ~fixed.acidity, y = ~volatile.acidity, z = ~citric.acid, 
        type = "scatter3d", marker = list(size = ~chlorides*50))
#因为在这个函数中size的基础大小不可修改，所以只能将size移动到maker中

# 二维坐标+气泡图大小+气泡颜色+气泡形状

fig = ggplot(data = df, 
             mapping = aes(x = fixed.acidity, y = volatile.acidity, 
                           size = citric.acid, color = chlorides, shape = type))
fig + geom_point() + 
  scale_color_gradient(low="lightblue",high ="darkblue") + 
  scale_shape_manual(values = c(21,22)) 

# 2.9 六维
# 三维坐标+气泡颜色+气泡大小+气泡形状
plot_ly(data = df, color = ~quality, x = ~fixed.acidity, 
        y = ~volatile.acidity, z = ~citric.acid,
        symbol = ~type ,  symbols = c('x', 'o'),
        type = "scatter3d", marker = list(size = ~chlorides*50))




# 太糟糕，没有什么意义


# 2.10 其余的一些

# 平行坐标图 ------多维
# 横轴为各个特征，图中每条线代表一个样本点，不同颜色代表不同分类
ggparcoord(data = winedata, groupColumn = 13) + geom_line()
ggparcoord(data = df, groupColumn = 13) + geom_line()


# 热力图 -----多维
# 可视化各变量之间的相关性
winedata_type_numeric = winedata
winedata_type_numeric$type = as.numeric(winedata$type)


# 优化一下
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



# ---------------------------------------
# ----------------------------------------
# 简单过一下直接出结果


# 降维操作
# 无监督的PCA
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

# 无监督的t-SNE方法
set.seed(1)

df = winedata[, -13]
tsne_result = Rtsne(df, check_duplicates = FALSE)
new_df = data.frame(tsne_result$Y, winedata$type)
fig = ggplot(data = new_df, 
             mapping = aes(x = X1, y = X2, color = winedata$type))
fig + geom_point(size = 2)
# 还可以做得更精细


# 有监督的方法、基于深度学习的方法等 

# 关于mnist数据集的可视化--纯优化的角度
# https://zhuanlan.zhihu.com/p/36648647












