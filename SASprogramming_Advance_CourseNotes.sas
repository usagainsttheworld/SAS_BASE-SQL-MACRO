/*Performing queries using PROC SQL */
Proc sql; /* do not forget the semicolon */
	select ActLevel, Age, KgWgt, MeterHgt,
			kgwgt/meterhgt**2 as BodyMass
		from Sasuser.Newadmit
		where sex = 'F'
		order by ActLevel;
quit;

/*join two set using Proc sql*/
Proc sql;
	select therapy1999.month, walkjogrun, swim,
			treadmill, newadmit, 
			walkjogrun+swim as Exercise
		from sasuser.therapy1999, sasuser.totals2000
		where therapy1999.month = totals2000.month; /* do not forget the semicolon */
quit;

/*summarize and group data using Proc sql*/
Proc sql;
	select sex, 
			avg(age) as averageage, 
			avg(weight) as averageweight
		from sasuser.diabetes
		group by sex;
quit;

/*ceate table to store the result*/
Proc sql;
	create table Sas_base.ave_diabete as
	select sex, 
			avg(age) as averageage, 
			avg(weight) as averageweight
		from sasuser.diabetes
		group by sex;
quit;

/* subseting-Having*/
proc sql;
	select jobcode,avg(salary) as Avg
		from sasuser.payrollmaster
		group by jobcode
		having avg(salary)>40000
		order by jobcode;
quit;
/************************************************/
/*Performing Advanced queries using Proc SQL*/

/*  members whose last name is spelled like SANDERS or SAUNDERS. 
You also want the output to include any program 
members whose last name contains one or more 
additional letters at the end (such as SANDERSON). */
Proc sql;
	select name, ffid
	from sasuser.frequentflyers
	where Name like 'SA%NDERS%, %'
	order by names;

/*select all obs and get col list in log */
proc sql outobs=10 feedback;
	select *
	from sasuser.marchflights 
	order by flightnumber;
quit;

/*unique obs*/
proc sql;
	select distinct flightnumber
	from sasuser.marchflights 
	order by flightnumber;
quit;

/*calculated + new var*/
proc sql;
	select flightnumber, date, destination,
		sum(boarded, transferred, nonrevenue) as Total, passengercapacity
	from sasuser.marchflights 
	where calculated Total < passengercapacity/3
	order by Total;
quit;

*between and;
proc sql;
	select flightnumber, date, destination,
		sum(boarded, transferred, nonrevenue) as Total, passengercapacity
	from sasuser.marchflights 
	where calculated Total between 0 and 50
	order by Total;
quit;

*add title and format to var;
proc sql;
title 'Federal Taxes';
title2 'Male Employees with Payroll Changes';
	select empid label= 'Employee ID Number', 
			gender, jobcode, 
			salary format = comma9.2,
			salary/3 as Tax format = comma9.2
	from sasuser.payrollchanges
	where gender = 'M'
	order by jobcode;
quit;
title;

*summarizing and group data;
proc sql;
title'Number of Employees in Each City';
	select state, city, count(*) as Employees
	from sasuser.staffmaster
	group by state,city;
quit;
title;

*subseting data within group;
proc sql;
title Total Miles Traveled for States;
title2 with Fewer Than 5 Members;
	select state, 
			sum(milestraveled) as TotTravelMiles,
			count(*) as Members
	from sasuser.frequentflyers	
	group by state
	having Members < 5
	order by state;
quit;
title;

*subsetting data by using noncorrelated subqueries;
proc sql;
	select empid, jobcode, salary
	from sasuser.payrollchanges
	where salary < 
		(select avg(salary)
			from sasuser.payrollmaster)
	order by empid;
quit;

proc sql;
title 'Contact Information for Level 3 Mechanics';
	select empid, lastname, firstname, phonenumber
		from sasuser.staffmaster
		where empid in 
			(select empid
				from sasuser.mechanicslevel3)
	order by lastname;
quit;
title;

proc sql;
title 'Employees with February Anniversaries';
	select firstname, lastname, state
		from sasuser.staffmaster
		where empid in 
			(select empid
				from sasuser.payrollmaster 
				where month(dateofhire) = 2)
	order by lastname;
quit;

proc sql;
title 'Employees with February Anniversaries';
title2 'by State';
	select state, count(empid) as Employees
		from sasuser.staffmaster
		where empid in 
			(select empid
				from sasuser.payrollmaster 
				where month(dateofhire) = 2)
	group by state;
	order by lastname;
quit;

*Correlated subquery--using "exists"!!!!!;
*Create a PROC SQL query to list all frequent-flyer program 
members who are also airline employees;
proc sql;
title 'Frequent Flyers Who Are Employees';
	select name
		from sasuser.frequentflyers
		where exists
			(select * 
				from sasuser.staffmaster
				where name=trim(lastname)||', '||firstname)
	order by name;
quit;

*list all frequent-flyer program members who are not employees;
proc sql;
title 'Frequent Flyers Who Are not Employees';
	select name
		from sasuser.frequentflyers
		where not exists
			(select * 
				from sasuser.staffmaster
				where name=trim(lastname)||', '||firstname)
	order by name;
quit;

*Display total number of frequent-flyer program members 
 who are not employees;
proc sql;
title 'Frequent Flyers Who Are not Employees';
	select count(*) as Count
		from sasuser.frequentflyers
		where not exists
			(select * 
				from sasuser.staffmaster
				where name=trim(lastname)||', '||firstname);
quit;
title;

*quiz notes:
 where clause before group by
 having clause after group by;

