# discriminiant
# 距离判别
setwd('C:\\Users\\xiawenjun\\Desktop\\助教\\Multivariate-statistical-analysis\\discriminant')
source('discriminiant.distance.R')
classX1<-data.frame(
  x1=c(6.60,  6.60,  6.10,  6.10,  8.40,  7.2,   8.40,  7.50,  
       7.50,  8.30,  7.80,  7.80),
  x2=c(39.00, 39.00, 47.00, 47.00, 32.00,  6.0, 113.00, 52.00,
       52.00,113.00,172.00,172.00),
  x3=c(1.00,  1.00,  1.00,  1.00,  2.00,  1.0,   3.50,  1.00,
       3.50,  0.00,  1.00,  1.50),
  x4=c(6.00,  6.00,  6.00,  6.00,  7.50,  7.0,   6.00,  6.00,
       7.50,  7.50,  3.50,  3.00),
  x5=c(6.00, 12.00,  6.00, 12.00, 19.00, 28.0,  18.00, 12.00,
       6.00, 35.00, 14.00, 15.00),
  x6=c(0.12,  0.12,  0.08,  0.08,  0.35,  0.3,   0.15,  0.16,
       0.16,  0.12,  0.21,  0.21),
  x7=c(20.00, 20.00, 12.00, 12.00, 75.00, 30.0,  75.00, 40.00,
       40.00,180.00, 45.00, 45.00)
)
classX2<-data.frame(
  x1=c(8.40,  8.40,  8.40,  6.3, 7.00,  7.00,  7.00,  8.30,
       8.30,   7.2,   7.2,  7.2, 5.50,  8.40,  8.40,  7.50,
       7.50,  8.30,  8.30, 8.30, 8.30,  7.80,  7.80),
  x2=c(32.0 ,32.00, 32.00, 11.0, 8.00,  8.00,  8.00, 161.00,
       161.0,   6.0,   6.0,  6.0, 6.00,113.00,113.00,  52.00,
       52.00, 97.00, 97.00,89.00,56.00,172.00,283.00),
  x3=c(1.00,  2.00,  2.50,  4.5, 4.50,  6.00,  1.50,  1.50,
       0.50,   3.5,   1.0,  1.0, 2.50,  3.50,  3.50,  1.00,
       1.00,  0.00,  2.50, 0.00, 1.50,  1.00,  1.00),
  x4=c(5.00,  9.00,  4.00,  7.5, 4.50,  7.50,  6.00,  4.00,
       2.50,   4.0,   3.0,  6.0, 3.00,  4.50,  4.50,  6.00,
       7.50,  6.00,  6.00, 6.00, 6.00,  3.50,  4.50),
  x5=c(4.00, 10.00, 10.00,  3.0, 9.00,  4.00,  1.00,  4.00,
       1.00,  12.0,   3.0,  5.0, 7.00,  6.00,  8.00,  6.00,
       8.00,  5.00,  5.00,10.00,13.00,  6.00,  6.00),
  x6=c(0.35,  0.35,  0.35,  0.2, 0.25,  0.25,  0.25,  0.08,
       0.08,  0.30,   0.3,  0.3, 0.18,  0.15,  0.15,  0.16,
       0.16,  0.15,  0.15, 0.16, 0.25,  0.21,  0.18),
  x7=c(75.00, 75.00, 75.00,  15.0, 30.00, 30.00, 30.00, 70.00,
       70.00,  30.0,  30.0,  30.0, 18.00, 75.00, 75.00, 40.00,
       40.00,180.00,180.00,180.00,180.00, 45.00, 45.00)
)
# discriminiant.distance
results = discriminiant.distance(classX1, classX2, var.equal=TRUE)
table(results, c(rep(1, nrow(classX1)),rep(2, nrow(classX2))))
results = discriminiant.distance(classX1, classX2)
table(results, c(rep(1, nrow(classX1)),rep(2, nrow(classX2))))


# 多分类
source("distinguish.distance.R")
X<-iris[,1:4]
G<-gl(3,50)
results = distinguish.distance(X,G)
table(results, G)



# bayes 判别
TrnX1<-matrix(
  c(24.8, 24.1, 26.6, 23.5, 25.5, 27.4, 
    -2.0, -2.4, -3.0, -1.9, -2.1, -3.1),
  ncol=2)
TrnX2<-matrix(
  c(22.1, 21.6, 22.0, 22.8, 22.7, 21.5, 22.1, 21.4, 
    -0.7, -1.4, -0.8, -1.6, -1.5, -1.0, -1.2, -1.3),
  ncol=2)
source("discriminiant.bayes.R")
#### 样本协方差相同
results = discriminiant.bayes(TrnX1, TrnX2, rate=8/6, var.equal=TRUE)
table(results, c(rep(1, nrow(TrnX1)),rep(2, nrow(TrnX2))))

#### 样本协方差不同
# rate 为第二类比上第一类的先验 即p2/p1
results = discriminiant.bayes(TrnX1, TrnX2, rate=8/6)
table(results, c(rep(1, nrow(TrnX1)),rep(2, nrow(TrnX2))))

# 多分类bayes
X<-iris[,1:4]
G<-gl(3,50)
source("distinguish.bayes.R")
results = distinguish.bayes(X,G)
table(results, G)


# fisher判别
# 对第一个例子进行fisher判别
source("discriminiant.fisher.R")
results = discriminiant.fisher(classX1, classX2)
table(results, c(rep(1, nrow(classX1)),rep(2, nrow(classX2))))





