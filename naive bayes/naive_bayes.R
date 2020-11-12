# ------------------------------------------------------
# ---- Theme: naive bayes  -----------------------------
# ---- Author：xiawenjun -------------------------------
# -----Main Packages: tm e1071 -------------------------   
#------Date:2020-11-10----------------------------------
# ------------------------------------------------------


library(tm)
library(e1071)
library(class)
library(wordcloud2)

mydata = read.csv('C:/Users/xiawenjun/Desktop/助教/Multivariate-statistical-analysis/naive bayes/spamdata_T2.csv', header = FALSE)
head(mydata)

names(mydata) = c('label', 'contents')
table(mydata$label)

############# funciont get.tdm  ###################
# target: 获取词频矩阵
# method: 通过tm包中携带的函数获取一系列文本的词频矩阵
# arguments: vector 文本数组
# return: matrix 词频数组

doc = mydata[1:nrow(mydata), 2]

# 构建语料库
doc_corpus = Corpus(VectorSource(doc))
doc_corpus[['1']]
doc_corpus[['1']]$content
doc_corpus[['1']]$meta

# 构建词频矩阵
# 确定分词标准，可以有自己的停用词库等
control = list(stopwords = TRUE, removePunctuation = TRUE, 
               removeNumbers = TRUE, minDocFreq = 1)
doc_tdm = TermDocumentMatrix(doc_corpus, control)
word_matrix = t(as.matrix(doc_tdm) )      #词文本矩阵，即这个词在某个文本中出现的次数 

ncol(word_matrix); nrow(word_matrix)
word_matrix[1:3, 1:3]


# 绘制词云
wordCloudPlot = function(word_matrix){
  word_counts = colSums(word_matrix) #每一列和，即单词在所有文本中出现的总次数
  
  word_counts = data.frame(cbind(names(word_counts), as.numeric(word_counts)))
  
  names(word_counts) = c('word','freq')
  
  word_counts[, 2] = as.numeric(word_counts[, 2])
  
  # head(word_counts)
  
  # word_counts[186, 1]   # 非UTF-8编码
  
  for (i in 1:nrow(word_counts)) {
    word_counts[i, 1] = iconv(word_counts[i, 1], "UTF-8", "UTF-8",sub='') # replace any non UTF-8 by ''
  }

  wordcloud2(word_counts, minRotation = -pi/2, maxRotation = -pi/2)  # 词云
  
}

# 绘制总的词云
wordCloudPlot(word_matrix)

# 看一下正常短信和垃圾短信的词频有没有什么区别
spam_index = (mydata$label == 'spam')
word_matrix_spam = word_matrix[spam_index, ]
word_matrix_ham = word_matrix[-spam_index, ]

wordCloudPlot(word_matrix_spam)
wordCloudPlot(word_matrix_ham)

# 发现一个bug，有的短信文本所有词频数均为零
# 直接删除
noZeroIndex = (rowSums(word_matrix) != 0)
word_matrix = word_matrix[noZeroIndex, ]
nrow(word_matrix);ncol(word_matrix)

####  特征筛选
# 特征工程
# 根据相关系数筛选重要的特征
data_words_count = cbind(mydata$label[noZeroIndex], data.frame(word_matrix))
names(data_words_count)[1] = 'label'

data_words_count[1:3, 1:10]

Y = data_words_count$label

Y[Y == 'ham'] = 0
Y[Y == 'spam'] = 1
Y = as.numeric(Y)

SIS = abs(apply(data_words_count[, 2:ncol(data_words_count)], 2, function(x){return(cor(x, Y))}))

good_word = sort(SIS, decreasing = TRUE)[1:50]
data.frame(good_word)


newmydata = data_words_count[, names(good_word)]
newmydata = cbind(as.factor(data_words_count$label), newmydata)
names(newmydata)[1] = 'label'


table(newmydata$label)   # 数据不平衡 很多分类算法都失效


# 建立模型
set.seed(1)
index = sample(x = 1:2,size = nrow(newmydata), replace = TRUE, prob = c(0.7,0.3))
train = newmydata[index == 1, ]
test = newmydata[index == 2, ]

# 朴素贝叶斯
?naiveBayes
naiveBayes.model = naiveBayes(label ~ ., data = train, laplace = 0)
train_predict = predict(naiveBayes.model, train)
train_table = table(actual = train$label, predict = train_predict)

test_predict = predict(naiveBayes.model, test)
test_table = table(actual = test$label, predict = test_predict)

cat('train accuracy:', sum(diag(train_table)/sum(train_table)), '\n', 'test accuracy:', sum(diag(test_table)/sum(test_table)))

test_table

# 精确率和召回率
cat('precision:', test_table[2, 2]/(test_table[1, 2] + test_table[2, 2]), '\n',  # 针对预测结果,在所有预测结果为spam的样本中，预测正确的概率有多少
    'recall:', test_table[2, 2]/(test_table[2, 1] + test_table[2, 2]))           # 针对原始样本，在真实为spam的样本中，预测正确的概率有多少

# 虽然准确率很高，但是precision和recall都很低

# 
# # KNN 失效
knn(train = train[, -1], test = test[, -1], cl = train[, 1], k = 10, use.all = FALSE)
# 
# 
# # How about tf-idf
# 
TF = word_matrix/rowSums(word_matrix)
IDF = apply(word_matrix, 2, function(x){return((log(nrow(word_matrix)/length(x[x != '0']))))})
TF_IDF = t(apply(TF, 1, function(x){return(x*IDF)}))

data_words_TFIDF = cbind(mydata$label[noZeroIndex], data.frame(TF_IDF))
names(data_words_TFIDF)[1] = 'label'
SIS = abs(apply(data_words_TFIDF[, 2:ncol(data_words_TFIDF)], 2, function(x){return(cor(x, Y))}))

good_word = sort(SIS, decreasing = TRUE)[1:50]

newmydata = data_words_TFIDF[, names(good_word)]
newmydata = cbind(as.factor(data_words_TFIDF$label), newmydata)
names(newmydata)[1] = 'label'


# 建立模型
set.seed(1)
index = sample(x = 1:2,size = nrow(newmydata), replace = TRUE, prob = c(0.7,0.3))
train = newmydata[index == 1, ]
test = newmydata[index == 2, ]

# 朴素贝叶斯
?naiveBayes
naiveBayes.model = naiveBayes(label ~ ., data = train, laplace = 0)
train_predict = predict(naiveBayes.model, train)
train_table = table(actual = train$label, predict = train_predict)

test_predict = predict(naiveBayes.model, test)
test_table = table(actual = test$label, predict = test_predict)

cat('train accuracy:', sum(diag(train_table)/sum(train_table)), '\n', 'test accuracy:', sum(diag(test_table)/sum(test_table)))

test_table

# 精确率和召回率
cat('precision:', test_table[2, 2]/(test_table[1, 2] + test_table[2, 2]), '\n',  # 针对预测结果
    'recall:', test_table[2, 2]/(test_table[2, 1] + test_table[2, 2]))           # 针对原始样本

# 结果更差了，但这是一种很常见的文本数据处理方法

# 其他可以尝试更好的词向量构建 word2vec autoencoder等等...


# 参考
# https://blog.csdn.net/clebeg/article/details/41015185