/*****************************************************/
*inner join;
proc sql;
	select r.student_name, student_company,
	city_state, course_number, paid
		from sasuser.register r, sasuser.students s
		where r.student_name=s.student_name;
quit;

*date transform using 'ddMMMYYYY'd, 'calculated' keyword in where clause;
proc sql;
	title 'Employees with more than 20 years of service';
	select lastname, firstname, jobcode, dateofhire, 
			int(('01jan2001'd-dateofhire)/365.25) as Years
		from sasuser.staffmaster s, sasuser.payrollmaster p
		where s.empid=p.empid 
			and calculated Years >20
		order by lastname;
quit;
	
proc sql;
	title 'Employees with more than 20 years of service';
	select jobcode, count(s.empid) as Employees
		from sasuser.staffmaster s, sasuser.payrollmaster p
		where s.empid=p.empid 
			and int(('01jan2001'd-dateofhire)/365.25) >20
		group by jobcode;
		order by jobcode;
quit;
title;

*left join, 'f.*', ;
proc sql;
title 'All Scheduled Employees';
title2 'and Any Payroll Changes';
	select f.*, jobcode, salary as NewSalary
		from sasuser.flightschedule f 
		left join 
		sasuser.payrollchanges p
		on f.empid=p.empid
	order by jobcode;
quit;

*right join, on'...and...';
proc sql;
title 'All Employees with Payroll Changes';
title2 'and Any Flight 622 Assignments';
	select p.empid, jobcode, salary as NewSalary,
			flightnumber, date as Flightdate
		from sasuser.flightschedule f 
		right join 
		sasuser.payrollchanges p
		on f.empid=p.empid and flightnumber = '622'
	order by p.empid;
quit;

*full join is diffrent than join;
proc sql;
title 'All Employees with Payroll Changes';
title2 'Their Flight Assignments (if any)';
title3 'and all Scheduled Flights';
	select p.empid, jobcode, salary as NewSalary,
			flightnumber, date as Flightdate
		from sasuser.flightschedule f 
		full join 
		sasuser.payrollchanges p
		on f.empid=p.empid 
	order by 4;
quit;
title;

*Combine three tables, all common col has to be equare;
proc sql outobs=20;
title 'Flight and Crew Schedule';
	select f.FlightNumber as FltNum, f.date, 
			s.firstname, s.lastname, s.empid,
			m.departuretime as DepTime, m.destination as Dest
			from sasuser.staffmaster s, sasuser.flightschedule f,
				sasuser.marchflights m
			where s.empid=f.empid and f.flightnumber=m.flightnumber
					and f.date=m.date
			order by 1,2,4,3;
quit;
title;

/****************************************************/
*combining tables vertically;
*EXCEPT;
proc sql;
	select empid, lastname, division, location
		from sasuser.empdata 
	except 
	select empid, lastname, division, location
		from sasuser.allemps;
quit;

*Intersect;
proc sql;
	select empid, lastname, division, location
		from sasuser.empdata
	intersect
	select empid, lastname, division, location
		from sasuser.allemps;
quit;

*Outer union to concatenate tables;
proc sql;
	select * from sasuser.therapy1999
	union 
	select * from sasuser.therapy2000;
quit;

proc sql;
	select * from sasuser.therapy1999
	outer union corr
	select * from sasuser.therapy2000;
quit;

/*****************************************************/
*Insert raw data into a table;
proc sql;
	insert into work.production(title, pages)
		values('Train Your Goldfish', 555);

*insert rows of data, and join the temporary table with the existing table;
proc sql;
	create table work.awards
				(PtsReqd num label='Points Required',
				Rank num format=3., 
				Award cha(25));
quit;
proc sql;
	insert into work.awards (PtsReqd, Rank, Award)
		values(2000, 1, 'free night in hotel')
		values(10000, 2, '50% discount on flight')
		values(20000, 3, 'free domestic flight')
		values(40000, 4, 'free international flight');
quit;		
proc sql;
	select *
		from work.awards;
quit;
proc sql;
title 'Awards for AZ Frequent Flyers';
	select ffid, name, 
			PointsEarned-PointsUsed as availablePoints,
			Award
		from work.awards, sasuser.frequentflyers
		where calculated availablepoints >=ptsreqd
			and state='AZ'
		order by 1;
quit;

*integrity constraints, undo_policy=option;
proc sql;
	create table work.campers
	(CampID num label='Camper ID',
		FName Char(10),
		LName Char(15),
		DOB num format=date9.,
		constraint unique_id unique(campid));
quit;
*display information about the table's integrity constraints;
Proc sql; 
	describe table constraints work.campers;
quit;
*load the following rows of data into the table;
* when the same rows are submitted for insertion into the table, 
PROC SQL will insert the rows that meet the constraint 
and skip any rows that do not;
proc sql undo_policy=none;
   insert into work.campers
       set campid=1001,fname='Mara',
           lname='Tolerud',dob='17JUL1993'd
       set campid=1002,fname='Kino',
           lname='Parks',dob='22SEP1995'd
       set campid=1002,fname='Adele',
           lname='Ruiz',dob='01DEC1992'd;
quit;
proc sql;
	select *
	from work.campers;
quit;

*create table from existing table using 'as', 
 update rows using 'set''case';
proc sql;
	create table work.newadmit2 as
		select id, name, sex, age, weight, actlevel
			from sasuser.newadmit;
	select *
		from work.newadmit2;
quit;
*increase the values for Weight by 2% in all of 
  the rows in Work.Newadmit2;
