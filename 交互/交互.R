library(reticulate)
setwd('C:/Users/xiawenjun/Desktop/助教/Multivariate-statistical-analysis/交互')


py_available()                  # 检查您的系统是否安装过Python
use_condaenv("D:/Anaconda")
py_config()                     #安装的python版本环境查看，显示anaconda和numpy的详细信息
py_available()


py_module_available("pandas")   #检查“pandas”是否安装


os <- import("os")
os$getcwd()
os$listdir()#您可以使用os包中的listdir（）函数来查看工作目录中的所有文件

numpy <- import("numpy")
y <- array(1:4, c(2, 2))
y
x <- numpy$array(y)
x
numpy$transpose(x)#将数组进行转置
numpy$linalg$eig(x)#求特征根和特征向量


# 交互使用R和Python
repl_python()
# 没什么用

# 调用python脚本
source_python('test1.py')
# 调用python脚本中的函数
source_python('test2.py')
pythonadd(1, 2)







