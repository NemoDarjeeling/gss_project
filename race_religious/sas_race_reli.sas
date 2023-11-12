/*Date: Feb 7, 2023
Author: Curdy

This code begins with "temp" (produced in "Step 2") and creates "temp1" 
which is our working data set. 
At the end of this code, "temp1" is saved to the GSS library/folder
so that we can run models (in "Step 4") without starting at Step 1.

This code consists of one data step that produces all the dummy recoding 
needed for our analyses.

*/

libname gss 'C:\Users\HOME\Desktop\LISA\LISA_DATA\GSS';


Data temp1;
	  Set temp; /*this was produced after "Step 2"*/

/*The GSS uses different weights in different years. Up until 2018, WTSSALL could be used
	  to compare data across time (from 1972 to 2018). But GSS changed their sampling method
	  for the 2021 data. We therefore need a weight to cross this gap. Especially for early 
	  GSS years, there aren't many weighting options: WTSALL is basically all we've got.
	  In 2004, GSS added weight variables so that data can be compared from 2000 to 2021 
	  (and beyond?)called WTSS and WTSSPS. WTSS is recommended for use on analysis between 
	  2004 and 2018. For 2000-2021, we should use WTSSPS.
	  My solution is to use WTSSALL up to 1999, then WTSSPS for 2000 forward. 

	  See the 2021 GSS codebook for a description of the weight situation for more info:
			https://gss.norc.org/Documents/codebook/GSS%202021%20Codebook.pdf

	  For simplicity's sake in coding, I create a single weight variable called WT_ONE
/*******************************CREATE VARIABLES********************************************/

/*longitudinal weight variable*/
WT_ONE=WTSSALL; 
	if year> 1999 then WT_ONE=WTSSPS; 


	Catholic=(relig=2); 
		if relig le 0 then Catholic	= .;
		if relig = 1 or relig gt 2 then Catholic = 0;

	Protestant=(relig=1 or relig=11 or relig=13); 
		if relig le 0 then Protestant = .;
		if relig ge 2 and relig lt 11 or relig =12 then Protestant = 0;

	None=(relig=4); 
		if relig le 0 then None	= .;
		if relig = 1 or relig = 2 or relig = 3 or relig gt 4 then None = 0;

	Oth_Rel=(relig=3 or relig=5 or relig=6 or relig=7 or relig=8 or relig=9 or relig=10 or relig=12);
		if relig le 0 then Oth_Rel	= .;
		if relig = 1 or relig = 2 or relig = 4 or relig = 13 then Oth_Rel = 0;

/*Four category current religion*/
	if relig lt 0 then relig_cat = .;
		else if Catholic = 1   then Relig_cat = 1;
		else if Protestant = 1 then Relig_cat = 2;
		else if None = 1       then Relig_cat = 3;
		else Relig_cat = 4;

/*Gender*/
female = .; if sex = 2 then female = 1; else if sex = 1 then female = 0;


/*Race*/
if race = 1 then white = 1; else if race lt 0 then white = .; else if race gt 1 then white = 0;
if race = 2 then black = 1; else if race lt 0 then black = .; else if race = 1 or race = 3 then black = 0;
if race = 3 then oth_race = 1; else if race lt 0 then oth_race = .; else if race = 1 or race = 2 then oth_race = 0;


/*Latino*/
	if Hispanic gt 1 then Latino = 1; 
		else if Hispanic lt 0 then Latino = .;
		else Latino = 0;

/*Race, four category*/
if  race = . or latino = . then Race_fourcat = .;
	else if white 	 = 1 and Latino = 0 then Race_fourcat = 1;		/*Non-Shipanic white*/
	else if black 	 = 1 and Latino = 0 then Race_fourcat = 2;		/*Non-Hispanic black*/
	else if Latino 	 = 1 				then Race_fourcat = 3;		/*Hispanic. I DELIBERATELY FORCE ALL 454 people WHO SAY LATINO TO BE CATEGORY 3*/
	else Race_fourcat = 4;											/*Other race*/

/*Current marital status
NotMar = widowed (marital = 2), divorced (marital = 3), or separated (marital = 4)*/
Married = .; if marital = 1 then Married = 1; else if marital ge 2 then Married = 0;
NotMar = .; if marital ge 2 and marital le 4 then NotMar = 1; else if marital = 1 or marital = 5 then NotMar = 0;
NevMar = .; if marital = 5 then NevMar = 1; else if marital le 4 and marital ge 1 then NevMar = 0;


/*Ever divorced or separated (divorce).Only asked of those who are currently married or widowed*/
EvDiv = .; if divorce = 1 then EvDiv = 1; else if divorce = 2 or divorce = -100 then EvDiv = 0;

/*Education - highest degree completed*/
if degree = 0 then educ_no = 1; else if degree = 1 or degree = 2 or degree = 3 or degree = 4 then educ_no = 0; else educ_no = .;
if degree = 1 then educ_hs = 1; else if degree = 0 or degree = 2 or degree = 3 or degree = 4 then educ_hs = 0; else educ_hs = .;

if degree = 0 or degree = 1 then educ_low = 1; else if degree = 2 or degree = 3 or degree = 4 then educ_low = 0; else educ_low = .;

if degree = 2 then educ_sc = 1; else if degree = 0 or degree = 1 or degree = 3 or degree = 4 then educ_sc = 0; else educ_sc = .;
if degree = 3 or degree = 4 then educ_ba = 1; else if degree = 0 or degree = 1 or degree = 2 then educ_ba = 0; else educ_ba = .;

if degree = 2 or degree = 3 or degree = 4 then educ_high = 1; else if degree = 0 or degree = 1 then educ_high = 0; else educ_high = .;


/*Create a few categorical variables based on the ones we made above:
##############################################################################
##############################################################################
##############################################################################*/

/*some character values, to aid with charts (my character varnames use an underscore afterward)*/
/*gender_*/
female_="placeholder for formatting"; 	if female=1 then 	female_="female"; 		if female=0 then 	female_="male"; if female=. then female_="";
/*race_*/
white_="placeholder for formatting"; 		if white=1 then 	white_="White"; 		if white=0 then 	white_="non-white"; if white=. then white_="";
black_="placeholder for formatting"; 		if black=1 then 	black_="Black"; 		if black=0 then 	black_="non-black"; if black=. then black_="";
oth_race_="placeholder for formatting"; 	if oth_race=1 then 	oth_race_="other race"; if oth_race=0 then 	oth_race_="white or black"; if oth_race=. then oth_race_="";
/*latino_*/
Latino_="placeholder for formatting"; 	if Latino=1 then 	Latino_="Latino"; 		if Latino=0 then 	Latino_="non-Latino"; if Latino=. then Latino_="";
/*race categories*/
Race_fourcat_="placeholder for formatting";
if Race_fourcat=1 then Race_fourcat_="1 White";
if Race_fourcat=2 then Race_fourcat_="3 Black";
if Race_fourcat=3 then Race_fourcat_="2 Hispanic";
if Race_fourcat=4 then Race_fourcat_="4 Other Race";
if Race_fourcat=. then Race_fourcat_="";



Tradition="placeholder for formatting";
	if Catholic=1 then Tradition="Catholic";
	if Protestant=1 then Tradition="Protestant";
	if None=1 then Tradition="None";
	if Oth_Rel=1 then Tradition="Other Rel";
		if Tradition="placeholder for formatting" then Tradition=""; /*shortcut for missing*/
race_cat="placeholder for formatting"; /*I don't think I use this one, but just in case*/
	if race_fourcat=1 then race_cat="1 White";
	if race_fourcat=2 then race_cat="3 Black";
	if race_fourcat=3 then race_cat="2 Hisp";
	if race_fourcat=4 then race_cat="4 Other";
	if race_fourcat=. then race_cat="";

	/*ETH_REGION = "from what country or countries did your ancestors come from?"

/*Figure 1.3b: Latino by religion, 2021*/
*no dummy code required;
/*Figure 1.3c: Latino Ethnicity by religion, 2021*/
LATIN_REGION="from what country or countries did your ancestors come from?";
	if ethregion58=1 then LATIN_REGION= "Argentina";
	if ethregion59=1 then LATIN_REGION= "Bolivia";
	if ethregion60=1 then LATIN_REGION= "Brazil";
	if ethregion61=1 then LATIN_REGION= "Chile";
	if ethregion62=1 then LATIN_REGION= "Colombia";
	if ethregion63=1 then LATIN_REGION= "Ecuador";
	if ethregion64=1 then LATIN_REGION= "French Guiana";
	if ethregion65=1 then LATIN_REGION= "Guyuna";
	if ethregion66=1 then LATIN_REGION= "Paraguay";
	if ethregion67=1 then LATIN_REGION= "Peru";
	if ethregion68=1 then LATIN_REGION= "Suriname";
	if ethregion69=1 then LATIN_REGION= "Uruguay";
	if ethregion70=1 then LATIN_REGION= "Venezuela";
	if ethregion71=1 then LATIN_REGION= "Oth South Am";
	if ethregion72=1 then LATIN_REGION= "Belize";
	if ethregion73=1 then LATIN_REGION= "Costa Rica";
	if ethregion74=1 then LATIN_REGION= "El Salvador";
	if ethregion75=1 then LATIN_REGION= "Guatemala";
	if ethregion76=1 then LATIN_REGION= "Honduras";
	if ethregion77=1 then LATIN_REGION= "Mexico";
	if ethregion78=1 then LATIN_REGION= "Nicaragua";
	if ethregion79=1 then LATIN_REGION= "Panama";
	if ethregion80=1 then LATIN_REGION= "Oth Cent Am";
	if ethregion84=1 then LATIN_REGION= "Puerto Rico";
	if ethregion86=1 then LATIN_REGION= "Cuba";
	if ethregion88=1 then LATIN_REGION= "Dominican Republic";
	*if ethregion87=1 then ETH_REGION= "Haiti"; /*should these be included?*/
	*if ethregion89=1 then ETH_REGION= "Jamaica";
	*if ethregion87=1 then ETH_REGION= "Oth Caribbean";
	if LATIN_REGION="from what country or countries did your ancestors come from?" then LATIN_REGION="";
Latin_Group="country of hispanic origin from ETHNICITY";
	if hispanic=1 then Latin_Group="Not Hispanic";
	if hispanic=2 then Latin_Group="Mexican (etc)";
	if hispanic=3 then Latin_Group="Puerto Rican";
	if hispanic=4 then Latin_Group="Cuban";
	if hispanic=5 then Latin_Group="Salvadorian";
	if hispanic=6 then Latin_Group="Guatemalan";
	if hispanic=7 then Latin_Group="Panamanian";
	if hispanic=8 then Latin_Group="Nicaraguan";
	if hispanic=9 then Latin_Group="Costa Rican";
	if hispanic=10 then Latin_Group="Central American";
	if hispanic=11 then Latin_Group="Honduran";
	if hispanic=15 then Latin_Group="Dominican";
	if hispanic=16 then Latin_Group="West Indian";
	if hispanic=20 then Latin_Group="Peruvian";
	if hispanic=21 then Latin_Group="Ecuadorian";
	if hispanic=22 then Latin_Group="Colombian";
	if hispanic=23 then Latin_Group="Venezuelan";
	if hispanic=24 then Latin_Group="Argentinian";
	if hispanic=25 then Latin_Group="Chilean";
	if hispanic=30 then Latin_Group="Spanish";
	if hispanic=31 then Latin_Group="Basque";
	if hispanic=35 then Latin_Group="Filipino/a";
	if hispanic=40 then Latin_Group="Latin American";
	if hispanic=41 then Latin_Group="South American";
	if hispanic=42 then Latin_Group="American";
	if hispanic=45 then Latin_Group="Latin";
	if hispanic=46 then Latin_Group="Latino/a";
	if hispanic=47 then Latin_Group="Hispanic";
	if hispanic=50 then Latin_Group="Other hispanic";
if Latin_Group="country of hispanic origin from ETHNICITY" then Latin_Group="";

Mar_Cat="unknown marriage category placeholder";
	if marital<1 then Mar_Cat="";
	if marital=1 & divorce=2 then Mar_Cat="Married, never divorced";
	if marital=1 & divorce=1 then Mar_Cat="Married, been divorced";
	if marital=2 & divorce=1 then Mar_Cat="Single (w), been divorced";
	if marital=2 & divorce=2 then Mar_Cat="Single (w), never divorced";
	if marital=3 then Mar_Cat="Single, been divorced";
	if marital=4 then Mar_Cat="Single, been divorced";
	if marital=5 then Mar_Cat="Single, never Married";
	if Mar_Cat="unknown marriage category placeholder" then Mar_Cat="";
Mar_Cat2=Mar_Cat;
	if Mar_Cat="Single (w), been divorced" then Mar_Cat2="Married, been divorced";
	if Mar_Cat="Single (w), never divorced" then Mar_Cat2="Married, never divorced";

/*code for the family ancestry (possibly used in Figure 1.2)*/
ANC_REGION="UNKNOWN ANCESTORY AND THIS IS A PLACEHOLDER";
if ETHNIC<1 then ANC_REGION= "";
if ETHNIC=. then ANC_REGION="";
/*Africa*/     if ETHNIC=1   				then ANC_REGION="Africa";
/*Austria*/     if ETHNIC=2   				then ANC_REGION="Europe";
/*Canada (french)*/     if ETHNIC=3   		then ANC_REGION="North America";
/*Canada (other)*/     if ETHNIC=4   		then ANC_REGION="North America";
/*China*/     if ETHNIC=5   				then ANC_REGION="Asia";
/*Czechoslovakia*/     if ETHNIC=6   		then ANC_REGION="Europe";
/*Denmark*/     if ETHNIC=7   				then ANC_REGION="Europe";
/*England and wales*/     if ETHNIC=8   	then ANC_REGION="Europe";
/*Finland*/     if ETHNIC=9   				then ANC_REGION="Europe";
/*France*/     if ETHNIC=10   				then ANC_REGION="Europe";
/*Germany*/     if ETHNIC=11   				then ANC_REGION="Europe";
/*Greece*/     if ETHNIC=12   				then ANC_REGION="Europe";
/*Hungary*/     if ETHNIC=13   				then ANC_REGION="Europe";
/*Ireland*/     if ETHNIC=14   				then ANC_REGION="Europe";
/*Italy*/     if ETHNIC=15   				then ANC_REGION="Europe";
/*Japan*/     if ETHNIC=16   				then ANC_REGION="Asia";
/*Mexico*/     if ETHNIC=17   				then ANC_REGION="Latin America";
/*Netherlands (dutch/holland)*/     if ETHNIC=18   then ANC_REGION="Europe";
/*Norway*/     if ETHNIC=19   				then ANC_REGION="Europe";
/*Philippines*/     if ETHNIC=20   			then ANC_REGION="Asia";*"SE Asia / Oceania";
/*Poland*/     if ETHNIC=21   				then ANC_REGION="Europe";
/*Puerto rico*/     if ETHNIC=22   			then ANC_REGION="Latin America";
/*Russia (ussr)*/     if ETHNIC=23  		then ANC_REGION="Asia";
/*Scotland*/     if ETHNIC=24   			then ANC_REGION="Europe";
/*Spain*/     if ETHNIC=25   				then ANC_REGION="Europe";
/*Sweden*/     if ETHNIC=26   				then ANC_REGION="Europe";
/*Switzerland*/     if ETHNIC=27   			then ANC_REGION="Europe";
/*West indies (not specified)*/     if ETHNIC=28   then ANC_REGION="Asia";*"SE Asia / Oceania";
/*Other*/     if ETHNIC=29   				then ANC_REGION="";*"Unknown";
/*American indian*/     if ETHNIC=30   		then ANC_REGION="North America";
/*India*/     if ETHNIC=31   				then ANC_REGION="Asia";
/*Portugal*/     if ETHNIC=32   			then ANC_REGION="Europe";
/*Lithuania*/     if ETHNIC=33   			then ANC_REGION="Europe";
/*Yugoslavia*/     if ETHNIC=34   			then ANC_REGION="Europe";
/*Romania*/     if ETHNIC=35   				then ANC_REGION="Europe";
/*Belgium*/     if ETHNIC=36   				then ANC_REGION="Europe";
/*Arabic*/     if ETHNIC=37   				then ANC_REGION="Africa";*"Middle East";
/*Other spanish*/     if ETHNIC=38   		then ANC_REGION="Latin America";
/*West indies (non-spanish)*/     if ETHNIC=39   then ANC_REGION="Asia";*"SE Asia / Oceania";
/*Other asian*/     if ETHNIC=40   			then ANC_REGION="Asia";
/*Other european*/     if ETHNIC=41   		then ANC_REGION="Europe";
/*American only*/     if ETHNIC=97   		then ANC_REGION="North America";
/*Turkey*/     if ETHNIC=101   				then ANC_REGION="Asia";
/*Algeria*/     if ETHNIC=202   			then ANC_REGION="Africa";
/*Congo*/     if ETHNIC=203   				then ANC_REGION="Africa";
/*Egypt*/     if ETHNIC=204   				then ANC_REGION="Africa";
/*Ethiopia*/     if ETHNIC=205   			then ANC_REGION="Africa";
/*Kenya*/     if ETHNIC=206   				then ANC_REGION="Africa";
/*Nigeria*/     if ETHNIC=207   			then ANC_REGION="Africa";
/*South Africa*/     if ETHNIC=208   		then ANC_REGION="Africa";
/*Other Africa*/     if ETHNIC=299   		then ANC_REGION="Africa";
/*S. Korea*/     if ETHNIC=301   			then ANC_REGION="Asia";
/*Bangladesh*/     if ETHNIC=302   			then ANC_REGION="Asia";
/*Pakistan*/     if ETHNIC=304   			then ANC_REGION="Asia";
/*Thailand*/     if ETHNIC=306   			then ANC_REGION="Asia";
/*Vietnam*/     if ETHNIC=307   			then ANC_REGION="Asia";
/*Iran*/     if ETHNIC=401   				then ANC_REGION="Africa";*"Middle East";
/*Iraq*/     if ETHNIC=402   				then ANC_REGION="Africa";*"Middle East";
/*Israel*/     if ETHNIC=403   				then ANC_REGION="Africa";*"Middle East";
/*Jordan*/     if ETHNIC=404   				then ANC_REGION="Africa";*"Middle East";
/*Saudi Arabia*/     if ETHNIC=405   		then ANC_REGION="Africa";*"Middle East";
/*Syria*/     if ETHNIC=406   				then ANC_REGION="Africa";*"Middle East";
/*Yemen*/     if ETHNIC=408   				then ANC_REGION="Africa";*"Middle East";
/*Other Middle East*/     if ETHNIC=499   	then ANC_REGION="Africa";*"Middle East";
/*Argentina*/     if ETHNIC=501   			then ANC_REGION="Latin America";
/*Brazil*/     if ETHNIC=503   				then ANC_REGION="Latin America";
/*Chile*/     if ETHNIC=504   				then ANC_REGION="Latin America";
/*Colombia*/     if ETHNIC=505   			then ANC_REGION="Latin America";
/*Ecuador*/     if ETHNIC=506   			then ANC_REGION="Latin America";
/*/*Guyana*/     if ETHNIC=508   			then ANC_REGION="Latin America";
/*Paraguay*/     if ETHNIC=509   			then ANC_REGION="Latin America";
/*Peru*/     if ETHNIC=510   				then ANC_REGION="Latin America";
/*Suriname*/     if ETHNIC=511   			then ANC_REGION="Latin America";
/*Venezuela*/     if ETHNIC=513   			then ANC_REGION="Latin America";
/*Other South America*/     if ETHNIC=599   then ANC_REGION="Latin America";
/*Belize*/     if ETHNIC=601   				then ANC_REGION="Latin America";
/*Costa Rica*/     if ETHNIC=602   			then ANC_REGION="Latin America";
/*El Salvador*/     if ETHNIC=603   		then ANC_REGION="Latin America";
/*Guatemala*/     if ETHNIC=604   			then ANC_REGION="Latin America";
/*Honduras*/     if ETHNIC=605   			then ANC_REGION="Latin America";
/*Nicaragua*/     if ETHNIC=606   			then ANC_REGION="Latin America";
/*Panama*/     if ETHNIC=607   				then ANC_REGION="Latin America";
/*Other Central America*/   if ETHNIC=699   then ANC_REGION="Latin America";
/*Other North America*/     if ETHNIC=799   then ANC_REGION="North America";
/*Cuba*/     if ETHNIC=801   				then ANC_REGION="Latin America";
/*Haiti*/     if ETHNIC=802   				then ANC_REGION="Latin America";
/*Dominican Republic*/     	if ETHNIC=803   then ANC_REGION="Latin America";
/*Jamaica*/     if ETHNIC=804   			then ANC_REGION="Latin America";
/*Other Caribbean*/     if ETHNIC=899   	then ANC_REGION="Latin America";
/*Australia*/     if ETHNIC=901   			then ANC_REGION="Asia";*"SE Asia / Oceania";
/*New Zealand*/     if ETHNIC=903   		then ANC_REGION="Asia";*"SE Asia / Oceania";
/*Samoa*/     if ETHNIC=904   				then ANC_REGION="Asia";*"SE Asia / Oceania";
/*Other Oceania*/     if ETHNIC=999   		then ANC_REGION="Asia";*"SE Asia / Oceania";


/*############################
Chapter 2:
######################*/

/*Religion at age 16; RELIG16 is missing for 1972*/
	Catholic16=(relig16=2);
		if relig16 le 0 then Catholic16 	= .; 
		if relig16 = 1 or relig16 gt 2 then Catholic16 = 0;

	Protestant16=(relig16=1 or relig16=11 or relig16=13);
		if relig16 le 0 then Protestant16	= .;
		if relig16 gt 1 and (relig16 ne 11 and relig16 ne 13) then Protestant16 = 0;

	None16=(relig16=4);
		if relig16 le 0 then None16			= .;
		if relig16 = 1 or relig16 = 2 or relig16 = 3 or relig16 gt 4 then None16 = 0;

	Oth_Rel16=(relig16=3 or relig16=5 or relig16=6 or relig16=7 or relig16=8 or relig16=9 or relig16=10 or relig16=12);
		if relig16 le 0 then Oth_Rel16		= .;
		if relig16 = 1 or relig16 = 2 or relig16 = 4 or relig16 = 13 then Oth_Rel16 = 0;

