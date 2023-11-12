////////////////////////////////
//
//   Steensland
//
////////////////////////////


//Coding Reltrad
//reltrad
gen denom1 = denom
  recode denom1 (12 13 20 21 = 1000)
  recode denom1 (32 33 34 42 = 2000)
  recode denom1 (22 30 31 35 38 40 41 43 48 50 = 3000)
  recode denom1 (10 14 15 18 23 = 998)
  recode denom1 (11 28 = 999)
  replace denom1=1000 if race==2 & denom1==998
  replace denom1 = 2000 if race~=2 & denom1==998
  replace denom1 = 1000 if race==2 & denom1==999
  replace denom1 = 3000 if race~=2 & denom1==999
tab denom1

gen othtrad = other
  recode othtrad (7 14 15 21 37 38 56 78 79 85 86 87 88 98 103 104 128 133 = 1000)
  recode othtrad (2 3 5 6 9 10 12 13 16 18 20 22 24 26 27 28 29 31 32 34 35 36 39 41 42 43 45 47 51 52 53 55 57 63 65 66 67 68 69 76 77 83 84 90 91 92 94 97 100 101 102 106 107 108 109 110 111 112 115 116 117 118 120 121 122 124 125 127 129 131 132 133 134 135 138 139 140 146 181 = 2000)
  replace othtrad=1000 if race==2 & othtrad==93
  replace othtrad=2000 if race~=2 & othtrad==93
  recode othtrad (1 8 19 23 25 40 44 46 49 48 50 54 70 71 73 72 81 89 96 99 105 119 143 148 166 178 = 3000)
  recode othtrad (11 17 30 33 58 59 60 61 62 64 74 75 80 82 95 113 114 123 130 136 137 141 145 152 153 155 167 171 173 187 188 189 195 = 4000)
//Find out what 195 equals
  recode othtrad (144 150 151 154 157 158 159 165 168 169 170 172 174 175 176 177 179 180=999)
  replace othtrad=1000 if race==2 & othtrad==999
  recode othtrad (999=1000) if race==2
  replace othtrad=2000 if race~=2 & othtrad==999
  recode othtrad (999=2000) if race~=2

gen reltrad=.
  replace reltrad=1 if denom1==1000
  replace reltrad=2 if denom1==2000
  replace reltrad=3 if denom1==3000

  replace reltrad = 1 if othtrad==1000
  replace reltrad = 2 if othtrad==2000
  replace reltrad = 3 if othtrad==3000
  replace reltrad = 4 if othtrad==4000

  replace reltrad = 1 if denom1==70 & race==2
  replace reltrad = 2 if denom1==70 & race~=2

  replace reltrad = 1 if (relig==11 | relig==13) & race==2
  replace reltrad = 2 if (relig==11 | relig==13) & race~=2
  replace reltrad = 5 if relig==2 | other==123

  replace reltrad = 6 if relig==3
  replace reltrad = 7 if relig==4 | relig==.d | relig==.n
  replace reltrad = 4 if relig>=5 & relig<=9

  replace reltrad = 3 if relig==10
  replace reltrad = 4 if relig==12

  replace reltrad = .n if other==.n | denom1==.n
  replace reltrad = .d if other==.d | denom1==.d
  replace reltrad = .d if denom1==60 & other==0

label variable reltrad "Steensland/Chaves Relig Affil"
label define denomin 1 "black protestant" 2 "evang" 3 "mainline"  4 "other" 5 "catholic" 6 "jewish" 7 "none"  9 "missing" .d "DK" .i "I/A" .n "N/A"
label values reltrad denomin

tab reltrad
tab reltrad, missing

//Drop Coding Variables
drop othtrad denom1

//Coding Reltrad Binaries

