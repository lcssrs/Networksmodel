rm()
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



df2 <- df[,c("FE_VIA", "MODOPRIN", "DURACAO", "ZONA_O", "ZONA_D", "H_SAIDA", "DISTANCIA", "ZONA_T1", "ZONA_T2", "ZONA_T3", "TIPVG")]

#Selecting motorized travels and no rush hours
df1 <- subset(df2, df2$MODOPRIN<15 & !between(df2$H_SAIDA,7,10) & !between(df2$H_SAIDA,17,20) &df2$TIPVG==1)

#df1 <- subset(df2, df2$MODOPRIN<15)

df1$VELOCIDADE <- df1$DISTANCIA/df1$DURACAO
df1<- df1[,c("FE_VIA", "VELOCIDADE", "ZONA_O", "ZONA_D", "DURACAO")]


#Preallocating matrix
matrix <- matrix(data=0,nrow=max(df1$ZONA_O),ncol=max(df1$ZONA_D))

#Creating each average time travel O-D
for (i in 1:nrow(matrix)){
  for (j in 1:ncol(matrix)){
    A <- subset(df1, df1$ZONA_O == i & df1$ZONA_D==j)
    a <- (sum(A[,1]*A[,5]))/sum(A[,1])
    matrix[i,j] = a
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
  normalized = TRUE,
  cutoff = -1
)

clocento<-data.frame(CL)
colnames(clocento)[1] <- "clocent_o7"
clocento["ZONA_O"]<-which(CL!="")
#write.dta(clocento, "Banco de Dados\\07_clocent_o2.dta")


clocentd<-data.frame(CL)
colnames(clocentd)[1] <- "clocent_d7"
clocentd["ZONA_D"]<-which(CL!="")
#write.dta(clocentd, "Banco de Dados\\07_clocent_d2.dta")

# which(CL == sort(CL)[length(CL)])


#Out degree of closeness
CL2 <- closeness(
  g,
  mode = c("out"),
  normalized = TRUE,
  cutoff = -1
)

clocentout<-data.frame(CL2)
colnames(clocentout)[1] <- "clocentout_o7"
clocentout["ZONA_O"]<-which(CL2!="")
#write.dta(clocentout, "Banco de Dados\\07_clocentout.dta")

#Preallocating matrix
matrix1 <- matrix(data=0,nrow=max(df1$ZONA_O),ncol=max(df1$ZONA_D))

#Creating each average time travel O-D
for (i1 in 1:nrow(matrix1)){
  for (j1 in 1:ncol(matrix1)){
    A1 <- subset(df1, df1$ZONA_O == i1 & df1$ZONA_D==j1)
    a1 <- (sum(A1[,1]*A1[,2]))/sum(A1[,1])
    matrix1[i1,j1] = a1
  }
}

#Replacing nans
matrix1[is.na(matrix1)] = 0


#EIGENCENTRALITY INDEGREE WITH THE SPEED

#Creating the graph
g12 <- graph.adjacency(matrix1, mode="directed", weighted=TRUE)

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
#write.dta(eigcento, "Banco de Dados\\07_eigcent_o2.dta")

eigcentd<-data.frame(A2$vector)
colnames(eigcentd)[1] <- "eigcent_d7"
eigcentd["ZONA_D"]<-which(A2$vector!="")
#write.dta(eigcentd, "Banco de Dados\\07_eigcent_d2.dta")




##############################
#  HUBS AND AUTHORITIES SCORES

#Selecting travels that started either during the lower band of the upper band of rush hours
df3 <- subset(df2, df2$MODOPRIN<15 & (between(df2$H_SAIDA,7,10) | between(df2$H_SAIDA,17,20)) &df2$TIPVG==1 )

df3<-df3[,c("FE_VIA", "ZONA_O", "ZONA_D", "ZONA_T1", "ZONA_T2", "ZONA_T3")]

#Preallocating matrix
matrix3 <- matrix(data=0,nrow=max(df3$ZONA_O),ncol=max(df3$ZONA_D))

# #Creating travel intensity matrix O-D [ORIGINAL LOOP]
# for (i in 1:nrow(matrix3)){
#   for (j in 1:ncol(matrix3)){
#     A <- subset(df3, df3$ZONA_O == i & df3$ZONA_D==j)
#     a1 <- sum(A[,1])
#     matrix3[i,j] = a1
#   }
# }

for (i2 in 1:nrow(matrix3)){
  for (j2 in 1:ncol(matrix3)){
    
    A3 <- subset(df3, df3$ZONA_O == i2 & df3$ZONA_D==j2)
    if (length(A3$FE_VIA)>0){  
      for (k1 in length(A3$FE_VIA)) {
        
        if (is.na(A3$ZONA_T1[k1])){
          matrix3[i2,j2] <- matrix3[i2,j2] + A3$FE_VIA[k1]
        } else {
          a11<-A3$ZONA_T1[k1]
          matrix3[i2,a11] <- matrix3[i2,a11] + A3$FE_VIA[k1]
          
          if (is.na(A3$ZONA_T2[k1])){
            matrix3[a11,j2] <- matrix3[a11,j2] + A3$FE_VIA[k1]
          } else {
            a21<-A3$ZONA_T2[k1]
            matrix3[a11,a21] <- matrix3[a11,a21] + A3$FE_VIA[k1]
            
            if (is.na(A3$ZONA_T3[k1])){
              matrix3[a21,j2] <- matrix3[a21,j2] + A3$FE_VIA[k1]
            } else{ 
              a31<-A3$ZONA_T3[k1]
              matrix3[a21,a31] <- matrix3[a21,a31] + A3$FE_VIA[k1]
              matrix3[a31,j2] <- matrix3[a31,j2] + A3$FE_VIA[k1]
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

#which(H == sort(H)[length(H)-1])

hubscoro<- data.frame(H)
colnames(hubscoro)[1] <- "hubscoro_o7"
hubscoro["ZONA_O"]<-which(H!="")
#write.dta(hubscoro, "Banco de Dados\\7_hubscoro.dta")


AT<- authority.score(gha)$vector

#which(AT == sort(AT), arr.ind = TRUE)

autscord<-data.frame(AT)
colnames(autscord)[1] <- "autscord_d7"
autscord["ZONA_D"]<-which(AT!="")
#write.dta(autscord, "Banco de Dados\\07_autscord.dta")




for (h in 1:460){
  if (is.na(clocento$ZONA_O[h])){
    clocento[h,]<-c(NA,h)
  }
  
  if (is.na(clocentd$ZONA_D[h])){
    clocentd[h,]<-c(NA,h)
  }
  
  if (is.na(clocentout$ZONA_O[h])){
    clocentout[h,]<-c(NA,h)
  }
  
  if (is.na(eigcentd$ZONA_D[h])){
    eigcentd[h,]<-c(NA,h)
  }
  
  if (is.na(eigcento$ZONA_O[h])){
    eigcento[h,]<-c(NA,h)
  }
  
  if (is.na(hubscoro$ZONA_O[h])){
    hubscoro[h,]<-c(NA,h)
  }
  
  if (is.na(autscord$ZONA_D[h])){
    autscord[h,]<-c(NA,h)
  }
}


#clocento$clocent_o7[is.na(clocento$clocent_o7)] = 0
write.dta(clocento, "Banco de Dados\\07_clocent_o2.dta")

#clocentd$clocent_d7[is.na(clocentd$clocent_d7)] = 0
write.dta(clocentd, "Banco de Dados\\07_clocent_d2.dta")

#clocentout$clocentout_o7[is.na(clocentout$clocentout_o7)] = 0
write.dta(clocentout, "Banco de Dados\\07_clocentout.dta")

#eigcento$eigcent_o7[is.na(eigcento$eicent_o7)] = 0
write.dta(eigcento, "Banco de Dados\\07_eigcent_o2.dta")

#eigcentd$eigcent_d7[is.na(eigcentd$eicent_d7)] = 0
write.dta(eigcentd, "Banco de Dados\\07_eigcent_d2.dta")

#hubscoro$hubscoro_o7[is.na(hubscoro$hubscoro_o7)] = 0
write.dta(hubscoro, "Banco de Dados\\07_hubscoro.dta")

#autscord$autscord_d7[is.na(autscord$autscord_d7)] = 0
write.dta(autscord, "Banco de Dados\\07_autscord.dta")




#Fixing the indexes of the zones that do not match
library(haven)
corresp07_17 <- read_excel("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2017/Banco de Dados/CORRESPONDÊNCIA ENTRE ZONAS 2007 e 2017.xlsx", 
                           sheet = "Correspondência", range = "A6:B523")


colnames(corresp07_17)<- c("Index07", "Index17")

correctclo<-clocentd
correctout<-clocentout
correcteig<-eigcentd
correcthub<-hubscoro
correctaut<-autscord

for (h in 517){
  #Finding correspondent index from 2017 in the 2007 region division
  correspondent<-corresp07_17$Index07[h]
  
  correctclo[h,]<-clocentd[correspondent,]
  
  correctout[h,]<-clocentout[correspondent,]
  
  correcteig[h,]<-eigcentd[correspondent,]
  
  correcthub[h,]<-hubscoro[correspondent,]
  
  correctaut[h,]<-autscord[correspondent,]
}

write.dta(correctclo, "Banco de Dados\\07_clocent_d2_adj.dta")
write.dta(correctout, "Banco de Dados\\07_clocentout_adj.dta")
write.dta(correcteig, "Banco de Dados\\07_eigcent_d2_adj.dta")
write.dta(correcthub, "Banco de Dados\\07_hubscoro_adj.dta")
write.dta(autscord, "Banco de Dados\\07_autscord_adj.dta")