/*Religious change since age 16*/
		/*CATHOLIC*/
	if Catholic16 = 1 and Catholic = 1 then Cath_stay  = 1; 	else if Catholic16 = . or Catholic = . then Cath_stay  = .;		else Cath_stay = 0;
	if Catholic16 = 1 and Catholic = 0 then Cath_leave  = 1; 	else if Catholic16 = . or Catholic = . then Cath_leave  = .;	else Cath_leave = 0;
	if Catholic16 = 0 and Catholic = 1 then Cath_join  = 1; 	else if Catholic16 = . or Catholic = . then Cath_join  = .;		else Cath_join = 0;
		/*PROTESTANT*/
	if Protestant16 = 1 and Protestant = 1 then Prot_stay  = 1; 	else if Protestant16 = . or Protestant = . then Prot_stay  = .;		else Prot_stay = 0;
	if Protestant16 = 1 and Protestant = 0 then Prot_leave  = 1; 	else if Protestant16 = . or Protestant = . then Prot_leave  = .;	else Prot_leave = 0;
	if Protestant16 = 0 and Protestant = 1 then Prot_join  = 1; 	else if Protestant16 = . or Protestant = . then Prot_join  = .;		else Prot_join = 0;
		/*NONE*/
	if None16 = 1 and None = 1 then none_stay  = 1; 	else if None16 = . or None = . then none_stay  = .;		else none_stay = 0;
	if None16 = 1 and None = 0 then none_leave  = 1; 	else if None16 = . or None = . then none_leave  = .;	else none_leave = 0;
	if None16 = 0 and None = 1 then none_join  = 1; 	else if None16 = . or None = . then none_join  = .;		else none_join = 0;
		/*OTHER*/
	if Oth_Rel16 = 1 and Oth_Rel = 1 then Oth_stay  = 1; 	else if Oth_Rel16 = . or Oth_Rel = . then Oth_stay  = .;		else Oth_stay = 0;
	if Oth_Rel16 = 1 and Oth_Rel = 0 then Oth_leave  = 1; 	else if Oth_Rel16 = . or Oth_Rel = . then Oth_leave  = .;		else Oth_leave = 0;
	if Oth_Rel16 = 0 and Oth_Rel = 1 then Oth_join  = 1; 	else if Oth_Rel16 = . or Oth_Rel = . then Oth_join  = .;		else Oth_join = 0;

/*Three category Catholic religious change*/
	if Cath_stay = 1 then Cath_change = 1;	else if Cath_leave = 1 then Cath_change = 2;	else if Cath_join = 1 then Cath_change = 3;	else Cath_change = .;
	if Prot_stay = 1 then Prot_change = 1;	else if Prot_leave = 1 then Prot_change = 2;	else if Prot_join = 1 then Prot_change = 3;	else Prot_change = .;
	if none_stay = 1 then none_change = 1;	else if none_leave = 1 then none_change = 2;	else if none_join = 1 then none_change = 3;	else none_change = .;
	if Oth_stay = 1 then Oth_change = 1;	else if Oth_leave = 1 then Oth_change = 2;	else if Oth_join = 1 then Oth_change = 3;	else Oth_change = .;

Cath_change_="Placeholder";
	if Cath_change=1 then Cath_change_="Stayed";
	if Cath_change=2 then Cath_change_="Left";
	if Cath_change=3 then Cath_change_="Joined";
	if Cath_change=. then Cath_change_="";
Prot_change_="Placeholder";
	if Prot_change=1 then Prot_change_="Stayed";
	if Prot_change=2 then Prot_change_="Left";
	if Prot_change=3 then Prot_change_="Joined";
	if Prot_change=. then Prot_change_="";
None_change_="Placeholder";
	if None_change=1 then None_change_="Stayed";
	if None_change=2 then None_change_="Left";
	if None_change=3 then None_change_="Joined";
	if None_change=. then None_change_="";
Oth_change_="Placeholder";
	if Oth_change=1 then Oth_change_="Stayed";
	if Oth_change=2 then Oth_change_="Left";
	if Oth_change=3 then Oth_change_="Joined";
	if Oth_change=. then Oth_change_="";

/*Immigrant generation*/
mom_cit=.;
if maborn<1 then mom_cit=.; if maborn=1 then mom_cit=1; if maborn=2 then mom_cit=0;
dad_cit=.;
if paborn<1 then dad_cit=.; if paborn=1 then dad_cit=1; if paborn=2 then dad_cit=0;
gran_cit=.;
if granborn<1 then gran_cit=.; if granborn=0 then gran_cit=1; if granborn>0 then gran_cit=0; /*any grandparent born outside US = 1*/
im_gen="placeholder for immigrant generation";

/* 
The issue here is that this scheme only sees observation where there are not missing 
on any of the three variables GRANBORN, MABORN, and PABORN.
The number of obs with non-missing MABORN and PABORN is 3,899.
Adding GRANBORN as a requirement brings us down to 3,594 (305 obs lost) for these three variables.

the logic here is: 
non-immigrant 		= both parents and all four grandparents are born in the US. 
second generation 	= both parents born in US, at least one grandparent born outside US.
first generation 	= at least one parent born outside US (regardless of where grandparents were born)

NOTE: there are some Rs in each category that are not themselves US citizens (according to the BORN variable).
But I force them into the im_gen categories anyway:
13 "non-immigrant" are non-citizens		(of 633 total)
5 "second generation" are non-citizens	(of 2,319 total)
21 "first generation" are non-citizens	(of 197 total)


*/
/*This is the basic coding for immigrant generation.
Using the "More thorough coding" information, we can add a couple more Rs at the end*/
if mom_cit=1 & dad_cit=1 & gran_cit=1 then im_gen="1 non-immigrant";
if mom_cit=1 & dad_cit=1 & gran_cit=0 then im_gen="2 second generation";
if mom_cit=0 & dad_cit=1 & gran_cit^=. then im_gen="3 first generation";
if mom_cit=1 & dad_cit=0 & gran_cit^=. then im_gen="3 first generation";
/*clear out missings*/if im_gen="placeholder for immigrant generation" then im_gen="";

/*More thorough coding*/
imgen_info="This is a placeholder to see what immigrant info we have";

if BORN<1 & mom_cit=. & dad_cit=. & gran_cit=. then imgen_info="all missing";

if BORN<1 & mom_cit=. & dad_cit=. & gran_cit^=. then imgen_info="have grand only";
if BORN<1 & mom_cit=. & dad_cit^=. & gran_cit=. then imgen_info="have dad only";
if BORN<1 & mom_cit^=. & dad_cit=. & gran_cit=. then imgen_info="have mom only";
if BORN^<1 & mom_cit=. & dad_cit=. & gran_cit=. then imgen_info="have R only";

if BORN<1 & mom_cit=. & dad_cit^=. & gran_cit^=. then imgen_info="have dad, grand only";
if BORN<1 & mom_cit^=. & dad_cit=. & gran_cit^=. then imgen_info="have mom, grand only";
if BORN^<1 & mom_cit=. & dad_cit=. & gran_cit^=. then imgen_info="have R, grand only";
if BORN<1 & mom_cit^=. & dad_cit^=. & gran_cit=. then imgen_info="have dad, mom only";
if BORN^<1 & mom_cit^=. & dad_cit=. & gran_cit=. then imgen_info="have R, mom only";
if BORN^<1 & mom_cit=. & dad_cit^=. & gran_cit=. then imgen_info="have R, dad only";
if BORN^<1 & mom_cit=. & dad_cit=. & gran_cit^=. then imgen_info="have R, grand only";

if BORN<1 & mom_cit^=. & dad_cit^=. & gran_cit^=. then imgen_info="have mom, dad, grand only";
if BORN^<1 & mom_cit=. & dad_cit^=. & gran_cit^=. then imgen_info="have R, dad, grand only";
if BORN^<1 & mom_cit^=. & dad_cit=. & gran_cit^=. then imgen_info="have R, mom, grand only";
if BORN^<1 & mom_cit^=. & dad_cit^=. & gran_cit=. then imgen_info="have R, mom, dad only";

if BORN^<1 & mom_cit^=. & dad_cit^=. & gran_cit^=. then imgen_info="have all";


/* find the foreign-born of US parents (we are treating as "non-immigrant")*/
im_gen2="placeholder for immigrant generation";
if BORN=2 & mom_cit=1 & dad_cit=1 then im_gen2="foreign of US parents";


/*Now we're going to add two groups back in: the "foreign of US parents" (we are treating as "non-immigrant") AND
5 Respondents who are missing their own citizenship, but we have their parents'*/
if im_gen2 = "foreign of US parents" then im_gen="1 non-immigrant";
if imgen_info="have mom, dad, grand only" & mom_cit=1 & dad_cit=1 then im_gen="1 non-immigrant";





/*I used this variable only for testing */
if BORN<1 then R_cit=.;
if BORN=1 then R_cit=1;
if BORN=2 then R_cit=0;


/*TESTING to try to figure out Hout and Greeley logic 
HG_gen="placeholder for immigrant generation";
if BORN = 1 then HG_gen="Native born";
if BORN = 2 then HG_gen="Foreign-born";
if BORN = 1 & mom_cit=1 & dad_cit=0 then HG_gen="Foreign-born parent";
if BORN = 1 & mom_cit=0 & dad_cit=1 then HG_gen="Foreign-born parent";
if BORN = 1 & mom_cit=1 & dad_cit=1 then HG_gen="Generation 3";
if BORN = 1 & mom_cit=1 & dad_cit=1 & gran_cit=0 then HG_gen="Generation 4+";
*/
/*CHECKING ON THIS VARIABLE*/
incom16_dum=.;
if incom16<0 then incom16_dum=.;
if incom16>0 & incom16<7 then incom16_dum=incom16; /*7=institutionalized (0 in 2021)*/

incom16_dum_="Placeholder for the income at 16 var";
if incom16=1 then incom16_dum_="1 Far below average";
if incom16=2 then incom16_dum_="2 Below average";
if incom16=3 then incom16_dum_="3 Average";
if incom16=4 then incom16_dum_="4 Above average";
if incom16=5 then incom16_dum_="5 Far above average";
if incom16<0 then incom16_dum_="";
if incom16=7 then incom16_dum_="";

DAD_deg="MISSING1234";
if PADEG=. then DAD_deg="";
if PADEG<0 then DAD_deg="";
if PADEG=0 then DAD_deg="1 <HS";
if PADEG=1 then DAD_deg="2 HS, AA";
if PADEG=2 then DAD_deg="2 HS, AA";
if PADEG=3 then DAD_deg="3 BA, BA+";
if PADEG=4 then DAD_deg="3 BA, BA+";

/*"Father's Prestige Score" (PAPRES10) 2021
min: 16
1st quartile: 35
median (2nd quartile) 44
mean: 47.99
3rd quartile 52
max 80
std 13.14
*/
DADpres=0; 
if PAPRES10<0 then DADpres=.;
if PAPRES10>15 & PAPRES10<36 then DADpres=1;
if PAPRES10>35 & PAPRES10<45 then DADpres=2;
if PAPRES10>44 & PAPRES10<53 then DADpres=3;
if PAPRES10>52 then DADpres=4;

city16="placeholder for city16";
if RES16<1 then city16="";
if RES16=1 then city16="Rural";
if RES16=2 then city16="Rural";
if RES16=3 then city16="Town";
if RES16=4 then city16="Town";
if RES16=5 then city16="City";
if RES16=6 then city16="City";
if city16="placeholder for city16" then city16="";

Prot_type="unknown placeholder";


/*RELTRAD2 Coding (adapted from Cyrus's STATA code)
Essentially, we start by coding the RELTRAD scheme then make 
an adjustment at the end to recategorize the Black Protestants.

Some NOTES about this coding scheme:

Fortunately, in GSS2021 DENOM=123 count is 0, so we don't have to worry about
recoding "Catholic" (see Steensland note "a" on pg 116)

Steensland et al. doesn't say how they coded DENOM=70 (non-denom) where ATTEND <4. 
They only say that they were NOT coded as "Conservative". So, by process of 
elimination, I code them as "Mainline".
I also code DENOM=70 (non-denom) where ATTEND=. as "Mainline";
(interestingly, this implicitly assumes that the more you go to a non-denom church, 
the more conservative you are).

*/
/*Using variable "DENOM" and "RELIG"*/
if DENOM=11 & RACE^=2 then Prot_type="Mainline";
if DENOM=30 then Prot_type="Mainline";
if DENOM=50 then Prot_type="Mainline";
if DENOM=35 then Prot_type="Mainline";
if DENOM=31 then Prot_type="Mainline";
if DENOM=38 then Prot_type="Mainline";
if DENOM=28 & RACE^=2 then Prot_type="Mainline";
if DENOM=40 then Prot_type="Mainline";
if DENOM=48 then Prot_type="Mainline";
if DENOM=43 then Prot_type="Mainline";
if DENOM=22 then Prot_type="Mainline";
if DENOM=41 then Prot_type="Mainline";
if DENOM=10 & RACE^=2 then Prot_type="Conservative";
if DENOM=18 & RACE^=2 then Prot_type="Conservative";
if DENOM=32 then Prot_type="Conservative";
if DENOM=15 & RACE^=2 then Prot_type="Conservative";
if DENOM=34 then Prot_type="Conservative";
if DENOM=23 & RACE^=2 then Prot_type="Conservative";
if DENOM=42 then Prot_type="Conservative";
if DENOM=14 & RACE^=2 then Prot_type="Conservative";
if DENOM=33 then Prot_type="Conservative";
if DENOM=20 then Prot_type="Black Protestant";
if DENOM=21 then Prot_type="Black Protestant";
if DENOM=10 & RACE=2 then Prot_type="Black Protestant";
if DENOM=11 & RACE=2 then Prot_type="Black Protestant";
if DENOM=18 & RACE=2 then Prot_type="Black Protestant";
if DENOM=28 & RACE=2 then Prot_type="Black Protestant";
if DENOM=12 then Prot_type="Black Protestant";
if DENOM=13 then Prot_type="Black Protestant";
if DENOM=15 & RACE=2 then Prot_type="Black Protestant";
if DENOM=23 & RACE=2 then Prot_type="Black Protestant";
if DENOM=14 & RACE=2 then Prot_type="Black Protestant";
				if DENOM=70 & ATTEND<0 then Prot_type="Mainline";
				if DENOM=70 & ATTEND=0 then Prot_type="Mainline";
				if DENOM=70 & ATTEND=1 then Prot_type="Mainline";
				if DENOM=70 & ATTEND=2 then Prot_type="Mainline";
				if DENOM=70 & ATTEND=3 then Prot_type="Mainline";
		if DENOM=70 & ATTEND = 4 then Prot_type="Conservative";
		if DENOM=70 & ATTEND = 5 then Prot_type="Conservative";
		if DENOM=70 & ATTEND = 6 then Prot_type="Conservative";
		if DENOM=70 & ATTEND = 7 then Prot_type="Conservative";
		if DENOM=70 & ATTEND = 8 then Prot_type="Conservative";
				if DENOM=11 & ATTEND<0 then Prot_type="Mainline";
				if DENOM=11 & ATTEND=0 then Prot_type="Mainline";
				if DENOM=11 & ATTEND=1 then Prot_type="Mainline";
				if DENOM=11 & ATTEND=2 then Prot_type="Mainline";
				if DENOM=11 & ATTEND=3 then Prot_type="Mainline";
		if RELIG=11 & ATTEND = 4 then Prot_type="Conservative";
		if RELIG=11 & ATTEND = 5 then Prot_type="Conservative";
		if RELIG=11 & ATTEND = 6 then Prot_type="Conservative";
		if RELIG=11 & ATTEND = 7 then Prot_type="Conservative";
		if RELIG=11 & ATTEND = 8 then Prot_type="Conservative";
				if DENOM=13 & ATTEND<0 then Prot_type="Mainline";
				if DENOM=13 & ATTEND=0 then Prot_type="Mainline";
				if DENOM=13 & ATTEND=1 then Prot_type="Mainline";
				if DENOM=13 & ATTEND=2 then Prot_type="Mainline";
				if DENOM=13 & ATTEND=3 then Prot_type="Mainline";
		if RELIG=13 & ATTEND = 4 then Prot_type="Conservative";
		if RELIG=13 & ATTEND = 5 then Prot_type="Conservative";
		if RELIG=13 & ATTEND = 6 then Prot_type="Conservative";
		if RELIG=13 & ATTEND = 7 then Prot_type="Conservative";
		if RELIG=13 & ATTEND = 8 then Prot_type="Conservative";
/*Using variable "OTHER"*/
if OTHER=15 then Prot_type="Black Protestant";
if OTHER=14 then Prot_type="Black Protestant";
if OTHER=128 then Prot_type="Black Protestant";
if OTHER=37 then Prot_type="Black Protestant";
if OTHER=38 then Prot_type="Black Protestant";
if OTHER=7 then Prot_type="Black Protestant";
if OTHER=88 then Prot_type="Black Protestant";
if OTHER=98 then Prot_type="Black Protestant";
if OTHER=56 then Prot_type="Black Protestant";
if OTHER=104 then Prot_type="Black Protestant";

if OTHER=103 then Prot_type="Black Protestant";
if OTHER=133 then Prot_type="Black Protestant";
if OTHER=78 then Prot_type="Black Protestant";
if OTHER=79 then Prot_type="Black Protestant";
if OTHER=21 then Prot_type="Black Protestant";
if OTHER=85 then Prot_type="Black Protestant";
if OTHER=86 then Prot_type="Black Protestant";
if OTHER=87 then Prot_type="Black Protestant";
if OTHER=99 then Prot_type="Mainline";
if OTHER=19 then Prot_type="Mainline";
if OTHER=25 then Prot_type="Mainline";
if OTHER=40 then Prot_type="Mainline";
if OTHER=44 then Prot_type="Mainline";
if OTHER=46 then Prot_type="Mainline";
if OTHER=49 then Prot_type="Mainline";
if OTHER=48 then Prot_type="Mainline";
if OTHER=50 then Prot_type="Mainline";
if OTHER=54 then Prot_type="Mainline";
if OTHER=89 then Prot_type="Mainline";
if OTHER=1 then Prot_type="Mainline";
if OTHER=105 then Prot_type="Mainline";
if OTHER=8 then Prot_type="Mainline";
if OTHER=70 then Prot_type="Mainline";
if OTHER=71 then Prot_type="Mainline";
if OTHER=73 then Prot_type="Mainline";
if OTHER=72 then Prot_type="Mainline";
if OTHER=148 then Prot_type="Mainline";
if OTHER=23 then Prot_type="Mainline";
if OTHER=119 then Prot_type="Mainline";
if OTHER=81 then Prot_type="Mainline";
if OTHER=96 then Prot_type="Mainline";
if OTHER=10 then Prot_type="Conservative";
if OTHER=111 then Prot_type="Conservative";
if OTHER=107 then Prot_type="Conservative";
if OTHER=138 then Prot_type="Conservative";
if OTHER=12 then Prot_type="Conservative";
if OTHER=109 then Prot_type="Conservative";
if OTHER=20 then Prot_type="Conservative";
if OTHER=22 then Prot_type="Conservative";
if OTHER=132 then Prot_type="Conservative";
if OTHER=110 then Prot_type="Conservative";
if OTHER=122 then Prot_type="Conservative";
if OTHER=102 then Prot_type="Conservative";
if OTHER=135 then Prot_type="Conservative";
if OTHER=108 then Prot_type="Conservative";
if OTHER=29 then Prot_type="Conservative";
if OTHER=9 then Prot_type="Conservative";
if OTHER=125 then Prot_type="Conservative";
if OTHER=28 then Prot_type="Conservative";
if OTHER=31 then Prot_type="Conservative";
if OTHER=32 then Prot_type="Conservative";
if OTHER=26 then Prot_type="Conservative";
if OTHER=101 then Prot_type="Conservative";
if OTHER=36 then Prot_type="Conservative";
if OTHER=35 then Prot_type="Conservative";
if OTHER=34 then Prot_type="Conservative";
if OTHER=127 then Prot_type="Conservative";
if OTHER=121 then Prot_type="Conservative";
if OTHER=5 then Prot_type="Conservative";
if OTHER=116 then Prot_type="Conservative";
if OTHER=39 then Prot_type="Conservative";
if OTHER=41 then Prot_type="Conservative";
if OTHER=42 then Prot_type="Conservative";
if OTHER=43 then Prot_type="Conservative";
if OTHER=2 then Prot_type="Conservative";
if OTHER=91 then Prot_type="Conservative";
if OTHER=45 then Prot_type="Conservative";
if OTHER=47 then Prot_type="Conservative";
if OTHER=112 then Prot_type="Conservative";
if OTHER=120 then Prot_type="Conservative";
if OTHER=139 then Prot_type="Conservative";
if OTHER=124 then Prot_type="Conservative";
if OTHER=51 then Prot_type="Conservative";
if OTHER=53 then Prot_type="Conservative";
if OTHER=13 then Prot_type="Conservative";
if OTHER=16 then Prot_type="Conservative";
if OTHER=52 then Prot_type="Conservative";
if OTHER=100 then Prot_type="Conservative";
if OTHER=90 then Prot_type="Conservative";
if OTHER=18 then Prot_type="Conservative";
if OTHER=55 then Prot_type="Conservative";
if OTHER=24 then Prot_type="Conservative";
if OTHER=3 then Prot_type="Conservative";
if OTHER=134 then Prot_type="Conservative";
if OTHER=146 then Prot_type="Conservative";
if OTHER=129 then Prot_type="Conservative";
if OTHER=131 then Prot_type="Conservative";
if OTHER=63 then Prot_type="Conservative";
if OTHER=115 then Prot_type="Conservative";

if OTHER=117 then Prot_type="Conservative";
if OTHER=92 then Prot_type="Conservative";
if OTHER=65 then Prot_type="Conservative";
if OTHER=6 then Prot_type="Conservative";
if OTHER=27 then Prot_type="Conservative";
if OTHER=97 then Prot_type="Conservative";
if OTHER=68 then Prot_type="Conservative";
if OTHER=66 then Prot_type="Conservative";
if OTHER=67 then Prot_type="Conservative";
if OTHER=69 then Prot_type="Conservative";
if OTHER=140 then Prot_type="Conservative";
if OTHER=57 then Prot_type="Conservative";
if OTHER=133 then Prot_type="Conservative";
if OTHER=76 then Prot_type="Conservative";
if OTHER=77 then Prot_type="Conservative";
if OTHER=94 then Prot_type="Conservative";
if OTHER=106 then Prot_type="Conservative";
if OTHER=118 then Prot_type="Conservative";
if OTHER=83 then Prot_type="Conservative";
if OTHER=84 then Prot_type="Conservative";
/*Other Affiliation (Conservative Nontraditional)*/
if OTHER=30 then Prot_type="Conservative";
if OTHER=33 then Prot_type="Conservative";
if OTHER=145 then Prot_type="Conservative";
if OTHER=114 then Prot_type="Conservative";
if OTHER=58 then Prot_type="Conservative";
if OTHER=62 then Prot_type="Conservative";
if OTHER=59 then Prot_type="Conservative";
if OTHER=60 then Prot_type="Conservative";
if OTHER=61 then Prot_type="Conservative";
if OTHER=64 then Prot_type="Conservative";
if OTHER=130 then Prot_type="Conservative";
if OTHER=113 then Prot_type="Conservative";
/*Other Affiliation (Liberal Nontraditional)*/
if OTHER=29 then Prot_type="Mainline";
if OTHER=17 then Prot_type="Mainline";
if OTHER=75 then Prot_type="Mainline";
if OTHER=136 then Prot_type="Mainline";
if OTHER=141 then Prot_type="Mainline";
if OTHER=74 then Prot_type="Mainline";
if OTHER=11 then Prot_type="Mainline";
if OTHER=80 then Prot_type="Mainline";
if OTHER=82 then Prot_type="Mainline";
if OTHER=95 then Prot_type="Mainline";

