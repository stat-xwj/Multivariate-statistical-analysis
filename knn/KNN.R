# ------------------------------------------------------
# ---- Theme: KNN  -------------------------------------
# ---- Author��xiawenjun -------------------------------
# -----Main Packages: class ----------------------------          
#------Date:2020-11-02-----------------------------------
# ------------------------------------------------------

library(class)

# ��ȡ����
mydata = read.table('C:/Users/xiawenjun/Desktop/����/Multivariate-statistical-analysis/knn/wdbc.data', 
                    sep = ',', header = FALSE)

# ���ݻ�����ʶ
head(mydata)
# ��һ��Ϊ��ţ�ɾ��
mydata = mydata[, -1]
str(mydata)
summary(mydata)

# ���ݹ�һ��
normalize = function(x){
  return((x-min(x))/(max(x)-min(x)))
}
X = data.frame(sapply(mydata[, 2:31], normalize))
Y = mydata[, 1]
table(Y)   # ���ݽ�Ϊ����
newmydata = cbind(Y, X)

# ����ѵ��������֤���Ͳ��Լ�
set.seed(0)
index = sample(x = 1:3,size = nrow(newmydata), replace = TRUE, prob = c(0.6,0.2,0.2))
train = newmydata[index == 1, ]
test = newmydata[index == 2, ]
valid = newmydata[index == 3, ]

?knn()
# ����֤��ȷ��k����
for (i in 1:round(sqrt(dim(train)[1]))){
  model = knn(train = train[, -1], test = valid[, -1], cl = train$Y, k = i)
  Freq = table(valid[, 1], model)
  cat('k=',i, '\t', 'error:', 1-sum(diag(Freq))/sum(Freq), '\n')
}

# choose k=6, ��Ӧ�ķ����������ͣ�Ϊ0.01785714 ����ȡk=6

fit = knn(train = train[, -1], test = test[, -1], cl = train$Y, k = 6)

#�鿴ģ��Ԥ����ʵ������������
Freq = table(test[, 1], fit)
sum(diag(Freq))/sum(Freq)



### KNN ��ά������
# ά�������Ժ� ���ݱ��ϡ�裬�Ҽ����ڳ�����ı�Ե�����¾�����жϱ���
library(MASS)

determinK = function(train, valid){
  min = 1
  minindex =1
  for (i in 1:round(sqrt(dim(train)[1]))){
    model = knn(train = train[, -1], test = valid[, -1], cl = train[, 1], k = i)
    Freq = table(valid[, 1], model)
    currerror = 1-sum(diag(Freq))/sum(Freq)
    if (currerror < min){
      minindex = i
      min = currerror
      }
  }
  return(minindex)
}

dimension = rep(1:50)*10
result = c(length(0))
for (i in 1:length(dimension)) {
  n = 1000
  p = dimension[i]
  mu = rep(0, p)
  Sigma = diag(p)
  set.seed(i)
  X = mvrnorm(n, mu, Sigma)
  Y = X %*% rnorm(p)
  Y = exp(Y)/(1+exp(Y))
  Y[Y>=0.5] = 1
  Y[Y<0.5] = 0
  
  data = data.frame(cbind(Y, X))
  data[, 1] = as.factor(data[, 1])
  
  index = sample(x = 1:3,size = nrow(X), replace = TRUE, prob = c(0.6,0.2,0.2))
  train = data[index == 1, ]
  test = data[index == 2, ]
  valid = data[index == 3, ]
  
  K = determinK(train, valid)
  fit <- knn(train = train[,-1], test = test[,-1], cl = train[, 1], k = K)
  Freq <- table(test[, 1], fit)
  
  result[i] = sum(diag(Freq))/sum(Freq)
  cat('p=',p,'accuracy',sum(diag(Freq))/sum(Freq), '\n')
  
}

plot(x=dimension, y=result, type = 'o', ylim = c(0.5, 0.9), ylab = 'accuracy')
abline(h = 0.5, col = "red")
