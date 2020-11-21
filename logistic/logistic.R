# ------------------------------------------------------
# ---- Theme: LR and multi anova  ----------------------
# ---- Author：xiawenjun -------------------------------
# -----Main Packages: nnet ----------------------------- 
#------Date:2020-11-17----------------------------------
# ------------------------------------------------------

library(nnet)

winedata = read.csv('C:\\Users\\xiawenjun\\Desktop\\助教\\Multivariate-statistical-analysis\\ggplot2\\wine_data.csv', head=TRUE)
winedata = winedata[sample(nrow(winedata)), ]
head(winedata)
summary(winedata)

mydata = winedata
mydata$type[mydata$type == 'red'] = 1
mydata$type[mydata$type == 'white'] = 0
mydata$type = as.numeric(mydata$type)


# logistic 拟合
# 建立模型
set.seed(1)
index = sample(x = 1:2,size = nrow(mydata), replace = TRUE, prob = c(0.7,0.3))
train = mydata[index == 1, ]
test = mydata[index == 2, ]
logistic.model = glm(type~., data = train, family = binomial(link = 'logit'))

train_predict = predict(logistic.model, train, type='response')
train_predict = ifelse(train_predict>0.5, 1, 0)
train_table = table(actual = train$type, pre = train_predict)

test_predict = predict(logistic.model, test, type='response')
test_predict = ifelse(test_predict>0.5, 1, 0)
test_table = table(actual = test$type, pre = test_predict)

cat('train accuracy:', sum(diag(train_table)/sum(train_table)), '\n', 
    'test accuracy:', sum(diag(test_table)/sum(test_table)))


# 手动写一下logistic
# 梯度下降法
logisticGradientDescent = function(input_data, maxIterion, epslion, learningRate){
  # input_data最后一列为标签
  eita = learningRate
  
  p = ncol(input_data); n = nrow(input_data)
  
  # 添加截距项
  X = input_data[, -p]
  intercpt = rep(1, n)
  
  X = as.matrix(cbind(intercpt, X))
  Y = input_data[, p]
  
  # 初始权重
  w = rep(0, p)
  k = 0
  
  repeat{
    # print(k)
    # 计算概率
    px = exp(X %*% w)/(1+exp(X %*% w))
    # 计算梯度
    gradient = (t(X) %*% (px-Y))/n
    
    # 权重更新
    w = w-eita*gradient
    k = k+1
    
    if(k > maxIterion){
      cat('I have reached my maxiterions, and still not converge')
      break
    }
    if(max(abs(eita*gradient)) < epslion){
      cat('After',k, 'iterions, I have been converged!')
      break
    }
  }
  return(w)
}

w = logisticGradientDescent(input_data = train, maxIterion = 1e5, epslion = 1e-5, learningRate = 0.0001)

# 评估准确率
p = ncol(train)
X_train = as.matrix(cbind(rep(1, nrow(train)), train[, -p]))
train_predict = exp(X_train %*% w)/(1+exp(X_train %*% w))
train_predict = ifelse(train_predict>0.5, 1, 0)
train_table = table(train_predict, train$type)
sum(diag(train_table))/sum(train_table)

X_test = as.matrix(cbind(rep(1, nrow(test)), test[, -p]))
test_predict = exp(X_test %*% w)/(1+exp(X_test %*% w))
test_predict = ifelse(test_predict>0.5, 1, 0)
test_table = table(test_predict, test$type)
sum(diag(test_table))/sum(test_table)

cat('train accuracy:', sum(diag(train_table)/sum(train_table)), '\n', 
    'test accuracy:', sum(diag(test_table)/sum(test_table)))


# 牛顿迭代
logisticNewton = function(input_data, maxIterion, epslion){
  p = ncol(input_data); n = nrow(input_data)
  
  # 添加截距项
  X = input_data[, -p]
  intercpt = rep(1, n)
  
  X = as.matrix(cbind(intercpt, X))
  Y = input_data[, p]
  
  w = rep(0, p)
  k = 0
  repeat{
    # print(k)
    # 计算概率
    px = 1/(1+exp(-X %*% w))
    
    # 计算二阶导
    gra1 = px * (1-px)
    gra2 = apply(X, 2, function(x){x*gra1})
    Hessian = (t(X) %*% gra2)/n
    gradient = (t(X) %*% (px-Y))/n
    
    # 计算变动值
    change = solve(Hessian)%*%gradient
    
    # 更新权重
    w = w - change
    
    k = k+1
    
    if(k > maxIterion){
      cat('I have reached my maxiterions, and still not converge')
      break
    }
    if(max(abs(change)) < epslion){
      cat('After',k, 'iterions, I have been converged!')
      break
    }
  }
  return(w)
}