/*cleaning up some idiosyncratic coding where order might matter, etc*/
if OTHER=93 then Prot_type="Conservative";
if OTHER=93 & RACE=2 then Prot_type="Black Protestant";

 /*Other=162 wasn't in Steensland, but it's an LDS church*/
if OTHER=162 then Prot_type="Conservative";

/*Vineyard church isn't in Steensland, but its evangelical, code 176*/
if OTHER=176 then Prot_type="Conservative";

/*Alliance World Fellowship isn't in Steensland, but its evangelical, code 182*/
if OTHER=182 then Prot_type="Conservative";

/*Some kind of typo? There is no 219 so I'm using Religion at 16 (RELIG16) to fill in:*/
if OTHER=219 then Prot_Type="Mainline"; /*only one observation*/

/*Let's remove my placeholder before fixing the missings*/
if Prot_type="unknown placeholder" then Prot_type="";

/*For the rest, we don't have any denomination info. There are two groups
of "RELIG"-only respondents:
First group: "Inter-Nondenominational"
Second group: "Protestant" 

I consider what Steensland et al. says on pg 297-298 for my coding scheme:

"... [we assign] nondenom/no-denom to the evangelical Protestant category
if they attend church 'about once a month' or more'.
>> so, the first group should be coded as "Mainline" or "Conservative" based
on the ATTEND variable.

"...[there is a] nondenominational movement among evangelicals [but not] among
mainline Protestants."
>> so, the second group will be coded as "Mainline"*/
if Prot_type="" & RELIG=1  then Prot_type="Mainline";
if Prot_type="" & RELIG=13 & ATTEND>3 then Prot_type="Conservative";
if Prot_type="" & RELIG=13 & ATTEND<4 then Prot_type="Mainline";


/*Just to stay organized, I create a 6-category dummy that will become RELTRAD2,
basically, it's RELTRAD2 except the Black Protestants haven't been sorted into
their Conservative/Mainline categories*/

Trad_sixcat_="unknown placeholder for Trad_sixcat_";
if Tradition="Catholic" then Trad_sixcat_="Catholic";
if Tradition="Protestant" & Prot_Type="Mainline" then Trad_sixcat_="Mainline";
if Tradition="Protestant" & Prot_Type="Conservative" then Trad_sixcat_="Conservative";
if Tradition="None" then Trad_sixcat_="None";
if Tradition="Other Rel" then Trad_sixcat_="Other";
if Tradition="Protestant" & Prot_Type="Black Protestant" then Trad_sixcat_="Black Protestant";

/*Now clear the empties*/
if Trad_sixcat_="unknown placeholder for Trad_sixcat_" then Trad_sixcat_="";

/*Now sort the Black Protestants into Conservative/Mainline*/
reltrad2=Trad_sixcat_;
if Prot_type = "Black Protestant" & relig=11 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & relig=13 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=10 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=12 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=13 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=14 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=15 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=18 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=70 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=60 then reltrad2="Conservative";
if Prot_type = "Black Protestant" & denom=11 then reltrad2="Mainline";
if Prot_type = "Black Protestant" & denom=20 then reltrad2="Mainline";
if Prot_type = "Black Protestant" & denom=21 then reltrad2="Mainline";
if Prot_type = "Black Protestant" & denom=23 then reltrad2="Mainline";
if Prot_type = "Black Protestant" & denom=28 then reltrad2="Mainline";


/*From earlier years, there are additional church codes. I looked up each one and categorized them
based on Steensland and/or the church's self-description on their website. 
I started on this, but it's a lot to research for one chart. 
I think these are otherwise left blank (they are not included in the Steenslad scheme)*/
/*if OTHER=123 then reltrad2=
if OTHER=137 then reltrad2=
if OTHER=143 then reltrad2=
if OTHER=144 then reltrad2=
if OTHER=150 then reltrad2=
if OTHER=151 then reltrad2=
if OTHER=152 then reltrad2=
if OTHER=153 then reltrad2=
if OTHER=154 then reltrad2=
if OTHER=155 then reltrad2=
if OTHER=157 then reltrad2=
if OTHER=158 then reltrad2=
if OTHER=159 then reltrad2=
if OTHER=166 then reltrad2=
if OTHER=167 then reltrad2=
if OTHER=168 then reltrad2=
if OTHER=169 then reltrad2=
if OTHER=170 then reltrad2=
if OTHER=171 then reltrad2=
if OTHER=172 then reltrad2=
if OTHER=173 then reltrad2=
if OTHER=174 then reltrad2=
if OTHER=175 then reltrad2=
if OTHER=177 then reltrad2=
if OTHER=178 then reltrad2=
if OTHER=179 then reltrad2=
if OTHER=180 then reltrad2=
if OTHER=181 then reltrad2=
if OTHER=185 then reltrad2=
if OTHER=186 then reltrad2=
if OTHER=187 then reltrad2=
if OTHER=188 then reltrad2=
if OTHER=191 then reltrad2=
if OTHER=196 then reltrad2=
if OTHER=197 then reltrad2=
if OTHER=198 then reltrad2=
if OTHER=201 then reltrad2=
if OTHER=205 then reltrad2="Conservative";
if OTHER=206 then reltrad2="Conservative";
if OTHER=207 then reltrad2="Conservative";
if OTHER=208 then reltrad2="Conservative";
if OTHER=210 then reltrad2="Conservative"; *Black Protestant;
if OTHER=211 then reltrad2="Mainline";
if OTHER=212 then reltrad2="Conservative"; *Brunstad?;
if OTHER=213 then reltrad2="Conservative";
if OTHER=214 then reltrad2="Conservative"; *Black Protestant;
if OTHER=215 then reltrad2="Conservative";
*/





Diddivorce=.;
if MARITAL=1 then Diddivorce=0;
if MARITAL=2 then Diddivorce=0;
if MARITAL=4 then Diddivorce=0;
if DIVORCE=1 then Diddivorce=1; /*recodes some MARITAL=1 or 2 to Diddivorce=1
				and some MARITAL=4 to Diddivorce=1 
				because of the question dependency, which is what we want.
				That is; it recodes "currently married"(1), "currently widowed"(2) and
				"currently seperated" (4) as Diddivorce=1 which is what we want because,
				although they are currently married, currently widowed, or currently 
				seperated, they have experienced divorce at some point previously.
				In cases where DIVORCE^=1, then the respondent is simply currently 
				married (never been divorced), currently widowed (never been divorced),
				or currently seperated (never been divorced); i.e., Diddivorce=0*/
if MARITAL=3 then Diddivorce=1; /*These are folks who are simply "currently divorced"*/
if MARITAL=5 then Diddivorce=.; /*These are the folks who are "never married" and so are omitted*/

actual_kids=CHILDS;
if CHILDS<0 then actual_kids=.;

Rel_commit=.;
if ATTEND >-1 & ATTEND<4 then Rel_commit=0;
if ATTEND >3 then Rel_commit=1;

age_recode=age;
	if age<18 then age_recode=.;
CHILDLESS=.;
	if age_recode>49 & CHILDS>0 then CHILDLESS=0;
	if age_recode>49 & CHILDS=0 then CHILDLESS=1;

/*quality of life improvement: use number prefix to auto-reorder the frequency tables*/
generation_=generation;
if generation="Generation Z" then generation_="1 Gen Z";
if generation="Millenial" then generation_="2 Mill";
if generation="Generation X" then generation_="3 Gen X";
if generation="Young Baby Boomer Generation" then generation_="4 Y BB";
if generation="Old Baby Boomer Generation" then generation_="5 O BB";
if generation="Silent Generation" then generation_="6 Silent";
Trad_6cat=Trad_sixcat_;
if Trad_sixcat_="Catholic" then Trad_6cat="1 Cath";
if Trad_sixcat_="Mainline Protestant" then Trad_6cat="2 ML Prot";
if Trad_sixcat_="Conservative Protestant" then Trad_6cat="3 Con Prot";
if Trad_sixcat_="None" then Trad_6cat="4 None";
if Trad_sixcat_="Other" then Trad_6cat="5 Oth";
if Trad_sixcat_="Black Protestant" then Trad_6cat="6 BProt";

if reltrad2="Catholic" then reltrad2="1 Cath";
if reltrad2="Mainline" then reltrad2="2 ML Prot";
if reltrad2="Conservative" then reltrad2="3 Con Prot";
if reltrad2="None" then reltrad2="4 None";
if reltrad2="Other" then reltrad2="5 Oth";


year_cat="placeholder for formatting";
	if year>1971 & year <1982 then year_cat="1972-1978";
	if year>1981 & year <1990 then year_cat="1980-1989";
	if year>1989 & year <2000 then year_cat="1990-1998";
	if year>1999 & year <2010 then year_cat="2000-2008";
	if year>2009 & year <2019 then year_cat="2010-2018";
	if year>2019 then year_cat="2021";
year_cat_dum=.;
if year_cat="1972-1978" then year_cat_dum=0;
if year_cat="1980-1989" then year_cat_dum=1;
if year_cat="1990-1998" then year_cat_dum=2;
if year_cat="2000-2008" then year_cat_dum=3;
if year_cat="2010-2018" then year_cat_dum=4;
if year_cat="2021" then year_cat_dum=5;

generation_dum=.;
if generation_="1 Gen Z" then generation_dum=5;
if generation_="2 Mill" then generation_dum=4;
if generation_="3 Gen X" then generation_dum=3;
if generation_="4 Y BB" then generation_dum=2;
if generation_="5 O BB" then generation_dum=1;
if generation_="6 Silent" then generation_dum=0;

/*##############################
New coding scheme:
White Catholic (to be omitted)

Latino Catholic
White MP
White CP
White None
Latino Protestant
Other
*/

New_Trad="placeholder for the variable New_Trad";
if Race_fourcat_="1 White" & reltrad2="1 Cath" then New_Trad="1 White Catholic";
if Race_fourcat_="1 White" & reltrad2="2 ML Prot" then New_Trad="3 White MP";
if Race_fourcat_="1 White" & reltrad2="3 Con Prot" then New_Trad="4 White CP";
if Race_fourcat_="1 White" & reltrad2="4 None" then New_Trad="5 White None";
if Race_fourcat_="1 White" & reltrad2="5 Oth" then New_Trad="7 All Other Trads";

if Race_fourcat_="2 Hispanic" & reltrad2="1 Cath" then New_Trad="2 Latino Catholic";
if Race_fourcat_="2 Hispanic" & reltrad2="2 ML Prot" then New_Trad="6 Latino Prot";
if Race_fourcat_="2 Hispanic" & reltrad2="3 Con Prot" then New_Trad="6 Latino Prot";
if Race_fourcat_="2 Hispanic" & reltrad2="4 None" then New_Trad="7 All Other Trads";
if Race_fourcat_="2 Hispanic" & reltrad2="5 Oth" then New_Trad="7 All Other Trads";

if Race_fourcat_="3 Black" & reltrad2="1 Cath" then New_Trad="7 All Other Trads";
if Race_fourcat_="3 Black" & reltrad2="2 ML Prot" then New_Trad="7 All Other Trads";
if Race_fourcat_="3 Black" & reltrad2="3 Con Prot" then New_Trad="7 All Other Trads";
if Race_fourcat_="3 Black" & reltrad2="4 None" then New_Trad="7 All Other Trads";
if Race_fourcat_="3 Black" & reltrad2="5 Oth" then New_Trad="7 All Other Trads";

if Race_fourcat_="4 Other Race" & reltrad2="1 Cath" then New_Trad="7 All Other Trads";
if Race_fourcat_="4 Other Race" & reltrad2="2 ML Prot" then New_Trad="7 All Other Trads";
if Race_fourcat_="4 Other Race" & reltrad2="3 Con Prot" then New_Trad="7 All Other Trads";
if Race_fourcat_="4 Other Race" & reltrad2="4 None" then New_Trad="7 All Other Trads";
if Race_fourcat_="4 Other Race" & reltrad2="5 Oth" then New_Trad="7 All Other Trads";

if New_Trad="placeholder for the variable New_Trad" then New_Trad="";


/*chapter 3 visuals*/
evermarried=.;
if marital<1 then evermarried=.;
	if marital>0 & marital<5 then evermarried=1;
	if marital=5 then evermarried=0;
/*
Cohabitate="placeholder for the cohabitate variable";
	if MARCOHAB<1 then Cohabitate="";
	if MARCOHAB=1 then Cohabitate="1 Married";
	if MARCOHAB=2 then Cohabitate="2 Not Married, cohab";
	if MARCOHAB=3 then Cohabitate="3 Not Married, no cohab";
	if MARCOHAB=4 then Cohabitate="";
*/
Livetogether_unmarried=.;
	if MARCOHAB=1 then Livetogether_unmarried=0;
	if MARCOHAB=2 then Livetogether_unmarried=1;
SPOUSE_tradition="unknown tradition";
	if SPREL=1 then SPOUSE_tradition="Protestant";
	if SPREL=2 then SPOUSE_tradition="Catholic";
	if SPREL=3 then SPOUSE_tradition="Other Rel";
	if SPREL=4 then SPOUSE_tradition="None";
	if SPREL=5 then SPOUSE_tradition="Other Rel";
	if SPREL=6 then SPOUSE_tradition="Other Rel";
	if SPREL=7 then SPOUSE_tradition="Other Rel";
	if SPREL=8 then SPOUSE_tradition="Other Rel";
	if SPREL=9 then SPOUSE_tradition="Other Rel";
	if SPREL=10 then SPOUSE_tradition="Other Rel";
	if SPREL=11 then SPOUSE_tradition="Protestant";
	if SPREL=12 then SPOUSE_tradition="Other Rel";
	if SPREL=13 then SPOUSE_tradition="Protestant";
	if SPOUSE_tradition="unknown tradition" then SPOUSE_tradition="";
Matched_tradition=.;
	if Tradition = SPOUSE_tradition then Matched_tradition=1;
	if Tradition ^= SPOUSE_tradition then Matched_tradition=0;
	if Tradition="" then Matched_tradition=.;
	if SPOUSE_tradition="" then Matched_tradition=.;
		/*0 lt HS; 1 HS; 2 AA/JC; 3 BA; 4 Grad*/
	if spdeg>-1 then spouse_degree=spdeg;
	if degree>-1 then R_degree=degree;
bothcoll=.;
	if spouse_degree>2 & R_degree>2 then bothcoll=1;
	if spouse_degree<3 & R_degree<3 then bothcoll=0;
	if spouse_degree=. then bothcoll=.;
	if R_degree=. then bothcoll=.;
ed_homo =.;
	if spouse_degree>2 & R_degree>2 then ed_homo=1;
	if spouse_degree<3 & R_degree<3 then ed_homo=1;
	if spouse_degree>2 & R_degree>3 then ed_homo=0;
	if spouse_degree<3 & R_degree>2 then ed_homo=0;
idealkids=CHLDIDEL;
	if CHLDIDEL<0 then idealkids=.;
idealkids_="placeholder for idealkids char";
	if idealkids=0 then idealkids_="1 Two or fewer";
	if idealkids=1 then idealkids_="1 Two or fewer";
	if idealkids=2 then idealkids_="1 Two or fewer";
	if idealkids=3 then idealkids_="2 Three or Four";
	if idealkids=4 then idealkids_="2 Three or Four";
	if idealkids=5 then idealkids_="3 Five or more";
	if idealkids=6 then idealkids_="3 Five or more";
	if idealkids=7 then idealkids_="3 Five or more";
	if idealkids=8 then idealkids_="4 As many as you want";
	if idealkids_="placeholder for idealkids char" then idealkids_="";
morethantwo=.;
	if idealkids<3 then morethantwo=0;
	if idealkids>2 then morethantwo=1;
	if idealkids=8 then morethantwo=.;
agekdbrn_cat="placeholder for agekdbrn_cat";
	if agekdbrn<0 then agekdbrn_cat="";
	if agekdbrn>8 & agekdbrn<18  then agekdbrn_cat="1 9 to 17";
	if agekdbrn>17 & agekdbrn<26 then agekdbrn_cat="2 18 to 25";
	if agekdbrn>25 & agekdbrn<31 then agekdbrn_cat="3 26 to 30";
	if agekdbrn>30 & agekdbrn<36 then agekdbrn_cat="4 31 to 35";
	if agekdbrn>35 & agekdbrn<41 then agekdbrn_cat="5 36 to 40";
	if agekdbrn>40 then agekdbrn_cat="6 41 or older";
	if educ <0 then edlevel=.;
	if educ>=0 & educ<12 then edlevel=0;	/*less than HS*/
	if educ=12 then edlevel=1; 				/*HS*/
	if educ>12 & educ<16 then edlevel=2;	/*some college*/
	if educ=16 then edlevel=3;				/*College*/
	if educ>16 then edlevel=4;				/*Grad school*/
fulltime=.;
	if hrs1>0 & hrs1<40 then fulltime=0;
	if hrs1>39 then fulltime=1;
Spouse_works=.;
	if spwrksta=1 | spwrksta=2 then Spouse_works=1;
	if spwrksta>2 then Spouse_works=0;

if coneduc=1 then conf_ed="Great deal of conf in educ";
if coneduc=2 then conf_ed="only some conf in educ";
if coneduc=3 then conf_ed="hardly any conf in educ";
if coneduc<1 then conf_ed="";
if coneduc=1 then conf_ed_dum=1;
if coneduc>1 then conf_ed_dum=0;
if coneduc=3 then noconf_ed_dum=1;
if coneduc=2 then noconf_ed_dum=0;
if coneduc=1 then noconf_ed_dum=0;
if educ <0 then edlevel=.;
if educ>=0 & educ<12 then edlevel=0;	/*less than HS*/
if educ=12 then edlevel=1; 				/*HS*/
if educ>12 & educ<16 then edlevel=2;	/*some college*/
if educ=16 then edlevel=3;				/*College*/
if educ>16 then edlevel=4;				/*Grad school*/

educ2=.;
if edlevel=0 then educ2=0;
if edlevel=1 then educ2=0;
if edlevel=2 then educ2=0;
if edlevel=3 then educ2=1;
if edlevel=4 then educ2=1;

RHoursPerWeek=hrs1;
SHoursPerWeek=sphrs1;
if hrs1<0 then RHoursPerWeek=.;
if hrs1=. then RHoursPerWeek=.;
if sphrs1<0 then SHoursPerWeek=.;
if sphrs1=. then SHoursPerWeek=.;
/*#####################
The missings are counting as zeroes for some reason? So I'm hardcoding the missing
################################*/

if RHoursPerWeek<10 then R_nonwork=1;
	if RHoursPerWeek=. then R_nonwork=.;
if RHoursPerWeek>34 then R_full=1;
	if RHoursPerWeek=. then R_full=.;
if RHoursPerWeek>9 & RHoursPerWeek<35 then R_part=1;
	if RHoursPerWeek=. then R_part=.;

if SHoursPerWeek<10 then S_nonwork=1;
	if SHoursPerWeek<10 then S_nonwork=.;
if SHoursPerWeek>34 then S_full=1;
	if SHoursPerWeek<10 then S_full=.;
if SHoursPerWeek>9 & SHoursPerWeek<35 then S_part=1;
	if SHoursPerWeek<10 then S_part=.;

if R_nonwork=1 & 	S_nonwork=1 then laborcat="NonWorker";
if R_full=1 & 		S_nonwork=1 then laborcat="Tradition";
if R_part=1 & 		S_nonwork=1 then laborcat="Tradition";
if R_full=1 & 		S_part=1 then laborcat="NeoTrad";
if R_full=1 & 		S_full=1 then laborcat="Dual";
if R_part=1 & 		S_part=1 then laborcat="Dual";
if R_nonwork=1 & 	S_full=1 then laborcat="Prog";
if R_nonwork=1 & 	S_part=1 then laborcat="Prog";
if R_part=1 & 		S_full=1 then laborcat="NeoProg";



labor3cat_="placeholder for laborcat";
if laborcat="Tradition" then labor3cat_="Traditional";
if laborcat="NeoTrad" then labor3cat_="NeoTrad";
if laborcat="Dual" then labor3cat_="Dual";
if labor3cat_="placeholder for laborcat" then labor3cat_="";


Owns_house=.;
if DWELOWN=1 then Owns_house=1;
if DWELOWN=2 then Owns_house=0;
if DWELOWN=3 then Owne_house=0;

if CLASS1>0 then R_class=CLASS1;
if ENDSMEET>0 then makeendsmeet=ENDSMEET;

/*CHAPTER 4*/
if coneduc=1 then conf_ed="Great deal of conf in educ";
if coneduc=2 then conf_ed="only some conf in educ";
if coneduc=3 then conf_ed="hardly any conf in educ";
if coneduc<1 then conf_ed="";
if coneduc=1 then conf_ed_dum=1;
if coneduc>1 then conf_ed_dum=0;
if coneduc=3 then noconf_ed_dum=1;
if coneduc=2 then noconf_ed_dum=0;
if coneduc=1 then noconf_ed_dum=0;
if educ <0 then edlevel=.;
if educ>=0 & educ<12 then edlevel=0;	/*less than HS*/
if educ=12 then edlevel=1; 				/*HS*/
if educ>12 & educ<16 then edlevel=2;	/*some college*/
if educ=16 then edlevel=3;				/*College*/
if educ>16 then edlevel=4;				/*Grad school*/


ed_dum=.;
if edlevel=0 then ed_dum=0;
if edlevel=1 then ed_dum=0;
if edlevel=2 then ed_dum=0;
if edlevel=3 then ed_dum=1;
if edlevel=4 then ed_dum=1;
R_degree_dum=.;
if R_degree<3 then R_degree_dum=0;
if R_degree>2 then R_degree_dum=1;

RHoursPerWeek=hrs1;
SHoursPerWeek=sphrs1;
if hrs1<0 then RHoursPerWeek=.;
if hrs1=. then RHoursPerWeek=.;
if sphrs1<0 then SHoursPerWeek=.;
if sphrs1=. then SHoursPerWeek=.;
/*#####################
The missings are counting as zeroes for some reason? So I'm hardcoding the missing
################################*/

if RHoursPerWeek<10 then R_nonwork=1;
	if RHoursPerWeek=. then R_nonwork=.;
if RHoursPerWeek>34 then R_full=1;
	if RHoursPerWeek=. then R_full=.;
if RHoursPerWeek>9 & RHoursPerWeek<35 then R_part=1;
	if RHoursPerWeek=. then R_part=.;

if SHoursPerWeek<10 then S_nonwork=1;
	if SHoursPerWeek<10 then S_nonwork=.;
if SHoursPerWeek>34 then S_full=1;
	if SHoursPerWeek<10 then S_full=.;
if SHoursPerWeek>9 & SHoursPerWeek<35 then S_part=1;
	if SHoursPerWeek<10 then S_part=.;