proc sql;
	update work.newadmit2 
		set weight=weight *1.02;
	select *
		from work.newadmit2;
quit;
proc sql;
	update work.newadmit2
		set actlevel=
			case actlevel
				when 'LOW' then '1'
				when 'MOD' then '2'
				when 'HIGH' then '3'
			end;
	select *
		from work.newadmit2;
quit;

* creates a new table by copying 
 the rows of existing table;
proc sql;
	create table work.newadmit3 as
		select *
			from sasuser.newadmit;
	select *
		from work.newadmit3;
quit;
* creates a new table by copying only the 
  column structure of existing table;
proc sql;
   create table work.newadmit3
      like sasuser.newadmit;
   describe table work.newadmit3;
quit;

*alter and drop col in the talbe;
proc sql;
	alter table work.newadmit3
		drop Height,Weight,Actlevel
		modify Fee label='Admit Fee'
		add Pulse num format=3.;
	describe table work.newadmit3;
quit;
 *drop the table Work.Newadmit3;
proc sql;
	drop table work.newadmit3;
quit;

/******************************************/
*managing indexes using proc sql;
*creat table by copying all col and rows;
proc sql;
	create table work.staffmaster as
		select *
			from sasuser.staffmaster;
quit;
*create a simple unique index on tabel;
proc sql;
	create unique index Lastname
		on work.staffmaster(Lastname);
quit;
*create a simple non-unique index;
proc sql;
	create index Lastname
		on work.staffmaster(Lastname);
quit;
* display index specifications ;
proc sql;
	describe table work.staffmaster;
quit;

*monitor the use of index;
option msglevel=i;
proc sql;
   select *
      from work.staffmaster
      where lastname contains 'AR';
quit;
*process query without using the index;
proc sql;
   select *
      from work.staffmaster (idxwhere=no)
      where lastname contains 'AR';
quit;
*set SAS log displays notes, warnings, and error messages only;
option msglevel=n;
*drop index;
proc sql;
	drop index Lastname
		from work.staffmaster;
quit;

/********************************************/
*create proc sql view;
proc sql;
	select empid, lastname, 
			firstname, phonenumber 
		from sasuser.staffmaster
		where city ='NEW YORK';
quit;
* save the query as a PROC SQL view;
proc sql;
	create view sasuser.myview as
		select empid, lastname, 
			firstname, phonenumber 
		from sasuser.staffmaster
		where city ='NEW YORK';
quit;
*displays all columns from Sasuser.Myview;
proc sql;
	select *
		from sasuser.myview;
quit;
proc sql;
	describe view sasuser.myview;
quit;

*update and drop a proc sql view;
proc sql;
   create view sasuser.mechview as 
      select id, lastname, firstname, 
             int((today()-hired)/365.25)
             as YearsEmployed, city
         from mechanics;
quit; 
*updated view includes only the rows where City is equal to NEW YORK;
proc sql;
	delete from sasuser.mechview
		where city ne 'NEW YORK';
quit;
proc sql;
	select *
		from sasuser.mechview;
quit;
proc sql;
	drop view sasuser.mechview;
quit;

/*************************************************/
*managing processing using PROC SQL;
*Prevents PROC SQL from taking more than 10 rows from 
 any single source as input;
proc sql inobs=10;
   select ffid, name, pointsused
      from sasuser.frequentflyers
      where membertype='GOLD' and pointsused>0
      order by pointsused;
quit;

*Add an option to specify that the output contains 
  a column with row numbers;
proc sql number;
   select flightnumber, date, destination,
          sum(boarded, transferred, nonrevenue)
          as Total
      from sasuser.marchflights
      where destination="LAX";
quit;

*Compare the timing information for two queries;
proc sql stimer;
   select empid, jobcode, dateofbirth
      from sasuser.payrollmaster
      where jobcode in ('FA1','FA2')
            and dateofbirth < any          
               (select dateofbirth
                   from sasuser.payrollmaster
                   where jobcode='FA3');
   select empid, jobcode, dateofbirth      
      from sasuser.payrollmaster
      where jobcode in ('FA1','FA2')
            and dateofbirth < all
               (select dateofbirth
                   from sasuser.payrollmaster
                   where jobcode='FA3');   
quit;

*Reset PROC SQL options without re-invoking the SQL procedure;
proc sql inobs=10;   
   select lastname, firstname, state     
      from sasuser.staffmaster    
      where state='NY';
   reset inobs=number;
   select lastname, firstname, state
      from sasuser.staffmaster
      where state='CT';
   quit;

*Use a Dictionary table to display information about the 
   tables stored in the Sasuser library;
proc sql;
	describe table dictionary.columns;
quit;
proc sql;
	select memname, varnum
		from dictionary.columns
		where libname='SASUSER'
			and name='JobCode';
quit;

/***********************************/
*Macro Variables;
*Use and display automatic macro variables;
proc print data=sasuser.all noobs label uniform;
   where student_name contains 'Babbit';
   by student_name student_company;
   var course_title begin_date location teacher;
   title 'Courses Taken by Selected Students:';
   title2 'Those with Babbit in Their Name';
   footnote "Report Created on &sysdate9";
run;

*Define and use macro variables;
footnote;
%let pattern = Ba;
proc print data=sasuser.all noobs label uniform;
   where student_name contains "&pattern";
   by student_name student_company;
   var course_title begin_date location teacher;
   title 'Courses Taken by Selected Students:';
   title2 "Those with &pattern in Their Name";
run;

