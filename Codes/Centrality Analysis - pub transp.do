

//import from qgis and 2007 2017

clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data"

import delimited using dummieszones2

rename numerozona ZONA_O

gen ZONA_D = ZONA_O

//Importing 2007 data
joinby ZONA_O using "OD\OD-2007\Banco de Dados\07_hubscoro_adj"


joinby ZONA_D using "OD\OD-2007\Banco de Dados\07_clocent_d2_adj"


joinby ZONA_D using "OD\OD-2007\Banco de Dados\07_eigcent_d2_adj"


joinby ZONA_O using "OD\OD-2007\Banco de Dados\07_clocentout_adj"

joinby ZONA_D using "OD\OD-2007\Banco de Dados\07_autscord_adj.dta"

//Importing 2017 data 

joinby ZONA_O using "OD\OD-2017\Banco de Dados\17_hubscoro" 


joinby ZONA_D using "OD\OD-2017\Banco de Dados\17_clocent_d2" 


joinby ZONA_D using "OD\OD-2017\Banco de Dados\17_eigcent_d2"


joinby ZONA_O using "OD\OD-2017\Banco de Dados\17_clocentout"

joinby ZONA_D using "OD\OD-2017\Banco de Dados\17_autscord"




gen clocent = clocent_d17 - clocent_d7

gen clocentout = clocentout_o17 - clocentout_o7

gen eigcent = eigcent_d17 - eigcent_d7

gen hubscoro = hubscoro_o17 - hubscoro_o7

gen autscord = autscord_d17 - autscord_d7


//growth rates
gen gclocent = log(clocent_d17) - log(clocent_d7)
replace gclocent = 0 if clocent_d17 == 0 & clocent_d7 == 0

gen gclocentout = log(clocentout_o17) - log(clocentout_o7)
replace gclocentout = 0 if clocentout_o17 == 0 & clocentout_o7 == 0

gen geigcent = log(eigcent_d17) - log(eigcent_d7)
replace geigcent = 0 if eigcent_d17 == 0 & eigcent_d7 == 0

gen ghubscoro = log(hubscoro_o17) - log(hubscoro_o7)
replace ghubscoro = 0 if hubscoro_o17 == 0 & hubscoro_o7 == 0

gen gautscord = log(autscord_d17) - log(autscord_d7)
replace gautscord = 0 if autscord_d17 == 0 & autscord_d7 == 0


//growth rates for urbanization


gen lg10 = log(vol10_vol10_sum) - log(vol05_vol05_sum)
gen lg15 = log(vol15_vol15_sum) - log(vol10_vol10_sum)


gen llg10 = log(vol10_vol10_sum - vol05_vol05_sum)
gen llg15 = log(vol15_vol15_sum - vol10_vol10_sum)


//All



gen all1 = direct + d1cptm
gen all2 = indirect + d2cptm
gen all3 = indirect2 + d3cptm



//Metro
reg clocent d1cptm llg10 lg15

reg clocentout d1cptm d2cptm d3cptm lg10 lg15

reg eigcent d1cptm d2cptm d3cptm lg10 lg15

reg hubscoro d1cptm d2cptm d3cptm lg10 lg15



//CPTM
reg clocent direct indirect indirect2 lg15 lg10

reg clocentout indirect indirect2 hubscoro lg15 lg10

reg eigcent direct indirect indirect2 lg15 lg10 

reg hubscoro direct indirect indirect2 llg15 lg10




reg clocent all1 all2 all3 lg10 lg15

reg clocentout all1 all2 all3 lg10 lg15

reg eigcent all1 all2 all3 lg10 lg15

reg hubscoro all1 all2 all3 lg10 lg15


//Metro
reg clocent d1cptm d2cptm d3cptm lg10 lg15

reg clocentout d1cptm d2cptm d3cptm lg10 lg15

reg eigcent d1cptm d2cptm d3cptm lg10 lg15

reg hubscoro d1cptm d2cptm d3cptm lg10 lg15


//Growth rates
//CPTM
reg gclocent direct indirect indirect2 lg10 lg15

reg gclocentout direct indirect indirect2 lg10 lg15

reg geigcent direct indirect indirect2 ghubscoro lg10 lg15

reg ghubscoro direct indirect indirect2 lg10 lg15

//Metro
reg gclocent d1cptm d2cptm d3cptm lg10 lg15

reg gclocentout d1cptm d2cptm d3cptm lg10 lg15

reg geigcent d1cptm d2cptm d3cptm lg10 lg15

reg ghubscoro d1cptm d2cptm d3cptm lg10 lg15



reg gclocent all1 all2 all3 lg10 lg15

reg gclocentout all1 all2 all3 lg10 lg15

reg geigcent all1 all2 all3 lg10 lg15

reg ghubscoro all1 all2 all3 lg10 lg15



gen m3 = indirect - indirect2
gen m2 = indirect2 - direct


gen cp3 = d3cptm - d2cptm
gen cp2 = d2cptm - d1cptm


//EXPERIMENT
reg clocent d2cptm cp3 indirect lg10 


//Cool regression to show 
reg gclocent d1cptm cp2 cp3 indirect2 m3 lg10 i.numeromuni



//negative signal
reg geigcent d1cptm cp2 cp3 direct m2 m3 lg10 i.numeromuni

//Not significant at all
reg ghubscoro d2cptm lg10 i.numeromuni

reg clocentout d1cptm cp2 cp3 direct lg10 i.numeromuni


//solved
reg eigcent all2 lg10

//negative regressors
reg gclocentout d1cptm cp2 cp3 lg10

reg hubscoro d2cptm lg10

reg ghubscoro indirect lg10 

 










