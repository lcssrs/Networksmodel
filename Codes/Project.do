/////////////////WHAT TO ADRESS//////////////



//1. CREATE A BACKUP OF THE DATA BASE AND WORK ON A COPY THEN I DON'T NEED RUN 
//THE CODE EVERYTIME AGAIN






////////////////////////////////////////////////////

clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD-2017\Banco de Dados-OD2017"

import dbase OD_2017_v1


gen vel = DISTANCIA/DURACAO

gen vel = DURACAO/DISTANCIA

bysort CRITERIOBR: sum vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8)

tabstat vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8), by(CRITERIOBR) stats(N mean)




estimates store abc
esttap	
	
	estpost


reg DURACAO QT_AUTO QT_MOTO RENDA_FA GRAU_INS DIA_SEM MODOPRIN [weight=FE_FAM]	

eststo reg1

esttab reg1 using 1.1.tex, beta tex 



// There are 25,100 missings in time duration of the trip

//Second regression
//Income is not significant when explaining duration now because I am only considering trips from home to work
reg DURACAO QT_AUTO QT_MOTO RENDA_FA GRAU_INS DIA_SEM MODOPRIN [weight=FE_FAM]	if MOTIVO_O == 8 & MOTIVO_D == (1 | 2 | 3)

eststo reg2

esttab reg2 using 1.2.tex, beta tex 


//3rd regression

reg DURACAO QT_AUTO QT_MOTO RENDA_FA GRAU_INS DIA_SEM MODOPRIN MOTIVO_D DISTANCIA [weight=FE_FAM]	if MOTIVO_O == 8 




//Show that these variables were power laws
gen dur = log(DURACAO)
gen rend = log(RENDA_FA)
gen dist = log(DISTANCIA)




//Significant regressors
reg dur QT_AUTO QT_MOTO rend i.GRAU_INS DIA_SEM i.MODOPRIN i.MOTIVO_D dist [weight=FE_FAM]	if MOTIVO_O == 8 


//Now address endogeneity questions
//Taking care of transferences

gen trans = 0
replace trans = 1 if ZONA_T1 != .
replace trans = 2 if ZONA_T2 != .
replace trans = 3 if ZONA_T3 != .

reg dur QT_AUTO QT_MOTO rend i.GRAU_INS DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist [weight=FE_FAM]	if MOTIVO_O == 8 


ivregress 2sls dur DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist (rend = GRAU_INS) [weight=FE_FAM]	if MOTIVO_O == 8 



//Controlling for work reasons the effect is not significant nor normal neither iv
reg dur i.MODOPRIN i.trans dist i.CRITERIOBR rend i.GRAU_INS i.CONDMORA i.MUNI_DOM [weight=FE_FAM] if MOTIVO_O == 8 & MOTIVO_D == (1 | 2 | 3)


ivregress 2sls dur i.DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist (rend = i.GRAU_INS) [weight=FE_FAM]	if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)

//No need to test for fixed effects since it is panel dimension



//Testing for another intrument - wealth

//VERY GOOD!!
ivregress 2sls dur i.DIA_SEM i.MODOPRIN i.trans dist (rend = i.GRAU_INS i.SEXO IDADE IDADE2 PONTO_BR) [weight=FE_FAM]	if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)



//////test for endogeneity:  is wealth endogenous?? very probably yes
//Control also for neighbourhood population


//REG WITH PROBLEMS - 0.8432
ivregress 2sls dur i.DIA_SEM i.MODOPRIN i.trans dist (rend = i.GRAU_INS IDADE i.SEXO) [weight=FE_FAM]	if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)




//REGRESSION THAT WORKS - BIGGER R2 0.8942
ivregress 2sls dur i.DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist i.MUNI_DOM (rend = i.CRITERIOBR) [weight=FE_FAM] if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)


//R2 0.777
ivregress 2sls dur i.MODOPRIN i.MOTIVO_D i.trans dist i.MUNI_DOM PONTO_BR (rend = i.GRAU_INS i.SEXO IDADE) [weight=FE_FAM] if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)


//R2 0.8087 WORKING REND = -0.04
ivregress 2sls dur i.MODOPRIN i.MOTIVO_D i.trans dist i.MUNI_DOM (rend = i.GRAU_INS i.SEXO IDADE) [weight=FE_FAM] 



//I have each attributte of the house, what if I control for it, instead of PONTO_BR??


//Working but R2 0.8093
ivregress 2sls dur i.MODOPRIN i.MOTIVO_D i.trans dist QT_AUTO QT_MOTO QT_BANHO i.CONDMORA (rend = i.GRAU_INS i.SEXO IDADE) [weight=FE_FAM] 


//Working R2 0.8494
ivregress 2sls dur i.DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist i.MUNI_DOM i.CONDMORA (rend = i.CRITERIOBR) [weight=FE_FAM] if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)


ivregress gmm dur i.DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist i.MUNI_DOM i.CONDMORA (PONTO_BR rend = i.GRAU_INS i.SEXO IDADE) [weight=FE_FAM] if MOTIVO_O == 8  & MOTIVO_D == (1 | 2 | 3)


///REPASAR ENDOGENEITY TEST

//OTHER REGS
gen IDADE2 = IDADE^2
gen classe = 0
replace classe = 1 if CRITERIOBR <= 2
replace classe = 2 if CRITERIOBR > 2 & CRITERIOBR < 5
replace classe = 3 if CRITERIOBR >= 5


