gen white = .
replace white = 1 if race == 1
replace white = 0 if race < 0 | race > 1

gen black = .
replace black = 1 if race == 2
replace black = 0 if race < 0 | race == 1 | race == 3

gen oth_race = .
replace oth_race = 1 if race == 3
replace oth_race = 0 if race < 0 | race == 1 | race == 2

gen latino = .
replace latino = 1 if hispanic > 1
replace latino = . if hispanic < 0
replace latino = 0 if latino == .

gen race_fourcat = .
replace race_fourcat = 1 if (white == 1 & latino == 0)
replace race_fourcat = 2 if (black == 1 & latino == 0)
replace race_fourcat = 3 if latino == 1
replace race_fourcat = 4 if (white != 1 & black != 1 & latino != 1)

gen catholic = (relig == 2)
replace catholic = . if relig <= 0
replace catholic = 0 if relig == 1 | relig > 2

gen protestant = (relig == 1 | relig == 11 | relig == 13)
replace protestant = . if relig <= 0
replace protestant = 0 if (relig >= 2 & relig < 11) | relig == 12

gen none = (relig == 4)
replace none = . if relig <= 0
replace none = 0 if relig == 1 | relig == 2 | relig == 3 | relig > 4

gen Oth_rel = (relig == 3 | relig == 5 | relig == 6 | relig == 7 | relig == 8 | relig == 9 | relig == 10 | relig == 12)
replace Oth_rel = . if relig <= 0
replace Oth_rel = 0 if relig == 1 | relig == 2 | relig == 4 | relig == 13

gen relig_cat = 4
replace relig_cat = 1 if catholic == 1
replace relig_cat = 2 if protestant == 1
replace relig_cat = 3 if none == 1

gen tradition = "placeholder for formatting"
replace tradition = "catholic" if catholic == 1
replace tradition = "protestant" if protestant == 1
replace tradition = "none" if none == 1
replace tradition = "other rel" if Oth_rel == 1
replace tradition = "" if tradition == "placeholder for formatting"

gen race_cat = "placeholder for formatting"
replace race_cat = "1 white" if race_fourcat == 1
replace race_cat = "3 black" if race_fourcat == 2
replace race_cat = "2 Hisp" if race_fourcat == 3
replace race_cat = "4 other" if race_fourcat == 4
replace race_cat = "" if missing(race_fourcat)

gen prot_type = "mainline" if (denom == 11 & race != 2) | (denom == 30) | (denom == 50) | (denom == 35) | (denom == 31) | (denom == 38) | (denom == 28 & race != 2) | (denom == 40) | (denom == 48) | (denom == 43) | (denom == 22) | (denom == 41) | (denom == 70 & attend < 0) | (denom == 70 & attend == 0) | (denom == 70 & attend == 1) | (denom == 70 & attend == 2) | (denom == 70 & attend == 3) | (denom == 11 & attend < 0) | (denom == 11 & attend == 0) | (denom == 11 & attend == 1) | (denom == 11 & attend == 2) | (denom == 11 & attend == 3) | (denom == 13 & attend < 0) | (denom == 13 & attend == 0) | (denom == 13 & attend == 1) | (denom == 13 & attend == 2) | (denom == 13 & attend == 3)

replace prot_type = "conservative" if (denom == 10 & race != 2) | (denom == 18 & race != 2) | (denom == 32) | (denom == 15 & race != 2) | (denom == 34) | (denom == 23 & race != 2) | (denom == 42) | (denom == 14 & race != 2) | (denom == 33) | (denom == 70 & attend == 4) | (denom == 70 & attend == 5) | (denom == 70 & attend == 6) | (denom == 70 & attend == 7) | (denom == 70 & attend == 8) | (relig == 11 & attend == 4) | (relig == 11 & attend == 5) | (relig == 11 & attend == 6) | (relig == 11 & attend == 7) | (relig == 11 & attend == 8)

replace prot_type = "black protestant" if (denom == 20) | (denom == 21) | (denom == 10 & race == 2) | (denom == 11 & race == 2) | (denom == 18 & race == 2) | (denom == 28 & race == 2) | (denom == 12) | (denom == 13) | (denom == 15 & race == 2) | (denom == 23 & race == 2) | (denom == 14 & race == 2)


replace prot_type = "black protestant" if (other == 15) | (other == 14) | (other == 128) | (other == 37) | (other == 38) | (other == 7) | (other == 88) | (other == 98) | (other == 56) | (other == 104) | (other == 103) | (other == 133) | (other == 78) | (other == 79) | (other == 21) | (other == 85) | (other == 86) | (other == 87)
replace prot_type = "mainline" if (other == 99) | (other == 19) | (other == 25) | (other == 40) | (other == 44) | (other == 46) | (other == 49) | (other == 48) | (other == 50) | (other == 54) | (other == 89) | (other == 1) | (other == 105) | (other == 8) | (other == 70) | (other == 71) | (other == 73) | (other == 72) | (other == 148) | (other == 23) | (other == 119) | (other == 81) | (other == 96)