if R_nonwork=1 & 	S_nonwork=1 then laborcat="NonWorker";
if R_full=1 & 		S_nonwork=1 then laborcat="Tradition";
if R_part=1 & 		S_nonwork=1 then laborcat="Tradition";
if R_full=1 & 		S_part=1 then laborcat="NeoTrad";
if R_full=1 & 		S_full=1 then laborcat="Dual";
if R_part=1 & 		S_part=1 then laborcat="Dual";
if R_nonwork=1 & 	S_full=1 then laborcat="Prog";
if R_nonwork=1 & 	S_part=1 then laborcat="Prog";
if R_part=1 & 		S_full=1 then laborcat="NeoProg";
/*Add this control, per Lisa's request*/;
nonimm_dum=.;
if im_gen="1 non-immigrant" then nonimm_dum=1;
if im_gen="2 second generation" then nonimm_dum=0;
if im_gen="3 first generation" then nonimm_dum=0;

dual_inc=0;
if wrkstat=1 & spwrksta=1 then dual_inc=1;
if wrkstat=1 & spwrksta=2 then dual_inc=1;
if wrkstat=2 & spwrksta=1 then dual_inc=1;
if wrkstat=2 & spwrksta=2 then dual_inc=1;
if wrkstat<0 then dual_inc=.;
if spwrksta <0 then dual_inc=.;




labor3cat_="placeholder for laborcat";
if laborcat="Tradition" then labor3cat_="Traditional";
if laborcat="NeoTrad" then labor3cat_="NeoTrad";
if laborcat="Dual" then labor3cat_="Dual";
if labor3cat_="placeholder for laborcat" then labor3cat_="";


Owns_house=.;
if DWELOWN=1 then Owns_house=1;
if DWELOWN=2 then Owns_house=0;
if DWELOWN=3 then Owne_house=0;

if CLASS1>0 then R_class=CLASS1;
R_upperclass=0;
if CLASS1=5 then R_upperclass=1;
if CLASS1=6 then R_upperclass=1;
if CLASS1<0 then R_upperclass=.;
R_lowerclass=.;
if CLASS1=1 then R_lowerclass=1;
if CLASS1=2 then R_lowerclass=1;
if CLASS1>2 then R_lowerclass=0;

if ENDSMEET>0 then makeendsmeet=ENDSMEET;
easy_ends=.;
if ENDSMEET>3 then easy_ends=1;
if ENDSMEET<4 & ENDSMEET>0 then easy_ends=0;
hard_ends=.;
if ENDSMEET>2 then hard_ends=0;
if ENDSMEET=1 then hard_ends=1;
if ENDSMEET=2 then hard_ends=1;

/*Pardon the ugly code, but for some reason, when coding normally, some of the dummies didn't work?*/
income2021=.;
if CONINC=336 then income2021=1;	/* 1-999 */
if CONINC=1344 then income2021=2;	/* 1000 - 1,999 */
if CONINC=2352 then income2021=3;	/* 2,000-2,999 */
if CONINC=3024 then income2021=4;	/* 3,000-3,999 */
if CONINC>3024 & CONINC<4368/*3696*/ then income2021=5;	/* 4,000-4,999 */
if CONINC=4368 then income2021=6;	/* 5,000-5,999 */
if CONINC=5040 then income2021=7;	/* 6,000-6,999 */
if CONINC=6048 then income2021=8;	/* 7,000-7,999 */
if CONINC>6048 & CONINC<9240 /*7560*/ then income2021=9;	/* 8,000-8,999 */
if CONINC=9240 then income2021=10;	/* 9,000-9,999 */
if CONINC=10920 then income2021=11;	/* 10,000-10,999 */
if CONINC=12600 then income2021=12;	/* 12,000-14,999 */
if CONINC=14280 then income2021=13;	/* between */
if CONINC>14280 & CONINC<18480 /*15960*/ then income2021=14;	/* 15,000-19,999 */
if CONINC=18480 then income2021=15;	/* between */
if CONINC=21840 then income2021=16;	/* 20,000-24,999 */
if CONINC=25200 then income2021=17;	/* 25,000-29,999 */
if CONINC>25200 & CONINC<36960 /*30240*/ then income2021=18;	/* 30,000-39,999 */
if CONINC=36960 then income2021=19;	/* between */
if CONINC=45360 then income2021=20;	/* 40,000-49,999 */
if CONINC=55440 then income2021=21;	/* 50,000-74,999 */
if CONINC=67200 then income2021=22;	/* between */
if CONINC=80640 then income2021=23;	/* 75,000-99,999 */
if CONINC=94080 then income2021=24;	/* between */
if CONINC=107520 then income2021=25;	/* 100,000-999,999 */
if CONINC=168736.29696 then income2021=26;	/* higher */
poverty2021=.;
if income2021>16 then poverty2021=0;
if income2021<17 then poverty2021=1;
rich2021=.;
if income2021>22 then rich2021=1;
if income2021<23 then rich2021=0;

abovemedian2021=.;
if income2021>22 then abovemedian2021=1;
if income2021<23 then abovemedian2021=0;


/*this is my ad hoc "in poverty" code:
"in Poverty" depends on income level and how many people are in the household.
The income level we are using is already binned, so this coding isn't exact. 
Where potential "in poverty" observations are omitted or "not in poverty" are 
included due to binning, I note that in my code, below. We can adjust this
however we want.

HHPOP (number of people in household) is not asked in 2021, so I'm going to 
estimate it by using the variables MARRIED, CHILDS, and AGE:
Married assumes R and spouse in household
Childs=number of kids
Age is used to filter kids of older adults who don't live at home anymore.
*/
HHPOP_est=.;
if Married=1 then HHPOP_est=2;
if Married=0 then HHPOP_est=1;
if Livetogether_unmarried=1 then HHPOP_est=2;
if AGE<59 & CHILDS>0 then HHPOP_est=HHPOP_est + CHILDS;
/*max HHPOP is 10*/

/*In Poverty*/
inpov=0;
if HHPOP_est=1 & income2021<12 then inpov=1; /*cutoff is 12,880 and bins are 10-10,999 and 12-14,999 (11K-12K is already missing in GSS), so $11,000 to $12,880 are OMITTED*/
if HHPOP_est=2 & income2021<15 then inpov=1; /*cutoff is 17,420 and bin is 15-19,999, so 17,421 to 19,999 is INCLUDED*/
if HHPOP_est=3 & income2021<16 then inpov=1; /*cutoff is 21,960 and top of bin #15 is 19,999, so 20,000 to 21,960 is OMITTED*/
if HHPOP_est=4 & income2021<17 then inpov=1; /*cutoff is 26,500 and top of bin #16 is 25,000, so 25,000 to 26,500 is OMITTED*/
if HHPOP_est=5 & income2021<18 then inpov=1; /*cutoff is 31,040 and top of bin #17 is 29,999, so 30,000 to 31,040 is OMITTED*/
if HHPOP_est=6 & income2021<19 then inpov=1; /*cutoff is 35,580 and falls in the middle of bin #18 (30-39,999) so 35,581 to 39,999 is INCLUDED*/
if HHPOP_est=7 & income2021<20 then inpov=1; /*cutoff is 40,120, which is very close to bottom of bin #19: 40,000*/
if HHPOP_est=8 & income2021<21 then inpov=1; /*cutoff is 44,660 and falls in the middle of bin #20 (40-49,999) so 44,661 to 49,999 is INCLUDED*/
if HHPOP_est=9 & income2021<21 then inpov=1; /*cutoff is about 50K, which is the bottom of bin #21 */
if HHPOP_est=10 & income2021<21 then inpov=1; /*cutoff is about 55K, which is 5K over bottom of bin #21, so 50K-55K is OMITTED*/
if HHPOP_est=. then inpov=.;
if income2021=. then inpov=.;

/*Chapter 5

Introduce the idea of RELTRAD3 (for across time religious change using religion at age 16 and current religion
Y_RELTRAD3 = tradition at age 16
RELTRAD3 = tradition at time of survey (18+)
religion at age 16 has less information for CP/MP  differentiation criteria, so I make a RELTRAD2 with what we have for 
RELIG16 and then use that same criteria for RELIG*/

/*New Tradition scheme that omits race and codes for religion at 16 with the available info*/

if DENOM=10 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/
if DENOM=11 then RELTRAD3="Mainline"; 		/*streamlined from RELTRAD2*/
if DENOM=12 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/
if DENOM=13 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/ /*depends how much they attend, <=3 is mainline */

if RELTRAD2="1 Cath" then RELTRAD3="Catholic";
if RELTRAD2="4 None" then RELTRAD3="None";
if RELTRAD2="5 Oth" then RELTRAD3="Other";
/*if RELIG=2 then RELTRAD3="Catholic";
if RELIG=3 then RELTRAD3="Other";
if RELIG>4 & RELIG<11 then RELTRAD3="Other";
if RELIG=12 then RELTRAD3="Other";*/

if DENOM=14 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/
if DENOM=15 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/
if DENOM=18 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/
if DENOM=20 then RELTRAD3="Mainline";		/*streamlined from RELTRAD2*/
if DENOM=21 then RELTRAD3="Mainline";		/*streamlined from RELTRAD2*/
/*23 black is mainline, 23 white is con:*/
if DENOM=23 & RACE^=2 then RELTRAD3="Conservative";
if Prot_type = "Black Protestant" & denom=23 then RELTRAD3="Mainline";
/*There are 31 Black DENOM=23 and 116 White DENOM=23 and 2 Other DENOM=23*/
if DENOM=22 then RELTRAD3="Mainline";
if DENOM=28 then RELTRAD3="Mainline";		/*streamlined from RELTRAD2*/
if DENOM=30 then RELTRAD3="Mainline";
if DENOM=31 then RELTRAD3="Mainline";
if DENOM=32 then RELTRAD3="Conservative";
if DENOM=33 then RELTRAD3="Conservative";
if DENOM=34 then RELTRAD3="Conservative";
if DENOM=35 then RELTRAD3="Mainline";
if DENOM=38 then RELTRAD3="Mainline";
if DENOM=40 then RELTRAD3="Mainline";
if DENOM=41 then RELTRAD3="Mainline";
if DENOM=42 then RELTRAD3="Conservative";
if DENOM=43 then RELTRAD3="Mainline";
if DENOM=48 then RELTRAD3="Mainline";
if DENOM=50 then RELTRAD3="Mainline";
if DENOM=60 then RELTRAD3="Conservative";	/*streamlined from RELTRAD2*/
if DENOM=70 & RACE^=1 then RELTRAD3="Conservative";	
if DENOM=70 & ATTEND>3 then RELTRAD3="Conservative";
if DENOM=70 & ATTEND<4 & ATTEND>-1 then RELTRAD3="Mainline";
/*I follow the RELTRAD2 scheme of using attendance to 
differentiate "non-denominational" for RELTRAD3.
For Y_RELTRAD3, though, if DENOM=70, there is no "ATTEND16" 
so I just say that Y_RELTRAD3=RELTRAD3.*/
if OTHER=99 then RELTRAD3="Mainline";
if OTHER=19 then RELTRAD3="Mainline";
if OTHER=25 then RELTRAD3="Mainline";
if OTHER=40 then RELTRAD3="Mainline";
if OTHER=44 then RELTRAD3="Mainline";
if OTHER=46 then RELTRAD3="Mainline";
if OTHER=49 then RELTRAD3="Mainline";
if OTHER=48 then RELTRAD3="Mainline";
if OTHER=50 then RELTRAD3="Mainline";
if OTHER=54 then RELTRAD3="Mainline";
if OTHER=89 then RELTRAD3="Mainline";
if OTHER=1 then RELTRAD3="Mainline";
if OTHER=105 then RELTRAD3="Mainline";
if OTHER=8 then RELTRAD3="Mainline";
if OTHER=70 then RELTRAD3="Mainline";
if OTHER=71 then RELTRAD3="Mainline";
if OTHER=73 then RELTRAD3="Mainline";
if OTHER=72 then RELTRAD3="Mainline";
if OTHER=148 then RELTRAD3="Mainline";
if OTHER=23 then RELTRAD3="Mainline";
if OTHER=119 then RELTRAD3="Mainline";
if OTHER=81 then RELTRAD3="Mainline";
if OTHER=96 then RELTRAD3="Mainline";
if OTHER=10 then RELTRAD3="Conservative";
if OTHER=111 then RELTRAD3="Conservative";
if OTHER=107 then RELTRAD3="Conservative";
if OTHER=138 then RELTRAD3="Conservative";
if OTHER=12 then RELTRAD3="Conservative";
if OTHER=109 then RELTRAD3="Conservative";
if OTHER=20 then RELTRAD3="Conservative";
if OTHER=22 then RELTRAD3="Conservative";
if OTHER=132 then RELTRAD3="Conservative";
if OTHER=110 then RELTRAD3="Conservative";
if OTHER=122 then RELTRAD3="Conservative";
if OTHER=102 then RELTRAD3="Conservative";
if OTHER=135 then RELTRAD3="Conservative";
if OTHER=108 then RELTRAD3="Conservative";
if OTHER=29 then RELTRAD3="Conservative";
if OTHER=9 then RELTRAD3="Conservative";
if OTHER=125 then RELTRAD3="Conservative";
if OTHER=28 then RELTRAD3="Conservative";
if OTHER=31 then RELTRAD3="Conservative";
if OTHER=32 then RELTRAD3="Conservative";
if OTHER=26 then RELTRAD3="Conservative";
if OTHER=101 then RELTRAD3="Conservative";
if OTHER=36 then RELTRAD3="Conservative";
if OTHER=35 then RELTRAD3="Conservative";
if OTHER=34 then RELTRAD3="Conservative";
if OTHER=127 then RELTRAD3="Conservative";
if OTHER=121 then RELTRAD3="Conservative";
if OTHER=5 then RELTRAD3="Conservative";
if OTHER=116 then RELTRAD3="Conservative";
if OTHER=39 then RELTRAD3="Conservative";
if OTHER=41 then RELTRAD3="Conservative";
if OTHER=42 then RELTRAD3="Conservative";
if OTHER=43 then RELTRAD3="Conservative";
if OTHER=2 then RELTRAD3="Conservative";
if OTHER=91 then RELTRAD3="Conservative";
if OTHER=45 then RELTRAD3="Conservative";
if OTHER=47 then RELTRAD3="Conservative";
if OTHER=112 then RELTRAD3="Conservative";
if OTHER=120 then RELTRAD3="Conservative";
if OTHER=139 then RELTRAD3="Conservative";
if OTHER=124 then RELTRAD3="Conservative";
if OTHER=51 then RELTRAD3="Conservative";
if OTHER=53 then RELTRAD3="Conservative";
if OTHER=13 then RELTRAD3="Conservative";
if OTHER=16 then RELTRAD3="Conservative";
if OTHER=52 then RELTRAD3="Conservative";
if OTHER=100 then RELTRAD3="Conservative";
if OTHER=90 then RELTRAD3="Conservative";
if OTHER=18 then RELTRAD3="Conservative";
if OTHER=55 then RELTRAD3="Conservative";
if OTHER=24 then RELTRAD3="Conservative";
if OTHER=3 then RELTRAD3="Conservative";
if OTHER=134 then RELTRAD3="Conservative";
if OTHER=146 then RELTRAD3="Conservative";
if OTHER=129 then RELTRAD3="Conservative";
if OTHER=131 then RELTRAD3="Conservative";
if OTHER=63 then RELTRAD3="Conservative";
if OTHER=115 then RELTRAD3="Conservative";
if OTHER=117 then RELTRAD3="Conservative";
if OTHER=92 then RELTRAD3="Conservative";
if OTHER=65 then RELTRAD3="Conservative";
if OTHER=6 then RELTRAD3="Conservative";
if OTHER=27 then RELTRAD3="Conservative";
if OTHER=97 then RELTRAD3="Conservative";
if OTHER=68 then RELTRAD3="Conservative";
if OTHER=66 then RELTRAD3="Conservative";
if OTHER=67 then RELTRAD3="Conservative";
if OTHER=69 then RELTRAD3="Conservative";
if OTHER=140 then RELTRAD3="Conservative";
if OTHER=57 then RELTRAD3="Conservative";
if OTHER=133 then RELTRAD3="Conservative";
if OTHER=76 then RELTRAD3="Conservative";
if OTHER=77 then RELTRAD3="Conservative";
if OTHER=94 then RELTRAD3="Conservative";
if OTHER=106 then RELTRAD3="Conservative";
if OTHER=118 then RELTRAD3="Conservative";
if OTHER=83 then RELTRAD3="Conservative";
if OTHER=84 then RELTRAD3="Conservative";
/*Other Affiliation (Conservative Nontraditional)*/
if OTHER=30 then RELTRAD3="Conservative";
if OTHER=33 then RELTRAD3="Conservative";
if OTHER=145 then RELTRAD3="Conservative";
if OTHER=114 then RELTRAD3="Conservative";
if OTHER=58 then RELTRAD3="Conservative";
if OTHER=62 then RELTRAD3="Conservative";
if OTHER=59 then RELTRAD3="Conservative";
if OTHER=60 then RELTRAD3="Conservative";
if OTHER=61 then RELTRAD3="Conservative";
if OTHER=64 then RELTRAD3="Conservative";
if OTHER=130 then RELTRAD3="Conservative";
if OTHER=113 then RELTRAD3="Conservative";
/*Other Affiliation (Liberal Nontraditional)*/
if OTHER=29 then RELTRAD3="Mainline";
if OTHER=17 then RELTRAD3="Mainline";
if OTHER=75 then RELTRAD3="Mainline";
if OTHER=136 then RELTRAD3="Mainline";
if OTHER=141 then RELTRAD3="Mainline";
if OTHER=74 then RELTRAD3="Mainline";
if OTHER=11 then RELTRAD3="Mainline";
if OTHER=80 then RELTRAD3="Mainline";
if OTHER=82 then RELTRAD3="Mainline";
if OTHER=95 then RELTRAD3="Mainline";

/*cleaning up the missings, following the logic from RELTRAD2*/
if RELTRAD3="" & RELIG=1 then RELTRAD3="Mainline";
if RELTRAD3="" & RELIG=11 & DENOM=70 then RELTRAD3="Conservative";
if RELTRAD3="" & RELIG=11 & DENOM=. then RELTRAD3="Mainline";
if RELTRAD3="" & RELIG=13 then RELTRAD3="Conservative";
/*Now, for Y_RELTRAD3
Basically, run it through the same coding scheme except for DENOM16=70
where we have to copy DENOM=70 if the two are the same*/
/*************************************************************************************************************************/

if DENOM16=10 then Y_RELTRAD3="Conservative";	
if DENOM16=11 then Y_RELTRAD3="Mainline"; 		
if DENOM16=12 then Y_RELTRAD3="Conservative";	
if DENOM16=13 then Y_RELTRAD3="Conservative";

if RELIG16=2 then Y_RELTRAD3="Catholic";
if RELIG16=3 then Y_RELTRAD3="Other";
if RELIG16=4 then Y_RELTRAD3="None";
if RELIG16>4 & RELIG16<11 then Y_RELTRAD3="Other";
if RELIG16=12 then Y_RELTRAD3="Other";

if Y_RELTRAD3="" & RELIG16=1 then Y_RELTRAD3="Mainline";
if Y_RELTRAD3="" & RELIG16=11 & DENOM16=70 then Y_RELTRAD3="Conservative";
if Y_RELTRAD3="" & RELIG16=11 & DENOM16=. then Y_RELTRAD3="Mainline";
if Y_RELTRAD3="" & RELIG16=13 then Y_RELTRAD3="Conservative";

