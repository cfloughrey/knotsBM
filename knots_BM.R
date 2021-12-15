#####################################################
# BALL MAPPER
# TO USE BEFORE graph_coloring.ipynb
#####################################################

setwd("~/GitHub/knotsBM/")

library(data.table) # to read csv faster

#source('R/BallMapper.R')
library(Rcpp)
sourceCpp('R/BallMapper.cpp')

source('R/BallMapper_utils.R')


#####################################################
#For standard, not symmetric data:
#This is the fucntion to create the standard BM
BallMapperCpp <- function( points , values , epsilon )
{
  output <- SimplifiedBallMapperCppInterface( points , values , epsilon )
  colnames(output$vertices) = c('id','size')
  return_list <- output
}#BallMapperCpp



# load the dataset
jones_13 <- fread('data/Jones_upto_13.csv', sep=',', header = TRUE)
sapply(jones_13[, 1:10], class)

# the table has 57 columns, the first 6 are info, from 7 to 57 there are the coefficients
colors <- jones_13[, 1:6]
coeff <- jones_13[, 7:57]
# add the norm of the coefficients
colors$norm <- wordspace::rowNorms(as.matrix(coeff))

# write the tables to file
write.table(colors, 'output/jones_13/Jones_upto_13_colors.csv')
write.table(coeff, 'output/jones_13/Jones_upto_13_coeff.csv')


# create a bm of radius epsilon, and color by the signature 
epsilon <- 20

print("COMPUTING BM")
start <- Sys.time()
jones_13_BM <- BallMapperCpp(coeff, jones_13$signature, epsilon)
print("DONE")
print(Sys.time() - start)
print("SAVING")
# save BM to file
# WARNING to not run more than once, it will corrupt the output files
storeBallMapperGraphInFile(jones_13_BM, filename = paste0("output/jones_13/", epsilon))
print("THE END")

# plot the BM
ColorIgraphPlot(jones_13_BM, seed=42)