w = logisticNewton(input_data = train, maxIterion = 1e5, epslion = 1e-5)

#和使用库函数得到的结果完全一致。
logistic.model$coefficients

# 多分类logit回归
# 建立模型
mydata = iris
set.seed(1)
index = sample(x = 1:2,size = nrow(mydata), replace = TRUE, prob = c(0.7,0.3))
train = mydata[index == 1, ]
test = mydata[index == 2, ]
multilogistic_model = multinom(Species~., data = train)

train_predict = predict(multilogistic_model, train, type='class')
train_table = table(actual = train$Species, pre = train_predict)

test_predict = predict(multilogistic_model, test, type='class')
test_table = table(actual = test$Species, pre = test_predict)


###########################################
###########################################
# 多元方差分析
mydata = read.table('C:/Users/xiawenjun/Desktop/助教/Multivariate-statistical-analysis/logistic/Body.txt', header = F)
colnames(mydata) = c('X1', 'X2', 'X3', 'X4', 'Y')
Y = as.factor(mydata$Y)
X = as.matrix(mydata[, 1:4])

?manova

# H0 各组均值向量相等
anova_model = manova(X~Y)
summary(anova_model, test = 'Wilks')

# 拒绝原假设，表明，方差有差异，再单独看哪个分量有差异
#对每个分量单独做方差分析
summary.aov(anova_model)

# 自己手动算一下
V1 = X[Y == 1, ]
V2 = X[Y == 2, ]
V3 = X[Y == 3, ]

# 组内离差阵
SSA = (nrow(V1)-1)*var(V1) + (nrow(V2)-1)*var(V2) + (nrow(V3)-1)*var(V3)



# 组间离差阵
SSB = nrow(V1)*(colMeans(V1)-colMeans(X)) %*% t(colMeans(V1)-colMeans(X)) + 
  nrow(V2)*(colMeans(V2)-colMeans(X)) %*% t(colMeans(V2)-colMeans(X)) + 
  nrow(V3)*(colMeans(V3)-colMeans(X)) %*% t(colMeans(V3)-colMeans(X))

# wilks统计量
Wilks = det(SSA)/det(SSA+SSB)

# 转化为F分布
# 由于p=4,r=3, n-r=57, 则wilks~lambda(4, 57, 2)
n = nrow(mydata)
r = 3
p = 4
f = ((n-2-p)/p)*((1-sqrt(Wilks))/sqrt(Wilks))

# f~F(2p, 2(n-2-p))
df1 = 2*p; df2 = 2*(n-2-p)

p = pf(f, df1, df2)
1-p







# how about minibatch
# epslion = 1e-4
# eita = 0.05
# 
# input_data = train
# p = ncol(input_data); n = nrow(input_data)
# X = input_data[, -p]
# intercpt = rep(1, n)
# 
# X = as.matrix(cbind(intercpt, X))
# 
# Y = input_data[, p]
# 
# 
# w = rep(0, p)
# batchsize = 50
# Epoch = 10000
# flag = 0
# for (epoch in 1:Epoch) {
#   
#   set.seed(epoch)
#   index = sample(1:n, replace = FALSE)
#   X = X[index, ]
#   Y = Y[index]
#   
#   for (i in 1:round(n/batchsize)) {
#     Xt = X[((i-1)*batchsize+1):(i*batchsize), ]
#     Yt = Y[((i-1)*batchsize+1):(i*batchsize)]
#     
#     px = exp(Xt %*% w)/(1+exp(Xt %*% w))
#     gradient = (t(Xt) %*% (px-Yt))/batchsize
#     
#     w = w-eita*gradient
#     # if(max(abs(eita*gradient)) < epslion){
#     #   flag = 1
#     #   break}
#     # if(flag == 1){break}
#   }
# }
# 
# train_predict = exp(X %*% w)/(1+exp(X %*% w))
# train_predict = ifelse(train_predict>0.5, 1, 0)
# train_table = table(train_predict, train$type)
# sum(diag(train_table))/sum(train_table)
# 
# X_test = as.matrix(cbind(rep(1, nrow(test)), test[, -p]))
# test_predict = exp(X_test %*% w)/(1+exp(X_test %*% w))
# test_predict = ifelse(test_predict>0.5, 1, 0)
# test_table = table(test_predict, test$type)
# sum(diag(test_table))/sum(test_table)
# 
# cat('train accuracy:', sum(diag(train_table)/sum(train_table)), '\n', 
#     'test accuracy:', sum(diag(test_table)/sum(test_table)))
# 
# 
# 
# 

