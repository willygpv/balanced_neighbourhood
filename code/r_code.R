library(cSEM)
library(readxl)
library(semPlot)
library(psych)
library(ggplot2)

# A first assessment is done for all possible values-----------------------

file_path = '..\\estimations\\'

#find all tifs in your directory
dir<-"..\\data\\processed\\"
#get a list of all files with ndvi in the name in your directory
files<-list.files(path=dir, full.names = FALSE)


file_path = '..\\estimations\\'

model_Med = ' # Outer model
              SC <~ aggv20a + aggv20b + aggv20d + aggv20f + aggv20h
              BN <~ KL_2019
              IS =~ aggv46b
              
              # Inner model
              SC ~ BN
              IS ~ BN + SC
              '
for (file in files) {
  agg_data_2019 <- read_excel(paste(dir,file,sep=''), skip=0)
  
  out <- csem(.data = agg_data_2019, .model = model_Med,
              .PLS_weight_scheme_inner = 'factorial',
              .tolerance = 1e-06,
              .PLS_modes = list(SC = 'modeBNNLS',
                                BN = 'modeB',
                                IS = 'modeA'),
              .resample_method = 'bootstrap',
              .eval_plan = 'multiprocess'
  )
  
  file<-gsub(pattern = "\\_kl_sc_2019.xlsx$", "", file)
  
  model_fit_est <- testOMF(.object = out, .alpha = 0.01, .verbose = FALSE)
  
  exportToExcel(summarize(out), .filename = paste(file,'_estimates.xlsx', sep=""), .path = file_path)
  exportToExcel(predict(out, .handle_inadmissibles = 'ignore'), .filename = paste(file,'_predict.xlsx', sep=""), .path = file_path)
  exportToExcel(assess(.object = out,.quality_criterion = 'all'), .filename = paste(file,'_quality.xlsx', sep=""), .path = file_path)
  exportToExcel(model_fit_est, .filename = paste(file,'_fit_est.xlsx', sep=""), .path = file_path)

  
}
print('END')



# Once we find out which are the selected models, we reasses using the indicators that were not dropped -------------------------------------

file_path = '..\\estimations\\selected_models\\'

#find all tifs in your directory
dir<-"..\\data\\processed\\selected_models\\"
#get a list of all files with ndvi in the name in your directory
files<-list.files(path=dir, full.names = FALSE)

model_Med = ' # Outer model
              SC <~ aggv20d #v20h for the sweep 0 dataset (kmeans cluster 3)!
              BN <~ KL_2019
              IS =~ aggv46b
              
              # Inner model
              SC ~ BN
              IS ~ BN + SC
              '
for (file in files) {
  agg_data_2019 <- read_excel(paste(dir,file,sep=''), skip=0)

  out <- csem(.data = agg_data_2019, .model = model_Med,
              .PLS_weight_scheme_inner = 'factorial',
              .tolerance = 1e-06,
              .PLS_modes = list(SC = 'modeB',
                                BN = 'modeB',
                                IS = 'modeA'),
              .resample_method = 'bootstrap',
              .eval_plan = 'multiprocess'
  )
  
  file<-gsub(pattern = "\\_kl_sc_2019.xlsx$", "", file)
  
  model_fit_est <- testOMF(.object = out, .alpha = 0.01, .verbose = FALSE)
  
  exportToExcel(summarize(out), .filename = paste(file,'_winner_estimates.xlsx', sep=""), .path = file_path)
  exportToExcel(predict(out, .handle_inadmissibles = 'ignore'), .filename = paste(file,'_winner_predict.xlsx', sep=""), .path = file_path)
  exportToExcel(assess(.object = out,.quality_criterion = 'all'), .filename = paste(file,'_winner_quality.xlsx', sep=""), .path = file_path)
  exportToExcel(model_fit_est, .filename = paste(file,'_winner_fit_est.xlsx', sep=""), .path = file_path)
  
  }
print('END')
