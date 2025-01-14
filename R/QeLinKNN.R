
#########################  qeLinKNN()  #################################

# arguments:  see above, plus

#     k: number of nearest neighbors
#     scaleX: if TRUE, features will be centered and scaled; note that
#        this means the features must be numeric
#     smoothingFtn: as in kNN(); 'mean' or 'loclin'
#     expandVars,expandVals:  e.g. expandVars element = 3 and
#        expandVals = 0.2 means give variable 3 a weight of 0.2
#        instead of 1.0 in the distance function

# value:  see above

# see note in kNN() man pg
 
qeLinKNN <- function(data,yName,k=25,scaleX=TRUE,
   smoothingFtn=mean,expandVars=NULL,expandVals=NULL,
   holdout=floor(min(1000,0.1*nrow(data))))
{
   classif <- is.factor(data[[yName]])
   if (classif) stop('not set up for classification problems')

   linout <- qeLin(data=data,yName=yName,holdout=holdout)
   hIdxs <- linout$holdIdxs
   trn <- data[-hIdxs,]
   tst <- data[hIdxs,]
   dataForKNN <- trn
   dataForKNN[[yName]] <- linout$residuals
   knnout <- qeKNN(dataForKNN,yName,k=k,holdout=NULL)
   linknnout <- list(linout=linout,knnout=knnout,classif=classif)
   class(linknnout) <- 'qeLinKNN'

   if (!is.null(holdout)) {
      predictHoldout(linknnout)
      linknnout$holdIdxs <- hIdxs
   } else linknnout$holdIdxs <- NULL
   linknnout
}

predict.qeLinKNN <- function(object,newx,newxK=1)
{
   classif <- object$classif
   if (classif) stop('not set up for classification problems')
   linout <- object$linout
   linPreds <- predict(linout,newx)
   knnout <- object$knnout
   knnPreds <- predict(knnout,newx,newxK=newxK)
   linPreds + knnPreds
}