if DENOM16=10 then Y_RELTRAD3="Conservative";	
if DENOM16=11 then Y_RELTRAD3="Mainline"; 		
if DENOM16=12 then Y_RELTRAD3="Conservative";	
if DENOM16=13 then Y_RELTRAD3="Conservative";	
if DENOM16=14 then Y_RELTRAD3="Conservative";	
if DENOM16=15 then Y_RELTRAD3="Conservative";	
if DENOM16=18 then Y_RELTRAD3="Conservative";	
if DENOM16=20 then Y_RELTRAD3="Mainline";		
if DENOM16=21 then Y_RELTRAD3="Mainline";		
if DENOM16=23 & RACE^=2 then Y_RELTRAD3="Conservative";
if DENOM16=23 & RACE=2 then Y_RELTRAD3="Mainline";
if DENOM16=22 then Y_RELTRAD3="Mainline";
if DENOM16=28 then Y_RELTRAD3="Mainline";		
if DENOM16=30 then Y_RELTRAD3="Mainline";
if DENOM16=31 then Y_RELTRAD3="Mainline";
if DENOM16=32 then Y_RELTRAD3="Conservative";
if DENOM16=33 then Y_RELTRAD3="Conservative";
if DENOM16=34 then Y_RELTRAD3="Conservative";
if DENOM16=35 then Y_RELTRAD3="Mainline";
if DENOM16=38 then Y_RELTRAD3="Mainline";
if DENOM16=40 then Y_RELTRAD3="Mainline";
if DENOM16=41 then Y_RELTRAD3="Mainline";
if DENOM16=42 then Y_RELTRAD3="Conservative";
if DENOM16=43 then Y_RELTRAD3="Mainline";
if DENOM16=48 then Y_RELTRAD3="Mainline";
if DENOM16=50 then Y_RELTRAD3="Mainline";
if DENOM16=60 then Y_RELTRAD3="Conservative";	
if DENOM16=70 & RACE^=1 then Y_RELTRAD3="Conservative";	
/*For DENOM16=70, we don't know attendance, so we can't say they 
changed. Since "change" is our object of study, 
we have to copy DENOM and say that they didn't change, 
conservative strategy which is best so we don't inflate our results*/
if DENOM16=70 & DENOM=70 then Y_RELTRAD3=RELTRAD3;
if DENOM16=70 & DENOM=70 then Y_RELTRAD3=RELTRAD3;
if OTH16=99 then Y_RELTRAD3="Mainline";
if OTH16=19 then Y_RELTRAD3="Mainline";
if OTH16=25 then Y_RELTRAD3="Mainline";
if OTH16=40 then Y_RELTRAD3="Mainline";
if OTH16=44 then Y_RELTRAD3="Mainline";
if OTH16=46 then Y_RELTRAD3="Mainline";
if OTH16=49 then Y_RELTRAD3="Mainline";
if OTH16=48 then Y_RELTRAD3="Mainline";
if OTH16=50 then Y_RELTRAD3="Mainline";
if OTH16=54 then Y_RELTRAD3="Mainline";
if OTH16=89 then Y_RELTRAD3="Mainline";
if OTH16=1 then Y_RELTRAD3="Mainline";
if OTH16=105 then Y_RELTRAD3="Mainline";
if OTH16=8 then Y_RELTRAD3="Mainline";
if OTH16=70 then Y_RELTRAD3="Mainline";
if OTH16=71 then Y_RELTRAD3="Mainline";
if OTH16=73 then Y_RELTRAD3="Mainline";
if OTH16=72 then Y_RELTRAD3="Mainline";
if OTH16=148 then Y_RELTRAD3="Mainline";
if OTH16=23 then Y_RELTRAD3="Mainline";
if OTH16=119 then Y_RELTRAD3="Mainline";
if OTH16=81 then Y_RELTRAD3="Mainline";
if OTH16=96 then Y_RELTRAD3="Mainline";
if OTH16=10 then Y_RELTRAD3="Conservative";
if OTH16=111 then Y_RELTRAD3="Conservative";
if OTH16=107 then Y_RELTRAD3="Conservative";
if OTH16=138 then Y_RELTRAD3="Conservative";
if OTH16=12 then Y_RELTRAD3="Conservative";
if OTH16=109 then Y_RELTRAD3="Conservative";
if OTH16=20 then Y_RELTRAD3="Conservative";
if OTH16=22 then Y_RELTRAD3="Conservative";
if OTH16=132 then Y_RELTRAD3="Conservative";
if OTH16=110 then Y_RELTRAD3="Conservative";
if OTH16=122 then Y_RELTRAD3="Conservative";
if OTH16=102 then Y_RELTRAD3="Conservative";
if OTH16=135 then Y_RELTRAD3="Conservative";
if OTH16=108 then Y_RELTRAD3="Conservative";
if OTH16=29 then Y_RELTRAD3="Conservative";
if OTH16=9 then Y_RELTRAD3="Conservative";
if OTH16=125 then Y_RELTRAD3="Conservative";
if OTH16=28 then Y_RELTRAD3="Conservative";
if OTH16=31 then Y_RELTRAD3="Conservative";
if OTH16=32 then Y_RELTRAD3="Conservative";
if OTH16=26 then Y_RELTRAD3="Conservative";
if OTH16=101 then Y_RELTRAD3="Conservative";
if OTH16=36 then Y_RELTRAD3="Conservative";
if OTH16=35 then Y_RELTRAD3="Conservative";
if OTH16=34 then Y_RELTRAD3="Conservative";
if OTH16=127 then Y_RELTRAD3="Conservative";
if OTH16=121 then Y_RELTRAD3="Conservative";
if OTH16=5 then Y_RELTRAD3="Conservative";
if OTH16=116 then Y_RELTRAD3="Conservative";
if OTH16=39 then Y_RELTRAD3="Conservative";
if OTH16=41 then Y_RELTRAD3="Conservative";
if OTH16=42 then Y_RELTRAD3="Conservative";
if OTH16=43 then Y_RELTRAD3="Conservative";
if OTH16=2 then Y_RELTRAD3="Conservative";
if OTH16=91 then Y_RELTRAD3="Conservative";
if OTH16=45 then Y_RELTRAD3="Conservative";
if OTH16=47 then Y_RELTRAD3="Conservative";
if OTH16=112 then Y_RELTRAD3="Conservative";
if OTH16=120 then Y_RELTRAD3="Conservative";
if OTH16=139 then Y_RELTRAD3="Conservative";
if OTH16=124 then Y_RELTRAD3="Conservative";
if OTH16=51 then Y_RELTRAD3="Conservative";
if OTH16=53 then Y_RELTRAD3="Conservative";
if OTH16=13 then Y_RELTRAD3="Conservative";
if OTH16=16 then Y_RELTRAD3="Conservative";
if OTH16=52 then Y_RELTRAD3="Conservative";
if OTH16=100 then Y_RELTRAD3="Conservative";
if OTH16=90 then Y_RELTRAD3="Conservative";
if OTH16=18 then Y_RELTRAD3="Conservative";
if OTH16=55 then Y_RELTRAD3="Conservative";
if OTH16=24 then Y_RELTRAD3="Conservative";
if OTH16=3 then Y_RELTRAD3="Conservative";
if OTH16=134 then Y_RELTRAD3="Conservative";
if OTH16=146 then Y_RELTRAD3="Conservative";
if OTH16=129 then Y_RELTRAD3="Conservative";
if OTH16=131 then Y_RELTRAD3="Conservative";
if OTH16=63 then Y_RELTRAD3="Conservative";
if OTH16=115 then Y_RELTRAD3="Conservative";
if OTH16=117 then Y_RELTRAD3="Conservative";
if OTH16=92 then Y_RELTRAD3="Conservative";
if OTH16=65 then Y_RELTRAD3="Conservative";
if OTH16=6 then Y_RELTRAD3="Conservative";
if OTH16=27 then Y_RELTRAD3="Conservative";
if OTH16=97 then Y_RELTRAD3="Conservative";
if OTH16=68 then Y_RELTRAD3="Conservative";
if OTH16=66 then Y_RELTRAD3="Conservative";
if OTH16=67 then Y_RELTRAD3="Conservative";
if OTH16=69 then Y_RELTRAD3="Conservative";
if OTH16=140 then Y_RELTRAD3="Conservative";
if OTH16=57 then Y_RELTRAD3="Conservative";
if OTH16=133 then Y_RELTRAD3="Conservative";
if OTH16=76 then Y_RELTRAD3="Conservative";
if OTH16=77 then Y_RELTRAD3="Conservative";
if OTH16=94 then Y_RELTRAD3="Conservative";
if OTH16=106 then Y_RELTRAD3="Conservative";
if OTH16=118 then Y_RELTRAD3="Conservative";
if OTH16=83 then Y_RELTRAD3="Conservative";
if OTH16=84 then Y_RELTRAD3="Conservative";
if OTH16=30 then Y_RELTRAD3="Conservative";
if OTH16=33 then Y_RELTRAD3="Conservative";
if OTH16=145 then Y_RELTRAD3="Conservative";
if OTH16=114 then Y_RELTRAD3="Conservative";
if OTH16=58 then Y_RELTRAD3="Conservative";
if OTH16=62 then Y_RELTRAD3="Conservative";
if OTH16=59 then Y_RELTRAD3="Conservative";
if OTH16=60 then Y_RELTRAD3="Conservative";
if OTH16=61 then Y_RELTRAD3="Conservative";
if OTH16=64 then Y_RELTRAD3="Conservative";
if OTH16=130 then Y_RELTRAD3="Conservative";
if OTH16=113 then Y_RELTRAD3="Conservative";
if OTH16=29 then Y_RELTRAD3="Mainline";
if OTH16=17 then Y_RELTRAD3="Mainline";
if OTH16=75 then Y_RELTRAD3="Mainline";
if OTH16=136 then Y_RELTRAD3="Mainline";
if OTH16=141 then Y_RELTRAD3="Mainline";
if OTH16=74 then Y_RELTRAD3="Mainline";
if OTH16=11 then Y_RELTRAD3="Mainline";
if OTH16=80 then Y_RELTRAD3="Mainline";
if OTH16=82 then Y_RELTRAD3="Mainline";
if OTH16=95 then Y_RELTRAD3="Mainline";

/*looking at change now*/
if RELTRAD3 ^= Y_RELTRAD3 then RELTRAD3_changed=1;
if RELTRAD3 = Y_RELTRAD3 then RELTRAD3_changed=0;
if RELTRAD3="" then RELTRAD3_changed=.;
if Y_RELTRAD3="" then RELTRAD3_changed=.;

if Y_RELTRAD3="Catholic" & RELTRAD3^="Catholic" then leaver_cath=1; 
												else leaver_cath=0;
							if Y_RELTRAD3="" 	then leaver_cath=.; 
							if RELTRAD3="" 		then leaver_cath=.;
if Y_RELTRAD3^="Catholic" & RELTRAD3="Catholic" then joiner_cath=1; 
												else joiner_cath=0;
							if Y_RELTRAD3="" 	then joiner_cath=.; 
							if RELTRAD3="" 		then joiner_cath=.;
if Y_RELTRAD3="Catholic" & RELTRAD3="Catholic" 	then stayer_cath=1; 
												else stayer_cath=0;
							if Y_RELTRAD3="" 	then stayer_cath=.; 
							if RELTRAD3="" 		then stayer_cath=.;

if Y_RELTRAD3="Mainline" & RELTRAD3^="Mainline" then leaver_MP=1; 
												else leaver_MP=0;
							if Y_RELTRAD3="" 	then leaver_MP=.; 
							if RELTRAD3="" 		then leaver_MP=.;
if Y_RELTRAD3^="Mainline" & RELTRAD3="Mainline" then joiner_MP=1; 
												else joiner_MP=0;
							if Y_RELTRAD3="" 	then joiner_MP=.; 
							if RELTRAD3="" 		then joiner_MP=.;
if Y_RELTRAD3="Mainline" & RELTRAD3="Mainline" 	then stayer_MP=1; 
												else stayer_MP=0;
							if Y_RELTRAD3="" 	then stayer_MP=.; 
							if RELTRAD3="" 		then stayer_MP=.;

if Y_RELTRAD3="Conservative" & RELTRAD3^="Conservative" then leaver_CP=1; 
														else leaver_CP=0;
							if Y_RELTRAD3="" 			then leaver_CP=.; 
							if RELTRAD3="" 				then leaver_CP=.;
if Y_RELTRAD3^="Conservative" & RELTRAD3="Conservative" then joiner_CP=1; 
														else joiner_CP=0;
							if Y_RELTRAD3="" 			then joiner_CP=.; 
							if RELTRAD3="" 				then joiner_CP=.;
if Y_RELTRAD3="Conservative" & RELTRAD3="Conservative" 	then stayer_CP=1; 
														else stayer_CP=0;
							if Y_RELTRAD3="" 			then stayer_CP=.; 
							if RELTRAD3="" 				then stayer_CP=.;

if Y_RELTRAD3="None" & RELTRAD3^="None" 		then leaver_none=1; 
												else leaver_none=0;
							if Y_RELTRAD3="" 	then leaver_none=.; 
							if RELTRAD3="" 		then leaver_none=.;
if Y_RELTRAD3^="None" & RELTRAD3="None" 		then joiner_none=1; 
												else joiner_none=0;
							if Y_RELTRAD3="" 	then joiner_none=.; 
							if RELTRAD3="" 		then joiner_none=.;
if Y_RELTRAD3="None" & RELTRAD3="None" 			then stayer_none=1; 
												else stayer_none=0;
							if Y_RELTRAD3="" 	then stayer_none=.; 
							if RELTRAD3="" 		then stayer_none=.;

/*#######################################################################
RETROSPECTIVE FIGURE 5.2
#########################################################################
The problem with the original coding scheme was that 
it didn't account for people who reported their religion
twice in the same decade: e.g., an R who was 20 in 1978
would have two observations in the 70's: 
their adult religion in 1978 and their age16 religion
in 1974. The way to get around this is to NOT group 
responses by decade. 
This is a problem because my analyses asks: 
How does a remembered religion in TIME(DECADE) TWO 
correspond to the measured religion in TIME(DECADE) ONE?
Grouping by decade means that for many respondents, 
TIME TWO and TIME ONE are the same (decade)
For now, I will resolve this by omitting same-decade observations
from my analysis - this means that early decade observations
will have older people and late decade observations will 
have younger people.
(where A_decade_70=1 and Y_decade_70=1, etc.)

Omitting these observations will impact more recent decades because
they have fewer retrospective observations.
Omitting these young people may increase the difference between
retrospective and contemporary traditions because young people:
 
1) have had literal less time/opportunity to change traditions
	(and so would report the same RELIG16 and RELIG)
2) may more accurately recall their age16 tradition because it was more recent
	(and so would report the same RELIG16 and RELIG)

On the other hand, omitting these young people may decrease the difference
between retrospective and contemporary traditions because young pepole:

1) may be more inclined to have a different current tradition than their 
parents brought them up in.
	(and so would report different RELIG16 and RELIG)
2) have a more flexible notion of religion, given the observed decline
in denominational affiliation.
	(and so would report different RELIG16 and RELIG)

For these reasons, a test of these data over 2-year increments (which would
enable all respondents to have a TIME ONE and TIME TWO observation) would be
more appropriate. However, it would make a very dense visualization.


To recreate the overall original analysis, I need a population of 
"retrospective religion" responses and a population of 
"contemporaneous religion" responses.

Then, to see if the distributions are different, by religion, I need to
create A/B binary distributions of "other vs X_religon" for each religion.
*/

/*Take 1970 for example: 
This makes a population of all the 1970's religions, excluding same-decade observations,
mentioned above, and adds a dummy for retrospective (orig70=0) and contemporary (orig70=1)
observations.
So, the analysis would be: trad70 * orig70. (Each tradition * original or not)
Then, cath70 * orig70. (Catholics * original or not, the null expectation
being that they are equal)
*/
if year^=. then do 
temp_year= year - age_recode + 16;
end;
else temp_year=.;
/*this is the survey year (YEAR) that they would be in as 16 year-olds*/
/*1974 to 2019*/
if temp_year=1972 then year_16=1972;
if temp_year=1973 then year_16=1972;
if temp_year=1974 then year_16=1974;
if temp_year=1975 then year_16=1975;
if temp_year=1976 then year_16=1976;
if temp_year=1977 then year_16=1977;
if temp_year=1978 then year_16=1978;
if temp_year=1979 then year_16=1978;
if temp_year=1980 then year_16=1980;
if temp_year=1981 then year_16=1980;
if temp_year=1982 then year_16=1982;
if temp_year=1983 then year_16=1983;
if temp_year=1984 then year_16=1984;
if temp_year=1985 then year_16=1985;
if temp_year=1986 then year_16=1986;
if temp_year=1987 then year_16=1987;
if temp_year=1988 then year_16=1988;
if temp_year=1989 then year_16=1989;
if temp_year=1990 then year_16=1990;
if temp_year=1991 then year_16=1991;
if temp_year=1992 then year_16=1991;
if temp_year=1993 then year_16=1993;
if temp_year=1994 then year_16=1994;
if temp_year=1995 then year_16=1995;
if temp_year=1996 then year_16=1996;
if temp_year=1997 then year_16=1996;
if temp_year=1998 then year_16=1998;
if temp_year=1999 then year_16=1998;
if temp_year=2000 then year_16=2000;
if temp_year=2001 then year_16=2000;
if temp_year=2002 then year_16=2002;
if temp_year=2003 then year_16=2002;
if temp_year=2004 then year_16=2004;
if temp_year=2005 then year_16=2004;
if temp_year=2006 then year_16=2006;
if temp_year=2007 then year_16=2006;
if temp_year=2008 then year_16=2008;
if temp_year=2009 then year_16=2008;
if temp_year=2010 then year_16=2010;
if temp_year=2011 then year_16=2010;
if temp_year=2012 then year_16=2012;
if temp_year=2013 then year_16=2012;
if temp_year=2014 then year_16=2014;
if temp_year=2015 then year_16=2014;
if temp_year=2016 then year_16=2016;
if temp_year=2017 then year_16=2016;
if temp_year=2018 then year_16=2018;
if temp_year=2019 then year_16=2018;

if year>1971 & year<1979 then A_decade_70=1;
if year>1979 & year<1990 then A_decade_80=1;
if year>1989 & year<1999 then A_decade_90=1;
if year>1999 & year<2009 then A_decade_00=1;
if year>2009 & year<2019 then A_decade_10=1;

if year_16>1971 & year_16<1979 then Y_decade_70=1;
if year_16>1979 & year_16<1990 then Y_decade_80=1;
if year_16>1989 & year_16<1999 then Y_decade_90=1;
if year_16>1999 & year_16<2009 then Y_decade_00=1;
if year_16>2009 & year_16<2019 then Y_decade_10=1;

trad70="placeholder for formatting";
if A_decade_70=1 then trad70=RELTRAD3;
if Y_decade_70=1 then trad70=Y_RELTRAD3;
if A_decade_70=1 & Y_decade_70=1 then trad70="";
if A_decade_70=1 then orig70=1;
if Y_decade_70=1 then orig70=0;
if trad70="placeholder for formatting" then trad70="";

trad80="placeholder for formatting";
if A_decade_80=1 then trad80=RELTRAD3;
if Y_decade_80=1 then trad80=Y_RELTRAD3;
if A_decade_80=1 & Y_decade_80=1 then trad80="";
if A_decade_80=1 then orig80=1;
if Y_decade_80=1 then orig80=0;
if trad80="placeholder for formatting" then trad80="";

trad90="placeholder for formatting";
if A_decade_90=1 then trad90=RELTRAD3;
if Y_decade_90=1 then trad90=Y_RELTRAD3;
if A_decade_90=1 & Y_decade_90=1 then trad90="";
if A_decade_90=1 then orig90=1;
if Y_decade_90=1 then orig90=0;
if trad90="placeholder for formatting" then trad90="";

trad00="placeholder for formatting";
if A_decade_00=1 then trad00=RELTRAD3;
if Y_decade_00=1 then trad00=Y_RELTRAD3;
if A_decade_00=1 & Y_decade_00=1 then trad00="";
if A_decade_00=1 then orig00=1;
if Y_decade_00=1 then orig00=0;
if trad00="placeholder for formatting" then trad00="";

trad10="placeholder for formatting";
if A_decade_10=1 then trad10=RELTRAD3;
if Y_decade_10=1 then trad10=Y_RELTRAD3;
if A_decade_10=1 & Y_decade_10=1 then trad10="";
if A_decade_10=1 then orig10=1;
if Y_decade_10=1 then orig10=0;
if trad10="placeholder for formatting" then trad10="";

if trad70="Catholic" then 		cath70=1;
if trad70^="Catholic" then 		cath70=0;
if trad70="" then 				cath70=.;
if trad70="Conservative" then 	con70=1;
if trad70^="Conservative" then 	con70=0;
if trad70="" then 				con70=.;
if trad70="Mainline" then 		main70=1;
if trad70^="Mainline" then 		main70=0;
if trad70="" then 				main70=.;
if trad70="None" then 			none70=1;
if trad70^="None" then 			none70=0;
if trad70="" then 				none70=.;
if trad70="Other" then 			oth70=1;
if trad70^="Other" then 		oth70=0;
if trad70="" then 				oth70=.;

if trad80="Catholic" then 		cath80=1;
if trad80^="Catholic" then 		cath80=0;
if trad80="" then 				cath80=.;
if trad80="Conservative" then 	con80=1;
if trad80^="Conservative" then 	con80=0;
if trad80="" then 				con80=.;
if trad80="Mainline" then 		main80=1;
if trad80^="Mainline" then 		main80=0;
if trad80="" then 				main80=.;
if trad80="None" then 			none80=1;
if trad80^="None" then 			none80=0;
if trad80="" then 				none80=.;
if trad80="Other" then 			oth80=1;
if trad80^="Other" then 		oth80=0;
if trad80="" then 				oth80=.;

if trad90="Catholic" then 		cath90=1;
if trad90^="Catholic" then 		cath90=0;
if trad90="" then 				cath90=.;
if trad90="Conservative" then 	con90=1;
if trad90^="Conservative" then 	con90=0;
if trad90="" then 				con90=.;
if trad90="Mainline" then 		main90=1;
if trad90^="Mainline" then 		main90=0;
if trad90="" then 				main90=.;
if trad90="None" then 			none90=1;
if trad90^="None" then 			none90=0;
if trad90="" then 				none90=.;
if trad90="Other" then 			oth90=1;
if trad90^="Other" then 		oth90=0;
if trad90="" then 				oth90=.;

if trad00="Catholic" then 		cath00=1;
if trad00^="Catholic" then 		cath00=0;
if trad00="" then 				cath00=.;
if trad00="Conservative" then 	con00=1;
if trad00^="Conservative" then 	con00=0;
if trad00="" then 				con00=.;
if trad00="Mainline" then 		main00=1;
if trad00^="Mainline" then 		main00=0;
if trad00="" then 				main00=.;
if trad00="None" then 			none00=1;
if trad00^="None" then 			none00=0;
if trad00="" then 				none00=.;
if trad00="Other" then 			oth00=1;
if trad00^="Other" then 		oth00=0;
if trad00="" then 				oth00=.;

if trad10="Catholic" then 		cath10=1;
if trad10^="Catholic" then 		cath10=0;
if trad10="" then 				cath10=.;
if trad10="Conservative" then 	con10=1;
if trad10^="Conservative" then 	con10=0;
if trad10="" then 				con10=.;
if trad10="Mainline" then 		main10=1;
if trad10^="Mainline" then 		main10=0;
if trad10="" then 				main10=.;
if trad10="None" then 			none10=1;
if trad10^="None" then 			none10=0;
if trad10="" then 				none10=.;
if trad10="Other" then 			oth10=1;
if trad10^="Other" then 		oth10=0;
if trad10="" then 				oth10=.;

/*CHAPTER 6*/
* FIGURE 6.1: STRENGTH OF BELIEF;
						RELITENV_="123456789012345678901234567890";
	if RELITENV=1 then 	RELITENV_="1 R is strong X relig pers";
	if RELITENV=2 then 	RELITENV_="2 R is nv strong X relig pers";
	if RELITENV=3 then 	RELITENV_="3 R is sw strong X relig pers";
	if RELITENV=4 then 	RELITENV_="4 R is no religion";
					if 	RELITENV_="123456789012345678901234567890" then 
						RELITENV_="";
if RELITENV_="" & RELITENNV=1 then RELITENV_="1 R is strong X relig pers";
if RELITENV_="" & RELITENNV=2 then RELITENV_="2 R is nv strong X relig pers";
if RELITENV_="" & RELITENNV=3 then RELITENV_="3 R is sw strong X relig pers";
if RELITENV_="" & RELITENNV=4 then RELITENV_="4 R is no religion";
*##;
RELITENV_strong="123456789012345678901234567890";
	if RELITENV=1 then RELITENV_strong="1 Strong";
	if RELITENV=2 then RELITENV_strong="0 Not strong";
	if RELITENV=3 then RELITENV_strong="0 Not strong";
	if RELITENV=4 then RELITENV_strong="0 Not strong";
	if RELITENV_strong="123456789012345678901234567890" then RELITENV_strong="";
*######################################################################;
						RELPERSN_="123456789012345678901234567890";
	if RELPERSN=1 then 	RELPERSN_="1 very religious person";
	if RELPERSN=2 then 	RELPERSN_="2 moderately rel person";
	if RELPERSN=3 then 	RELPERSN_="3 slightly rel person";
	if RELPERSN=4 then 	RELPERSN_="4 not at all rel person";
					if 	RELPERSN_="123456789012345678901234567890" then 
						RELPERSN_="";
*##;
						RELPERSN_MorV="123456789012345678901234567890";
	if RELPERSN=1 then 	RELPERSN_MorV="1 Mod or very religious";
	if RELPERSN=2 then 	RELPERSN_MorV="1 Mod or very religious";
	if RELPERSN=3 then 	RELPERSN_MorV="0 Not mod or very religious";
	if RELPERSN=4 then 	RELPERSN_MorV="0 Not mod or very religious";
	if 					RELPERSN_MorV="123456789012345678901234567890" then 
						RELPERSN_MorV="";
