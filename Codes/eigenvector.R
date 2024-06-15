library(tidyverse)
library(tidygraph)
library(qgraph)
library(igraph)
library(igraphdata)
library(foreign)
library(readxl)
Tab26_OD2007 <- read_excel("G:/Other computers/My laptop/Workarea/QEM Msc/Barcelona/2nd semester/Spatial Economics/Term paper/Data/OD/OD-2007/Tabelas-OD2007/Tab26_OD2007.xlsx", 
                           range = "B10:QS469", col_names = FALSE)

matrix <- as.matrix(Tab26_OD2007)
g1 <- graph.adjacency(matrix, mode="directed", weighted=TRUE)

g2 <- decompose(g1)

g <- g2[[1]]
#plot(g, layout=layout.fruchterman.reingold)

A <- eigen_centrality(
  g,
  directed = TRUE,
  scale = TRUE,
  weights = NULL,
  options = arpack_defaults
)

df <- data.frame(A$vector)

rownames(df)<-sub("...","",rownames(df))

df[2] <- rownames(df)
colnames(df) <- c("DestEig","ZONA")
df$ZONA <- as.numeric(df$ZONA)
write.dta(df, "C:\\Users\\BANDOLERO\\Desktop\\data.dta")