xi i.reltrad, noomit
  rename _Ireltrad_1 blackprot
  label var blackprot "R is Black Protestant"
  label values blackprot binary
  
  rename _Ireltrad_2 evang
  label var evang "R is Evangelical"
  label values evang binary
  
  rename _Ireltrad_3 mainline
  label var mainline "R is Mainliner"
  label values mainline binary
  
  rename _Ireltrad_4 othtrad
  label var othtrad "R is Other Religious Tradition"
  label values othtrad binary
  
  rename _Ireltrad_5 catholic
  label var catholic "R is Catholic"
  label values catholic binary
  
  rename _Ireltrad_6 jewish
  label var jewish "R is Jewish"
  label values jewish binary
  
  rename _Ireltrad_7 nones
  label var nones "R has no religious Affiliation"
  label values nones binary
  
  // Collapsing Jewes and Black Protestant into other
  recode reltrad (1 4 6 = 1) (.=.) (else=0), gen(othv2)
  label var othv2 "R is Other Religious Tradition (with Jew and Black Prod)"
  label values othv2 binary

foreach x in blackprot evang mainline othtrad catholic jewish nones othv2 {
  tab `x'
}


//Reltrad @ 16
gen denom2 = denom16
  recode denom2 (12 13 20 21 = 1000)
  recode denom2 (32 33 34 42 = 2000)
  recode denom2 (22 30 31 35 38 40 41 43 48 50 = 3000)
  recode denom2 (10 14 15 18 23 = 998)
  recode denom2 (11 28 = 999)
  replace denom2 = 1000 if race==2 & denom2==998
  replace denom2 = 2000 if race~=2 & denom2==998
  replace denom2 = 1000 if race==2 & denom2==999
  replace denom2 = 3000 if race~=2 & denom2==999

tab denom2

gen othtrad16 = oth16
  recode othtrad16 (7 14 15 21 37 38 56 78 79 85 86 87 88 98 103 104 128 133 = 1000)
  recode othtrad16 (2 3 5 6 9 10 12 13 16 18 20 22 24 26 27 28 29 31 32 34 35 36 39 41 42 43 45 47 51 52 53 55 57 63 65 66 67 68 69 76 77 83 84 90 91 92 94 97 100 101 102 106 107 108 109 110 111 112 115 116 117 118 120 121 122 124 125 127 129 131 132 133 134 135 138 139 140 146 181 = 2000)
  replace othtrad16=1000 if race==2 & othtrad16==93
  replace othtrad16=2000 if race~=2 & othtrad16==93
  recode othtrad16 (1 8 19 23 25 40 44 46 49 48 50 54 70 71 73 72 81 89 96 99 105 119 143 148 166 178 = 3000)
  recode othtrad16 (11 17 30 33 58 59 60 61 62 64 74 75 80 82 95 113 114 123 130 136 137 141 145 152 153 155 167 171 173 187 188 189 195 = 4000)
//Find out what 195 equals
  recode othtrad16 (144 150 151 154 157 158 159 165 168 169 170 172 174 175 176 177 179 180=999)
  replace othtrad16=1000 if race==2 & othtrad16==999
  recode othtrad16 (999=1000) if race==2
  replace othtrad16=2000 if race~=2 & othtrad16==999
  recode othtrad16 (999=2000) if race~=2

gen reltrad16=.
  replace reltrad16=1 if denom2==1000
  replace reltrad16=2 if denom2==2000
  replace reltrad16=3 if denom2==3000

  replace reltrad16 = 1 if othtrad16==1000
  replace reltrad16 = 2 if othtrad16==2000
  replace reltrad16 = 3 if othtrad16==3000
  replace reltrad16 = 4 if othtrad16==4000

  replace reltrad16 = 1 if denom2==70 & race==2
  replace reltrad16 = 2 if denom2==70 & race~=2

  replace reltrad16 = 1 if (relig16==11 | relig16==13) & race==2
  replace reltrad16 = 2 if (relig16==11 | relig16==13) & race~=2
  replace reltrad16 = 5 if relig16==2 | oth16==123

  replace reltrad16 = 6 if relig16==3
  replace reltrad16 = 7 if relig16==4 | relig16==.d | relig16==.n
  replace reltrad16 = 4 if relig16>=5 & relig16<=9

  replace reltrad16 = 3 if relig16==10 
  replace reltrad16 = 4 if relig16==12

  replace reltrad16 = .n if oth16==.n | denom2==.n
  replace reltrad16 = .d if oth16==.d | denom2==.d
  replace reltrad16 = .d if denom2==60 & oth16==0

label variable reltrad16 "Steensland/Chaves Relig Affil @ 16"
label values reltrad16 denomin

tab reltrad16
tab reltrad16, missing

//Coding Reltrad Binaries
drop denom2 othtrad16

xi i.reltrad16, noomit
  rename _Ireltrad16_1 blackprot16
  label var blackprot16 "R was Black Protestant @ 16"
  label values blackprot16 binary
  
  rename _Ireltrad16_2 evang16
  label var evang16 "R was Evangelical @ 16"
  label values evang16 binary
  
  rename _Ireltrad16_3 mainline16
  label var mainline16 "R was Mainliner @ 16"
  label values mainline16 binary
  
  rename _Ireltrad16_4 othtrad16
  label var othtrad16 "R was Other Religious Tradition @ 16"
  label values othtrad16 binary
  
  rename _Ireltrad16_5 catholic16
  label var catholic16 "R was Catholic @ 16"
  label values catholic16 binary
  
  rename _Ireltrad16_6 jewish16
  label var jewish16 "R was Jewish @ 16"
  label values jewish16 binary
  
  rename _Ireltrad16_7 nones16
  label var nones16 "R had no religious Affiliation @ 16"
  label values nones16 binary
  
  // Collapsing Jews and Black Protestant into other
  recode reltrad16 (1 4 6 = 1) (.=.) (else=0), gen(oth16v2)
  label var oth16v2 "R was Other Religious Tradition @ 16 (with Jew and Black Prod)"
  label values oth16v2 binary

foreach x in blackprot16 evang16 mainline16 othtrad16 catholic16 jewish16 nones16 oth16v2 {
  tab `x'
}

