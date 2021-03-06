options( java.parameters = "-Xmx16000m" )

set.seed(2707)
require(ggplot2)
require(GGally)
require(corrgram)
require(lightgbm)
require(foreach)
require(doParallel)
require(caret)
require(randomForest)
require(lars)
require(xgboost)
require(e1071)
require(rJava)
require(extraTrees)

debugSource("ext.R")
debugSource("algos.R")
debugSource("cache.R")
debugSource("lgb.R")
debugSource("xgb.R")
debugSource("nnet.R")
debugSource("et.R")
debugSource("knn.R")
debugSource("aggregator.R")
debugSource("genetic.R")
debugSource("preprocess.R")

my.dopar.exports = c('validation.tqfold', 'validation.tqfold.enumerate', 'my.normalizedTrain', 'nnetTrainAlgo', 
                     'my.extendedColsTrain', 'my.roundedTrain', 'error.accuracy', 'my.train.nnet',
                     'my.boot', 'meanAggregator', 'extendXYCols', 'extendCols', 'my.train.lgb',
                     'my.dopar.exports', 'my.dopar.packages')
my.dopar.packages = c('caret', 'lightgbm', 'foreach', 'rJava', 'extraTrees')

XX = read.csv(file="data/x_train.csv", head=F, sep=";", na.strings="?")
YY = read.csv(file="data/y_train.csv", head=F, sep=";", na.strings="?")
colnames(YY) = 'Y'
colnames(XX) = paste0('X', 1:ncol(XX))

#XX = my.data.transformFeatures(XX)
XLL = cbind(data.matrix(XX), YY)

XXX = read.csv(file='data/x_test.csv', head=F, sep=';', na.strings='?')
colnames(XXX) = paste0('X', 1:ncol(XXX))
XXX = my.data.transformFeatures(XXX)

XLLbin12 = XLL
XLLbin12[, ncol(XLLbin12)] = ifelse(XLLbin12[, ncol(XLLbin12)] <= 1, 0, 1)

XLLbin23 = XLL
XLLbin23[, ncol(XLLbin23)] = ifelse(XLLbin23[, ncol(XLLbin23)] <= 2, 0, 1)

ang.result = readRDS('cache/ang.result')

xgbParams = expand.grid(
  iters=250,
  rowsFactor=0.99,
  
  max_depth=c(13), 
  gamma=0,
  lambda=c(0.2),
  alpha=0.812294, 
  eta=0.03,
  colsample_bytree=c(0.4),
  min_child_weight=c(0.3),
  subsample=c(0.8),
  nthread=4, 
  nrounds=c(500),
  early_stopping_rounds=0,
  num_parallel_tree=1
)

"
my.gridSearch(XLL, function (params) {
  function (XL, newdata=NULL) {
    my.roundedTrain(XL, function (XL, newdata=NULL) {
      etXgbMeanTrainAlgo(XL, params, newdata=newdata)
      #etXgbTrainAlgo(XL, params, newdata=newdata)
    },  newdata=newdata)
  }
}, expand.grid(
               use.04=c(T),
               #p1=seq(from=0.45, to=0.55, length.out=10), 
               #iters=1,
               p1=0.4947368,
               lol=1), verbose=T, iters=15, use.newdata=T)
exit()
"

"
my.gridSearch(XLL, function (params) {
  function (XL, newdata=NULL) {
    my.roundedTrain(XL, function (XL, newdata=NULL) {
      #etWithBin123TrainAlgo(XL, params, newdata=newdata)
      #etTrainAlgo(XL, params, newdata=newdata)
      knnTrainAlgo(XL, params, newdata=newdata)
      #knnEtTrainAlgo(XL, params, newdata=newdata)
      #etGlmTrainAlgo(XL, params)
    }, newdata=newdata)
  }
}, expand.grid(numRandomCuts=c(1), mtry=c(2), ntree=c(2000), nodesize=1, iters=1, rowsFactor=1, k=6, km='kknn', kernel=c(
      'triangular', 'inv'
)), verbose=T, iters=15, use.newdata=T)
exit()
"


"
my.gridSearch(XLLbin12, function (params) {
  function (XL, newdata) {
    my.roundedTrain(XL, function (XL, newdata) {
      xgbTrainAlgo(XL, params)
      #xgbWithBin123TrainAlgo(XL, params)
    })
  }
}, xgbParams, verbose=T, iters=15, use.newdata=T)
exit()          
"


print('processing x_test...')
#set.seed(2701);aEtwb_1_3_11_feat510 = etWithBin123TrainAlgo(XLL, expand.grid(numRandomCuts=1, mtry=3, ntree=2000, nodesize=1, iters=250, rowsFactor=1), newdata=XXX); print('trained')
#set.seed(2707);aEt = etTrainAlgo(XLL, expand.grid(numRandomCuts=1, mtry=2, ntree=2000, iters=1, rowsFactor=1)); print('trained')
#set.seed(2707);aXgb = xgbTrainAlgo(XLL, xgbParams, newdata=XXX)
#set.seed(2709);aXgbwb12_11_feat1245 = xgbWithBin123TrainAlgo(XLL, xgbParams, newdata=XXX); print('trained')
#set.seed(2709);aEtxgb = etXgbTrainAlgo(XLL, expand.grid(iters=15), newdata=XXX)
#exit()
#alg=aEtwb_1_3_11_feat510