*Display resolved macro variables in the SAS log;
options symbolgen;
%let num=8;
proc print data=sasuser.all label noobs n;
   where course_number = #
   var student_name Student_Company;
   title "Enrollment for Course &num";
run;

options nosymbolgen;
%let num=8;
proc print data=sasuser.all label noobs n;
   where course_number = #
   var student_name Student_Company;
   title "Enrollment for Course &num";
   %put the value of macro var num is: &num;
run;


*use macro quoting funciton;
%let pattern=%str(O%'Savio); * %STR (%');
proc print data=sasuser.all noobs label uniform;
   where student_name contains "&pattern"; *"";
   by student_name student_company;
   var course_title begin_date location teacher;
   title 'Courses Taken by Selected Students:';
   title2 "Those with &pattern in Their Name";*"";
run;

*macro charactor function;
%let dsn=SASUSER.SCHEDULE;
title;
proc sort data=&dsn out=work.sorted;
   by course_number begin_date;
run;
title "Variables in &dsn";
proc sql;
   select name, type, length
      from dictionary.columns
      where libname="%upcase(%scan(&dsn,1,.))" and
            memname="%upcase(%scan(&dsn,2,.))";
quit;


%let dsn=&syslast;
title;
proc sort data=&dsn out=work.sorted;
   by course_number begin_date;
run;
title "Variables in &dsn";
proc sql;
   select name, type, length
      from dictionary.columns
      where libname="%upcase(%scan(&dsn,1,.))" and
            memname="%upcase(%scan(&dsn,2,.))";
quit;

*;
title;
%let table1 = schedule;
%let table2 = register;
%let joinvar = course_number;
%let freqvar = location;
proc sql;
   select &freqvar,n(&freqvar) label='Count'
      from sasuser.&table1,sasuser.&table2
      where &table1..&joinvar=
            &table2..&joinvar
      group by &freqvar;
quit;

/******************************************/
*Macro Variables at execution time;
*SYMPUT routine;
data practice;
  set sasuser.schedule;
  where location = "Boston";
  call symput ('same_val', 'Hallis, Dr.George');
  call symput ('current_val', Teacher);
run;
  %put same is &same_val;
  %put current is &current_val;

*call symput, put;
options nodate symbolgen;
data _null_;
	call symput('date', put(today(), mmddyy10.));
title "Courses Offered of &date";
proc print data=sasuser.courses;
run;
	
options nodate symbolgen;
data _null_;
	call symput('date', 
			trim(left(put(today(), worddate20.))));
title "Courses Offered of &date";
proc print data=sasuser.courses;
run;

*multiple macro variables, &&macro1&macro2);
data _null_;
	set sasuser.schedule;
	call symput('start'||trim(left(course_number)),
			put(begin_date, mmddyy10.));
run;
%put _user_;

%let crs=9;
proc print data=sasuser.all noobs n;
   where course_number=&crs;
   var student_name student_company;
   title 
     "Roster for Course &crs Beginning on &&start&crs";
run;

*sas var=Symget(macro var);
data unpaid;
	set sasuser.register;
	where paid='N';
	Begin=symget('start'||left(course_number));
run;
title;
proc print data=unpaid;
run;

*creat multiple macro var with SQL procedure;
proc sql;
	select begin_date format=mmddyy10.
		into :begin1-:begin18
		from sasuser.schedule;
quit;
%put _user_;

%let num=4;
proc print data=sasuser.all noobs n;
   where course_number=&num;
   var student_name student_company;
   title1 "Roster for Course &num";
   title2 "Beginning on &&begin&num";
run;

/*******************************************/
*Creating and Using Macro Program(Macros);
%macro prtlast;
	proc print data=&syslast (obs=5);
	title " Listing of &syslast data set";
	run;
%mend;
proc sort data=sasuser.courses out=courses;
     by course_code;
run;
%prtlast
    
proc sort data=sasuser.schedule out=schedule;
     by begin_date;
run;
%prtlast

*Define and execute a macro;
options mcompilenote=all; *to see is compile with no error in log;
%macro Printnum;
proc print data=sasuser.all label noobs n;
   where course_number=&num;
   var student_name student_company;
   title "Enrollment for Course &num";
run;
%mend;
%let num = 6;
%Printnum

*Define and execute a macro, use debugging options;
%macro Printnum;
%*to put comments here;
proc print data=sasuser.all label noobs n;
   	where course_number=&num;
   	var student_name student_company;
   	title "Enrollment for Course &num";
run;
options mprint mlogic;
%mend;
%let num=8;
%Printnum

%macro prtstus(crsnum);
	proc print data=sasuser.all;
		var student_name;
		where course_number=&crsnum;
	run;
%mend;
%prtstus(9)

*macro with positional parameters;
%macro Attend1(opts, start, stop);
%let start=%upcase(&start);
%let stop=%upcase(&stop);
proc freq data=sasuser.all;
   where begin_date between "&start"d and "&stop"d;
   table location / &opts;
   title1 "Enrollment from &start to &stop";
run;
%mend;
*specify the appropriate system options to display the source code 
that is received by the SAS compiler and to track the macro's execution;
options mprint mlogic;
%Attend1(nocum, 01jan2001, 31dec2001)
*specifying a null value for opts;
%Attend1(, 01jan2001, 31dec2001)

*macro with keyword parameters;
%macro Attend2(opts=, start=01jan2001, stop=31dec2001);
%let start=%upcase(&start);
%let stop=%upcase(&stop);
proc freq data=sasuser.all;
   where begin_date between "&start"d and "&stop"d;
   table location / &opts;
   title1 "Enrollment from &start to &stop";