*######################################################################;
						SPRTPRSN_="123456789012345678901234567890";
	if SPRTPRSN=1 then 	SPRTPRSN_="1 very spiritual person";
	if SPRTPRSN=2 then 	SPRTPRSN_="2 moderately spiritual person";
	if SPRTPRSN=3 then 	SPRTPRSN_="3 slightly spiritual person";
	if SPRTPRSN=4 then 	SPRTPRSN_="4 not at all spiritual person";
	if 					SPRTPRSN_="123456789012345678901234567890" then 
						SPRTPRSN_="";
*##;
						SPRTPRSN_MorV="123456789012345678901234567890";
	if SPRTPRSN=1 then 	SPRTPRSN_MorV="1 Mod or very spiritual";
	if SPRTPRSN=2 then 	SPRTPRSN_MorV="1 Mod or very spiritual";
	if SPRTPRSN=3 then 	SPRTPRSN_MorV="0 Not mod or very spiritual";
	if SPRTPRSN=4 then 	SPRTPRSN_MorV="0 Not mod or very spiritual";
	if 					SPRTPRSN_MorV="123456789012345678901234567890" then 
						SPRTPRSN_MorV="";
*######################################################################;
						RELIGIMP_="123456789012345678901234567890";
	if RELIGIMP=1 then 	RELIGIMP_="1 REL is V imp in my life";
	if RELIGIMP=2 then 	RELIGIMP_="2 REL is SW imp in my life";
	if RELIGIMP=3 then 	RELIGIMP_="3 REL is NT imp in my life";
	if RELIGIMP=4 then 	RELIGIMP_="4 REL is NAA imp in my life";
	if 					RELIGIMP_="123456789012345678901234567890" then 
						RELIGIMP_="";
*##;
						RELIGIMP_very="123456789012345678901234567890";
	if RELIGIMP=1 then 	RELIGIMP_very="1 REL is very imp";
	if RELIGIMP=2 then 	RELIGIMP_very="0 REL is not very imp";
	if RELIGIMP=3 then 	RELIGIMP_very="0 REL is not very imp";
	if RELIGIMP=4 then 	RELIGIMP_very="0 REL is not very imp";
	if 					RELIGIMP_very="123456789012345678901234567890" then 
						RELIGIMP_very="";
*######################################################################;
*						RELIDIMP_="123456789012345678901234567890";
*	if RELIDIMP=1 then 	RELIDIMP_="1 being REL is E important";
*	if RELIDIMP=2 then 	RELIDIMP_="2 being REL is V important";
*	if RELIDIMP=3 then 	RELIDIMP_="3 being REL is SW important";
*	if RELIDIMP=4 then 	RELIDIMP_="4 being REL is NV important";
*	if RELIDIMP=5 then 	RELIDIMP_="5 being REL is N important";
*	if 					RELIDIMP_="123456789012345678901234567890" then 
*						RELIDIMP_="";
*######################################################################;
						RELIDESC_="123456789012345678901234567890";
	if RELIDESC=1 then 	RELIDESC_="1 REL E describes me";
	if RELIDESC=2 then 	RELIDESC_="2 REL V describes me";
	if RELIDESC=3 then 	RELIDESC_="3 REL SW describes me";
	if RELIDESC=4 then 	RELIDESC_="4 REL NV describes me";
	if RELIDESC=5 then 	RELIDESC_="5 REL NAA describes me";
	if 					RELIDESC_="123456789012345678901234567890" then 
						RELIDESC_="";
*##;
						RELIDESC_EXorVERY="123456789012345678901234567890";
	if RELIDESC=1 then 	RELIDESC_EXorVERY="1 REL Ex or Very me";
	if RELIDESC=2 then 	RELIDESC_EXorVERY="1 REL Ex or Very me";
	if RELIDESC=3 then 	RELIDESC_EXorVERY="0 REL not Ex or Very me";
	if RELIDESC=4 then 	RELIDESC_EXorVERY="0 REL not Ex or Very me";
	if 					RELIDESC_EXorVERY="123456789012345678901234567890" then 
						RELIDESC_EXorVERY="";
*######################################################################;
						RELIDWE_="123456789012345678901234567890";
	if RELIDWE=1 then 	RELIDWE_="1 REL N say WE";
	if RELIDWE=2 then 	RELIDWE_="2 REL R say WE";
	if RELIDWE=3 then 	RELIDWE_="3 REL ST say WE";
	if RELIDWE=4 then 	RELIDWE_="4 REL MoT say WE";
	if RELIDWE=5 then 	RELIDWE_="5 REL AtT say WE";
	if 					RELIDWE_="123456789012345678901234567890" then 
						RELIDWE_="";
*##;
						RELIDWE_MorA="123456789012345678901234567890";
	if RELIDWE=1 then 	RELIDWE_MorA="1 most or always WE";
	if RELIDWE=2 then 	RELIDWE_MorA="1 most or always WE";
	if RELIDWE=3 then 	RELIDWE_MorA="0 not most or always WE";
	if RELIDWE=4 then 	RELIDWE_MorA="0 not most or always WE";
	if 					RELIDWE_MorA="123456789012345678901234567890" then 
						RELIDWE_MorA="";
*######################################################################;
						RELIDINS_="123456789012345678901234567890";
	if RELIDINS=1 then 	RELIDINS_="1 insulted aGD";
	if RELIDINS=2 then 	RELIDINS_="2 insulted SW";
	if RELIDINS=3 then 	RELIDINS_="3 insulted VL";
	if RELIDINS=4 then 	RELIDINS_="4 insulted NAA";
	if 					RELIDINS_="123456789012345678901234567890" then 
						RELIDINS_="";
*##;
						RELIDINS_GDorSW="123456789012345678901234567890";
	if RELIDINS=1 then 	RELIDINS_GDorSW="1 GD or SW insulting";
	if RELIDINS=2 then 	RELIDINS_GDorSW="1 GD or SW insulting";
	if RELIDINS=3 then 	RELIDINS_GDorSW="0 not GD or SW insulting";
	if RELIDINS=4 then 	RELIDINS_GDorSW="0 not GD or SW insulting";
	if 					RELIDINS_GDorSW="123456789012345678901234567890" then 
						RELIDINS_GDorSW="";
*######################################################################;
						*FIGURE 6.2: RELIGIOUS SERVICE ATTENDANCE, PRAYER, MEDITATION;
*######################################################################;
						ATTEND_="123456789012345678901234567890";
	if ATTEND=0 then 	ATTEND_="0 attend N";
	if ATTEND=1 then 	ATTEND_="1 attend <1x year";
	if ATTEND=2 then 	ATTEND_="2 attend 1|2x year";
	if ATTEND=3 then 	ATTEND_="3 attend severalx year";
	if ATTEND=4 then 	ATTEND_="4 attend 1x month";
	if ATTEND=5 then 	ATTEND_="5 2-3x month";
	if ATTEND=6 then 	ATTEND_="6 nearly every week";
	if ATTEND=7 then 	ATTEND_="7 every week";
	if ATTEND=8 then 	ATTEND_="8 severalx week";
	if 					ATTEND_="123456789012345678901234567890" then 
						ATTEND_="";
*##;
						ATTEND_alot="123456789012345678901234567890";
	if ATTEND=0 then 	ATTEND_alot="0 attend < every week";
	if ATTEND=1 then 	ATTEND_alot="0 attend < every week";
	if ATTEND=2 then 	ATTEND_alot="0 attend < every week";
	if ATTEND=3 then 	ATTEND_alot="0 attend < every week";
	if ATTEND=4 then 	ATTEND_alot="0 attend < every week";
	if ATTEND=5 then 	ATTEND_alot="0 attend < every week";
	if ATTEND=6 then 	ATTEND_alot="1 attend nearly wk+";
	if ATTEND=7 then 	ATTEND_alot="1 attend nearly wk+";
	if ATTEND=8 then 	ATTEND_alot="1 attend nearly wk+";
	if 					ATTEND_alot="123456789012345678901234567890" then 
						ATTEND_alot="";
*######################################################################;
						PRAY_="123456789012345678901234567890";
	if PRAY=1 then 		PRAY_="1 pray sevx day";
	if PRAY=2 then 		PRAY_="2 pray 1x day";
	if PRAY=3 then 		PRAY_="3 pray sevx week";
	if PRAY=4 then 		PRAY_="4 pray 1x week";
	if PRAY=5 then 		PRAY_="5 pray <1x week";
	if PRAY=6 then 		PRAY_="6 pray never";
	if 					PRAY_="123456789012345678901234567890" then 
						PRAY_="";
*##;
						PRAY_alot="123456789012345678901234567890";
	if PRAY=1 then 		PRAY_alot="1 pray daily +";
	if PRAY=2 then 		PRAY_alot="1 pray daily +";
	if PRAY=3 then 		PRAY_alot="0 pray <daily";
	if PRAY=4 then 		PRAY_alot="0 pray <daily";
	if PRAY=5 then 		PRAY_alot="0 pray <daily";
	if PRAY=6 then 		PRAY_alot="0 pray <daily";
	if 					PRAY_alot="123456789012345678901234567890" then 
						PRAY_alot="";
*##;
						PRAY_never="123456789012345678901234567890";
	if PRAY=1 then 		PRAY_never="0 prays";
	if PRAY=2 then 		PRAY_never="0 prays";
	if PRAY=3 then 		PRAY_never="0 prays";
	if PRAY=4 then 		PRAY_never="0 prays";
	if PRAY=5 then 		PRAY_never="0 prays";
	if PRAY=6 then 		PRAY_never="1 never prays";
	if 					PRAY_never="123456789012345678901234567890" then 
						PRAY_never="";
*######################################################################;
						MDITATE1_="123456789012345678901234567890";
	if MDITATE1=1 then 	MDITATE1_="1 meditate >1x day";
	if MDITATE1=2 then 	MDITATE1_="2 meditate 1x day";
	if MDITATE1=3 then 	MDITATE1_="3 meditate 1|2x week";
	if MDITATE1=4 then 	MDITATE1_="4 meditate 1|2x month";
	if MDITATE1=5 then 	MDITATE1_="5 meditate fewx year";
	if MDITATE1=6 then 	MDITATE1_="6 meditate1x|<1x year";
	if MDITATE1=7 then 	MDITATE1_="7 never meditates";
	if 					MDITATE1_="123456789012345678901234567890" then 
						MDITATE1_="";
*##;
						MDITATE1_EDorONE="123456789012345678901234567890";
	if MDITATE1=1 then 	MDITATE1_EDorONE="1 meditate >1x or 1x day";
	if MDITATE1=2 then 	MDITATE1_EDorONE="1 meditate >1x or 1x day";
	if MDITATE1=3 then 	MDITATE1_EDorONE="0 meditate <1x day";
	if MDITATE1=4 then 	MDITATE1_EDorONE="0 meditate <1x day";
	if MDITATE1=5 then 	MDITATE1_EDorONE="0 meditate <1x day";
	if MDITATE1=6 then 	MDITATE1_EDorONE="0 meditate <1x day";
	if MDITATE1=7 then 	MDITATE1_EDorONE="0 meditate <1x day";
	if 					MDITATE1_EDorONE="123456789012345678901234567890" then 
						MDITATE1_EDorONE="";
*##;
						MDITATE1_never="123456789012345678901234567890";
	if MDITATE1=1 then 	MDITATE1_never="0 meditates";
	if MDITATE1=2 then 	MDITATE1_never="0 meditates";
	if MDITATE1=3 then 	MDITATE1_never="0 meditates";
	if MDITATE1=4 then 	MDITATE1_never="0 meditates";
	if MDITATE1=5 then 	MDITATE1_never="0 meditates";
	if MDITATE1=6 then 	MDITATE1_never="0 meditates";
	if MDITATE1=7 then 	MDITATE1_never="1 never meditates";
	if 					MDITATE1_never="123456789012345678901234567890" then 
						MDITATE1_never="";
*######################################################################;
*FIGURE 6.3 RELIGIOUS EXPERIENCE AND EVANGELIZATION;
*######################################################################;
						REBORN_="123456789012345678901234567890";
	if REBORN=1 then 	REBORN_="1 been born again";
	if REBORN=2 then 	REBORN_="0 not been born again";
	if 					REBORN_="123456789012345678901234567890" then 
						REBORN_="";
*######################################################################;
						RELEXP_="123456789012345678901234567890";
	if RELEXP=1 then 	RELEXP_="1 Y, had a rel experience";
	if RELEXP=2 then 	RELEXP_="0 N, had a rel experience";
	if 					RELEXP_="123456789012345678901234567890" then 
						RELEXP_="";
*######################################################################;
						SAVESOUL_="123456789012345678901234567890";
	if SAVESOUL=1 then 	SAVESOUL_="1 Y, encouraged oth to JC";
	if SAVESOUL=2 then 	SAVESOUL_="0 N, encouraged oth to JC";
	if 					SAVESOUL_="123456789012345678901234567890" then 
						SAVESOUL_="";
*######################################################################;


*						EVNGELZE_="123456789012345678901234567890";
*	if EVNGELZE=1 then 	EVNGELZE_="1 SA: imp to evangel-JC";
*	if EVNGELZE=2 then 	EVNGELZE_="2 Ag imp to evangel-JC";
*	if EVNGELZE=3 then 	EVNGELZE_="3 nAnD: imp to evangel-JC";
*	if EVNGELZE=4 then 	EVNGELZE_="4 Dg imp to evangel-JC";
*	if EVNGELZE=5 then 	EVNGELZE_="5 SD: imp to evangel-JC";
*	if 					EVNGELZE_="123456789012345678901234567890" then 
*						EVNGELZE_="";
*######################################################################;
*						SINSACRI_="123456789012345678901234567890";
*	if SINSACRI=1 then 	SINSACRI_="1 SA: JC pay sin";
*	if SINSACRI=2 then 	SINSACRI_="2 Ag JC pay sin";
*	if SINSACRI=3 then 	SINSACRI_="3 nAnD: JC pay sin";
*	if SINSACRI=4 then 	SINSACRI_="4 Dg JC pay sin";
*	if SINSACRI=5 then 	SINSACRI_="5 SD: JC pay sin";
*	if 					SINSACRI_="123456789012345678901234567890" then 
*						SINSACRI_="";
*######################################################################;						
*						CHRSTSAV_="123456789012345678901234567890";
*	if CHRSTSAV=1 then 	CHRSTSAV_="1 SA: only JC to heaven";
*	if CHRSTSAV=2 then 	CHRSTSAV_="2 Ag only JC to heaven";
*	if CHRSTSAV=3 then 	CHRSTSAV_="3 nAnD: only JC to heaven";
*	if CHRSTSAV=4 then 	CHRSTSAV_="4 Dg only JC to heaven";
*	if CHRSTSAV=5 then 	CHRSTSAV_="5 SD: only JC to heaven";
*	if 					CHRSTSAV_="123456789012345678901234567890" then 
*						CHRSTSAV_="";
*######################################################################;
							SPRTCONNCT_="123456789012345678901234567890";
	if SPRTCONNCT=1 then 	SPRTCONNCT_="1 at least 1x day";
	if SPRTCONNCT=2 then 	SPRTCONNCT_="2 almost every day";
	if SPRTCONNCT=3 then 	SPRTCONNCT_="3 1-2x week";
	if SPRTCONNCT=4 then 	SPRTCONNCT_="4 1-2x month";
	if SPRTCONNCT=5 then 	SPRTCONNCT_="5 fewx year";
	if SPRTCONNCT=6 then 	SPRTCONNCT_="6 1x |<x year";
	if SPRTCONNCT=7 then 	SPRTCONNCT_="7 never";
	if 						SPRTCONNCT_="123456789012345678901234567890" then 
							SPRTCONNCT_="";
*##;
							SPRTCONNCT_1DorED="1234567890123456789012345678901234567890";
	if SPRTCONNCT=1 then 	SPRTCONNCT_1DorED="1 connect >1x day or every day";
	if SPRTCONNCT=2 then 	SPRTCONNCT_1DorED="1 connect >1x day or every day";
	if SPRTCONNCT=3 then 	SPRTCONNCT_1DorED="0 connect <1x day";
	if SPRTCONNCT=4 then 	SPRTCONNCT_1DorED="0 connect <1x day";
	if SPRTCONNCT=5 then 	SPRTCONNCT_1DorED="0 connect <1x day";
	if SPRTCONNCT=6 then 	SPRTCONNCT_1DorED="0 connect <1x day";
	if SPRTCONNCT=7 then 	SPRTCONNCT_1DorED="0 connect <1x day";
	if 						SPRTCONNCT_1DorED="1234567890123456789012345678901234567890" then 
							SPRTCONNCT_1DorED="";
*######################################################################;
						SPRTLRGR_="123456789012345678901234567890";
	if SPRTLRGR=1 then 	SPRTLRGR_="1 at least 1x day";
	if SPRTLRGR=2 then 	SPRTLRGR_="2 almost every day";
	if SPRTLRGR=3 then 	SPRTLRGR_="3 1-2x week";
	if SPRTLRGR=4 then 	SPRTLRGR_="4 1-2x month";
	if SPRTLRGR=5 then 	SPRTLRGR_="5 fewx year";
	if SPRTLRGR=6 then 	SPRTLRGR_="6 1x |<x year";
	if SPRTLRGR=7 then 	SPRTLRGR_="7 never";
	if 					SPRTLRGR_="123456789012345678901234567890" then 
						SPRTLRGR_="";
*##;
						SPRTLRGR_1DorED="123456789012345678901234567890";
	if SPRTLRGR=1 then 	SPRTLRGR_1DorED="1 larger >1x day or every day";
	if SPRTLRGR=2 then 	SPRTLRGR_1DorED="1 larger >1x day or every day";
	if SPRTLRGR=3 then 	SPRTLRGR_1DorED="0 larger <1x day";
	if SPRTLRGR=4 then 	SPRTLRGR_1DorED="0 larger <1x day";
	if SPRTLRGR=5 then 	SPRTLRGR_1DorED="0 larger <1x day";
	if SPRTLRGR=6 then 	SPRTLRGR_1DorED="0 larger <1x day";
	if SPRTLRGR=7 then 	SPRTLRGR_1DorED="0 larger <1x day";
	if 					SPRTLRGR_1DorED="123456789012345678901234567890" then 
						SPRTLRGR_1DorED="";
*######################################################################;
						SPRTPURP_="123456789012345678901234567890";
	if SPRTPURP=1 then 	SPRTPURP_="1 at least 1x day";
	if SPRTPURP=2 then 	SPRTPURP_="2 almost every day";
	if SPRTPURP=3 then 	SPRTPURP_="3 1-2x week";
	if SPRTPURP=4 then 	SPRTPURP_="4 1-2x month";
	if SPRTPURP=5 then 	SPRTPURP_="5 fewx year";
	if SPRTPURP=6 then 	SPRTPURP_="6 1x |<x year";
	if SPRTPURP=7 then 	SPRTPURP_="7 never";
	if 					SPRTPURP_="123456789012345678901234567890" then 
						SPRTPURP_="";
*##;
						SPRTPURP_1DorED="123456789012345678901234567890";
	if SPRTPURP=1 then 	SPRTPURP_1DorED="1 purp >1x day or every day";
	if SPRTPURP=2 then 	SPRTPURP_1DorED="1 purp >1x day or every day";
	if SPRTPURP=3 then 	SPRTPURP_1DorED="0 purp <1x day";
	if SPRTPURP=4 then 	SPRTPURP_1DorED="0 purp <1x day";
	if SPRTPURP=5 then 	SPRTPURP_1DorED="0 purp <1x day";
	if SPRTPURP=6 then 	SPRTPURP_1DorED="0 purp <1x day";
	if SPRTPURP=7 then 	SPRTPURP_1DorED="0 purp <1x day";
	if 					SPRTPURP_1DorED="123456789012345678901234567890" then 
						SPRTPURP_1DorED="";
*######################################################################;
*FIGURE 6.4: SPIRITUAL CONNECTION;
*######################################################################;
					GOD_="123456789012345678901234567890";
	if GOD=1 then 	GOD_="1 dont believe";
	if GOD=2 then 	GOD_="2 dont know, unknowable";
	if GOD=3 then 	GOD_="3 higher power";
	if GOD=4 then 	GOD_="4 believe sometimes";
	if GOD=5 then 	GOD_="5 believe with doubts";
	if GOD=6 then 	GOD_="6 believe no doubts";
	if 				GOD_="123456789012345678901234567890" then 
					GOD_="";
*##;
					GOD_nodoubt="123456789012345678901234567890";
	if GOD=1 then 	GOD_nodoubt="0 < believe, no doubts";
	if GOD=2 then 	GOD_nodoubt="0 < believe, no doubts";
	if GOD=3 then 	GOD_nodoubt="0 < believe, no doubts";
	if GOD=4 then 	GOD_nodoubt="0 < believe, no doubts";
	if GOD=5 then 	GOD_nodoubt="0 < believe, no doubts";
	if GOD=6 then 	GOD_nodoubt="1 believe, no doubts";
	if 				GOD_nodoubt="123456789012345678901234567890" then 
					GOD_nodoubt="";
*######################################################################;
							POSTLIFEV_="123456789012345678901234567890";
	if POSTLIFEV=1 then 	POSTLIFEV_="1 Yes, life after death";
	if POSTLIFEV=2 then 	POSTLIFEV_="0 No, no life after death";
	if 						POSTLIFEV_="123456789012345678901234567890" then 
							POSTLIFEV_="";
	if POSTLIFEV_="" & POSTLIFENV=1 then POSTLIFEV_="1 Yes, life after death";
	if POSTLIFEV_="" & POSTLIFENV=2 then POSTLIFEV_="0 No, no life after death";
*######################################################################;
						POPESPKS_="123456789012345678901234567890";
	if POPESPKS=1 then 	POPESPKS_="1 certainly true";
	if POPESPKS=2 then 	POPESPKS_="2 probably true";
	if POPESPKS=3 then 	POPESPKS_="3 Uncertain T or F";
	if POPESPKS=4 then 	POPESPKS_="4 probably false";
	if POPESPKS=5 then 	POPESPKS_="5 certainly false";
	if 					POPESPKS_="123456789012345678901234567890" then 
						POPESPKS_="";
*##;
						POPESPKS_CTvsOTH="123456789012345678901234567890";
	if POPESPKS=1 then 	POPESPKS_CTvsOTH="1 certainly true";
	if POPESPKS=2 then 	POPESPKS_CTvsOTH="0 other than certainly true";
	if POPESPKS=3 then 	POPESPKS_CTvsOTH="0 other than certainly true";
	if POPESPKS=4 then 	POPESPKS_CTvsOTH="0 other than certainly true";
	if POPESPKS=5 then 	POPESPKS_CTvsOTH="0 other than certainly true";
	if 					POPESPKS_CTvsOTH="123456789012345678901234567890" then 
						POPESPKS_CTvsOTH="";
