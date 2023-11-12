* preserve the original dataset
preserve

* filter the dataset to include only rows year == 2022
keep if year == 2022

* keep only varaibles of age, respondents income, sex, race, degree of partner, degree of respondents
keep age rincome sex race codeg degree

* delete codeg as it provides nothing
drop codeg

* recode degree - having bachelor's or not
tabulate degree
codebook degree
gen deg_bach = .
replace deg_bach = 0 if (degree == 0 | degree == 1 | degree == 2)
replace deg_bach = 1 if (degree == 3 | degree == 4)
tabulate deg_bach // obtain the percentage of having bachelor's degree

* recode race - white or not
tabulate race
codebook race
gen race_white = .
replace race_white = 0 if (race == 2 | race == 3)
replace race_white = 1 if race == 1
tabulate race_white // obtain the percentage of white

* recode sex - female or not
tabulate sex
codebook sex
gen sex_f = .
replace sex_f = 1 if sex == 2
replace sex_f = 0 if sex == 1
tabulate sex_f // obtain the percentage of woman, just trial

* inspect other variables
tabulate age
codebook age

tabulate rincome
codebook rincome

* plot the relation between gender and education
tabulate degree sex, matcell(freq)
histogram degree, by(sex)
* plot side by side
preserve
drop if sex_f != 1 & sex_f != 0
generate count_freq_ds = 1
gen degree_male = degree - 0.2
collapse (count) count_freq_ds, by(degree_male degree sex_f)
twoway bar count_freq_ds degree_male if sex_f == 0, barwidth(0.4) || bar count_freq_ds degree if sex_f == 1, barwidth(0.4)
restore
// seems any further modification has to be done in graph editor, commands are no longer compatible, such as legends and axis and lables

* plot the relation between age and income
graph box age, over(rincome)

* plot the relation between race and income
histogram rincome // plot the income, regardless of race
graph box rincome, over(race)

* correlation scatter - age and rincome, not quite informative
scatter rincome age

* regression
regress rincome sex race degree

* create a new variable identifies unique group based on degree, sex, and race, and then regress against respondents income
egen combined_id = group(degree sex race)
regress rincome combined_id

* test for multicolinearity
cor degree sex race // correlation is acceptable and no multicolinearity detected

regress rincome sex race degree 
vif // all varaince inflation factor is smaller than 5, so still no multicolinearity

* just for trial purpose, suppose there is multicolinearity or we just need to reduce dimensions
pca degree sex race
predict pc_dsr, score
regress rincome pc_dsr

* logistic regression
* parse the dependent variable rincome
preserve
gen rincome_log = .
replace rincome_log = 0 if (rincome == 1 | rincome == 2 | rincome == 3 | rincome == 4 | rincome == 5 | rincome == 6 | rincome == 7 | rincome == 8 | rincome == 9 | rincome == 10 | rincome == 11)
replace rincome_log = 1 if rincome == 12
drop if rincome_log != 0 & rincome_log != 1
tabulate rincome_log
logit rincome_log degree sex race // logit regression
restore

/* test for def functions, iteration, might not be frequently used
capture program drop summarize_vars // remove any previous defined program 
program define summarize_vars, varlist(abc)
    foreach var of varlist `abc' {
        summarize `var'
    }
end
summarize_vars degree sex race
*definition and call of functions is not quite handy and syntax are less clear, should avoid using it*/

/* * trial for machine learning and use for prediction, might not be frequently used
preserve
gen rincome_log = .
replace rincome_log = 0 if (rincome == 1 | rincome == 2 | rincome == 3 | rincome == 4 | rincome == 5 | rincome == 6 | rincome == 7 | rincome == 8 | rincome == 9 | rincome == 10 | rincome == 11)
replace rincome_log = 1 if rincome == 12 // income higher than $25000 would be considered as "high income", and the rest would be "low income"
boost train rincome_log, learners(degree sex race) nlearners(100)
predict boost_predictions
gen residuals = rincome_log - boost_predictions
gen rmse = sqrt(mean(residuals^2))
egen mae = mean(abs(resididuals))
restore
//not working, STATA does not support machine learning unless we opt for python or R API */