replace prot_type = "conservative" if (other == 10) | (other == 111) | (other == 107) | (other == 138) | (other == 12) | (other == 109) | (other == 20) | (other == 22) | (other == 132) | (other == 110) | (other == 122) | (other == 102) | (other == 135) | (other == 108) | (other == 29) | (other == 9) | (other == 125) | (other == 28) | (other == 31) | (other == 32) | (other == 26) | (other == 101) | (other == 36) | (other == 35) | (other == 34) | (other == 127) | (other == 121) | (other == 5) | (other == 116) | (other == 39) | (other == 41) | (other == 42) | (other == 43) | (other == 2) | (other == 91) | (other == 45) | (other == 47) | (other == 112) | (other == 120) | (other == 139) | (other == 124) | (other == 51) | (other == 53) | (other == 13) | (other == 16) | (other == 52) | (other == 100) | (other == 90) | (other == 18) | (other == 55) | (other == 24) | (other == 3) | (other == 134) | (other == 146) | (other == 129) | (other == 131) | (other == 63) | (other == 115) | (other == 117) | (other == 92) | (other == 65) | (other == 6) | (other == 27) | (other == 97) | (other == 68) | (other == 66) | (other == 67) | (other == 69) | (other == 140) | (other == 57) | (other == 133) | (other == 76) | (other == 77) | (other == 94) | (other == 106) | (other == 118) | (other == 83) | (other == 84) | (other == 29) | (other == 17) | (other == 75) | (other == 136) | (other == 141) | (other == 74) | (other == 11) | (other == 80) | (other == 82) | (other == 95)

replace prot_type = "conservative" if other == 93
replace prot_type = "black protestant" if other == 93 & race == 2
replace prot_type = "conservative" if other == 162
replace prot_type = "conservative" if other == 176
replace prot_type = "conservative" if other == 182
replace prot_type = "mainline" if other == 219

replace prot_type = "" if prot_type == "unknown placeholder"

replace prot_type = "mainline" if prot_type == "" & relig == 1
replace prot_type = "conservative" if prot_type == "" & relig == 13 & attend > 3
replace prot_type = "mainline" if prot_type == "" & relig == 13 & attend < 4

gen trad_sixcat_ = "unknown placeholder for trad_sixcat_"
replace trad_sixcat_ = "catholic" if tradition == "catholic"
replace trad_sixcat_ = "mainline" if tradition == "protestant" & prot_type == "mainline"
replace trad_sixcat_ = "conservative" if tradition == "protestant" & prot_type == "conservative"
replace trad_sixcat_ = "none" if tradition == "none"
replace trad_sixcat_ = "other" if tradition == "other rel"
replace trad_sixcat_ = "black protestant" if tradition == "protestant" & prot_type == "black protestant"

replace trad_sixcat_ = "" if trad_sixcat_ == "unknown placeholder for trad_sixcat_"

gen reltrad2 = trad_sixcat_
replace reltrad2 = "conservative" if prot_type == "black protestant" & relig == 11
replace reltrad2 = "conservative" if prot_type == "black protestant" & relig == 13
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 10
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 12
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 13
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 14
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 15
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 18
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 70
replace reltrad2 = "conservative" if prot_type == "black protestant" & denom == 60
replace reltrad2 = "mainline" if prot_type == "black protestant" & denom == 11
replace reltrad2 = "mainline" if prot_type == "black protestant" & denom == 20
replace reltrad2 = "mainline" if prot_type == "black protestant" & denom == 21
replace reltrad2 = "mainline" if prot_type == "black protestant" & denom == 23
replace reltrad2 = "mainline" if prot_type == "black protestant" & denom == 28




gen new_trad = "placeholder for the variable new_trad"
replace new_trad = "1 white catholic" if race_fourcat == 1 & reltrad2 == "catholic"
replace new_trad = "3 white mp" if race_fourcat == 1 & reltrad2 == "mainline"
replace new_trad = "4 white cp" if race_fourcat == 1 & reltrad2 == "conservative"
replace new_trad = "5 white none" if race_fourcat == 1 & reltrad2 == "none"
replace new_trad = "7 all other trads" if race_fourcat == 1 & reltrad2 == "other"

replace new_trad = "2 latino catholic" if race_fourcat == 2 & reltrad2 == "catholic"
replace new_trad = "6 latino prot" if race_fourcat == 2 & inlist(reltrad2, "mainline", "conservative")
replace new_trad = "7 all other trads" if race_fourcat == 2 & inlist(reltrad2, "other","none")

replace new_trad = "7 all other trads" if race_fourcat == 3 & inlist(reltrad2, "catholic", "mainline", "conservative", "none", "other")

replace new_trad = "7 all other trads" if race_fourcat == 4 & inlist(reltrad2, "catholic", "mainline", "conservative", "none", "other")
