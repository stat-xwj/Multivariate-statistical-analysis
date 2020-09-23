# ------------------------------------------------------
# ---- Theme: an introduction to ggplot2  --------------
# ---- Author：xiawenjun -------------------------------
# -----Main Packages: ggplot2+GGally -------------------
#------Date:2020-9-19-----------------------------------
# ------------------------------------------------------

# 
# ggplot2 是R中一个常见的作图包，其有几个重要的理念：
#   1. 将绘图与数据相分离
#   2. 按照图层作图
# 
# ggplot2 常见的层：
#   1. 数据层  ggplot()
#   2. 几何图形层  geom_line(), geom_point()
#   3. 美学层  labs(), guides(), theme()
# 
# 映射的概念：
#   aes() 将数据集中的数据关联到相应的图形属性过程中一种对应关系

# 常见的步骤/格式
ggplot(data, aes(x = , y = , )) +    # 添加数据 
  geom_xxx() +                       # 添加图形
  geom_xxx() +                       # 可能会添加多个图形
  annotate() +                       # 添加标注 
  labs() +                           # 添加坐标轴、标题、副标题等
  guides() +                         # 修改默认图例
  theme() +                          # 全局修改主题，例如字体、背景色等
# 

# 数据准备
library(ggplot2)
winedata = read.csv('C:\\Users\\xiawenjun\\Desktop\\助教\\Multivariate-statistical-analysis\\ggplot2\\wine_data.csv', head=TRUE)
winedata = winedata[sample(nrow(winedata)), ]
head(winedata)
summary(winedata)


# 一 散点图
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point() 
 

# 如何更改散点的颜色？
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(aes(color = 'darkblue'))


# 特别注意！！
# 这里如果把color写在了aes里面结果是错误的
# Reason：映射关系，aes映射函数中将color这个变量映射到’darkblue‘这个字符串，由于该字符串
#         不表示具体一个颜色，系统将自动为它分配一个颜色
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 1.5, color = 'darkblue')


# 考虑如何分组作散点图？
# 颜色、大小、形状、透明度等
# 仍然采用映射关系
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 3, aes(color = type))  


ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 3, aes(color = type, shape = type))


# 如何修改默认分配的颜色？
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 3, aes(color = type, shape = type)) + 
  scale_color_manual(values = c("#E69F00", "#999999")) + 
  scale_shape_manual(values = c(15, 19)) 
# 如果要分组的变量是连续的，应该设置 scale_color_gradient(low="",high ="")



# 添加坐标轴和标题
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 3, aes(color = type, shape = type)) + 
  scale_color_manual(values = c("#E69F00", "#999999")) + 
  scale_shape_manual(values = c(15, 19)) + 
  labs(x = 'concentration of fixed.acidity', 
       y = 'concentration of violatile.acidity', 
       title = 'scatter plot of fixed.acidity and violatile.acidity by type')


ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 3, aes(color = type, shape = type)) + 
  scale_color_manual(values = c("#E69F00", "#999999"), 
                     labels=c("red wine", "white wine")) + 
  scale_shape_manual(values = c(15, 19), labels=c("red wine", "white wine")) + 
  labs(x = 'concentration of fixed.acidity', 
       y = 'concentration of violatile.acidity', 
       title = 'scatter plot of fixed.acidity and violatile.acidity by type') + 
  theme(
    # title居中
    plot.title = element_text(hjust = 0.5, family="mono", face = 'bold'),
    # 坐标轴标签字体变大
    axis.title.x = element_text(size = 15), 
    axis.title.y = element_text(size = 15), 
    # 坐标轴刻度字体变大加粗
    axis.text.x = element_text(size = 12, face = 'bold'), 
    axis.text.y = element_text(size = 12, face = 'bold'), 
    # 图例字体大小
    legend.text = element_text(size=12), 
    # 图例标题
    legend.title = element_blank(), 
    # 图例位置
    legend.position = 'top',
    panel.background = element_rect(colour = "black", size = 2), 
)


