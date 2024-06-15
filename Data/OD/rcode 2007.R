#Measures from 2007 sample

library(tidyverse)
library(tidygraph)
library(qgraph)
library(igraph)
library(igraphdata)
library(foreign)
library(readxl)

######## CALCULATING CENTRALITY SCORES #########

setwd("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2007")
#IMPORT MICRODATA

df <- read.dbf("Banco de Dados/OD_2007_v2d.dbf")

df2 <- df[,c("FE_VIA", "MODOPRIN", "DURACAO", "ZONA_O", "ZONA_D", "H_SAIDA", "DISTANCIA", "ZONA_T1", "ZONA_T2", "ZONA_T3")]

#Selecting motorized travels and no rush hours
#df1 <- subset(df2, df2$MODOPRIN<15 & !between(df2$H_SAIDA,7,10) & !between(df2$H_SAIDA,17,20))

df1 <- subset(df2, df2$MODOPRIN<15)

df1$DURACAO <- df1$DISTANCIA/df1$DURACAO




#Preallocating matrix
matrix <- matrix(data=0,nrow=max(df$ZONA),ncol=max(df$ZONA))

#Creating each average time travel O-D
for (i in 1:nrow(matrix)){
  for (j in 1:ncol(matrix)){
    A <- subset(df1, df1$ZONA_O == i & df1$ZONA_D==j)
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

clocento<-data.frame(CL)
colnames(clocento)[1] <- "clocent_o7"
clocento["ZONA_O"]<-which(CL!="")
write.dta(clocento, "Banco de Dados\\07_clocent_o2.dta")


clocentd<-data.frame(CL)
colnames(clocentd)[1] <- "clocent_d7"
clocentd["ZONA_D"]<-which(CL!="")
write.dta(clocentd, "Banco de Dados\\07_clocent_d2.dta")

# which(CL == sort(CL)[length(CL)])


#Out degree of closeness
CL2 <- closeness(
  g,
  mode = c("out"),
  normalized = FALSE,
  cutoff = -1
)

clocentout<-data.frame(CL2)
colnames(clocentout)[1] <- "clocentout_o7"
clocentout["ZONA_O"]<-which(CL2!="")
write.dta(clocentout, "Banco de Dados\\07_clocentout.dta")
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
#Zone of origin
eigcento<-data.frame(A2$vector)
colnames(eigcento)[1] <- "eigcent_o7"
eigcento["ZONA_O"]<-which(A2$vector!="")
write.dta(eigcento, "Banco de Dados\\07_eigcent_o2.dta")

eigcentd<-data.frame(A2$vector)
colnames(eigcentd)[1] <- "eigcent_d7"
eigcentd["ZONA_D"]<-which(A2$vector!="")
write.dta(eigcentd, "Banco de Dados\\07_eigcent_d2.dta")




##############################
#  HUBS AND AUTHORITIES SCORES

#Selecting travels that started either during the lower band of the upper band of rush hours
df3 <- subset(df2, df2$MODOPRIN<15 & (between(df2$H_SAIDA,7,10) | between(df2$H_SAIDA,17,20)))

df3<-df3[,c("FE_VIA", "ZONA_O", "ZONA_D", "ZONA_T1", "ZONA_T2", "ZONA_T3")]

#Preallocating matrix
matrix3 <- matrix(data=0,nrow=max(df$ZONA),ncol=max(df$ZONA))

# #Creating travel intensity matrix O-D [ORIGINAL LOOP]
# for (i in 1:nrow(matrix3)){
#   for (j in 1:ncol(matrix3)){
#     A <- subset(df3, df3$ZONA_O == i & df3$ZONA_D==j)
#     a1 <- sum(A[,1])
#     matrix3[i,j] = a1
#   }
# }

for (i in 1:nrow(matrix3)){
  for (j in 1:ncol(matrix3)){
    
    A <- subset(df3, df3$ZONA_O == i & df3$ZONA_D==j)
  if (length(A$FE_VIA)){  
      for (k in length(A$FE_VIA)) {
        
        if (is.na(A$ZONA_T1[k])){
          matrix3[i,j] <- matrix3[i,j] + A$FE_VIA[k]
        } else {
          a1<-A$ZONA_T1[k]
          matrix3[i,a1] <- matrix3[i,a1] + A$FE_VIA[k]
          
          if (is.na(A$ZONA_T2[k])){
            matrix3[a1,j] <- matrix3[a1,j] + A$FE_VIA[k]
          } else {
            a2<-A$ZONA_T2[k]
            matrix3[a1,a2] <- matrix3[a1,a2] + A$FE_VIA[k]
          
            if (is.na(A$ZONA_T3[k])){
              matrix3[a2,j] <- matrix3[a2,j] + A$FE_VIA[k]
            } else{ 
              a3<-A$ZONA_T3[k]
              matrix3[a2,a3] <- matrix3[a2,a3] + A$FE_VIA[k]
              matrix3[a3,j] <- matrix3[a3,j] + A$FE_VIA[k]
            }
          }
        }  
      }
    
    }
  }
}

#FOR DEBUGGING
# for (k in length(A$FE_VIA)) {
#   
#   if (is.na(A$ZONA_T1[k])){
#     matrix3[i,j] <- matrix3[i,j] + A$FE_VIA[k]
#   } else {
#     a1<-A$ZONA_T1[k]
#     matrix3[i,a1] <- matrix3[i,a1] + A$FE_VIA[k]
#     
#     if (is.na(A$ZONA_T2[k])){
#       matrix3[a1,j] <- matrix3[a1,j] + A$FE_VIA[k]
#     } else {
#       a2<-A$ZONA_T2[k]
#       matrix3[a1,a2] <- matrix3[a1,a2] + A$FE_VIA[k]
#       
#       if (is.na(A$ZONA_T3[k])){
#         matrix3[a2,j] <- matrix3[a2,j] + A$FE_VIA[k]
#       } else{ 
#         a3<-A$ZONA_T3[k]
#         matrix3[a2,a3] <- matrix3[a2,a3] + A$FE_VIA[k]
#         matrix3[a3,j] <- matrix3[a3,j] + A$FE_VIA[k]
#         }
#       }
#     }  
# }




#Replacing nans
matrix3[is.na(matrix3)] = 0

gh1 <- graph.adjacency(matrix3, mode="directed", weighted=TRUE)

gh2 <- decompose(gh1)

gha <- gh2[[1]]

#Hubs authorities centrality
H<-hub_score(gha)$vector
which(H == sort(H)[length(H)-1])
sort(AT, index.return=TRUE)

hubscoro<- data.frame(H)
colnames(hubscoro)[1] <- "hubscoro_o7"
hubscoro["ZONA_O"]<-which(H!="")
write.dta(hubscoro, "Banco de Dados\\7_hubscoro.dta")



AT<- authority.score(gha)$vector
which(AT == sort(AT), arr.ind = TRUE)

autscord<-data.frame(AT)
colnames(autscord)[1] <- "autscord_d7"
autscord["ZONA_D"]<-which(AT!="")
write.dta(autscord, "Banco de Dados\\07_autscord.dta")