*##;
						POPESPKS_PTvsOTH="123456789012345678901234567890";
	if POPESPKS=1 then 	POPESPKS_PTvsOTH="0 other than probably true";
	if POPESPKS=2 then 	POPESPKS_PTvsOTH="1 probably true";
	if POPESPKS=3 then 	POPESPKS_PTvsOTH="0 other than probably true";
	if POPESPKS=4 then 	POPESPKS_PTvsOTH="0 other than probably true";
	if POPESPKS=5 then 	POPESPKS_PTvsOTH="0 other than probably true";
	if 					POPESPKS_PTvsOTH="123456789012345678901234567890" then 
						POPESPKS_PTvsOTH="";
*##;
						POPESPKS_UCvsOTH="123456789012345678901234567890";
	if POPESPKS=1 then 	POPESPKS_UCvsOTH="0 other than uncertain";
	if POPESPKS=2 then 	POPESPKS_UCvsOTH="0 other than uncertain";
	if POPESPKS=3 then 	POPESPKS_UCvsOTH="1 uncertain";
	if POPESPKS=4 then 	POPESPKS_UCvsOTH="0 other than uncertain";
	if POPESPKS=5 then 	POPESPKS_UCvsOTH="0 other than uncertain";
	if 					POPESPKS_UCvsOTH="123456789012345678901234567890" then 
						POPESPKS_UCvsOTH="";
*##;
						POPESPKS_FvsOTH="123456789012345678901234567890";
	if POPESPKS=1 then 	POPESPKS_FvsOTH="0 other than false";
	if POPESPKS=2 then 	POPESPKS_FvsOTH="0 other than false";
	if POPESPKS=3 then 	POPESPKS_FvsOTH="0 other than false";
	if POPESPKS=4 then 	POPESPKS_FvsOTH="1 Prob or cert false";
	if POPESPKS=5 then 	POPESPKS_FvsOTH="1 Prob or cert false";
	if 					POPESPKS_FvsOTH="123456789012345678901234567890" then 
						POPESPKS_FvsOTH="";
*######################################################################;

*						BIBLAUTH_="123456789012345678901234567890";
*	if BIBLAUTH=1 then 	BIBLAUTH_="1 SA: bible is authority";
*	if BIBLAUTH=2 then 	BIBLAUTH_="2 A: bible is authority";
*	if BIBLAUTH=3 then 	BIBLAUTH_="3 nAnD: bible is authority";
*	if BIBLAUTH=4 then 	BIBLAUTH_="4 D: bible is authority";
*	if BIBLAUTH=5 then 	BIBLAUTH_="5 SD: bible is authority";
*	if	 				BIBLAUTH_="123456789012345678901234567890" then 
*						BIBLAUTH_="";
*######################################################################;
										*FIGURE 6.6: The Bible;
*######################################################################;
							BIBLE_="123456789012345678901234567890";
	if BIBLE=1 then 		BIBLE_="1 Word of god";
	if BIBLE=2 then 		BIBLE_="2 Inspired word";
	if BIBLE=3 then 		BIBLE_="3 Ancient book";
	if BIBLE=4 then 		BIBLE_="4 Other";
	if 						BIBLE_="123456789012345678901234567890" then 
							BIBLE_="";
	if BIBLE_="" & BIBLENV=1 then BIBLE_="1 Word of god";
	if BIBLE_="" & BIBLENV=2 then BIBLE_="2 Inspired word";
	if BIBLE_="" & BIBLENV=3 then BIBLE_="3 Ancient book";
	if BIBLE_="" & BIBLENV=4 then BIBLE_="4 Other";
*######################################################################;
*Figure 6.7: Religion, Politics, and Science;
*######################################################################;
							PRAYERNV_="1234567890123456789012345678901234567890";
	if PRAYERNV=1 then 		PRAYERNV_="1 approve read LP in pub school";
	if PRAYERNV=2 then 		PRAYERNV_="0 disapprove read LP in pub school";
	if 						PRAYERNV_="1234567890123456789012345678901234567890" then 
							PRAYERNV_="";
	if PRAYERV=1 then 		PRAYERNV_="1 approve read LP in pub school";
	if PRAYERV=2 then 		PRAYERNV_="0 disapprove read LP in pub school";
*######################################################################;
						GRTWRKS_="123456789012345678901234567890";
	if GRTWRKS=1 then 	GRTWRKS_="1 SA: grtwrks truth source";
	if GRTWRKS=2 then 	GRTWRKS_="2 A: grtwrks truth source";
	if GRTWRKS=3 then 	GRTWRKS_="3 nAnD: grtwrks truth source";
	if GRTWRKS=4 then 	GRTWRKS_="4 D: grtwrks truth source";
	if GRTWRKS=5 then 	GRTWRKS_="5 SD: grtwrks truth source";
	if	 				GRTWRKS_="123456789012345678901234567890" then 
						GRTWRKS_="";
*##;
						GRTWRKS_AorSA="123456789012345678901234567890";
	if GRTWRKS=1 then 	GRTWRKS_AorSA="1 AorSA: grtwrks truth source";
	if GRTWRKS=2 then 	GRTWRKS_AorSA="1 AorSA: grtwrks truth source";
	if GRTWRKS=3 then 	GRTWRKS_AorSA="0 grtwrks not truth source";
	if GRTWRKS=4 then 	GRTWRKS_AorSA="0 grtwrks not truth source";
	if GRTWRKS=5 then 	GRTWRKS_AorSA="0 grtwrks not truth source";
	if	 				GRTWRKS_AorSA="123456789012345678901234567890" then 
						GRTWRKS_AorSA="";

						FREEMIND_="123456789012345678901234567890";
	if FREEMIND=1 then 	FREEMIND_="1 SA: must free from trad";
	if FREEMIND=2 then 	FREEMIND_="2 A: must free from trad";
	if FREEMIND=3 then 	FREEMIND_="3 nAnD: must free from trad";
	if FREEMIND=4 then 	FREEMIND_="4 D: must free from trad";
	if FREEMIND=5 then 	FREEMIND_="5 SD: must free from trad";
	if	 				FREEMIND_="123456789012345678901234567890" then 
						FREEMIND_="";
						FREEMIND_AorSA="123456789012345678901234567890";
	if FREEMIND=1 then 	FREEMIND_AorSA="1 AorSA: must free from trad";
	if FREEMIND=2 then 	FREEMIND_AorSA="1 AorSA: must free from trad";
	if FREEMIND=3 then 	FREEMIND_AorSA="0 must not free from trad";
	if FREEMIND=4 then 	FREEMIND_AorSA="0 must not free from trad";
	if FREEMIND=5 then 	FREEMIND_AorSA="0 must not free from trad";
	if	 				FREEMIND_AorSA="123456789012345678901234567890" then 
						FREEMIND_AorSA="";

						DECEVIDC_="123456789012345678901234567890";
	if DECEVIDC=1 then 	DECEVIDC_="1 SA: I rely on reason";
	if DECEVIDC=2 then 	DECEVIDC_="2 A: I rely on reason";
	if DECEVIDC=3 then 	DECEVIDC_="3 nAnD: I rely on reason";
	if DECEVIDC=4 then 	DECEVIDC_="4 D: I rely on reason";
	if DECEVIDC=5 then 	DECEVIDC_="5 SD: I rely on reason";
	if	 				DECEVIDC_="123456789012345678901234567890" then 
						DECEVIDC_="";
						DECEVIDC_AorSA="123456789012345678901234567890";
	if DECEVIDC=1 then 	DECEVIDC_AorSA="1 AorSA: I rely on reason";
	if DECEVIDC=2 then 	DECEVIDC_AorSA="1 AorSA: I rely on reason";
	if DECEVIDC=3 then 	DECEVIDC_AorSA="0 I do not rely on reason";
	if DECEVIDC=4 then 	DECEVIDC_AorSA="0 I do not rely on reason";
	if DECEVIDC=5 then 	DECEVIDC_AorSA="0 I do not rely on reason";
	if	 				DECEVIDC_AorSA="123456789012345678901234567890" then 
						DECEVIDC_AorSA="";

						ADVFMSCI_="123456789012345678901234567890";
	if ADVFMSCI=1 then 	ADVFMSCI_="1 SA: all adv from sci";
	if ADVFMSCI=2 then 	ADVFMSCI_="2 A: all adv from sci";
	if ADVFMSCI=3 then 	ADVFMSCI_="3 nAnD: all adv from sci";
	if ADVFMSCI=4 then 	ADVFMSCI_="4 D: all adv from sci";
	if ADVFMSCI=5 then 	ADVFMSCI_="5 SD: all adv from sci";
	if	 				ADVFMSCI_="123456789012345678901234567890" then 
						ADVFMSCI_="";
						ADVFMSCI_AorSA="123456789012345678901234567890";
	if ADVFMSCI=1 then 	ADVFMSCI_AorSA="1 AorSA: all adv from sci";
	if ADVFMSCI=2 then 	ADVFMSCI_AorSA="1 AorSA: all adv from sci";
	if ADVFMSCI=3 then 	ADVFMSCI_AorSA="0 not all adv from sci";
	if ADVFMSCI=4 then 	ADVFMSCI_AorSA="0 not all adv from sci";
	if ADVFMSCI=5 then 	ADVFMSCI_AorSA="0 not all adv from sci";
	if	 				ADVFMSCI_AorSA="123456789012345678901234567890" then 
						ADVFMSCI_AorSA="";
	
						GODUSA_="123456789012345678901234567890";
	if GODUSA=1 then 	GODUSA_="1 SA: US is gods plan";
	if GODUSA=2 then 	GODUSA_="2 A: US is gods plan";
	if GODUSA=3 then 	GODUSA_="3 nAnD: US is gods plan";
	if GODUSA=4 then 	GODUSA_="4 D: US is gods plan";
	if GODUSA=5 then 	GODUSA_="5 SD: US is gods plan";
	if	 				GODUSA_="123456789012345678901234567890" then 
						GODUSA_="";
						GODUSA_AorSA="123456789012345678901234567890";
	if GODUSA=1 then 	GODUSA_AorSA="1 AorSA: US is gods plan";
	if GODUSA=2 then 	GODUSA_AorSA="1 AorSA: US is gods plan";
	if GODUSA=3 then 	GODUSA_AorSA="0 US is not gods plan";
	if GODUSA=4 then 	GODUSA_AorSA="0 US is not gods plan";
	if GODUSA=5 then 	GODUSA_AorSA="0 US is not gods plan";
	if	 				GODUSA_AorSA="123456789012345678901234567890" then 
						GODUSA_AorSA="";

						GOVCHRST_="123456789012345678901234567890";
	if GOVCHRST=1 then 	GOVCHRST_="1 SA: Fed should be Christian";
	if GOVCHRST=2 then 	GOVCHRST_="2 A: Fed should be Christian";
	if GOVCHRST=3 then 	GOVCHRST_="3 nAnD: Fed should be Christian";
	if GOVCHRST=4 then 	GOVCHRST_="4 D: Fed should be Christian";
	if GOVCHRST=5 then 	GOVCHRST_="5 SD: Fed should be Christian";
	if	 				GOVCHRST_="123456789012345678901234567890" then 
						GOVCHRST_="";
						GOVCHRST_AorSA="1234567890123456789012345678901234567890";
	if GOVCHRST=1 then 	GOVCHRST_AorSA="1 AorSA: Fed should be Christian";
	if GOVCHRST=2 then 	GOVCHRST_AorSA="1 AorSA: Fed should be Christian";
	if GOVCHRST=3 then 	GOVCHRST_AorSA="0 Fed should not be Christian";
	if GOVCHRST=4 then 	GOVCHRST_AorSA="0 Fed should not be Christian";
	if GOVCHRST=5 then 	GOVCHRST_AorSA="0 Fed should not be Christian";
	if	 				GOVCHRST_AorSA="1234567890123456789012345678901234567890" then 
						GOVCHRST_AorSA="";

						RELIGINF_="123456789012345678901234567890";
	if RELIGINF=1 then 	RELIGINF_="1 SA: US better < rel inf";
	if RELIGINF=2 then 	RELIGINF_="2 A: US better < rel inf";
	if RELIGINF=3 then 	RELIGINF_="3 nAnD: US better < rel inf";
	if RELIGINF=4 then 	RELIGINF_="4 D: US better < rel inf";
	if RELIGINF=5 then 	RELIGINF_="5 SD: US better < rel inf";
	if	 				RELIGINF_="123456789012345678901234567890" then 
						RELIGINF_="";
						RELIGINF_AorSA="123456789012345678901234567890";
	if RELIGINF=1 then 	RELIGINF_AorSA="1 AorSA: US better < rel inf";
	if RELIGINF=2 then 	RELIGINF_AorSA="1 AorSA: US better < rel inf";
	if RELIGINF=3 then 	RELIGINF_AorSA="0 US not better < rel inf";
	if RELIGINF=4 then 	RELIGINF_AorSA="0 US not better < rel inf";
	if RELIGINF=5 then 	RELIGINF_AorSA="0 US not better < rel inf";
	if	 				RELIGINF_AorSA="123456789012345678901234567890" then 
						RELIGINF_AorSA="";
*######################################################################;
*Figure 6.8: Sexual Morality
*######################################################################;
						PILLOK_="123456789012345678901234567890";
	if PILLOK=1 then 	PILLOK_="1 SA: ok teen pill";
	if PILLOK=2 then 	PILLOK_="2 A: ok teen pill";
	if PILLOK=3 then 	PILLOK_="3 D: ok teen pill";
	if PILLOK=4 then 	PILLOK_="4 SD: ok teen pill";
	if	 				PILLOK_="123456789012345678901234567890" then 
						PILLOK_="";
						PILLOK_AorSA="123456789012345678901234567890";
	if PILLOK=1 then 	PILLOK_AorSA="1 AorSA: ok teen pill";
	if PILLOK=2 then 	PILLOK_AorSA="1 AorSA: ok teen pill";
	if PILLOK=3 then 	PILLOK_AorSA="0 not ok teen pill";
	if PILLOK=4 then 	PILLOK_AorSA="0 not ok teen pill";
	if	 				PILLOK_AorSA="123456789012345678901234567890" then 
						PILLOK_AorSA="";

						SEXEDUC_="123456789012345678901234567890";
	if SEXEDUC=1 then 	SEXEDUC_="1 in favor: sex ed in pub sch";
	if SEXEDUC=2 then 	SEXEDUC_="2 oppose: sex ed in pub sch";
	if SEXEDUC=3 then 	SEXEDUC_="3 depends:  sex ed in pub sch";
	if	 				SEXEDUC_="123456789012345678901234567890" then 
						SEXEDUC_="";
						SEXEDUC_favor="123456789012345678901234567890";
	if SEXEDUC=1 then 	SEXEDUC_favor="1 in favor: sex ed in pub sch";
	if SEXEDUC=2 then 	SEXEDUC_favor="0 not in favor sex ed in sch";
	if SEXEDUC=3 then 	SEXEDUC_favor="0 not in favor sex ed in sch";
	if	 				SEXEDUC_favor="123456789012345678901234567890" then 
						SEXEDUC_favor="";

						DIVLAW_="123456789012345678901234567890";
	if DIVLAW=1 then 	DIVLAW_="1 Easier divorce";
	if DIVLAW=2 then 	DIVLAW_="2 Difficult divorce";
	if DIVLAW=3 then 	DIVLAW_="3 As is";
	if 					DIVLAW_="123456789012345678901234567890" then 
						DIVLAW_="";
	if DIVLAW_="" & DIVLAWV=1 then DIVLAW_="1 Easier divorce";
	if DIVLAW_="" & DIVLAWV=2 then DIVLAW_="2 Difficult divorce";
	if DIVLAW_="" & DIVLAWV=3 then DIVLAW_="3 As is";
	if DIVLAW_="" & DIVLAWNV=1 then DIVLAW_="1 Easier divorce";
	if DIVLAW_="" & DIVLAWNV=2 then DIVLAW_="2 Difficult divorce";
	if DIVLAW_="" & DIVLAWNV=3 then DIVLAW_="3 As is";
										DIVLAW_easier="12345678901234567890";
if DIVLAW_="1 Easier divorce" then 		DIVLAW_easier="1 easier divorce";
if DIVLAW_="2 Difficult divorce" then 	DIVLAW_easier="0 not easier divorce";;
if DIVLAW_="3 As is" then 				DIVLAW_easier="0 not easier divorce";
if										DIVLAW_easier="12345678901234567890" then
										DIVLAW_easier="";

						PREMARSX_="1234567890123456789012345678901234567890";
	if PREMARSX=1 then 	PREMARSX_="1 always wrong: premarsex";
	if PREMARSX=2 then 	PREMARSX_="2 almost always wrong: premarsex";
	if PREMARSX=3 then 	PREMARSX_="3 sometimes wrong: premarsex";
	if PREMARSX=4 then 	PREMARSX_="4 not wrong: premarsex";
	if	 				PREMARSX_="1234567890123456789012345678901234567890" then 
						PREMARSX_="";
						PREMARSX_NW="1234567890123456789012345678901234567890";
	if PREMARSX=1 then 	PREMARSX_NW="0 wrong: premarsex";
	if PREMARSX=2 then 	PREMARSX_NW="0 wrong: premarsex";
	if PREMARSX=3 then 	PREMARSX_NW="0 wrong: premarsex";
	if PREMARSX=4 then 	PREMARSX_NW="1 not wrong: premarsex";
	if	 				PREMARSX_NW="1234567890123456789012345678901234567890" then 
						PREMARSX_NW="";

						TEENSEX_="1234567890123456789012345678901234567890";
	if TEENSEX=1 then 	TEENSEX_="1 always wrong: teensex";
	if TEENSEX=2 then 	TEENSEX_="2 almost always wrong: teensex";
	if TEENSEX=3 then 	TEENSEX_="3 sometimes wrong: teensex";
	if TEENSEX=4 then 	TEENSEX_="4 not wrong: teensex";
	if	 				TEENSEX_="1234567890123456789012345678901234567890" then 
						TEENSEX_="";
						TEENSEX_NW="1234567890123456789012345678901234567890";
	if TEENSEX=1 then 	TEENSEX_NW="0 wrong: teensex";
	if TEENSEX=2 then 	TEENSEX_NW="0 wrong: teensex";
	if TEENSEX=3 then 	TEENSEX_NW="0 wrong: teensex";
	if TEENSEX=4 then 	TEENSEX_NW="1 not wrong: teensex";
	if	 				TEENSEX_NW="1234567890123456789012345678901234567890" then 
						TEENSEX_NW="";

						XMARSEX_="1234567890123456789012345678901234567890";
	if XMARSEX=1 then 	XMARSEX_="1 always wrong: x mar sex";
	if XMARSEX=2 then 	XMARSEX_="2 almost always wrong: x mar sex";
	if XMARSEX=3 then 	XMARSEX_="3 sometimes wrong: x mar sex";
	if XMARSEX=4 then 	XMARSEX_="4 not wrong: x mar sex";
	if	 				XMARSEX_="1234567890123456789012345678901234567890" then 
						XMARSEX_="";
						XMARSEX_NW="1234567890123456789012345678901234567890";
	if XMARSEX=1 then 	XMARSEX_NW="0 wrong: x mar sex";
	if XMARSEX=2 then 	XMARSEX_NW="0 wrong: x mar sex";
	if XMARSEX=3 then 	XMARSEX_NW="0 wrong: x mar sex";
	if XMARSEX=4 then 	XMARSEX_NW="1 not wrong: x mar sex";
	if	 				XMARSEX_NW="1234567890123456789012345678901234567890" then 
						XMARSEX_NW="";

						MARHOMO_="123456789012345678901234567890";
	if MARHOMO=1 then 	MARHOMO_="1 SA: gay marriage ok";
	if MARHOMO=2 then 	MARHOMO_="2 A: gay marriage ok";
	if MARHOMO=3 then 	MARHOMO_="3 nAnD: gay marriage ok";
	if MARHOMO=4 then 	MARHOMO_="4 D: gay marriage ok";
	if MARHOMO=5 then 	MARHOMO_="5 SD: gay marriage ok";
	if	 				MARHOMO_="123456789012345678901234567890" then 
						MARHOMO_="";
						MARHOMO_AorSA="123456789012345678901234567890";
	if MARHOMO=1 then 	MARHOMO_AorSA="1 AorSA: gay marriage ok";
	if MARHOMO=2 then 	MARHOMO_AorSA="1 AorSA: gay marriage ok";
	if MARHOMO=3 then 	MARHOMO_AorSA="0 gay marriage not ok";
	if MARHOMO=4 then 	MARHOMO_AorSA="0 gay marriage not ok";
	if MARHOMO=5 then 	MARHOMO_AorSA="0 gay marriage not ok";
	if	 				MARHOMO_AorSA="123456789012345678901234567890" then 
						MARHOMO_AorSA="";

						HOMOSEX_="123456789012345678901234567890";
	if HOMOSEX=1 then 	HOMOSEX_="1 always wrong: homosex";
	if HOMOSEX=2 then 	HOMOSEX_="2 almst always wrong: homosex";
	if HOMOSEX=3 then 	HOMOSEX_="3 sometimes wrong: homosex";
	if HOMOSEX=4 then 	HOMOSEX_="4 not wrong: homosex";
	*if HOMOSEX=5 then 	HOMOSEX_="5 other: homosex"; *NO OBS;
	if	 				HOMOSEX_="123456789012345678901234567890" then 
						HOMOSEX_="";
						HOMOSEX_NW="123456789012345678901234567890";
	if HOMOSEX=1 then 	HOMOSEX_NW="0 wrong: homosex";
	if HOMOSEX=2 then 	HOMOSEX_NW="0 wrong: homosex";
	if HOMOSEX=3 then 	HOMOSEX_NW="0 wrong: homosex";
	if HOMOSEX=4 then 	HOMOSEX_NW="1 not wrong: homosex";
	if	 				HOMOSEX_NW="123456789012345678901234567890" then 
						HOMOSEX_NW="";

						PORNLAW_="123456789012345678901234567890";
	if PORNLAW=1 then 	PORNLAW_="1 laws against, any age";
	if PORNLAW=2 then 	PORNLAW_="2 laws against, <18";
	if PORNLAW=3 then 	PORNLAW_="3 no laws";
	if	 				PORNLAW_="123456789012345678901234567890" then 
						PORNLAW_="";
						PORNLAW_18law="123456789012345678901234567890";
	if PORNLAW=1 then 	PORNLAW_18law="0 outlaw or no law";
	if PORNLAW=2 then 	PORNLAW_18law="1 law for <18";
	if PORNLAW=3 then 	PORNLAW_18law="0 outlaw or no law";
	if	 				PORNLAW_18law="123456789012345678901234567890" then 
						PORNLAW_18law="";

						XMOVIE_="123456789012345678901234567890";
	if XMOVIE=1 then 	XMOVIE_="1 Yes, porn in last year";
	if XMOVIE=2 then 	XMOVIE_="0 No, porn in last year";
	if	 				XMOVIE_="123456789012345678901234567890" then 
						XMOVIE_="";
