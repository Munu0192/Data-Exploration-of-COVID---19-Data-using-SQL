# Data-Exploration-of-COVID---19-Data-using-SQL
Data Exploration of COVID - 19 data using SQL query

In this data exploration, we have 2 data sets giving information regarding ‘Covid Deaths’ and ‘Covid Vaccinations’ around the globe.

1.	 Have calculated the ‘Total Percentage Infected’ from COVID 19 for every location using CTE, MAX, ROUND function. And have used an ORDER BY clause to display the locations that are worst affected in terms of COVID infection and removed NULL values using WHERE clause. (Total Percent Affected =100* [MAX(Total Cases) / Population]). 

2.	And from the ‘Covid Death’ data table we have calculated the Total Death Percentage of each location using the CTE function to create a temporary table having details of maximum total cases and total deaths using MAX() for each country. And then used the table columns to calculate Total Death Percent and used ROUND function to get the value upto 1 decimal place and display the ‘%’ sign using the CONCAT function. (Total Death Percent = CONCAT(ROUND(100*[ MAX(Total Deaths) / MAX(Total Cases)],1), ‘%’). And because of presence of some NULL values we have used WHERE clause, to show the values where Total Cases and Total Deaths IS NOT NULL. And used ORDER BY clause to arrange the list in descending order of Total Death Percent to see the worst affected locations in terms of COVID deaths.

3.	We have calculated the Total no.of New Cases and Total no.of New Death as well as its death percentage on the basis of date throughout the entire globe using SUM() and GROUP BY date. And the variables were not ‘INT’ type and therefore used CAST() to convert it into ‘int’ types. And ordered the list by date using ORDER BY clause.

4.	Have also calculated the cumulative value of New Vaccinations for each location on the basis of date. And for this I used JOIN inorder to join the covid.death table with covid.vaccination table ON location and date. And used OVER() and ‘PARTITION BY’ clause so that we could able to get the cumulative value of new vaccinations on the basis of date and for a particular location. And then again with change in location it will give its cumulative value. And have also used ORDER BY clause in the OVER() so that we could able to get the cumulative value on the basis of each date. 

5.	Then I have calculated the percentage of Total people vaccinated using CTE, JOIN and MAX(). And using CTE we could able to create a table having the derived column table name which we then can use with aggregate function. JOIN is used to join the 2 tables and MAX() is used for calculating the total percent of people vaccinated in different locations.