# 添加标识
ggplot(data = winedata, aes(x = fixed.acidity, 
                            y = volatile.acidity)) + 
  geom_point(size = 3, aes(color = type, shape = type)) + 
  scale_color_manual(values = c("#E69F00", "#999999"), labels=c("red wine", "white wine")) + 
  scale_shape_manual(values = c(15, 19), labels=c("red wine", "white wine")) + 
  labs(x = 'concentration of fixed.acidity', 
       y = 'concentration of violatile.acidity', 
       title = 'scatter plot of fixed.acidity and violatile.acidity by type') + 
  theme(
    # title居中
    plot.title = element_text(hjust = 0.5, family="mono", face = 'bold'),
    # 坐标轴标签字体变大
    axis.title.x = element_text(size = 15), 
    axis.title.y = element_text(size = 15), 
    # 坐标轴刻度字体变大加粗
    axis.text.x = element_text(size = 12, face = 'bold'), 
    axis.text.y = element_text(size = 12, face = 'bold'), 
    # 图例字体大小
    legend.text=element_text(size=12), 
    # 图例标题
    legend.title=element_blank(), 
    # 图例位置
    legend.position = 'top',
    panel.background = element_rect(colour = "black", size = 2), 
  ) + 
  annotate(geom = 'rect',             # 方形区域
           xmin = 6, xmax =10,        # 
           ymin = 1.2, ymax = 1.6,    # 坐标范围
           fill = 'red', alpha = 0.2) + # 填充为红色，透明度为0.2
  # 添加箭头，不建议在annotate中添加箭头，方向不好控制
  geom_segment(aes(x = 12, y = 1.4, xend = 10, yend = 1.3),
               size = 1, 
               arrow = arrow(angle = 20, length = unit(4, "mm"))) + 
  # 添加文字
  annotate(geom = 'text', 
           x = 13.5, y = 1.4, size = 5, 
           label = 'low fixed.acidity but \n high violatile.acidity')


# 二 直方图
ggplot(data = winedata, 
       aes(x = volatile.acidity)) + 
  geom_histogram(bins = 50, alpha = 0.6, fill = 'steelblue', 
                 colour = 'black')



ggplot(data = winedata, 
       aes(x = volatile.acidity)) + 
  geom_histogram(bins = 50, alpha = 0.6, fill = 'steelblue', colour = 'black') + 
  geom_density(color = 'red', size = 1.5)

# 密度函数的范围比y轴的范围小, 在一张图里显示不出来
# 需要用map映射一下 将y的尺度映射到density的尺度

ggplot(data = winedata, 
       aes(x = volatile.acidity)) + 
  geom_histogram(bins = 50, 
                 mapping = aes(y = ..density..), 
                 alpha = 0.6, fill = 'steelblue', colour = 'black')+
  geom_line(stat = 'density', size = 1.1, color = 'red')















# 三 地图

# 新冠疫情
# 下载安装包 https://api.github.com/repos/GuangchuangYu/nCov2019/tarball/HEAD
# cmd进入R安装路径下的bin/x64 文件夹
# 运行 Rcmd.exe INSTALL C:\Users\xiawenjun\Downloads\nCov2019-218c30f.tar.gz

library(nCov2019)
library(maptools)
library(dplyr)
library(ggplot2)
# --------------------------------
library(lubridate)

x = load_nCov2019()
data_province = summary(x)
head(data_province)
data_province = data.frame(time = data_province$time,  
                           NAME = data_province$province, 
                           cum_confirm = data_province$cum_confirm)
head(data_province)
tail(data_province)
# 把数据分成几类
data_province$Group = cut(data_province$cum_confirm, 
                          breaks=  c(0,1,10,50,100,500,1000,5000,100000), 
                          labels = c("0","1-9","10-49","50-99","100-499","500-999","1000-4999",">=5000"), 
                          order = TRUE,
                          include.lowest = TRUE, 
                          right = TRUE) 
head(data_province)
tail(data_province)

# ymd 将字符串解析为时间
startTime = ymd("2019-12-01")
nowTime = Sys.time()
endTime = date(nowTime) - ddays(2)
timeLength = interval(startTime, endTime) %>% time_length("day")
mytime = startTime + ddays(0:timeLength)
mytime


# 地图
setwd('C:\\Users\\xiawenjun\\Desktop\\助教\\Multivariate-statistical-analysis\\ggplot2\\china_basic_map')
china_map = readShapePoly("bou2_4p.shp")

# 建立地图格点数据
x1 = china_map@data          
xs = data.frame(x1, id=seq(0:923)-1)
# 将地理信息文件转换为data.frame格式数据
china_map1 = fortify(china_map) 
china_map1$id = as.integer(china_map1$id)
china_map_data = full_join(china_map1, xs)  
head(china_map_data)

# map中的省份名和data_province中的省份名不一样，修改一下使得一一对应
# mutate 添加一列
china_map_data = china_map_data %>%
  mutate(NAME = substr(NAME, 1, 2))
china_map_data[which(china_map_data$NAME == '黑龙'), ]$NAME = '黑龙江'
china_map_data[which(china_map_data$NAME == '内蒙'), ]$NAME = '内蒙古'
head(china_map_data)
head(data_province)

# 将map数据与data_province数据连接起来
# 全连接方法参照sql语法
china_data = full_join(china_map_data, data_province) 
head(china_data)
# 删除不重要的列
china_data = china_data[ , -which(colnames(china_data) 
                                  %in% c('order', 'hole', 'piece', 'AREA', 'PERIMETER', 
                                         'BOU2_4M_', 'BOU2_4M_ID', 'ADCODE93', 'ADCODE99' ))]
