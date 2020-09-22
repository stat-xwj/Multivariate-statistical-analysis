
daytime = mytime[50]
df = subset(china_data, time == daytime)

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
p

df
head(df)

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