//REGRESSION CONSIDERING PERCAPITA INCOME HAS SIGNIFICANT EFFECT FOR CLASSES 3 AND 4 -> DO NOT CHANGE THIS PIECE OF CODE
//SEQUENCE
drop rendpc
gen rendpc = RENDA_FA/NO_MORAF
drop lrendpc
gen lrendpc = log(VL_REN_I)
gen lrendpc = log(rendpc)
drop rand  
xtile rand = rendpc, nquantiles(9)

//replace rand = 5 if rand == 6
//replace rand = 4 if rand == 5
//replace rand = 3 if rand == 2

//You have to choose properly how to divide the variable income

ivregress 2sls dur i.trans dist i.MODOPRIN i.MUNI_DOM ANDA_O ANDA_D (lrendpc = i.GRAU_INS i.SEXO IDADE IDADE2 i.OCUP1 i.SETOR1 i.TRABEXT2#i.OCUP2 i.TRABEXT2#i.SETOR2 i.VINC1 i.TRABEXT2#i.VINC2 i.TRABEXT2)  [weight=FE_VIA]


//CONTROLLING FOR ANDA ONLY CLASS 4 IS SIGNIFICANT XTILE(5) OR 6
// CLASSES 7 AND 8 FOR XTILE CLASSES 7 AND 8
//END OF SEQUENCE

//WORK IT HERE








gen IDADE2 = IDADE^2

//ENDOGENEITY TEST

reg lrendpc i.GRAU_INS i.SEXO IDADE IDADE2 i.OCUP1 i.SETOR1 i.TRABEXT2#i.OCUP2 i.TRABEXT2#i.SETOR2 i.VINC1 i.TRABEXT2#i.VINC2 i.TRABEXT2 [weight=FE_FAM] if VL_REN_I != 0

drop pred_rand
predict pred_rand
drop rand1
predict rand1, res

reg dur i.trans dist i.MODOPRIN i.MUNI_DOM ANDA_O ANDA_D lrendpc rand1 [weight=FE_VIA] if VL_REN_I != 0

test rand1

//Durbin-Watson test suggests this new variable is not endogenous anymore
//OLS should be consistent -> coefficient very small

reg dur i.trans dist i.MODOPRIN i.MUNI_DOM ANDA_O ANDA_D lrendpc [weight=FE_VIA]

//NOW DO THE SAME WITH 2007 SAMPLE -> sugests endogeneity



reg rand i.GRAU_INS i.SEXO IDADE IDADE2 i.OCUP1 i.SETOR1 i.OCUP2 i.SETOR2 i.VINC1 i.VINC2


ivregress 2sls dur i.trans dist i.MODOPRIN (i.classe = i.GRAU_INS i.SEXO IDADE IDADE2) [weight=FE_VIA] if  (MOTIVO_O == 8) & (MOTIVO_D == 1 | MOTIVO_D == 2 | MOTIVO_D == 3)


reg dur i.MODOPRIN i.trans dist i.CRITERIOBR [weight=FE_FAM] if MOTIVO_O == (8)  & MOTIVO_D == (1 | 2 | 3)

reg dur i.DIA_SEM i.MODOPRIN i.MOTIVO_D i.trans dist i.MUNI_DOM rend [weight=FE_FAM] 

reg classe i.GRAU_INS i.SEXO IDADE IDADE2 [weight=FE_FAM]




////////////----------------------////////////////

clear 

cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD-2007\Banco de Dados-OD2007"


gen vel = DISTANCIA/DURACAO

bysort CRITERIOBR: sum DURACAO

clear
import dbase OD_2007_v2d


gen vel = DURACAO/DISTANCIA

bysort CRITERIOBR: sum vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8)

tabstat vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8), by(CRITERIOBR) stats(N mean)


gen dur = log(DURACAO)
gen rend = log(RENDA_FA)
gen dist = log(DISTANCIA)



gen trans = 0
replace trans = 1 if ZONA_T1 != .
replace trans = 2 if ZONA_T2 != .
replace trans = 3 if ZONA_T3 != .




clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD 2012\Banco de Dados"

import dbase Mobilidade_2012_v0


gen vel = DISTANCIA/DURACAO

bysort CRITERIO_B: sum DURACAO

gen dur = log(DURACAO)
gen rend = log(RENDA_FA)
//gen dist = log(DISTANCIA)

//There are ont coordinates either

gen vel = DURACAO/DISTANCIA

bysort CRITERIOBR: sum vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8)

tabstat vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8), by(CRITERIO_B) stats(N mean)





clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD 2002\Banco de Dados"

import dbase od2002


gen vel = DISTANCIA/DURACAO


tabstat vel if MOTIVO_O == (8 | 1 | 2| 3) & MOTIVO_D == (1 | 2 | 3 | 8), by(CRIT_BR) stats(N mean)



bysort CRIT_BR: sum DURACAO

gen dur = log(DURACAO)
gen rend = log(RENDA_FA)
gen dist = log(DISTANCIA)



gen trans = 0
replace trans = 1 if ZONA_T1 != .
replace trans = 2 if ZONA_T2 != .
replace trans = 3 if ZONA_T3 != .

gen IDADE2 = IDADE^2

gen rendpc = RENDA_FA/NO_MORAF

gen lrendpc = log(VL_REN_I)


ivregress 2sls dur i.trans dist i.MODOPRIN i.MUNI_DOM ANDA_O ANDA_D (lrendpc = i.GRAU_INS i.SEXO IDADE IDADE2 i.OCUP1 i.SETOR1 i.TRABEXT2#i.OCUP2 i.TRABEXT2#i.SETOR2 i.VINC1 i.TRABEXT2#i.VINC2 i.TRABEXT2)  [weight=FE_VIA]
