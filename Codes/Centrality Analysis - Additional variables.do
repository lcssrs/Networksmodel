

//import from qgis and 2007 2017

clear
cd "G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Data"

import delimited using dummieszones3

rename ZONA ZONA_O

gen ZONA_D = ZONA_O

joinby ZONA_O ZONA_D using "OD\tabledata.dta"


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




//Substituting variables to account for zones included/excluded from the network

replace clocent_d17 = 0 if clocent_d17 == . & clocent_d7 != .

replace clocent_d7 = 0 if clocent_d7 == . & clocent_d17 != .

replace clocentout_o17 = 0 if clocentout_o17 == . & clocentout_o7 != .

replace clocentout_o7 = 0 if clocentout_o7 == . & clocentout_o17 != .

replace eigcent_d17 = 0 if eigcent_d17 == . & eigcent_d7 != .

replace eigcent_d7 = 0 if eigcent_d7 == . & eigcent_d17 != .

replace hubscoro_o17 = 0 if hubscoro_o17 == . & hubscoro_o7 != .

replace hubscoro_o7 = 0 if hubscoro_o7 == . & hubscoro_o17 != .

replace autscord_d17 = 0 if autscord_d17 == . & autscord_d7 != 0

replace autscord_d7 = 0 if autscord_d7 == . & autscord_d17 != 0



//Creating relevant variables

gen clocent = clocent_d17 - clocent_d7

gen clocentout = clocentout_o17 - clocentout_o7

gen eigcent = eigcent_d17 - eigcent_d7

gen hubscoro = hubscoro_o17 - hubscoro_o7

gen autscord = autscord_d17 - autscord_d7


gen pop = POP17 - POP07
gen emp = EMP17 - EMP07
gen aut = PART17 - PART07
gen inc = PCINC17 - PCINC07
gen viat = ATR17 - ATR07
gen prod = PROD17 - PROD07
gen tot = viat + prod


gen gpop = ln(POP17) - ln(POP07)
gen gemp = ln(EMP17) - ln(EMP07)
gen gaut = ln(PART17) - ln(PART07)
gen ginc = ln(PCINC17) - ln(PCINC07)
gen gviat = ln(PROD17 + ATR17) - ln(PROD17+ATR07)

gen gprod = ln(PROD17) - ln(PROD07)
gen grat = ln(ATR17) - ln(ATR07)

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


gen lg00 = log(vol00_vol00_sum) - log(vol95_vol95_sum)
gen lg05 = log(vol05_vol05_sum) - log(vol00_vol00_sum)
gen lg10 = log(vol10_vol10_sum) - log(vol05_vol05_sum)
gen lg15 = log(vol15_vol15_sum) - log(vol10_vol10_sum)


gen llg10 = log(vol10_vol10_sum - vol05_vol05_sum)
gen llg15 = log(vol15_vol15_sum - vol10_vol10_sum)


//Creating dummies for external rings and clustering subway+railwayy = all

gen m3 = indirect2 - indirect
gen m2 = indirect - direct

gen me = m2 + m3

gen cp3 = d3cptm - d2cptm
gen cp2 = d2cptm - d1cptm

gen cp = cp2 + cp3

gen all1 = direct + d1cptm
gen all2 = indirect + d2cptm
gen all3 = indirect2 + d3cptm

gen alli2 = all2 - all1 
gen alli3 = all3 - all2
gen alli = alli2 + alli3


//REGRESSIONS

cd"G:\Other computers\My laptop\Workarea\QEM Msc\Barcelona\2nd semester\Spatial Economics\Term paper\Term Paper\Tables"



//CLOSENESS INCENTRALITY

eststo clear

eststo: reg gclocent direct indirect indirect2 d1cptm d2cptm d3cptm gemp gpop ginc gviat lg10
eststo: reg gclocentout direct indirect indirect2 d1cptm d2cptm d3cptm gemp gpop ginc gviat lg10


esttab using 1.clocent.tex, b(3) se r2 title("Closeness in centrality 1st specification") label star(* 0.10 ** 0.05 *** 0.01) wide replace


eststo clear

eststo: reg gclocent direct m2 m3 d1cptm cp2 cp3 gemp gpop ginc gviat lg10
eststo: reg gclocentout direct m2 m3 d1cptm cp2 cp3 gemp gpop ginc gaut gviat lg10

esttab using 2.clocent.tex, b(3) se r2 title("Closeness in centrality 2nd specification") label star(* 0.10 ** 0.05 *** 0.01) wide replace






//EIGCENTRALITY


eststo clear

eststo: reg geigcent direct m2 m3 d1cptm cp2 cp3 lg10 gemp gpop gaut ginc grat

esttab using 3.eigcent.tex, b(3) se r2 title("Eigencentrality") label star(* 0.10 ** 0.05 *** 0.01) wide replace



//HUBS AND AUTHORITIES


eststo clear

eststo: reg hubscoro direct me d1cptm cp gemp gpop gaut ginc gprod
eststo: reg autscord direct me d1cptm cp gemp gpop gaut ginc gviat

esttab using 4.authubscor.tex, b(3) se r2 title("Hubs and Authorities scores") label star(* 0.10 ** 0.05 *** 0.01) wide replace





//CONCLUDING EVIDENCES


eststo clear

eststo: reg gviat gemp gpop direct m2 m3 d1cptm cp2 cp3
eststo: reg grat gemp gpop gaut ginc direct m2 m3 d1cptm cp2 cp3
eststo: reg gprod gemp gpop gaut ginc direct m2 m3 d1cptm cp2 cp3

esttab using 5.gviat.tex, b(3) se r2 title("Changes in travels") label star(* 0.10 ** 0.05 *** 0.01) wide replace




///////           END          ///////////////////////////////
//////////////////////////////////////////////////////////////


//SUPPLEMENTARY REGRESSIONS

//Metro
reg clocent d1cptm llg10 lg15

reg clocentout d1cptm d2cptm d3cptm lg10 lg15

reg eigcent d1cptm d2cptm d3cptm lg10 lg15

reg hubscoro d1cptm d2cptm d3cptm lg10 lg15



//METRO
reg clocent direct indirect indirect2 lg15 lg10

reg clocentout indirect indirect2 hubscoro lg15 lg10

reg eigcent direct indirect indirect2 lg15 lg10 

reg hubscoro direct indirect indirect2 llg15 lg10



reg clocent all1 all2 all3 lg10 lg15

reg clocentout all1 all2 all3 lg10 lg15

reg eigcent all1 all2 all3 lg10 lg15

reg hubscoro all1 all2 all3 lg10 lg15


//CPTM
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


