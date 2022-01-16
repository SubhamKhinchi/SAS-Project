/* Question 1. */
/* Import all the 4 files in SAS data environment */
/*================= Import datafiles */
proc import datafile='Datasets/Agent_Score.csv' out= agent_score dbms=csv;
run;
proc import datafile='Datasets/Online.csv' out= online dbms=csv;
run;
proc import datafile='Datasets/Roll_Agent.csv' out= roll_agent dbms=csv;
run;
proc import datafile='Datasets/Third_Party.csv' out= third_party dbms=csv;
run;





/*Question 2. */
/* Create one dataset from all the 4 dataset? */
/* Alter the column length same for all acq_chnl variable */
proc sql;
	alter table online modify acq_chnl char(14);
quit;

proc sql;
	alter table third_party modify acq_chnl char(14);
quit;

/* Appending */
data customer;
set online roll_agent third_party;
run;





/*--------------------------------------- LEFT JOIN -------------------------------------------*/
/* Let's sort our datasets by variable we will be using for merging */
proc sort data=customer;
by agentid;
run;
proc sort data=agent_score;
by agentid;
run;

/* Merging */
data customer_agent;
merge customer(in=x) agent_score(in=y);
by agentid;
if x;
run;
/*------------------------------------------------------------------------------------------  */





/*Question 3. */
/* Remove all unwanted ID variables? */
data customer_agent (drop=hhid custid agentid proposal_num policy_num);
set customer_agent;
run;





/*Question 4. */
/* Calculate annual premium for all customers? */
data customer_agent;
set customer_agent;
if payment_mode = 'Annual' then annual_premium = premium;
else if payment_mode = 'Semi Annual' then annual_premium = 2*premium;
else if payment_mode = 'Quaterly' then annual_premium = 4*premium;
else if payment_mode = 'Monthly' then annual_premium = 12*premium;
run;





/*Question 5. */
/* Calculate age and tenure as of 31 July 2020 for all customers? */
/* Age of customer */
data customer_agent;
set customer_agent;
customer_age = intck('year',dob,'31jul2020'd);/*date function used to find difference between dates*/
run;

/* Tenure in months from policy date */
data customer_agent;
set customer_agent;
tenure_period = intck('month',policy_date,'31jul2020'd);
run;





/*Question 6. */
/* Create a product name by using both level of product information. */
/* Let's extract the product name using substring method*/
data customer_agent;
set customer_agent;
product_name = substr(product_lvl2,6,length(product_lvl2)-5);
run;

/*Let's concat product_lvl1 and product name to get the Final Product Name */
data customer_agent(drop=product_lvl2);
set customer_agent;
final_product = cats(product_lvl1,"_",product_name);
run;





/*Question 7. */
/* After doing clean up in your data, you have to calculate the distribution of customers across product and policy status? */
proc freq data=customer_agent;
tables
	final_product*policy_status /nofreq;
run;





/*Question 8. */
/* Calculate Average annual premium for different payment mode and interpret the result? */
proc summary print mean data = customer_agent NONOBS;
class payment_mode;
var annual_premium;
run;





/*Question 9. */
/* Calculate Average persistency score, no fraud score and tenure of customers across product and policy status, and interpret the result? */
proc summary print mean data = customer_agent NONOBS;
class final_product policy_status;
var Persistency_Score NoFraud_Score tenure_period;
run;





/*Question 10. */
/* Calculate Average age of customer across acquisition channel and policy status, and interpret the result? */
proc summary print mean data=customer_agent NONOBS;
class acq_chnl policy_status;
var customer_age;
run;












