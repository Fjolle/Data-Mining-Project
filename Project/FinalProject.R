happiness <- na.omit(world_happiness_report_2021)

library(tidyverse)


#In order to construct an accurate statictical model that accurately predicts happiness levels accross
#the world I apply four different Healthy_life_expectancy statistical models: The linear model, Lasso, Random Forest and Boosting.
#Predictions using each one of the above models are then compared to observe which one provides us with
#the best performance. I analyze different Healthy_life_expectancy broken-down regions of the world in order to observe the score
#of the factors adding to the population's happiness level.


#Healthy life expectancy explained by perceptions of corruption

happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Perceptions_of_corruption,
  color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 1: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()

#Healthy life expectancy explained by social support


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Social_support, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 2:Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()

#Healthy life expectancy explained by freedom to make life choices


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Freedom_to_make_life_choices, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 3: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()


#Healthy life expectancy explained by generosity


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Generosity, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 4: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()

#Healthy life expectancy explained by log GDP per capita


happiness %>%
  group_by(Regional_indicator) %>%
  ggplot() +
  geom_line(aes(y = Healthy_life_expectancy, x = Explained_by_Log_GDP_per_capita, color = Regional_indicator)) +
  facet_wrap(~ Regional_indicator, scales = "free") + 
  labs(x = "Regional Indicator", y = "Average Life Expectancy",
       title = "Figure 5: Healthy Life Expectancy based on Freedom to make life choices",
       caption = "Data from Gallup World Poll")+
  theme_minimal()


# First Model: Hand-Built Linear Model
lm_happiness = lm(Healthy_life_expectancy ~ Regional_indicator + Explaine_by_Social_support+
                    Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                    Explained_by_Generosity+Explained_by_Perceptions_of_corruption+
                    Regional_indicator*Explaine_by_Social_support+
                    Regional_indicator*Explained_by_Log_GDP_per_capita+
                    Regional_indicator*Explained_by_Freedom_to_make_life_choices+
                    Regional_indicator*Explained_by_Generosity+
                    Regional_indicator*Explained_by_Perceptions_of_corruption,data=happiness)


#Second Model: Lasso 
library(glmnet)

x = model.matrix(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                   Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                   Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data=happiness)[,-1]
x = scale(x, center=TRUE, scale=TRUE) 
y = happiness$Healthy_life_expectancy
grid=15^seq(5,-1, length =30)
lasso.mod=glmnet(x,y,alpha=1, lambda =grid)
cv.out=cv.glmnet(x,y,alpha=1)
bestlam =cv.out$lambda.min
plot(lasso.mod)
title("Lasso Coefficients", line = 3)

library(data.table)
library(kableExtra)
lasso.coef=predict(lasso.mod ,type ="coefficients",s=bestlam)
LassoCoef=as.data.table(as.matrix(lasso.coef), keep.rownames = TRUE)
kable(LassoCoef, col.names = c("Predictor", "Estimate"), caption = "Lasso Model Predictor Estimates",  format_caption = c("italic", "underline")) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)

#Split into training and testing sets
library(rsample)
happiness_split = initial_split(happiness, prop = 0.8)
happiness_train = training(happiness_split)
happiness_test = testing(happiness_split)
#K- fold cross validation
library(modelr)
happiness_folds = crossv_kfold(happiness, k=20)
best = map(happiness_folds$train, ~ lm(Healthy_life_expectancy~Regional_indicator+
                                         Explaine_by_Social_support+
                                         Explained_by_Log_GDP_per_capita+
                                         Explained_by_Freedom_to_make_life_choices+ 
                                         Explained_by_Generosity+
                                         Explained_by_Perceptions_of_corruption,
                                       data=happiness_train))


library(mosaic)
# Mean RMSE
rmse = function(y, yhat) {
  sqrt(mean((y - yhat)^2))}