*######################################################################;
*Figure 6.9: Abortion
*######################################################################;

						PROLIFE_="123456789012345678901234567890";
	if PROLIFE=1 then 	PROLIFE_="1 SA: I am pro-life";
	if PROLIFE=2 then 	PROLIFE_="2 A: I am pro-life";
	if PROLIFE=3 then 	PROLIFE_="3 nAnD: I am pro-life";
	if PROLIFE=4 then 	PROLIFE_="4 D: I am pro-life";
	if PROLIFE=5 then 	PROLIFE_="5 SD: I am pro-life";
	if	 				PROLIFE_="123456789012345678901234567890" then 
						PROLIFE_="";
						PROLIFE_SAorA="123456789012345678901234567890";
	if PROLIFE=1 then 	PROLIFE_SAorA="1 SA or A: I am pro-life";
	if PROLIFE=2 then 	PROLIFE_SAorA="1 SA or A: I am pro-life";
	if PROLIFE=3 then 	PROLIFE_SAorA="0 not SA pro-life";
	if PROLIFE=4 then 	PROLIFE_SAorA="0 not SA pro-life";
	if PROLIFE=5 then 	PROLIFE_SAorA="0 not SA pro-life";
	if	 				PROLIFE_SAorA="123456789012345678901234567890" then 
						PROLIFE_SAorA="";
						PROLIFE_A="123456789012345678901234567890";
	if PROLIFE=1 then 	PROLIFE_A="0 not A pro-life";
	if PROLIFE=2 then 	PROLIFE_A="1 A: I am pro-life";
	if PROLIFE=3 then 	PROLIFE_A="0 not A pro-life";
	if PROLIFE=4 then 	PROLIFE_A="0 not A pro-life";
	if PROLIFE=5 then 	PROLIFE_A="0 not A pro-life";
	if	 				PROLIFE_A="123456789012345678901234567890" then 
						PROLIFE_A="";

						PROCHOIC_="123456789012345678901234567890";
	if PROCHOIC=1 then 	PROCHOIC_="1 SA: I am pro-choice";
	if PROCHOIC=2 then 	PROCHOIC_="2 A: I am pro-choice";
	if PROCHOIC=3 then 	PROCHOIC_="3 nAnD: I am pro-choice";
	if PROCHOIC=4 then 	PROCHOIC_="4 D: I am pro-choice";
	if PROCHOIC=5 then 	PROCHOIC_="5 SD: I am pro-choice";
	if	 				PROCHOIC_="123456789012345678901234567890" then 
						PROCHOIC_="";
						PROCHOIC_SAorA="123456789012345678901234567890";
	if PROCHOIC=1 then 	PROCHOIC_SAorA="1 SA or A: I am pro-choice";
	if PROCHOIC=2 then 	PROCHOIC_SAorA="1 SA or A: I am pro-choice";
	if PROCHOIC=3 then 	PROCHOIC_SAorA="0 not SA pro-choice";
	if PROCHOIC=4 then 	PROCHOIC_SAorA="0 not SA pro-choice";
	if PROCHOIC=5 then 	PROCHOIC_SAorA="0 not SA pro-choice";
	if	 				PROCHOIC_SAorA="123456789012345678901234567890" then 
						PROCHOIC_SAorA="";
						PROCHOIC_A="123456789012345678901234567890";
	if PROCHOIC=1 then 	PROCHOIC_A="0 not A pro-choice";
	if PROCHOIC=2 then 	PROCHOIC_A="1 A: I am pro-choice";
	if PROCHOIC=3 then 	PROCHOIC_A="0 not A pro-choice";
	if PROCHOIC=4 then 	PROCHOIC_A="0 not A pro-choice";
	if PROCHOIC=5 then 	PROCHOIC_A="0 not A pro-choice";
	if	 				PROCHOIC_A="123456789012345678901234567890" then 
						PROCHOIC_A="";

						ABDEFECT_="123456789012345678901234567890";
	if ABDEFECT=1 then 	ABDEFECT_="1 Yes, abort ok if defect";
	if ABDEFECT=2 then 	ABDEFECT_="2 No, abort ok if defect";
	if	 				ABDEFECT_="123456789012345678901234567890" then 
						ABDEFECT_="";
	if ABDEFECT_="" & ABDEFECTG=1 then ABDEFECT_="1 Yes, abort ok if defect";
	if ABDEFECT_="" & ABDEFECTG=2 then ABDEFECT_="2 No, abort ok if defect";
													ABDEFECT_YES="123456789012345678901234567890";
	if ABDEFECT_="1 Yes, abort ok if defect" then 	ABDEFECT_YES="1 Yes, abort ok if defect";
	if ABDEFECT_="2 No, abort ok if defect" then 	ABDEFECT_YES="0 No, abort ok if defect";
	if	 											ABDEFECT_YES="123456789012345678901234567890" then 
													ABDEFECT_YES="";

						ABNOMORE_="123456789012345678901234567890";
	if ABNOMORE=1 then 	ABNOMORE_="1 Yes, abort ok if want nomore";
	if ABNOMORE=2 then 	ABNOMORE_="2 No, abort ok if want nomore";
	if	 				ABNOMORE_="123456789012345678901234567890" then 
						ABNOMORE_="";
	if ABNOMORE_="" & ABNOMOREG=1 then ABNOMORE_="1 Yes, abort ok if want nomore";
	if ABNOMORE_="" & ABNOMOREG=2 then ABNOMORE_="2 No, abort ok if want nomore";
														ABNOMORE_YES="123456789012345678901234567890";
	if ABNOMORE_="1 Yes, abort ok if want nomore" then 	ABNOMORE_YES="1 Yes, abort ok if want nomore";
	if ABNOMORE_="2 No, abort ok if want nomore" then 	ABNOMORE_YES="0 No, abort ok if want nomore";
	if	 												ABNOMORE_YES="123456789012345678901234567890" then 
														ABNOMORE_YES="";

						ABHLTH_="123456789012345678901234567890";
	if ABHLTH=1 then 	ABHLTH_="1 Yes, abort ok if mom hlth";
	if ABHLTH=2 then 	ABHLTH_="2 No, abort ok if mom hlth";
	if	 				ABHLTH_="123456789012345678901234567890" then 
						ABHLTH_="";
	if ABHLTH_="" & ABHLTHG=1 then ABHLTH_="1 Yes, abort ok if mom hlth";
	if ABHLTH_="" & ABHLTHG=2 then ABHLTH_="2 No, abort ok if mom hlth";
													ABHLTH_YES="123456789012345678901234567890";
	if ABHLTH_="1 Yes, abort ok if mom hlth" then 	ABHLTH_YES="1 Yes, abort ok if mom hlth";
	if ABHLTH_="2 No, abort ok if mom hlth" then 	ABHLTH_YES="0 No, abort ok if mom hlth";
	if	 											ABHLTH_YES="123456789012345678901234567890" then 
													ABHLTH_YES="";

						ABPOOR_="123456789012345678901234567890";
	if ABPOOR=1 then 	ABPOOR_="1 Yes, abort ok if poor";
	if ABPOOR=2 then 	ABPOOR_="2 No, abort ok if poor";
	if	 				ABPOOR_="123456789012345678901234567890" then 
						ABPOOR_="";
	if ABPOOR_="" & ABPOORG=1 then ABPOOR_="1 Yes, abort ok if poor";
	if ABPOOR_="" & ABPOORG=2 then ABPOOR_="2 No, abort ok if poor";
												ABPOOR_YES="123456789012345678901234567890";
	if ABPOOR_="1 Yes, abort ok if poor" then 	ABPOOR_YES="1 Yes, abort ok if poor";
	if ABPOOR_="2 No, abort ok if poor" then 	ABPOOR_YES="0 No, abort ok if poor";
	if	 										ABPOOR_YES="123456789012345678901234567890" then 
												ABPOOR_YES="";

						ABRAPE_="123456789012345678901234567890";
	if ABRAPE=1 then 	ABRAPE_="1 Yes, abort ok if rape";
	if ABRAPE=2 then 	ABRAPE_="2 No, abort ok if rape";
	if	 				ABRAPE_="123456789012345678901234567890" then 
						ABRAPE_="";
	if ABRAPE_="" & ABRAPEG=1 then ABRAPE_="1 Yes, abort ok if rape";
	if ABRAPE_="" & ABRAPEG=2 then ABRAPE_="2 No, abort ok if rape";
												ABRAPE_YES="123456789012345678901234567890";
	if ABRAPE_="1 Yes, abort ok if rape" then 	ABRAPE_YES="1 Yes, abort ok if rape";
	if ABRAPE_="2 No, abort ok if rape" then 	ABRAPE_YES="0 No, abort ok if rape";
	if	 										ABRAPE_YES="123456789012345678901234567890" then 
												ABRAPE_YES="";

						ABSINGLE_="123456789012345678901234567890";
	if ABSINGLE=1 then 	ABSINGLE_="1 Yes, abort ok if single";
	if ABSINGLE=2 then 	ABSINGLE_="2 No, abort ok if single";
	if	 				ABSINGLE_="123456789012345678901234567890" then 
						ABSINGLE_="";
	if ABSINGLE_="" & ABSINGLEG=1 then ABSINGLE_="1 Yes, abort ok if single";
	if ABSINGLE_="" & ABSINGLEG=2 then ABSINGLE_="2 No, abort ok if single";
													ABSINGLE_YES="123456789012345678901234567890";
	if ABSINGLE_="1 Yes, abort ok if single" then 	ABSINGLE_YES="1 Yes, abort ok if single";
	if ABSINGLE_="2 No, abort ok if single" then 	ABSINGLE_YES="0 No, abort ok if single";
	if	 											ABSINGLE_YES="123456789012345678901234567890" then 
													ABSINGLE_YES="";

						ABANY_="123456789012345678901234567890";
	if ABANY=1 then 	ABANY_="1 Yes, abort ok any reason";
	if ABANY=2 then 	ABANY_="2 No, abort ok any reason";
	if	 				ABANY_="123456789012345678901234567890" then 
						ABANY_="";
	if ABANY_="" & ABANYG=1 then ABANY_="1 Yes, abort ok any reason";
	if ABANY_="" & ABANYG=2 then ABANY_="2 No, abort ok any reason";
													ABANY_YES="123456789012345678901234567890";
	if ABANY_="1 Yes, abort ok any reason" then 	ABANY_YES="1 Yes, abort ok any reason";
	if ABANY_="2 No, abort ok any reason" then 		ABANY_YES="0 No, abort ok any reason";
	if	 											ABANY_YES="123456789012345678901234567890" then 
													ABANY_YES="";

*COMPLEXITY SCORE;													
if ABDEFECT=1 then ABCOMPLEX_1y = 1;
if ABDEFECT=2 then ABCOMPLEX_1y = 0;
if ABNOMORE=1 then ABCOMPLEX_2y = 1;
if ABNOMORE=2 then ABCOMPLEX_2y = 0;
if ABHLTH=1 then ABCOMPLEX_3y = 1;
if ABHLTH=2 then ABCOMPLEX_3y = 0;
if ABPOOR=1 then ABCOMPLEX_4y = 1;
if ABPOOR=2 then ABCOMPLEX_4y = 0;
if ABRAPE=1 then ABCOMPLEX_5y = 1;
if ABRAPE=2 then ABCOMPLEX_5y = 0;
if ABSINGLE=1 then ABCOMPLEX_6y = 1;
if ABSINGLE=2 then ABCOMPLEX_6y = 0;

if ABDEFECT=2 then ABCOMPLEX_1n =-1;
if ABDEFECT=1 then ABCOMPLEX_1n =0;
if ABNOMORE=2 then ABCOMPLEX_2n =-1;
if ABNOMORE=1 then ABCOMPLEX_2n =0;
if ABHLTH=2 then ABCOMPLEX_3n =-1;
if ABHLTH=1 then ABCOMPLEX_3n =0;
if ABPOOR=2 then ABCOMPLEX_4n =-1;
if ABPOOR=1 then ABCOMPLEX_4n =0;
if ABRAPE=2 then ABCOMPLEX_5n =-1;
if ABRAPE=1 then ABCOMPLEX_5n =0;
if ABSINGLE=2 then ABCOMPLEX_6n =-1;
if ABSINGLE=1 then ABCOMPLEX_6n =0;
ABCOMPLEX_d = ABCOMPLEX_1y + ABCOMPLEX_2y + ABCOMPLEX_3y + ABCOMPLEX_4y +
 ABCOMPLEX_5y + ABCOMPLEX_6y + ABCOMPLEX_1n + ABCOMPLEX_2n + ABCOMPLEX_3n + 
ABCOMPLEX_4n + ABCOMPLEX_5n + ABCOMPLEX_6n;
if ABCOMPLEX_d=-6 then ABCOMPLEX=0;
if ABCOMPLEX_d=6 then ABCOMPLEX=0;
if ABCOMPLEX_d=-4 then ABCOMPLEX=1;
if ABCOMPLEX_d=4 then ABCOMPLEX=1;
if ABCOMPLEX_d=-2 then ABCOMPLEX=2;
if ABCOMPLEX_d=2 then ABCOMPLEX=2;
if ABCOMPLEX_d=0 then ABCOMPLEX=3; 
*clear out any "I don't know" / missing, per methodology;
if ABDEFECT<0 then ABCOMPLEX=.;
if ABNOMORE<0 then ABCOMPLEX=.;
if ABHLTH<0 then ABCOMPLEX=.;
if ABPOOR<0 then ABCOMPLEX=.;
if ABRAPE<0 then ABCOMPLEX=.;
if ABSINGLE<0 then ABCOMPLEX=.;
if ABCOMPLEX>0 then ABCOMPLEX_="0 conflicted";
if ABCOMPLEX=0 then ABCOMPLEX_="1 polarized";

*######################################################################;
*Figure 6.10: Assisted Suicide
*######################################################################;


						LETDIE1_="123456789012345678901234567890";
	if LETDIE1=1 then 	LETDIE1_="1 Yes, can die if P wants";
	if LETDIE1=2 then 	LETDIE1_="0 No, can die if P wants";
	if	 				LETDIE1_="123456789012345678901234567890" then 
						LETDIE1_="";

							SUICIDE1_="123456789012345678901234567890";
	if SUICIDE1_=1 then 	SUICIDE1_="1 Yes, suicide ok if disease";
	if SUICIDE1_=2 then 	SUICIDE1_="0 No, suicide ok if disease";
	if	 					SUICIDE1_="123456789012345678901234567890" then 
							SUICIDE1_="";
	if SUICIDE1_="" & SUICIDE1G=1 then SUICIDE1_="1 Yes, suicide ok if disease";
	if SUICIDE1_="" & SUICIDE1G=2 then SUICIDE1_="0 No, suicide ok if disease";

							SUICIDE2_="123456789012345678901234567890";
	if SUICIDE2_=1 then 	SUICIDE2_="1 Yes, suicide ok if bankrupt";
	if SUICIDE2_=2 then 	SUICIDE2_="0 No, suicide ok if bankrupt";
	if	 					SUICIDE2_="123456789012345678901234567890" then 
							SUICIDE2_="";
	if SUICIDE2_="" & SUICIDE2G=1 then SUICIDE2_="1 Yes, suicide ok if bankrupt";
	if SUICIDE2_="" & SUICIDE2G=2 then SUICIDE2_="0 No, suicide ok if bankrupt";

							SUICIDE3_="12345678901234567890123456789012345";
	if SUICIDE3_=1 then 	SUICIDE3_="1 Yes, suicide ok if dishonored";
	if SUICIDE3_=2 then 	SUICIDE3_="0 No, suicide ok if dishonored";
	if	 					SUICIDE3_="12345678901234567890123456789012345" then 
							SUICIDE3_="";
	if SUICIDE3_="" & SUICIDE3G=1 then SUICIDE3_="1 Yes, suicide ok if dishonored";
	if SUICIDE3_="" & SUICIDE3G=2 then SUICIDE3_="0 No, suicide ok if dishonored";

							SUICIDE4_="123456789012345678901234567890";
	if SUICIDE4_=1 then 	SUICIDE4_="1 Yes, suicide ok if tired";
	if SUICIDE4_=2 then 	SUICIDE4_="0 No, suicide ok if tired";
	if	 					SUICIDE4_="123456789012345678901234567890" then 
							SUICIDE4_="";
	if SUICIDE4_="" & SUICIDE4G=1 then SUICIDE4_="1 Yes, suicide ok if tired";
	if SUICIDE4_="" & SUICIDE4G=2 then SUICIDE4_="0 No, suicide ok if tired";
*######################################################################;
*Figure 6.11: Capital Punishment
*######################################################################;
							CAPPUN_="12345678901234567890123456789012345";
	if CAPPUN=1 then 		CAPPUN_="1 Favor: capital punishment";
	if CAPPUN=2 then 		CAPPUN_="0 Oppose: capital punishment";
	if	 					CAPPUN_="12345678901234567890123456789012345" then 
							CAPPUN_="";

if Latino=1 & Y_RELTRAD3="Catholic" then temp_cath=1;
if Latino=0 & Y_RELTRAD3="Catholic" then temp_cath=2;
if RELTRAD3^="Catholic" & temp_cath=1 then LW_leavers="Latino Cath leaver";
if RELTRAD3^="Catholic" & temp_cath=2 then LW_leavers="White Cath leaver";

/*Chapter 7 recodes*/

if PARTYID=3 | PARTYID=7 then PARTYID_="3 Independent or Other";
if PARTYID=0 | PARTYID=1 | PARTYID=2 then PARTYID_="1 Democrat";
if PARTYID=4 | PARTYID=5 | PARTYID=6 then PARTYID_="2 Republican";

if COURTSNV=2 then COURTS_="Not harshly enough";
if COURTSNV=1 then COURTS_="Too harshly";
if COURTSNV=3 then COURTS_="About right";
if COURTSV=2 then COURTS_="Not harshly enough";
if COURTSV=1 then COURTS_="Too harshly";
if COURTSV=3 then COURTS_="About right";
if COURTS_="" & COURTS=1 then COURTS_="Too harshly";
if COURTS_="" & COURTS=2 then COURTS_="Not harshly enough";
if COURTS_="" & COURTS=3 then COURTS_="About right";

if GRASSV=2 then GRASS_="MJ should NOT be legal";
if GRASSV=1 then GRASS_="MJ should be legal";
if GRASSNV=2 then GRASS_="MJ should NOT be legal";
if GRASSNV=1 then GRASS_="MJ should be legal";
if GRASS_="" & GRASS=1 then GRASS_="MJ should be legal";
if GRASS_="" & GRASS=2 then GRASS_="Should not be legal";

if RELTRAD3^=Y_RELTRAD3 then leaver=1;
if RELTRAD3=Y_RELTRAD3 then leaver=0;
if RELTRAD3="" then leaver=.;
if Y_RELTRAD3="" then leaver=.;
if Y_RELTRAD3="Catholic" & leaver=1 then leaver_cat="1 Cath leaver";
if Y_RELTRAD3="Conservative" & leaver=1 then leaver_cat="3 CP leaver";
if Y_RELTRAD3="Mainline" & leaver=1 then leaver_cat="2 MP leaver";
if Y_RELTRAD3="None" & leaver=1 then leaver_cat="4 None leaver";
if Y_RELTRAD3="Other" & leaver=1 then leaver_cat="5 Oth leaver";

/*Chapter 8 recodes*/
if FEJOBAFF=3 | FEJOBAFF=4 then FEJOBAFF_="Oppose giving women employment preference";
if FEJOBAFF=1 | FEJOBAFF=2 then FEJOBAFF_="Favor giving women employment preference";
if FEFAM=3 | FEFAM=4 then FEFAM_="Disagree: Not better if man works and woman stays home";
if FEFAM=1 | FEFAM=2 then FEFAM_="Agree: Better if man works and woman stays home";
if FECHLD=3 | FECHLD=4 then FECHLD_="Disagree: working mom cannot be a good mom";
if FECHLD=1 | FECHLD=2 then FECHLD_="Agree: working mom can be a good mom";
if FEPRESCH=3 | FEPRESCH=4 then FEPRESCH_="Disagree or strongly D: a tot will not suffer if mom works";
if FEPRESCH=1 | FEPRESCH=2 then FEPRESCH_="Agree or strongly A: a tot will suffer if mom works";

if INCGAP=3 | INCGAP=4 | INCGAP=5 then INCGAP_="Not agree: income gap is not too large";
if INCGAP=1 | INCGAP=2 then INCGAP_="Agree: income gap is too large";

if AFFRMACT=3 | AFFRMACT=4 then AFFRMACT_="Oppose giving blacks employment preference";
if AFFRMACT=1 | AFFRMACT=2 then AFFRMACT_="Favor giving blacks employment preference";
if TAXSHARE=2 | TAXSHARE=3 | TAXSHARE=4 | TAXSHARE=5 then TAXSHARE_="Rich should pay less than much larger share of taxes";
if TAXSHARE=1 then TAXSHARE_="Rich should pay much larger share of taxes";
if TRDUNIO1=3 | TRDUNIO1=4 | TRDUNIO1=5 then TRDUNIO1_="OtherThan agree or strongly agree that workers need unions";
if TRDUNIO1=1 | TRDUNIO1=2 then TRDUNIO1_="Agree & strongly agree that workers need unions";

if EQWLTH=7 | EQWLTHY=7 then EQWLTH_="7 The gov should not reduce INCGAP";
if EQWLTH=1 | EQWLTHY=1 then EQWLTH_="1 The gov should reduce INCGAP";
if EQWLTH=2 | EQWLTHY=2 then EQWLTH_="2";
if EQWLTH=3 | EQWLTHY=3 then EQWLTH_="3";
if EQWLTH=4 | EQWLTHY=4 then EQWLTH_="4";
if EQWLTH=5 | EQWLTHY=5 then EQWLTH_="5";
if EQWLTH=6 | EQWLTHY=6 then EQWLTH_="6";

if TRUSTV=2 | TRUSTNV=2 then TRUST_="Can't be too careful";
if TRUSTV=1 | TRUSTNV=1 then TRUST_="Can't trust people";
if TRUSTV=3 | TRUSTNV=3 then TRUST_="Depends";

if CONPHARVACY=1 | CONPHARVAC=1 then CONPHARVAC_="A great deal of confidence";
if CONPHARVACY=2 | CONPHARVAC=2 then CONPHARVAC_="Only some confidence";
if CONPHARVACY=3 | CONPHARVAC=3 then CONPHARVAC_="Harldly any confidence";

if CONFEDVACY=1 | CONFEDVAC=1 then CONFEDVAC_="A great deal of confidence";
if CONFEDVACY=2 | CONFEDVAC=2 then CONFEDVAC_="Only some confidence";
if CONFEDVACY=3 | CONFEDVAC=3 then CONFEDVAC_="Harldly any confidence";

if Y_RELTRAD3="Catholic" & RELTRAD3^="Catholic" then C_leaver="left Catholicism";
if Y_RELTRAD3="Catholic" & RELTRAD3="Catholic" then C_leaver="stayed Catholic";

run;
data GSS.temp1; set WORK.temp1; run;

/*
proc freq data=temp1;
table New_Trad * generation_; 
weight WT_ONE;
where year=2021; 
run;