//Spouse Reltrad -spoth spden sprel

gen denom3 = spden
recode denom3 (12 13 20 21 = 1000)
recode denom3 (32 33 34 42 = 2000)
recode denom3 (22 30 31 35 38 40 41 43 48 50 = 3000)
recode denom3 (10 14 15 18 23 = 998)
recode denom3 (11 28 = 999)
replace denom3=1000 if race==2 & denom3==998
replace denom3 = 2000 if race~=2 & denom3==998
replace denom3 = 1000 if race==2 & denom3==999
replace denom3 = 3000 if race~=2 & denom3==999

tab denom3

gen spothtrad = spother
recode spothtrad (7 14 15 21 37 38 56 78 79 85 86 87 88 98 103 104 128 133 = 1000)
recode spothtrad (2 3 5 6 9 10 12 13 16 18 20 22 24 26 27 28 29 31 32 34 35 36 39 41 42 43 45 47 51 52 53 55 57 63 65 66 67 68 69 76 77 83 84 90 91 92 94 97 100 101 102 106 107 108 109 110 111 112 115 116 117 118 120 121 122 124 125 127 129 131 132 133 134 135 138 139 140 146 181 = 2000)
replace spothtrad=1000 if race==2 & spothtrad==93
replace spothtrad=2000 if race~=2 & spothtrad==93
recode spothtrad (1 8 19 23 25 40 44 46 49 48 50 54 70 71 73 72 81 89 96 99 105 119 143 148 166 178 = 3000)
recode spothtrad (11 17 30 33 58 59 60 61 62 64 74 75 80 82 95 113 114 123 130 136 137 141 145 152 153 155 167 171 173 187 188 189 195 = 4000)
//Find out what 195 equals
recode spothtrad (144 150 151 154 157 158 159 165 168 169 170 172 174 175 176 177 179 180=999)
replace spothtrad=1000 if race==2 & spothtrad==999
recode spothtrad (999=1000) if race==2
replace spothtrad=2000 if race~=2 & spothtrad==999
recode spothtrad (999=2000) if race~=2

gen reltradsp=.

replace reltradsp=1 if denom3==1000
replace reltradsp=2 if denom3==2000
replace reltradsp=3 if denom3==3000

replace reltradsp = 1 if spothtrad==1000
replace reltradsp = 2 if spothtrad==2000
replace reltradsp = 3 if spothtrad==3000
replace reltradsp = 4 if spothtrad==4000

replace reltradsp = 1 if denom3==70 & race==2
replace reltradsp = 2 if denom3==70 & race~=2