run;
%mend;
options mprint mlogic;
*specifies nocum as a value for opts and that specifies 
default values for both start and stop;
%Attend2(opts=nocum)
%Attend2(opts=nocum nopercent, stop=30jun2001)

*macro with mixed parameter;
%macro Attend3(opts, start=01jan2001,stop=31dec2001);
%let start=%upcase(&start);
%let stop=%upcase(&stop);
proc freq data=sasuser.all;
   where begin_date between "&start"d and "&stop"d;
   table location / &opts;
   title1 "Enrollment from &start to &stop";
run;
%mend;
%Attend3(nocum)
%Attend3(,start=01oct2001)

*Macro nest to create multiple local sysbol tables;
%macro datemvar (frmt=date9.);
	data _null_; *there is a space btw data and _null_!!;
		call symput('today',(put(today(),&frmt)));
	run;
%mend datemvar;

%macro prtrost(num=1);
	%local today;
	%datemvar(frmt=mmddyy10.)
	proc print data=sasuser.all label noobs n;
		where course_number=&num;
		var student_name student_company city_state;
		title1 "Course &num Enrollment
			as of &today";
	run;
%mend prtrost;

options mprintnest mlogicnest;
%prtrost(num=8)

*macro with conditionally process;
data current(drop=diff);
   set sasuser.all;
   if year(begin_date)=2001;
      diff=year(today())-year(begin_date);
      begin_date=begin_date+(365*diff);
run; 

%macro reports;
	proc sort data=work.current out=thisweek;
	   where put(begin_date,monyy7.)=
	         "%substr(&sysdate9,3,7)"
	         and begin_date ge "&sysdate9"d;
	   by begin_date location course_title;
	run;
	proc print data=thisweek noobs n;
		%if &sysday=Friday %then %do;
			proc sort data=work.current out=thisweek;
			   where put(begin_date,monyy7.)=
			         "%substr(&sysdate9,3,7)"
			         and begin_date le "&sysdate9"d;
			   by begin_date location course_title;
			run;
			proc means data=thisweek maxdec=0 sum;
			   by begin_date location course_title;
			   var fee;
			   class paid;
			   title "Revenue for Courses as of &sysdate9";
			run;
		%end;
	    by begin_date location course_title;
	    var student_name student_company paid;
	    title "Course Registration as of &sysdate";
	run;
%mend;	
options mprint mlogic;
%reports

*macro loop;
%macro printlib(lib=SASUSER,obs=5);
	%let lib=%upcase(&lib);
	data _null_;
		set sashelp.vstabvw end=final;
		where libname="&lib";
		call symput('dsname'||left(_n_),trim(memname));
		if final then call symput('totaldsn',_n_);
	run;
	%local i;
	%do i=1 %to &totaldsn;
	  	proc print data = &lib..&&dsname&i (obs=&obs);
		title "Listing of &lib..&&dsname&i Data set"; *has to be "";
		run;
	%end;
%mend printlib;
options mprint;
%printlib(lib=work, obs=5)
*eval and %sysevalf;
%let sal1=25000;
%let sal2=27000;
%let saldiff=%eval(&sal2-&sal1);
%put The salary difference is &saldiff;

%let sal1=25000;
%let sal2=27050.45;
%let saldiff=%sysevalf(&sal2-&sal1); * handle with numeric with period;
%put The salary difference is &saldiff;

/****************************************/
*Storing Macro Programs;
*1.%include!!!!!!;
%macro prtlast;
   %if &syslast ne _NULL_ %then %do;
      proc print data=&syslast(obs=5);
         title "Listing of &syslast data set";
      run;
   %end;
   %else
      %put No data set has been created yet.;
%mend;
*save the above program as an external file named prtlast.sas;
proc sort data=sasuser.courses out=bydays;
	by days;
run;
%include 'C:\Users\mac\Desktop\SAS\prtlast.sas';
%prtlast

*2.save macro as catalog SOURCE entry;
%macro sortlast(sortby);
   %if &syslast ne _NULL_ %then %do;
      proc sort data=&syslast out=sorted;
         by &sortby;
      run;
   %end;
   %else
      %put No data set has been created yet.;
%mend;
*save the above program in SAS catalog sasuser.mymacs as source entry;
filename sortlast catalog 'sasuser.mymacs.sortlast.source';
%include sortlast;
data course1;
	set sasuser.register;
	where course_number=1;
run;
%sortlast(paid)
proc print data=work.sorted;
run;
*display the contents of the Sasuser.Mymacs catalog;
proc catalog cat=sasuser.mymacs;
	contents;
quit;

*3.autocall macros from SAS catalog;
options mautosource mlogic; *must specify mautosource mlogic!!;
proc print data=sasuser.courses;
   title "this title is in %lowcase(LOWERCASE)";
run;

*4.stored compiled macro;
options mstored sasmstore=sasuser; *must specify mstored sasmstore;
%macro printit(dataset)/store;
   proc print data=&dataset(obs=5);
      title "Listing of &dataset data set";
   run;
%mend;
proc catalog catalog=sasuser.sasmacr;
	contents;
quit;
*call the Printit macro ;
option mastored sasmstore=sasuser;
%printit(sasuser.courses)

/*********************************************************/
/*Creating Samples and Index*/
*systematic samle from set with known number of obs;
data Samp1;
	do pickit=1 to 153 by 12;
		set sasuser.sale2000 point=pickit;
		output;
	end;
	stop;
