
                                          /*GETTING DATA INTO SAS SYSTEM & SUBSETTING*/

Proc import datafile='data\stock_returns_base150.csv' dbms=csv out=Raw_data;
run; /*Importing Raw Data File into SAS and storing it in the name of Raw_data*/

data Mod_Data;
  set Raw_data;
  input ID; /* Adding input ID to help segregate the Train and Test data */ 
  datalines; 
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
run;

data Train_data Test_data;
set Mod_data;
if ID le 50 then output Train_data;
else output Test_data;
run;  /* Subseting the modified data into Training and Test data*/

Proc Print Data=Train_data;
title 'TRAINING DATA';
run; /* printing the Trainig Data*/

Proc Print Data=Test_data;
title 'TESTING DATA';
run;/* printing the Testing Data*/
                                                       
 
                                                       /*AUTOMATIC VARIABLE SELETION*/

proc reg data=Train_data; /*FORWARD SELECTION METHOD*/
FORWARD: model S1= S2 S3 S4 S5 S6 S7 S8 S9 S10 /selection=forward SLENTRY=0.10 vif; /*Increasing the Significance level in steps of 0.05, 
Does not affect R(Squared) as there is an increment of less than 0.1% in R(Squared)/Adj R(Squared)for every other variable included */ 
title 'Forward Regression Method for Variable Selection'; 
run;
quit;


proc reg data=Train_data; /*BACKWARD SELECTION METHOD*/
BACKWARD: model S1= S2 S3 S4 S5 S6 S7 S8 S9 S10/selection=backward SLSTAY=0.10 vif; /*Increasing the Significance level in steps of 0.05, 
Does not affect R(Squared) as there is an increment of less than 0.1% in R(Squared)/Adj R(Squared)for every other variable included */ 
title 'Backward Regression Method for Variable Selection'; 
run;
quit;

proc reg data=Train_data; /*STEPWISE SELECTION METHOD*/
STEPWISE: model S1= S2 S3 S4 S5 S6 S7 S8 S9 S10/selection=stepwise  SLENTRY=0.10 SLSTAY=0.10 vif; /*Increasing the Significance level in steps of 0.05, 
Does not affect R(Squared) as there is an increment of less than 0.1% in R(Squared)/Adj R(Squared)for every other variable included*/ 
title 'Stepwise Regression Method for Variable Selection'; 
run;
quit;




 /*MODEL TRAINING*/
/*Final Model with the Significant Variables*/
proc reg data=Train_data outest=Reg_Out;
S1_Predicted: model S1= s2 s6 s8;
title 'Model with the significant variables'; 
run;

/*Printing Data Set from the Proc REG Procedure*/
 proc print data=Reg_Out;
 title2 'OUTEST= Data Set from PROC REG';
 run;



 /*MODEL VALIDATION using Regression estimates*/
proc score data=Train_data score=Reg_Out out=RScore_Pred type=parms;
 var s2 s6 s8;
run;
   
 proc print data=RScore_Pred;
  title2 'Predicted Scores for S1 using the Training data';
 run;


 /*MODEL TESTING using the Testing data with missing values for S1*/
 proc score data=Test_data score=Reg_Out out=NewPred type=parms nostd predict;
   var s1 s2 s6 s8;
 run;

 /*Printing The Final Predited values of missing S1 values*/
 proc print data=NewPred;
    title2 'Predicted Scores for Regression';
    title3 'for Additional Data having blank values for S1 ';
 run;



                              /*SUMMARIZING RESULTS*/

/* Retaining only newly predicted values for S1 and date*/
data predictions (keep= Date Value);
rename S1_Predicted=value;
set NewPred;
run;
/* Printing the Subset data*/
Proc Print Data=predictions;
title ' Required Data';
run;


/* Exporting the predicted data into a CSV file*/
proc export data=predictions outfile='predictions.csv' dbms=csv replace;
run;




/*********************************END******************************************/