LoopModels = do(20)*{
  n = nrow(happiness)
  n_train = round(0.8*n)  
  n_test = n - n_train
  train_cases = sample.int(n, n_train, replace=FALSE)
  test_cases = setdiff(1:n, train_cases) 
  happiness_train = happiness[train_cases,]
  happiness_test = happiness[test_cases,]
  
  lm_happiness = lm(Healthy_life_expectancy~Regional_indicator+
                      Explaine_by_Social_support+
                      Explained_by_Log_GDP_per_capita+
                      Explained_by_Freedom_to_make_life_choices+ 
                      Explained_by_Generosity+
                      Explained_by_Perceptions_of_corruption
                    , data=happiness_train)
  
  x = model.matrix(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                     Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                     Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data=happiness)[,-1]
  
  x = scale(x, center=TRUE, scale=TRUE) 
  y = happiness$Healthy_life_expectancy
  grid=10^seq(10,-2, length =100)
  lasso.mod=glmnet(x[train_cases,],y[train_cases],alpha=1, lambda =grid)
  cv.out=cv.glmnet(x[train_cases,],y[train_cases],alpha=1)
  bestlam =cv.out$lambda.min
  
  yhat_test_lmhappiness = predict(lm_happiness, happiness_test)
  yhat_Lasso = predict(lasso.mod, s=bestlam, newx=x[test_cases,])
  
  c(RMSEhappiness = rmse(happiness_test$Healthy_life_expectancy, yhat_test_lmhappiness),
    RMSELasso = rmse(happiness_test$Healthy_life_expectancy,yhat_Lasso))
  
}
RMSEMeans = c("Hand-Built Linear Model" = mean(LoopModels$RMSEhappiness), 
              "Lasso" = mean(LoopModels$RMSELasso))
kable(RMSEMeans, col.names = c("Mean RMSE"), caption = "Mean RMSE",  format_caption = c("italic", "underline")) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


##Bagging

library(randomForest)
set.seed(1)
happyBagging = randomForest(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                              Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                              Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data = happiness_train, mtry=7, importance=TRUE)
happyBagging


yhat_happyBagging = predict(happyBagging, newdata = happiness_test)
plot(yhat_happyBagging, happiness_test$Healthy_life_expectancy, xlab = "Predicted Values for Healthy life expectancy: Bagging", ylab = "Healthy_life_expectancy")
title("Comparison between Bagging Predicted Healthy life expectancy and Actual Healthy life expectancy")



#Random Forest

set.seed(1)
happyRandomForest = randomForest(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                                   Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                                   Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data = happiness_train,
                                 mtry=3, importance=TRUE)
happyRandomForest = predict(happyRandomForest, newdata = happiness_test)
plot(happyRandomForest, happiness_test$Healthy_life_expectancy, xlab = "Predicted Values for Healthy life expectancy: Random Forest", ylab = "Healthy life expectancy")
title("Comparison between Random Forest Predicted Healthy life expectancy and Actual Healthy life expectancy")





### Comparison of all 4 Predictive Models: Hand-Built Linear Model, Lasso, Bagging and Random Forest:

library(foreach)
N=nrow(happiness)
K=3
fold_id = rep_len(1:K, N)
fold_id = sample(fold_id, replace = FALSE)



#Compute cross validation error for Model1 
err_save = rep(0, K)
for (i in 1:K) {
  train_set = which(fold_id != i)
  y_testCV = happiness$Healthy_life_expectancy[-train_set]
  lm_Healthy_life_expectancyCV = lm(Healthy_life_expectancy ~  Regional_indicator + Explaine_by_Social_support+
                                      Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                                      Explained_by_Generosity+Explained_by_Perceptions_of_corruption+
                                      Regional_indicator*Explaine_by_Social_support+
                                      Regional_indicator*Explained_by_Log_GDP_per_capita+
                                      Regional_indicator*Explained_by_Freedom_to_make_life_choices+
                                      Regional_indicator*Explained_by_Generosity+
                                      Regional_indicator*Explained_by_Perceptions_of_corruption 
                                    , data=happiness[train_set,]) 
  
  yhat_Healthy_life_expectancy_CV = predict(lm_Healthy_life_expectancyCV, newdata = happiness[-train_set,])
  
  err_save[i] = mean((y_testCV - yhat_Healthy_life_expectancy_CV)^2)
}
RMSE = sqrt(mean(err_save))
RMSE


