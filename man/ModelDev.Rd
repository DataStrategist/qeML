\name{FeatureModelSelect}
\alias{qeCompare}
\alias{qeFT}
\alias{qeText}
\alias{qeTS}

\alias{predict.qeText}
\alias{predict.qeTS}

\title{Feature Selection and Model Building}

\description{
Utilties to help build models.
}

\usage{
qeCompare(data,yName,qeFtnList,nReps,opts=NULL,seed=9999)
qeFT(data,yName,qeftn,pars,nCombs,nTst,nXval,showProgress=TRUE)
qeText(data,kTop=50,stopWords=tm::stopwords("english"),
   qeName,opts=NULL,holdout=floor(min(1000,0.1*nrow(data))))
qeTS(lag,data,qeName,opts=NULL,holdout=floor(min(1000,0.1*length(data))))
\method{predict}{qeText}(object,newx)
\method{predict}{qeTS}(object,newx)
}

\arguments{
  \item{pcaProp}{Desired proportion of overall variance for the PCs.`}
  \item{data}{Dataframe, training set. Classification case is signaled
     via labels column being an R factor.}
  \item{yName}{Name of the class labels column.}
  \item{holdout}{If not NULL, form a holdout set of the specified size.
     After fitting to the remaining data, evaluate accuracy on the test set.}
  \item{k}{Number of nearest neighbors. In functions other than
     \code{qeKNN} for which this is an argument, it is the number of 
     neighbors to use in finding conditional probabilities via 
     \code{knnCalib}.} 
  \item{smoothingFtn}{As in \code{kNN}.}
  \item{scaleX}{Scale the features.} 
  \item{nTree}{Number of trees.} 
  \item{minNodeSize}{Minimum number of data points in a tree node.} 
  \item{learnRate}{Learning rate.} 
  \item{hidden}{Vector of units per hidden layer.  Fractional values
     indicated dropout proportions.  Can be specified as a string, e.g.
     '100,50', for use with \code{qeFT}.} 
  \item{nEpoch}{Number of iterations in neural net.}
  \item{acts}{Vector of names of the activation functions, one per
     hidden layer.  Choices inclde 'relu', 'sigmoid', 'tanh', 'softmax',
     'elu', 'selu'.}
  \item{alpha}{1 for LASSO, 2 for ridge.}
  \item{gamma}{Scale parameter in \code{e1071::svm}.}
  \item{cost}{Cost parameter in \code{e1071::svm}.}
  \item{kernel}{One of 'linear','radial','polynomial' and 'sigmoid'.}
  \item{degree}{Degree of SVM polynomial kernel, if any.}
  \item{qeFtnList}{Character vector of \code{qe*} names.}
  \item{nReps}{Number of holdout sets to generate.}
  \item{opts}{R list of optional arguments for none, some or all of th
     functions in \code{qeFtnList}.}
  \item{seed}{Seed for random number generation.}
  \item{qeftn}{Quoted string, specifying the name of a qe-series
     machine learning method.}
  \item{pars}{R list of hyperparameter ranges.  See 
     \code{regtools::fineTuning}.}
  \item{nCombs}{Number of hyperparameter combinations to run.  
     See \code{regtools::fineTuning}.}
  \item{nTsts}{Size of test sets.  See \code{regtools::fineTuning}.}
  \item{nXval}{Number of cross-validations to run.  
     See \code{regtools::fineTuning}.}
  \item{showProgress}{If TRUE, show results as they arise.  
     See \code{regtools::fineTuning}.}
  \item{nComps}{Number of UMAP components to extract.}
  \item{nNeighbors}{Number of nearest neighbors to use in UMAP.}
  \item{ll}{If TRUE, use local linear forest.}
  \item{lambda}{Ridge lambda for local linear forest.}
  \item{splitCutoff}{For leaves smaller than this value, do not fit
     linear model.  Just use the linear model fit to the entire dataset.}
  \item{xShape}{Input X data shape, e.g. c(28,28) for 28x28 grayscale
     images.  Must be non-NULL if \code{conv} is.}
  \item{yYesName}{For a binary classification problem, the value to
     be considered "yes" in probability reports.}
}

\details{

As noted, these functions are intended for quick, first-level analysis
of regression/machine learning problems.  Emphasis here is
on convenience and simplicity.  

The idea is that, given a new dataset, the analyst can quickly and
easily try fitting a number of models in succession, say first k-NN,
then random forests: 

\preformatted{
# built-in data on major league baseball players
> data(mlb)  
> mlb <- mlb[,3:6]  # position, height, weight, age

# fit models
> knnout <- qeKNN(mlb,'Weight',k=25)
> rfout <- qeRF(mlb,'Weight')

# mean abs. pred. error on holdout set, in pounds
> knnout$testAcc
[1] 11.75644
> rfout$testAcc
[1] 12.6787

# predict a new case
> newx <- data.frame(Position='Catcher',Height=73.5,Age=26)
> predict(knnout,newx)
       [,1]
[1,] 204.04
> predict(rfout,newx)
      11 
199.1714

}

The \code{holdout} argument triggers formation of a holdout set
and the corresponding cross-validation evaluation of predictive power.
Note that if a holdout is formed, the return value will consist of the
fit on the training set, not on the full original dataset.
Most of these functions are paired with a \code{predict} method.

In most cases, the full basket of options in the wrapped function is not
reflected.  Use of arguments not presented in the qe function requires
direct use the relevant packages.

The \code{qe*} functions do model fit.  Each of them has a
\code{predict} method, and some also have a \code{plot} method.
Arguments for \code{qe*} are at least: \code{data} and \code{yName};
arguments for \code{predict} are at least: \code{object}, the return
value from \code{qe*}, and \code{newx}, a data frame of points to be
predicted.  In some cases, there are additional algorithm-specific
parameters; default values are provided.

An additional benefit is that the \code{predict} functions work
correctly on new cases with R factors.  The proper levels are assigned
to the new cases.  (Of course, if a new case has a level not in the
original data, nothing can be done.)

Some notes on specific functions:

\itemize{

   \item The function \code{qeLin} handles classification problems as
   multivariate-outcome linea models. If one's goal is prediction, it
   can be much faster than \code{qeLogit}, often with comparable
   accuracy.
   
   \item Several functions fit polynomial models.
   The \code{qePolyLin} function does polynomial regression of the
   indicated degree. In the above example degree 3 means all terms
   through degree 3, e.g. \code{Height * Age^2}.  Dummy variables are
   handled properly, e.g.  no powers of a dummy are generatd.  The
   logistic polynomial regression version is \code{qePolyLog}, and there
   is a LASSO version, \code{qePolyLASSO}.
   
   \item The \code{qeCompare} function does quick-and-easy
   cross-validated comparisons among the \code{qe*} functions.  The same
   holdout sets are generated and used by all the functions.  Default
   values of hyperparameters of those functions can be set via
   \code{opts}.  Hyperparameter tuning for a given \code{qe*} function
   can be done using \code{qeFT}, a wrapper to the 
   \code{regtools::fineTuning} function.  See also \code{replicMean}.

   \item Several SVM implementations are offered:  \code{qeSVM} wraps
   the SVM algorithm in the \pkg{e1071} package; \code{qeskSVM} wraps
   \code{svm.SVC} in the Python \pkg{sklearn}.  (Both \code{qeSVM} and
   \code{qeskSVM} use the \code{libsvm} C library.)

   \item Several random forests implementations are offered:
   \code{qeRF} wraps \code{randomForest} in the package of the same name; 
   \code{qeRFranger} wraps \code{ranger} in the package of the same name; 
   \code{qeRFgrf} wraps \code{regression_forest} and 
   \code{ll_regression_forest} in \pkg{grf} (the latter does local
   linear smoothing); \code{qeskRF} wraps \code{ensemble.RandomForestRegressor}
   and \code{RandomForestClassifier} in the Python \pkg{sklearn}.

   \item Two implementations of gradient boosting are offered, with
   \code{qeGBoost} using the \code{gbm} package, and with
   \code{qelightGBoost} using \code{lightgbm}.

   \item The functions \code{qeTS} and \code{qeText} handle time series
   and text applications, respectively.

   \item Pre-mapping to lower-dimensional manifolds can be done via
   \code{qePCA} and \code{qeUMAP}.  For instance, the former will first
   extract the specified number of principal components, then fit the
   user's desired ML model, say k-NN (\code{qeKNN}) or gradient boosting
   (\code{qeGBoost}).
   
   \item The \code{qeIso} function is intended mainly for use as a
   smoothing method in calibration actions.  }
}

\value{

The value returned by \code{qe*} functions depends on the algorithm, but
with some commonality, e.g. \code{classif}, a logical value indicating
whether the problem was of classification type.  

If a holdout set was requested, an additional returned component will be
\code{testAcc}, the accuracy on the holdout set.  This will be Mean
Absolute Prediction Error in the regression case, and proportion of
misclassified cases in the classification case.

The value returned by the \code{predict} functions is an
R list with components as follows:

Classification case:

\itemize{

\item \code{predClasses}:  R factor instance of predicted class labels 

\item \code{probs}:  vector/matrix of class probabilities; in the 2-class
case, a vector, the probabilities of Y = 1

}

Regression case: vector of predicted values

}

\examples{

# see also 'details' above

\dontrun{

data(peFactors)  
pef <- peFactors[,c(1,3,5,7:9)]  
# most people in the dataset have at least a Bachelor's degree; so let's
# just consider Master's (code 14) and PhD (code 16) as special
pef$educ <- toSubFactor(pef$educ,c('14','16'))  

# predict occupation; 6 classes, 100, 101, 102, 106, 140, 141, using SVM
svmout <- qeSVM(pef,'occ',holdout=NULL) 
# as example of prediction, take the 8th case, but change the gender and
# age to female and 25; note that by setting k to non-null, we are
# requesting that conditional probabilities be calculated, via
# knnCalib(), here using 25 nearest neighbors
newx <- pef[8,-3] 
newx$sex <- '2'
newx$age <- 25
predict(svmout,newx,k=25)
# $predClasses
#   8 
# 100 
# Levels: 100 101 102 106 140 141
# $dvals
#      102/101    102/100   102/141  102/140  102/106    101/100  101/141
# 8 -0.7774038 -0.5132022 0.9997894 1.003251 0.999688 -0.4023077 1.000419
#    101/140   101/106  100/141  100/140  100/106   141/140    141/106   140/106
# 8 1.000474 0.9997371 1.000088 1.000026 1.000126 0.9460703 -0.4974625 -1.035721
# 
# $probs
#       100  101  102  106 140  141
# [1,] 0.24 0.52 0.12 0.08   0 0.04
#
# so, occupation code 100 is predicted, with a 0.36 conditional
# probability

# if holdout evaluation is desired as well, say 1000 cases, seed 9999:
> svmout <- qeSVM(pef,'occ',holdout=c(1000,9999)) 
> svmout$testAcc
[1] 0.622  # 62% error rate (overall rate for 6 classes)

# linear
# lm() doesn't like numeric factor levels, so prepend an 'a'
pef$occ <- prepend('a',pef$occ)
lmout <- qeLin(pef,'occ')
predict(lmout,pef[1,-3])  # occ 100, prob 0.3316
lmout <- qeLin(pef,'wageinc')
predict(lmout,pef[1,-5])  # 70857.79

qeCompare(mlb,'Weight',c('qeLin','qeKNN','qeRF'),25)
#   qeFtn  meanAcc
# 1 qeLin 13.30490
# 2 qeKNN 13.72708
# 3  qeRF 13.46515
qeCompare(mlb,'Weight',c('qeLin','qeKNN','qeRF'),25,
   list(qeKNN='k=5',qeRF='nTree = 100, minNodeSize = 15'))
#   qeFtn  meanAcc
# 1 qeLin 13.30490
# 2 qeKNN 14.34051
# 3  qeRF 13.02334

data(pef)
# investigate values of k, 1 through 25, in predicting occupation using
# k-NN; holdout set size is 1000, with 5 sets run for each k
ftout <- qeFT(data=pef,yName='wageinc',qeftn='qeKNN',
   pars=list(k=1:25),nTst=1000,nXval=5)

}

}

\author{
Norm Matloff
}

