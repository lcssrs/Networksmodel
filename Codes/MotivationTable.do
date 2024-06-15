
/////////////////////////////////////////////////////////


clear all

cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data"


//DATA 2017
frame create set17

frame set17: import dbase "OD\OD-2017\Banco de Dados\OD_2017_v1"

frame change set17

//FIRST TABLE
gen vel17 = DISTANCIA/DURACAO


eststo tab17: estpost tabstat vel17 if inlist(MOTIVO_D, 8, 1, 2, 3, 5, 6, 7, 9 ,10) & inlist(MOTIVO_O, 8, 1, 2, 3, 5, 6, 7, 9 ,10) &MODOPRIN<15 [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

/// data 2007

frame create set07
frame set07: import dbase "OD\OD-2007\Banco de Dados\OD_2007_v2d" //check this piece
frame change set07


gen vel07 = DISTANCIA/DURACAO

eststo tab07: estpost tabstat vel07 if inlist(MOTIVO_D, 8, 1, 2, 3, 5, 6, 7, 9 ,10) & inlist(MOTIVO_O, 8, 1, 2, 3, 5, 6, 7, 9 ,10) &MODOPRIN<15 [weight = FE_VIA], by(CRITERIOBR) stats(N mean)

esttab tab17 tab07, cells(mean)

esttab tab17 tab07 using "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Term Paper\Tables\0.mottab.tex", cells(mean) replace



///////////////////////NOT FINISHED//// NEXT STEP ADJUST THE DATA AND GO BACK TO THE CROSS SECTION


import delimited using dummieszones3

rename numerozona ZONA_O

gen ZONA_D = ZONA_O

joinby ZONA_O ZONA_D using "OD\tabledata.dta"


//Importing 2007 data
joinby ZONA_O using "OD\OD-2007\Banco de Dados\07_hubscoro_adj"


joinby ZONA_D using "OD\OD-2007\Banco de Dados\07_clocent_d2_adj"

joinby ZONA_D using "OD\OD-2007\Banco de Dados\07_eigcent_d2_adj"


joinby ZONA_O using "OD\OD-2007\Banco de Dados\07_clocentout_adj"

joinby ZONA_D using "OD\OD-2007\Banco de Dados\07_autscord_adj.dta"





/////


gen ZONA_O = ZONA_D
//IMPORT CENTRALITIES

joinby ZONA_O using "OD\OD-2017\Banco de Dados\Full sample\17_hubscoro" 

joinby ZONA_D using "OD\OD-2017\Banco de Dados\Full sample\17_clocent_d2" 

joinby ZONA_O using "OD\OD-2017\Banco de Dados\Full sample\17_eigcent_o2"

joinby ZONA_O using "OD\OD-2017\Banco de Dados\Full sample\17_eigcent_o2"

joinby ZONA_O using "OD\OD-2017\Banco de Dados\Full sample\17_clocentout"

joinby ZONA_D using "OD\OD-2017\Banco de Dados\Full sample\17_autscord"

rename eigcent_d17 eigcent_d

drop eigcent_d17
drop clocent_d17
drop clocentout_o17
drop hubscoro_o17
drop autscord_d17

drop lvel17 leigd17
drop lclo17 lcld17 laut lhub

//GENERATING VARIABLES

gen lvel17 = log(vel17)
gen leigd17 = log(eigcent_d17)
gen lclo17 = log(clocentout_o17)
gen lcld17 = log(clocent_d17)
gen laut = log(autscord_d17)
gen lhub = log(hubscoro_o17)
gen leigo = log(eigcent_o17)


gen trans = 0
replace trans = 1 if ZONA_T1 != .
replace trans = 2 if ZONA_T2 != .
replace trans = 3 if ZONA_T3 != .


reg lvel17 leigd17 leigo i.MODOPRIN i.trans c.leigd17#i.CRITERIOBR c.leigo#i.CRITERIOBR[weight = FE_VIA] if MODOPRIN<15 & MOTIVO_D != 4 & MOTIVO_O != 4