head(china_data)

covid_plot = function(china_data, daytime){
  
  # 选择特定时期的数据
  df = subset(china_data, time == daytime)
  
  # 修改
  # df = df_prepare(china_map_data, df)
  
  # 以group填充
  p = ggplot(data = df, aes(x = long, y = lat, 
                            group = group, fill = Group)) + 
    geom_polygon(colour = 'Black') + 
    coord_map('polyconic') + 
    scale_fill_brewer(palette = 'OrRd') + 
    # scale_color_manual(values = c("#E69F00", "#999999", 'red')) + 
    labs(title = '新冠疫情累计确诊', 
         subtitle = daytime, 
         x = '', 
         y = '') + 
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(face = "bold", hjust = 0.5, size = 15, color = "red"),
      legend.title = element_text(face = 'bold'), 
      legend.text = element_text(face = "bold",color = "black"),
      legend.background = element_rect(colour = "black"),
      legend.key = element_rect(fill = NA),
      legend.position = 'right',
      panel.border = element_rect(color = "black", linetype = "solid", size = 1, fill = NA) 
    ) + 
    guides(fill=guide_legend(title='累计确诊量'))
  
  # 保存图片
  ggsave(filename = paste(sep = '', daytime, '.png'), 
         plot = p, 
         path = 'C:\\Users\\xiawenjun\\Desktop\\助教\\\\Multivariate-statistical-analysis\\ggplot2\\covid', 
         width = 20, height = 20, units = 'cm')
}





for (i in seq(1, length(mytime), 3)) {
  daytime = mytime[i]
  covid_plot(china_data, daytime)
}

# 动态渲染

# 先读取文件夹下所有的图片
setwd('C:\\Users\\xiawenjun\\Desktop\\助教\\Multivariate-statistical-analysis\\ggplot2\\covid_now')
# 获取文件名
filename = list.files(pattern="*.png")

library(magick)
library(gganimate)
animate_p = image_animate(image = image_read(
  path = filename))
# 保存gif
anim_save(filename = "现存确诊.gif",animation = animate_p)

# ---------------------------------

# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
# -------------------------------------------------------------------------
# Question ----
# 思考上述过程有没有什么问题？
#---- 由于在subset过程只会提取存在疫情点的地区，不存在疫情的地区不会再图中展示出来
#可以试图作出2019.12.1号开始的图像可以发现此问题
#------------------------
#-----如何解决？---------

#---扩充数据
#将每个时间点每个地区的数据补充完整，就算疫情为0那也要在数据中加上
#这个过程不难，但是可能扩充后数据会很大，同学们可以试试。
#同样也可以尝试作出单个省份的图像和世界地图


# 还有个bug 2020-09-08 2020-09-17 没有数据


add_zero_province = function(china_map_data, df, provincename){
  df_new = china_map_data[which(china_map_data$NAME == provincename), ]
  # 只选择有用的列
  df_new = df_new[, which(colnames(df_new) %in% c('long', 'lat', 'id', 'group', 'NAME'))]
  # 添加时间列
  n = nrow(df_new)
  daytime = df$time[1]
  df_new$time = rep(daytime, n)
  # 添加数据列
  df_new$data_name = rep(0, n)
  names(df_new)[ncol(df_new)] = names(df)[7]
  # 添加Group列
  df_new$Group = rep('0', n)
  
  head(df_new)
  return (rbind(df, df_new))
}


add_not_exist_province = function(china_map_data, df){
  total_province = data.frame(table(china_map_data$NAME))[, 1]
  total_province = as.character(total_province)
  exist_province = data.frame(table(df$NAME))[, 1]
  exist_province = as.character(exist_province)
  
  not_exist = total_province %in% exist_province
  not_exist_province = total_province[not_exist == FALSE]
  
  for (provincename in not_exist_province) {
    df = add_zero_province(china_map_data, df, provincename)
  }
  return(df)
}

add_point_for_legend = function(df){
  # 一种非常愚蠢的解决方法....
  # 将不同尺度的点都添加一个
  sample_data = sample(1:nrow(df))
  df[sample_data[1], 8] = '0'
  df[sample_data[2], 8] = '1-9'
  df[sample_data[3], 8] = "10-49"
  df[sample_data[4], 8] = "50-99"
  df[sample_data[5], 8] = "100-499"
  df[sample_data[6], 8] = "500-999" 
  df[sample_data[7], 8] = "1000-4999"
  df[sample_data[8], 8] = ">=5000"   
  return(df)
}

df_prepare = function(china_map_data, df){
  df = add_not_exist_province(china_map_data, df)
  df = add_point_for_legend(df)
  return(df)
}


## 主要参考 https://zhuanlan.zhihu.com/p/115480483