run;

proc print data=work.samp1;
run;

*systematic sample from set with unkown number of obs;
data Samp2;
	do pickit=1 to totobs by 10;
		set sasuser.expenses point=pickit nobs=totobs;
		output;
	end;
	stop;
run;

proc print data=work.samp2;
run;

*random sample with replacement;
data rsamp1 (drop = i);
	do i=1 to 25;
		pickit=ceil(ranuni(0)*totobs);
		set sasuser.salcomps point=pickit nobs=totobs;
		output;
	end;
	stop;
run;
proc print data=work.rsamp1;
run;

*Revise the program so that the sample observations are 
output to two different temporary data sets rather than 
just one. For each sample observation;
data over30 (drop=i) upto30 (drop=i);
	do i=1 to 25;
		pickit=ceil(ranuni(0)*totobs);
		set sasuser.salcomps point=pickit nobs=totobs;
		if salary > 30000 then output over30;
		else output upto30;
	end;
	stop;
run;
proc print data=over30;
title 'Salaries over $30,000';
run;
proc print data=upto30;
title 'Salaries up to $30,000';
run;
title;

*create random sample of set without replacement;
data rsamp2(drop=obsleft sampsize);
	sampsize=25;
	obsleft=totobs;
	do while (sampsize>0);
		pickit+1;
		if ranuni(0) < sampsize/obsleft then do;
			set sasuser.salcomps point=pickit
				nobs=totobs;
			output;
			sampsize=sampsize-1;
		end;
		obsleft=obsleft-1;
	end;
	stop;
run;
proc print data=work.rsamp2;
run;

*create an index;
options msglevel=i;
data sasuser.flighttimes(index=(date Fltdte=(flight date)/unique));
	infile flighttm dlm=",";
	input flight $ depart date;
	format Date date9.;
run;

*use proc dataset to create an index;
proc datasets library=sasuser nolist;
	modify empdata;
	index create hiredate;
	index delete hiredate;
	index create Name=(lastname firstname); *concatenation of ...;
quit;

*create index using Proc sql;
proc sql;
	drop index date from sasuser.expenses;
	create index flightdate
		on sasuser.expenses(flightid, date);
quit;


*view a list of index;
proc contents data=sasuser.flighttimes;
run;
*copies the Sasuser.Flighttimes data set into the Work library;
proc datasets library=sasuser nolist;
	copy out=work;
	select flighttimes;
quit;
*renames Work.Flighttimes to Work.Departures;
proc datasets library= work nolist;
	change flighttimes=departures;
quit;
*lists the contents of the Work.Departures data set;
proc datasets nolist;
	contents data=work.departures;
quit;