replace reltradsp = 1 if (sprel==11 | sprel==13) & race==2
replace reltradsp = 2 if (sprel==11 | sprel==13) & race~=2
replace reltradsp = 5 if sprel==2 | spother==123

replace reltradsp = 6 if sprel==3
replace reltradsp = 7 if sprel==4 | sprel==.d | sprel==.n
replace reltradsp = 4 if sprel>=5 & sprel<=9

replace reltradsp = 3 if sprel==10
replace reltradsp = 4 if sprel==12

replace reltradsp = .n if spother==.n | denom3==.n
replace reltradsp = .d if spother==.d | denom3==.d
replace reltradsp = .d if denom3==60 & spother==0

label variable reltradsp "Steensland/Chaves Relig Affil of spouse"
label values reltradsp denomin

tab reltradsp
tab reltradsp, missing  

drop denom3 spothtrad

xi i.reltradsp, noomit
  rename _Ireltradsp_1 blackprotsp
  label var blackprotsp "R spouse is Black Protestant"
  label values blackprotsp binary
  
  rename _Ireltradsp_2 evangsp
  label var evangsp "R spouse is Evangelical"
  label values evangsp binary
  
  rename _Ireltradsp_3 mainlinesp
  label var mainlinesp "R spouse is Mainliner"
  label values mainlinesp binary
  
  rename _Ireltradsp_4 othtradsp
  label var othtradsp "R spouse is Other Religious Tradition"
  label values othtradsp binary
  
  rename _Ireltradsp_5 catholicsp
  label var catholicsp "R spouse is Catholic"
  label values catholicsp binary
  
  rename _Ireltradsp_6 jewishsp
  label var jewishsp "R spouse is Jewish"
  label values jewishsp binary
  
  rename _Ireltradsp_7 nonessp
  label var nonessp "R spouse has no religious Affiliation"
  label values nonessp binary
  
  // Collapsing Jews and Black Protestant into other
  recode reltradsp (1 4 6 = 1) (.=.) (else=0), gen(othspv2)
  label var othspv2 "R spouse is Other Religious Tradition (with Jew and Black Prod)"
  label values othspv2 binary

foreach x in blackprotsp evangsp mainlinesp othtradsp catholicsp jewishsp nonessp othspv2 {
  tab `x'
}  

** Steensland's Reltrad creates 7 indicators and some of these create problems
** In particular, the Black protestant variable mutes any racial difference when
** you include a race varible in your models. Additionally, there is only a 
** small number of jewish individual in the GSS sample and this create an issue
** with empty cells. The following code decomposes the black protestants across
** the evangelical and mainline categories and collaspes jews into the other
** religious tradition categories. Not the first to make this adjustment, see:
** Uecker and Ellison 2012; Wilcox and Wolfinger 2007; Schleifer and Chaves 2014
  gen reltrad2 = reltrad
    replace reltrad2 = 2 if reltrad == 1 & (relig == 11 | relig == 13)
    replace reltrad2 = 2 if reltrad == 1 & (denom == 10 | denom ==12 |       ///
       denom == 13 | denom == 14 | denom == 15 | denom == 18 | denom == 70 | ///
	   denom == 60)
    replace reltrad2 = 3 if reltrad == 1 & (denom == 11 | denom == 20 |      ///
     denom == 21 | denom == 23 | denom == 28)
  ** Recode new reltrad into sensible categories. NOTE: Jews set to other
  recode reltrad2 (2 = 1) (3 = 2) (4 6 = 3) (5 = 4) (7 = 5)
    label de reltradL 1 "Evang" 2 "Mainline" 3 "Other" 4 "Catholic"          ///
                  5 "Nones", replace 
    label val reltrad2 reltradL
  ** Dropping steensland dummies
  drop mainline blackprot evang othtrad catholic jewish nones othv2 reltrad

  ** Rename reltrad2 to new version of reltrad
  rename reltrad2 reltrad
  ** Creating dummies
  recode reltrad (1=1) (.=.) (else=0), gen(evang)
  recode reltrad (2=1) (.=.) (else=0), gen(mainl)
  recode reltrad (4=1) (.=.) (else=0), gen(cathl)
  recode reltrad (3=1) (.=.) (else=0), gen(othtr)
