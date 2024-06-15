
library(foreign)
library(readxl)


######Getting content from the tables - Variable of interest ######

## First from 2017
library(readxl)
setwd("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2017")
Tab01 <- read_excel("Tabelas/Tab01_OD2017.xlsx", range = "A8:K526")

Tab01 <- Tab01[-1,]
Tab01["ZONA_O"] <- Tab01$ZONA
Tab01["ZONA_D"] <- Tab01$ZONA

Tab01<- Tab01[, c("ZONA_O", "ZONA_D", "População", "Empregos", "Particulares", "Produzidas", "Atraidas")]

colnames(Tab01)[c(3,4,5,6,7)]<- c("POP17", "EMP17", "PART17", "PROD17", "ATR17")

#write.dta(Tab01, "Banco de Dados\\zonedata.dta")


Tab06 <- read_excel("Tabelas/Tab06_OD2017.xlsx", range = "A8:D526", col_types = c("numeric", "skip", "skip", "numeric"))
Tab06 <- Tab06[-1,]

Tab01$PCINC17<- Tab06$RENDAPC

#get correspondence




setwd("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2007")


Tab02 <- read_excel("Tabelas/Tab01_OD2007.xlsx", range = "A8:K469")

Tab02 <- Tab02[-1,]
Tab02["ZONA_O"] <- Tab02$Zona
Tab02["ZONA_D"] <- Tab02$Zona

Tab02<- Tab02[, c("ZONA_O", "ZONA_D", "População", "Empregos", "Particulares", "Produzidas", "Atraidas")]

colnames(Tab02)[c(3,4,5,6,7)]<- c("POP07", "EMP07", "PART07", "PROD07", "ATR07")



Tab07 <- read_excel("Tabelas/Tab06_OD2007.xlsx", range = "A7:D468", col_types = c("numeric", "skip", "skip", "numeric"))
Tab07 <- Tab07[-1,]

Tab02$PCINC07<- Tab07$RENDAPC




##Getting correspondences

corresp07_17 <- read_excel("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2017/Banco de Dados/CORRESPONDÊNCIA ENTRE ZONAS 2007 e 2017.xlsx", sheet = "Correspondência", range = "A6:B523")

colnames(corresp07_17)<- c("Index07", "Index17")

Tabaux<-data.frame(Tab02)

for (h in 1:517){
  #Finding correspondent index from 2017 in the 2007 region division
  correspondent<-corresp07_17$Index07[h]
  
  Tabaux[h,]<-data.frame(Tab02[correspondent,])
  Tabaux$ZONA_O[h]<-h
  Tabaux$ZONA_D[h]<-h
}


Tabfinal<-data.frame(Tab01,Tabaux[,3:8])


write.dta(Tabfinal, "G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/tabledata.dta")