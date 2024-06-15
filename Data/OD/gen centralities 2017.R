rm()
#Measures from 2017 sample

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

# str(df)

df2 <- df[,c("FE_VIA", "MODOPRIN", "DURACAO", "ZONA_O", "ZONA_D", "H_SAIDA", "DISTANCIA", "ZONA_T1", "ZONA_T2", "ZONA_T3", "TIPVG")]

#Selecting motorized travels and no rush hours
df1 <- subset(df2, df2$MODOPRIN<15 & !between(df2$H_SAIDA,7,10) & !between(df2$H_SAIDA,17,20) &df2$TIPVG==1 )

#df1 <- subset(df2, df2$MODOPRIN<15)

df1$VELOCIDADE <- df1$DISTANCIA/df1$DURACAO #???
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
colnames(clocento)[1] <- "clocent_o17"
clocento["ZONA_O"]<-which(CL!="")
#write.dta(clocento, "Banco de Dados\\07_clocent_o2.dta")


clocentd<-data.frame(CL)
colnames(clocentd)[1] <- "clocent_d17"
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
colnames(clocentout)[1] <- "clocentout_o17"
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
colnames(eigcento)[1] <- "eigcent_o17"
eigcento["ZONA_O"]<-which(A2$vector!="")
#write.dta(eigcento, "Banco de Dados\\17_eigcent_o2.dta")

eigcentd<-data.frame(A2$vector)
colnames(eigcentd)[1] <- "eigcent_d17"
eigcentd["ZONA_D"]<-which(A2$vector!="")
#write.dta(eigcentd, "Banco de Dados\\17_eigcent_d2.dta")




##############################
#  HUBS AND AUTHORITIES SCORES

#Selecting travels that started either during the lower band of the upper band of rush hours
df3 <- subset(df2, df2$MODOPRIN<15 & (between(df2$H_SAIDA,7,10) | between(df2$H_SAIDA,17,20)) &df2$TIPVG==1 ) #weekdays

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






























#Replacing nans
matrix3[is.na(matrix3)] = 0

gh1 <- graph.adjacency(matrix3, mode="directed", weighted=TRUE)

gh2 <- decompose(gh1)

gha <- gh2[[1]]

#Hubs authorities centrality
H<-hub_score(gha)$vector

#which(H == sort(H)[length(H)-1])

hubscoro<- data.frame(H)
colnames(hubscoro)[1] <- "hubscoro_o17"
hubscoro["ZONA_O"]<-which(H!="")
#write.dta(hubscoro, "Banco de Dados\\17_hubscoro.dta")


AT<- authority.score(gha)$vector

#which(AT == sort(AT), arr.ind = TRUE)

autscord<-data.frame(AT)
colnames(autscord)[1] <- "autscord_d17"
autscord["ZONA_D"]<-which(AT!="")
#write.dta(autscord, "Banco de Dados\\17_autscord.dta")













######Getting content from the tables######

#Controls in the diff-diff regression because the degree of connectiveness a place gains depends on other variables

#Address reverse causality in this regression no pop increases investment which increases conectivity but investment is controlled for
# employment increases investment which increases conectivity, conectivity increases employment investment is controlled for
# hyp the only channel connectivity increases is through investment that is why it is important to control for


####################### GETTING MEASURES FROM 2007 SAMPLE

for (h in 1:517){
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



#clocento$clocent_o17[is.na(clocento$clocent_o17)] = 0
write.dta(clocento, "Banco de Dados\\17_clocent_o2.dta")

#clocentd$clocent_d17[is.na(clocentd$clocent_d17)] = 0
write.dta(clocentd, "Banco de Dados\\17_clocent_d2.dta")

#clocentout$clocentout_o17[is.na(clocentout$clocentout_o17)] = 0
write.dta(clocentout, "Banco de Dados\\17_clocentout.dta")

#eigcento$eigcent_o17[is.na(eigcento$eicent_o17)] = 0
write.dta(eigcento, "Banco de Dados\\17_eigcent_o2.dta")

#eigcentd$eigcent_d17[is.na(eigcentd$eicent_d17)] = 0
write.dta(eigcentd, "Banco de Dados\\17_eigcent_d2.dta")

#hubscoro$hubscoro_o17[is.na(hubscoro$hubscoro_o17)] = 0
write.dta(hubscoro, "Banco de Dados\\17_hubscoro.dta")

#autscord$autscord_d17[is.na(autscord$autscord_d17)] = 0
write.dta(autscord, "Banco de Dados\\17_autscord.dta")










####In the end get the differences to explain centrality from the tables stats
library(readxl)
Tab01 <- read_excel("Tabelas/Tab01_OD2017.xlsx", 
                           range = "A8:K526")

Tab01 <- Tab01[-1,]
Tab01["ZONA_O"] <- Tab01$ZONA
Tab01["ZONA_D"] <- Tab01$ZONA
write.dta(Tab01, "Banco de Dados\\zonedata.dta")


Tab06 <- read_excel("Tabelas/Tab06_OD2017.xlsx", 
                           range = "A8:D526", col_types = c("numeric", 
                                                            "skip", "skip", "numeric"))
Tab06 <- Tab06[-1,]
Tab06["ZONA_O"] <- Tab06$ZONA
Tab06["ZONA_D"] <- Tab06$ZONA
colnames(Tab06)[2] <- paste('17', colnames(df)[2], sep = '_') 
write.dta(Tab06, "Banco de Dados\\incdata.dta")