/*********************************************/
filename routes (' C:\Users\mac\Documents\My SAS Files\9.3
\route1.dat'
   ' C:\Users\mac\Documents\My SAS Files\9.3
\route2.dat'
   ' C:\Users\mac\Documents\My SAS Files\9.3
\route3.dat');
data work.newroutes;
infile routes;
input RouteID $7. Origin $3. Dest $3.
      Distance 5. Fare1stclass 4. FareBusiness 4.
      FareCoach 4. FareCargo 5.;
run;
proc print data=work.newroutes;
run;

*use FILEVAR= option to concatenate the raw data files Route8.dat, 
Route9.dat, and Route10.dat;
data work.routedata;
   do i = 8, 9, 10;
      nextfile="C:\Users\mac\Documents\My SAS Files\9.3"
               !!compress("\route"!!put(i,2.)!!".dat",' ');
      do until (lastobs);
         infile temp filevar=nextfile end=lastobs;
         input RouteID $7. Origin $3. Dest $3.
               Distance 5. Fare1stclass 4.
               FareBusiness 4. FareCoach 4.
               FareCargo 5.;
      output;
      end;
   end;
   stop;
run;

proc print data=work.routedata;
run;

* use filevar=option and sas date function;
data work.last2 (drop=thisyear lastyear);
   thisyear=year(today());
   lastyear=year(intnx('year',today(),-1));
   do Year = thisyear, lastyear;
      nextfile="C:\Users\mac\Documents\My SAS Files\9.3"
         !!put(year,4.)!!".dat";
      do until (lastobs);
         infile temp filevar=nextfile end=lastobs
            dlm=",";
         input Flight $ Date : date9. Depart $;
      output;
      end;
   end;
   stop;
run;
proc print data=work.last2;
run;

*append data set;
proc append base=sasuser.Y2000
			data=sasuser.quarter4 force;
run;
proc print data=sasuser.y2000;
run;

/******************************************/
*Combning data Horizontally;
*use data step to merge three data sets;
proc sort data=sasuser.empdata out=empdata;
	by empid;
run;
proc sort data=sasuser.newsals out=newsals;
	by empid;
run;
data temp1;
	merge newsals(in=n) empdata(in=e);
	by empid;
	if n and e;
run;
proc sort data=temp1;
	by jobcode;
run;
proc sort data=sasuser.jcodedat out=jcodedat;
	by jobcode;
run;
data jobdata (keep =empid jobcode descript salary newsalary);
	merge temp1(in=t) jcodedat(in=j);
	by jobcode;
	if t and j;
run;
proc print data=jobdata;
run;

*use Proc sql to join three data sets;
proc sql;
   create table jobdata2 as
      select empdata.empid, empdata.salary, 
             newsals.newsalary, jcodedat.jobcode, 
             jcodedat.descript
         from sasuser.empdata, sasuser.newsals, 
              sasuser.jcodedat
         where empdata.empid=newsals.empid
               and jcodedat.jobcode=empdata.jobcode
         order by jobcode, empid;
quit;
proc print data=work.jobdata;
run;

*create a summary data set;
*Name the variable that holds this average value AvgAmt.;
proc means data=sasuser.contrib;
	var amount;
	output out=work.mean mean=avgamt
run;
*DiffAvg should record the difference between each individual 
contribution and the overall average contribution;
data work.diff;
	if _n_=1 then set mean(drop=_type_ _freq_);
	set sasuser.contrib;
	diffavg=round(amount-avgamt, .01);
run;
proc print data=work.diff;
run;

*Create a summary data set, and combine it with detail data 
from the Sasuser.Contrib data set in one DATA step;
data work.diff2(drop=totcont n);
   retain avgamt;
   if _n_=1 then do until(last);
      set sasuser.contrib end=last;
      totcont+amount;
	  *Do not include missing values in AvgAmt;
      if amount ne . then N+1;
      if last then AvgAmt=totcont/n;
   end;
   set sasuser.contrib;
   * do not include observations with a missing value ;
   if amount ne .;
   DiffAvg=round(amount-avgamt, .01);
run;
proc print data=work.diff2;
run;

*use the flight index to combine data;
proc datasets library=sasuser;
   modify flighttimes;
   index create flight;
quit;

data work.newsched;
	set sasuser.newtimes;
	set sasuser.flighttimes key=flight;
	newdepart=sum(timediff*60, depart); 
	*depart is SAS time value(number of seconds since midnight;
	format newdepart time5.;
run;
*revise the program to use _IORC_ to detect data errors;
data work.newsched;
	set sasuser.newtimes;
	set sasuser.flighttimes key=flight;
	if _iorc_=0 then do;
		newdepart=sum(timediff*60, depart); 
		output work.newsched;
	end;
	else do;
		_error_=0;
		output work.errors;
	end;
	format newdepart time5.;
run;
proc print data=work.newsched;
run;
proc print data=work.errors;
run;

/******************************************/
*Use lookup table to match data;
*use a table and two-dimensional array to determine the score;
data work.results;
	array award {3,4}_temporary_
		(65,55,45,35,80,70,60,50,70,60,50,40);
	set sasuser.compete;
	score=award{Event, finish};
run;
proc print data=work.results;
run;

*create array in data set;
data work.wndchll2;
title 'Work.Wndchll2';
data work.wndchll2(keep = flight temp wspeed chill);
   array wc{8,9} _temporary_; 
   if _n_ = 1 then do i = 1 to 8; 
      set sasuser.wchill;
      array tmp{9} TmpNeg10 -- Temp30;
      do j = 1 to 9;
         wc{i,j}= tmp{j};
      end;
   end;
   set sasuser.flights2;
   row = round(wSpeed,5)/5;
   column = (round(temp,5)/5)+3;
   Chill = wc{row,column}; 
run;
proc print data = work.wndchll2;
run;

*use proc transpose;
proc transpose data=sasuser.econtrib 
	out=work.tcontrib
	name=QtrNum
	prefix=Amount;
	by empid;
run;
proc print data=work.tcontrib;
run;
 
/********************************************/
*Formatting Data;
*create a multilabel format;
proc format;
   value skicond (multilabel)
         0-4='Poor'
         4<-7='Fair'
         7<-10='Good'
         10<-high='Excellent'
         .='Check Data'
         0-4='Lift 3 Closed'
         4<-high='All Lifts Open';
run;

*create a picture format;
proc format;
   picture newdate
           low-high='%b %Y   '(datatype=date);
   picture cargo
           low-70000='99,999 Below Capacity';
run;
proc print data=sasuser.cargo99;
format date newdate. cargowgt cargo.;
run;

*manage format using pro catalog;
proc format lib=work fmtlib;
run;
proc catalog catalog=work.formats;
	copy out=sasuser.formats;
	select newdate.format cargo.format;
run;
quit;

*custom format;
proc copy in=sasuser out=work;
   select dnunder;
run;
proc format library=sasuser;
   value $regions
         '0000102'-'0000103'='Region1'
         '0000104'-'0000105'='Region2'
         '0000106'-'0000107'='Region3'
                   '0000108'='Region4'
                       other='Unknown';
run;
options fmtsearch=(sasuser);
proc print data=sasuser.dnunder;
	format routeid $regions.;
run;
*assigns the $REGIONS. format to the 
variable RouteID in the Work.Dnunder data set;
proc datasets nolist;
	modify dnunder;
	format routeid $regions.;
quit;
proc print data=work.dnunder;
run;

*create a custom format from a data set;
data newjcodedat;
   keep Start Label FmtName;
   retain FmtName '$jcodes';
   set sasuser.jcodedat 
      (rename=(Jobcode=Start 
               Descript=Label));
run;
proc format lib=sasuser cntlin=newjcodedat;
run;
proc format lib=sasuser fmtlib;
   select $jcodes;
run;

*add codes to a custom format;
*Submit a PROC FORMAT step that writes the $JCODES. 
format out to the data set Sasuser.Jcodedat;
proc format lib=sasuser.jcodedata;
	select $jcodes;
run;
proc sql;
   insert into sasuser.jcodedata
   set fmtname='$jcodes',
       start='TKTAG1',
       end='TKTAG1',
       label='Ticket Agent Grade 1'
   set fmtname='$jcodes',
       start='TKTAG2',
       end='TKTAG2',
       label='Ticket Agent Grade 2'
   set fmtname='$jcodes',
       start='TKTAG3', 
       end='TKTAG3',
       label='Ticket Agent Grade 3';
quit;
*saves a new version of the $JCODES. format in the Sasuser library;
proc format lib=sasuser cntlin=sasuser.jcodedata;
run;
*documents the $JCODES. format;
proc format lib=sasuser fmtlib;
   select $jcodes;
run;

/*****************************************/
*modifying SAS data sets and tracking changes;
*update all obs;
proc copy in=sasuser out=work;
   select empdata;
run;
proc print data=empdata (obs=5);
run;
* give all the employees in the Work.Empdata 
SAS data set a 5% salary increase;
data empdata;
	modify empdata;
	salary=salary*1.05;
run;
proc print data=empdata (obs=5);
run;

*use transaction data set to modify data set;
proc copy in=sasuser out=work;
   select empdata;
run;
proc print data=empdata (obs=15);
run;
data empdata;
	modify empdata sasuser.empdatu;
	by empid;
run;
proc print data=empdata (obs=15);
run;

*modify data set with missing values;
data missing;
   input EmpID $ Salary;
   datalines;
   E00002 .
   E00005 25000
   ;
run;
data empdata;
   modify empdata missing
          updatemode=nomissingcheck; *missing values in the transaction 
		      data set replace values in the master data set;
   by empid;
run;
proc print data=work.empdata(obs=5);
run;

*use transaction data set to modify a data set;
proc copy in=sasuser out=work;
   select empdata;
run;
proc print data=empdata (obs=5);
run;
data empdata;
   set sasuser.empdatu2 
       (rename=(lastname=NewLastName
                location=NewLocation
                salary=NewSalary));
   modify empdata key=empiD;
   lastname=newlastname;
   location=newlocation;
   salary=newsalary;
run;
proc print data=empdata (obs=5);
run;

*use_IORC_and %	sysrc;
proc copy in=sasuser out=work;
   select empdata;
run;
data sasuser.newsalary;
   input EmpId $ Increase;
   datalines;
   E00001 3250
   E00002 3500
   E00300 6250
   ;
run;

data empdata;
   set sasuser.newsalary; 
   modify empdata key=empid;
   *For matching values;
   if _iorc_=%sysrc(_sok) then 
      do;
      salary=salary+increase;
      replace;
      end;
   else do;
   put '***Incorrect Employee Number***';
   _error_=0;
   end;
run;
proc print data=empdata (obs=5);
run;

*Add integrity constraints to data set;
proc copy in=sasuser out=work;
   select empdata;
run;
proc datasets nolist;
   modify empdata;
   ic create PKEmpID=Primary Key (EmpID)
      message='Please supply an employee ID 
               number.';
   ic create Lname=Not Null (LastName)
      message='Please supply a last name.';
quit;

*integrity constraints;
proc datasets nolist;
   contents data=empdata;
quit;
proc datasets nolist;
   modify empdata;
   ic delete pkempid;
   ic delete lname;
quit;

*Initiate an audit trail;
proc copy in=sasuser out=work;
   select pilotemp;
run;
proc datasets nolist;
   audit pilotemp;
   initiate;
quit;
data pilotemp;
   modify pilotemp;
   salary=salary*1.2;
run;
proc print data=pilotemp(type=audit);
run;

*create customized audit trail;
proc copy in=sasuser out=work;
   select pilotemp;
run;
data promotion;
   length EmpID $ 6;
   input EmpID $ JobCode $ Increase;
   datalines;
   E00031 Pilot4 2400
   E00055 Pilot4 5000
   ;
run;
proc datasets nolist;
   audit pilotemp;
   initiate;
   user_var User $20 label='Who made the change'
      		Reason $20 label='Why the change was made';
   log before_image=no;
quit;
data pilotemp;
   modify pilotemp promotion;
   by empid;
   salary=salary+increase;
   user="My Name";
   reason="Raise";
run;
proc print data=pilotemp(type=audit);
run;

*Suspend, resume, and terminate the audit trail;
* suspend the audit trail;
proc datasets nolist;
   audit pilotemp;
   suspend;
quit;
*modify the data set;
data pilotemp;
   modify pilotemp;
   location='Honolulu';
run;
*resume the audit trail;
proc datasets nolist;
   audit pilotemp;
   resume;
quit;
*modify data;
data pilotemp; 
   modify pilotemp promotion;
   by empid; 
   salary=salary+increase;
   user="My Name";
   reason="Year 2 Raise";
run;
*view the audit file;
proc print data=pilotemp(type=audit);
run;
*terminate the audit trail;
proc datasets nolist;
   audit pilotemp;
   terminate;
quit;

*generation data set;
proc copy in=sasuser out=work;
   select jobhstry;
run;
*modify the SAS data set Work.Jobhstry 
to save a maximum of three generations;
proc datasets nolist;
   modify jobhstry (genmax=3);
quit;
data jobhstry;
   set jobhstry sasuser.y200061;
run;
data jobhstry;
   set jobhstry sasuser.y200062;
run;
data jobhstry;
   set jobhstry sasuser.y200061;
run;
data jobhstry;
   set jobhstry sasuser.y200062;
run;

*generation data sets;
proc print data=sasuser.jobhstry;
run;
proc print data=work.jobhstry(gennum=0);
run;

proc datasets nolist;
   contents data=jobhstry(gennum=2);
quit;

proc datasets nolist;
   delete jobhstry(gennum=all);
quit;

proc datasets;
quit;
