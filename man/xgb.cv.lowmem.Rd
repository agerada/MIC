% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cv.R
\name{xgb.cv.lowmem}
\alias{xgb.cv.lowmem}
\title{Low memory cross-validation wrapper for XGBoost}
\usage{
xgb.cv.lowmem(
  params = list(),
  data,
  nrounds,
  nfold,
  label = NULL,
  missing = NA,
  prediction = FALSE,
  metrics = list(),
  obj = NULL,
  feval = NULL,
  stratified = TRUE,
  folds = NULL,
  train_folds = NULL,
  verbose = 1,
  print_every_n = 1L,
  early_stopping_rounds = NULL,
  maximize = NULL,
  save_models = FALSE,
  ...
)
}
\arguments{
\item{params}{parameters for xgboost}

\item{data}{DMatrix or matrix}

\item{nrounds}{number of training rounds}

\item{nfold}{number of folds, or if < 1 then the proportion will be used
as the training split in a train-test split}

\item{label}{data labels (alternatively provide with DMatrix)}

\item{missing}{handling of missing data (see xgb.cv)}

\item{prediction}{return predictions}

\item{metrics}{evaluation metrics}

\item{obj}{custom objective function}

\item{feval}{custom evaluation function}

\item{stratified}{whether to use stratified folds}

\item{folds}{custom folds}

\item{train_folds}{custom train folds}

\item{verbose}{verbosity level}

\item{print_every_n}{print every n iterations}

\item{early_stopping_rounds}{early stopping rounds (applied to each fold)}

\item{maximize}{whether to maximize the evaluation metric}

\item{save_models}{whether to save the models}

\item{...}{additional arguments passed to xgb.train}
}
\value{
xgb.cv.synchronous object
}
\description{
This function performs similar operations to xgboost::xgb.cv, but with the
operations performed in a memory efficient manner. Unlike xgboost::xgb.cv,
this version does not load all folds into memory from the start. Rather it
loads each fold into memory sequentially, and trains trains each fold using
xgboost::xgb.train. This allows larger datasets to be cross-validated.

The main disadvantage of this function is that it is not possible to perform
early stopping based the results of all folds. The function does accept an
early stopping argument, but this is applied to each fold separately. This
means that different folds can (and should be expected to) train for a
different number of rounds.

This function also allows for a train-test split (as opposed to multiple)
folds. This is done by providing a value of less than 1 to nfold, or a list
of 1 fold to folds. This is not possible with xgboost::xgb.cv, but can be
desirable if there is downstream processing that depends on an
xgb.cv.synchromous object (which is the return object of both this function
and xgboost::xgb.cv).

Otherwise, where possible this function tries to return the same data
structure as xgboost::xgb.cv, with the exception of callbacks (not supported
as a field within the return object). To save models, use the save_models
argument, rather than the cb.cv.predict(save_models = TRUE) callback.
}
\examples{
train <- list(data = matrix(rnorm(20), ncol = 2),
             label = rbinom(10, 1, 0.5))
dtrain <- xgboost::xgb.DMatrix(train$data, label = train$label, nthread = 1)
cv <- xgb.cv.lowmem(data = dtrain,
                   params = list(objective = "binary:logistic"),
                   nrounds = 2,
                   nfold = 3,
                   prediction = TRUE,
                   nthread = 1)
cv
}