#compute cross validation error for Lasso Model 
err_saveLasso = rep(0, K)
for (i in 1:K) {
  train_set = which(fold_id != i)
  y_testCV = happiness$Healthy_life_expectancy[-train_set] 
  x = model.matrix(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                     Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                     Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data=happiness)[,-1]
  x = scale(x, center=TRUE, scale=TRUE) 
  y = happiness$Healthy_life_expectancy
  grid=10^seq(10,-2, length =100)
  lasso.mod=glmnet(x[train_set,],y[train_set],alpha=1, lambda =grid)
  cv.out=cv.glmnet(x[train_set,],y[train_set],alpha=1)
  bestlam =cv.out$lambda.min
  
  yhat_lm_Healthy_life_expectancy_Lasso = predict(lasso.mod, s=bestlam, newx=x[-train_set,])
  
  err_saveLasso[i] = mean((y_testCV - yhat_lm_Healthy_life_expectancy_Lasso)^2)
}
RMSE3 = sqrt(mean(err_saveLasso))
RMSE3

#Bagging Model
err_saveTreeBag = rep(0, K)
for (i in 1:K) {
  train_set = which(fold_id != i)
  happiness_train = happiness[train_set,]
  #train_set = scale(train_set, center=TRUE, scale=TRUE) 
  y_testCV = happiness$Healthy_life_expectancy[-train_set] 
  y = happiness$Healthy_life_expectancy
  happiness_test = happiness[-train_set,]
  
  set.seed(1)
  greenbuildBagging = randomForest(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                                     Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                                     Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data = happiness_train,
                                   mtry=17, importance=TRUE)
  
  yhat_greenbuildBagging = predict(greenbuildBagging, newdata = happiness_test)
  
  err_saveTreeBag[i] = mean((y_testCV - yhat_greenbuildBagging)^2)
}
RMSE4 = sqrt(mean(err_saveTreeBag))
RMSE4 


#Random Forest
err_saveTreeForest = rep(0, K)
for (i in 1:K) {
  train_set = which(fold_id != i)
  happiness_train = happiness[train_set,]
  #train_set = scale(train_set, center=TRUE, scale=TRUE) 
  y_testCV = happiness$Healthy_life_expectancy[-train_set] 
  y = happiness$Healthy_life_expectancy
  happiness_test = happiness[-train_set,]
  
  set.seed(1)
  greenbuildRandomForest = randomForest(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                                          Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                                          Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data = happiness_train,
                                        mtry=4, importance=TRUE)
  
  yhat_greenbuildRandomForest = predict(greenbuildRandomForest, newdata = happiness_test)
  
  err_saveTreeForest[i] = mean((y_testCV - yhat_greenbuildRandomForest)^2)
}
RMSE5 = sqrt(mean(err_saveTreeForest))
RMSE5

AvgRMSEModels = c("LOOCV RMSE Healthy_life_expectancy Hand-Built Model"=sqrt(mean(err_save)), 
                  "LOOCV RMSE Model Lasso Model" = sqrt(mean(err_saveLasso)),
                  "LOOCV RMSE Model Bagging Model" = sqrt(mean(err_saveTreeBag)),
                  "LOOCV RMSE Model RandomForest Model" = sqrt(mean(err_saveTreeForest)))
kable(AvgRMSEModels, col.names = c("LOOCV RMSE"), caption = " LOOCV RMSE per Model",  format_caption = c("italic", "underline")) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)


set.seed(1)
greenbuildRandomForest2 = randomForest(Healthy_life_expectancy~Regional_indicator+Explaine_by_Social_support+
                                         Explained_by_Log_GDP_per_capita+Explained_by_Freedom_to_make_life_choices+ 
                                         Explained_by_Generosity+Explained_by_Perceptions_of_corruption, data = happiness,
                                       mtry=4, importance=TRUE)
VariableImp = as.data.table(importance(greenbuildRandomForest2), keep.rownames = TRUE)
kable(VariableImp, caption = "**Table 1.4 Variable Importance in Random Forest Model**", col.names = c("Predictor", "% Increase in MSE", "Increase in Node Purity"),  format_caption = c("italic", "underline")) %>%
  kable_styling(bootstrap_options = "striped", full_width = F)