"
set.seed(37233)
addRemoveSelect(iterations=10000, XL=extendXYCols(XLL, idxes=neee, pairs=T), teach=function (XL, newdata=NULL) {
  my.roundedTrain(XL, function (XL, newdata=NULL) {
    my.normalizedTrain(XL, function (XL, newdata=NULL) {
      my.train.et(XL, expand.grid(numRandomCuts=1, mtry=2, ntree=2000, nodesize=1, iters=1, rowsFactor=1), newdata=newdata)
    }, newdata=newdata)
  }, newdata=newdata)
}, startVec=nppp)
"

"
set.seed(2563)
binRemoveSelect(XL=extendXYCols(XLL, idxes=neee, pairs=nppp, angles=T, x11=F), binX=XLL$X11, teach=function (XL, newdata=NULL) {
  params = expand.grid(numRandomCuts=1, mtry=2, ntree=2000, nodesize=1, iters=1, rowsFactor=1)
  my.roundedTrain(XL, function (XL, newdata=NULL) {
    #my.normalizedTrain(XL, function (XL, newdata=NULL) {
    #  my.train.xgb(XL, xgbParams, newdata=newdata)
    #}, newdata=newdata)
    
    #bin123TrainAlgo(XL, xgbParams, newdata=newdata, trainAlgo=function (XL, params, newdata=NULL) {
    #  my.normalizedTrain(XL, function (XL, newdata=NULL) {
    #    my.train.xgb(XL, params, newdata=newdata)
    #  }, newdata=newdata)
    #}, use23=F)
    
    #my.normalizedTrain(XL, function (XL, newdata=NULL) {
    #  my.train.et(XL, params, newdata=newdata)
    #}, newdata=newdata)
    
    bin123TrainAlgo(XL, params, newdata=newdata, trainAlgo=function (XL, params, newdata=NULL) {
      my.normalizedTrain(XL, function (XL, newdata=NULL) {
        my.train.et(XL, params, newdata=newdata)
      }, newdata=newdata)
    })
  }, newdata=newdata)
})
"


"
set.seed(2563)
addRemoveSelect(iterations=10000, XL=extendXYCols(XLL, idxes=xeee, pairs=xppp, angles=T, x11=T, x11bin=T), teach=function (XL) {
  my.roundedTrain(XL, function (XL, newdata=NULL) {
    my.normalizedTrain(XL, function (XL, newdata=NULL) {
      my.train.xgb(XL, xgbParams)
    })
  })
}, startVec=rep(1, ncol(extendXYCols(XLL, idxes=xeee, pairs=xppp, angles=T, x11=T, x11bin=F))+1))
"

"
set.seed(427333)
addRemoveSelect(iterations=10000, XL=extendXYCols(XLL, idxes=neee, pairs=T, angles=T), teach=function (XL) {
  my.roundedTrain(XL, function (XL, newdata=NULL) {
    my.normalizedTrain(XL, function (XL, newdata=NULL) {
      my.train.knn(XL, expand.grid(k=4))
    })
  })
}, startVec=c(1,1,1,1,1,1,1,1,1,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
              0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
"


# https://www.r-bloggers.com/7-visualizations-you-should-learn-in-r/


#ggplot(train, aes(Item_Visibility, Item_MRP)) + geom_point() + scale_x_continuous("Item Visibility", breaks = seq(0,0.35,0.05))+ scale_y_continuous("Item MRP", breaks = seq(0,270,by = 30))+ theme_bw() 

#X_X = data.frame(XX)
#plt = ggplot(data=X_X, aes(X_X[,18]))+geom_histogram(binwidth=0.01)
#print(plt)
  #scale_x_continuous("Item MRP", breaks = seq(0,270,by = 30)) +
  #scale_y_continuous("Count", breaks = seq(0,200,by = 20)) +
  #labs(title = "Histogram")


#plot(density((X_X[,77]-mean(X_X[,77])/sd(X_X[,77]))))
#lines(density((X_X[,103]-mean(X_X[,103])/sd(X_X[,103]))), col='red')

qwe = function (XL) {
  meanAggregator04(c(
    aEtwb_1_3_11_feat510,
    aXgbwb12_11_feat1245,
    knnTrainAlgo(XL, expand.grid(k=6, km='knn'), newdata=XXX)
  ), w=c(0.35, 0.35, 0.3))
}
alg = qwe(XLL)

#set.seed(2707);


results1 = alg(XXX)
results = my.roundAns(XXX, results1)
source('repeats-check.R')
source('knn-check.R')
write(results, file='res/res.txt', sep='\n')
print('done')
