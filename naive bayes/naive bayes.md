
文中使用数据为短信文本数据，共有正常短信文本(ham)4305条，垃圾短信文本(spam)668条，本文的目的为建立分类器判别未知的短信文本类型。首先，对于短信文本，将其数值化处理，计算词频，最后可以一个词频矩阵。

```r
library(tm)
library(e1071)
library(class)
library(wordcloud2)

mydata = read.csv('C:/spamdata_T2.csv', header = FALSE)
head(mydata)

names(mydata) = c('label', 'contents')
table(mydata$label)

############# funciont get.tdm  ###################

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
word_matrix[1:3, 1:5]
```
通过上述过程，可以得到一个维数为4973$*$7823 的词频矩阵，部分如下所示，其中每一行代表每个文本，每一列代表分词，表中的数字代表词语在该文本中出现的次数。

|     | amore  | crazy  | buffet  |bugis|cine
|  ----  | ----  |   ----  | ----  | ----  | ----  |
|  1   | 1  | 1  | 1  |1  | 1  | 1  |
|  2   | 0  | 0  | 0  |0  | 0  | 0  |
|  3   | 0  | 0  | 0  |0  | 0  | 0 |

接下来，绘制词云图。

```r
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
```

![所有词语的词频图，图中字体越大，代表该词出现的频率越高](https://cdn.jsdelivr.net/gh/stat-xwj/weixin/2020-11-12/1605154292642-Rplot.png)

由于共有词语7824个，但文本只有4944个，需要进行特征筛选。本文采用计算各个词频向量与因变量之间的pearson边际相关系数，选取边际相关系数绝对值最大的50个词语作为分类器的特征。

```r
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
```
现在，我们建立分类器。采用‘e1071’包里的‘naiveBaives’函数，划分训练集和测试集后，在训练集上进行训练，接着在测试集上评估结果。


```r
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
```
最终在训练集和测试集上的准确率分别为0.9412、0.9329. 然而，该准确率并不能很好评估分类的结果，由于我们关心的是垃圾短信的识别问题，因此计算presion和recall，分别为0.8631和0.6502。在测试集上的分类混淆矩阵如下，其中行代表真实值，列代表预测值。可以看到spam样本误分类的概率很高。


|   | ham  | spam  |
|  ----  | ----  |   ----  |
|  ham   | 1259  | 23  |
|  spam   | 78  | 145  | 

```r
#  KNN 失效
knn(train = train[, -1], test = test[, -1], cl = train[, 1], k = 10, use.all = FALSE)
```
同时，在此问题中，KNN算法失效。将上述数据带入KNN中，会得到错误“Error in knn(train = train[, -1], test = test[, -1], cl = train[, 1],  : too many ties in knn”，这是由于数据稀疏，有很多的点和未知点的距离相等，导致KNN无法判断。

本文只是粗糙的给出了一个基于naive bayes的文本分类器，对于分词以及特征筛选没有做细致的分析，可以考虑对此进行更加精确的分析得到更优的结论。此外，也可考虑TF-IDF等特征构建方法(在此例中效果较差，具体代码见文末)，或者wordvec2等词向量方法。

参考：
https://blog.csdn.net/clebeg/article/details/41015185

代码及数据见：
https://github.com/stat-xwj/Multivariate-statistical-analysis/tree/master/naive%20bayes
