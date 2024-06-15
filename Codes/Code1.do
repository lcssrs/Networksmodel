clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD-2017\Banco de Dados"

import dbase OD_2017_v1


joinby ZONA_O using clocent_o


joinby ZONA_D using clocent_d

joinby ZONA_O using eigcent_o
joinby ZONA_D using eigcent_d

joinby ZONA using incdata
joinby ZONA using zonedata


gen vel = DISTANCIA/DURACAO


gen lvel = log(vel)
gen leigo = log(eigcent_o)
gen leigd = log(eigcent_d)
gen lclo = log(clocent_o)
gen lcld = log(clocent_d)


gen trans = 0
replace trans = 1 if ZONA_T1 != .
replace trans = 2 if ZONA_T2 != .
replace trans = 3 if ZONA_T3 != .


reg lvel leigo leigd i.MODO1 i.MODO2 i.MODO3 i.MODO4 i.trans [weight = FE_VIA]

reg lvel lclo lcld i.MODO1 i.MODO2 i.MODO3 i.MODO4 i.trans [weight = FE_VIA]

reg lvel17 eigcent_o17 eigcent_d17 i.MODO1 i.MODO2 i.MODO3 i.trans c.eigcent_o17#i.CRITERIOBR c.eigcent_d17#i.CRITERIOBR[weight = FE_VIA]

reg lvel clocent_o clocent_d i.MODO1 i.MODO2 i.MODO3 i.trans c.clocent_o#i.CRITERIOBR c.clocent_d#i.CRITERIOBR [weight = FE_VIA]



//What to add -> centrality in the mass network at rush hours measure of crowdness
//leigo and lclo not in rush hours measure of infrastructure because it also considers self loops
reg lvel leigo leigd i.MODO1 i.trans c.leigo#i.CRITERIOBR c.leigd##i.CRITERIOBR [weight = FE_VIA]

reg lvel lclo lcld i.MODO1 i.trans c.lclo#i.CRITERIOBR c.lcld##i.CRITERIOBR [weight = FE_VIA]

reg lvel leigd leigo i.MODO1 i.trans c.leigd#i.CRITERIOBR c.leigo#i.CRITERIOBR if MODOPRIN<15

//Cool regression highest R squared - using eigenvectors coming from full matrix modo<15
 reg lvel leigd leigo i.MODOPRIN i.trans c.leigd#i.CRITERIOBR c.leigo#i.CRITERIOBR


//tabstat DURACAO DISTANCIA if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) & (inlist(1, MODO1, MODO2, MODO3, MODO4) | inlist(2, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

tabstat vel if (inlist(1, MODO1, MODO2, MODO3, MODO4) | inlist(2, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

tabstat vel if MODOPRIN<15 [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

tabstat vel if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD 2012\Banco de Dados"

import dbase Mobilidade_2012_v0


gen vel = DISTANCIA/DURACAO


tabstat vel if MODOPRIN<15 [weight = FE_VIA], by(CRITERIO_B) stats(N mean)

//tabstat DURACAO DISTANCIA if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) & (inlist(12, MODO1, MODO2, MODO3, MODO4) | inlist(13, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRITERIO_B) stats(N mean)


//tabstat vel if (inlist(12, MODO1, MODO2, MODO3, MODO4) | inlist(13, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRITERIO_B) stats(N mean)

tabstat vel if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) [weight = FE_VIA], by(CRITERIO_B) stats(N mean)

clear 

cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD-2007\Banco de Dados"

import dbase OD_2007_v2d

joinby using data

gen vel = DISTANCIA/DURACAO

gen lvel = log(vel)
gen leig = log(DestEig)

gen trans = 0
replace trans = 1 if ZONA_T1 != .
replace trans = 2 if ZONA_T2 != .
replace trans = 3 if ZONA_T3 != .



tabstat vel if MODOPRIN<15 [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

reg lvel leig i.MODO1 i.trans if inlist(MOTIVO_D, 1, 2, 3) & inlist(MOTIVO_O, 8) [weight = FE_VIA]


//tabstat DURACAO DISTANCIA if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) & (inlist(13, MODO1, MODO2, MODO3, MODO4) | (inlist(12, MODO1, MODO2, MODO3, MODO4)) | inlist(13, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRITERIOBR) stats(N mean)


//tabstat vel if (inlist(13, MODO1, MODO2, MODO3, MODO4) | (inlist(12, MODO1, MODO2, MODO3, MODO4)) | inlist(13, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRITERIOBR) stats(N mean)


tabstat vel if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) [weight = FE_VIA], by(CRITERIOBR) stats(N mean)
/*
clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD 2002\Banco de Dados"

import dbase od2002


//tabstat DURACAO if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) & (inlist(8, MODO1, MODO2, MODO3, MODO4) | inlist(9, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRIT_BR) stats(N mean)


tabstat DURACAO if (inlist(8, MODO1, MODO2, MODO3, MODO4) | inlist(9, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(CRIT_BR) stats(N mean)

clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data\OD\OD-1997\Banco de Dados\Domiciliar"

import dbase OD97Zona


//tabstat DURACAO if inlist(MOTIVO_D, 8, 1, 2, 3) & inlist(MOTIVO_O, 8, 1, 2, 3) & (inlist(8, MODO1, MODO2, MODO3, MODO4) | inlist(9, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(ABIPEME) stats(N mean)


tabstat DURACAO if (inlist(8, MODO1, MODO2, MODO3, MODO4) | inlist(9, MODO1, MODO2, MODO3, MODO4)) [weight = FE_VIA], by(ABIPEME) stats(N mean)



//With only tabstat I can see that commuting time reduced more within upper classes even when the distance kept constant










