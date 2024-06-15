library(tidyverse)
library(tidygraph)
library(qgraph)
library(igraph)
library(igraphdata)
library(foreign)
library(readxl)

######## CALCULATING CENTRALITY SCORES #########

setwd("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2017")
#IMPORT MICRODATA

df <- read.dbf("Banco de Dados/OD_2017_v1.dbf")

str(df)

df2 <- df[,c("FE_VIA", "MODOPRIN", "DURACAO", "ZONA_O", "ZONA_D")]

#Selecting motorized travels
df1 <- subset(df2, df2$MODOPRIN<15)

#Preallocating matrix
matrix <- matrix(data=0,nrow=max(df$ZONA),ncol=max(df$ZONA))

#Creating each average time travel O-D
for (i in 1:nrow(matrix)){
  for (j in 1:ncol(matrix)){
    A <- subset(df1, df1$ZONA_O == 2 & df1$ZONA_D==2)
    a1 <- (sum(A[,1]*A[,3]))/sum(A[,1])
    matrix[i,j] = a1
  }
}

#Replacing nans
matrix[is.na(matrix)] = 0

#Creating the graph
g1 <- graph.adjacency(matrix, mode="directed", weighted=TRUE)

g2 <- decompose(g1)

g <- g2[[1]]

#CLOSENESS CENTRALITY
CL <- closeness(
  g,
  mode = c("in"),
  normalized = FALSE,
  cutoff = -1
)

clocentr<-data.frame(CL)
colnames(clocentr)[1] <- "clocent2017"
clocentr["ZONA"]<-which(CL!=0)
write.dta(clocentr, "Banco de Dados\\clocentrality2017.dta")

which(CL == sort(CL)[length(CL)])


CL2 <- closeness(
  g,
  mode = c("out"),
  normalized = FALSE,
  cutoff = -1
)

#Not informative
# matrix[is.na(matrix)] = 0
# A <- eigen_centrality(
#   g,
#   directed = TRUE,
#   scale = TRUE,
#   weights = NULL,
#   options = arpack_defaults
#  )
# 
# which(A$vector == sort(A$vector)[length(A$vector)])


#EIGENCENTRALITY INDEGREE WITH THE INVERSE "DISTANCE"
#Using the inverse of time matrix

matrix2 = 1./matrix
matrix2[matrix2==Inf] = 0

#Creating the graph
g12 <- graph.adjacency(matrix2, mode="directed", weighted=TRUE)

g22 <- decompose(g12)

gp <- g22[[1]]

A2 <- eigen_centrality(
  gp,
  directed = TRUE,
  scale = TRUE,
  weights = NULL,
  options = arpack_defaults
)

#Exporting
eigcentr<-data.frame(A2$vector)
colnames(eigcentr)[1] <- "eigcent2017"
eigcentr["ZONA"]<-which(A2$vector!=0)
write.dta(eigcentr, "C:\\Users\\BANDOLERO\\Desktop\\eigcentrality2017.dta")


which(A2$vector == sort(A2$vector)[length(A2$vector)-11])


#Hubs authorities centrality
H<-hub_score(g)$vector
which(H == sort(H)[length(A2$vector)-11])
AT<- authority.score(g)$vector
