---Here are checking the columns of CovidDeaths and ordering by location and date
SELECT *
FROM [dbo].[CovidDeaths]
Order By [location], [date] 



---Here are checking the columns of CovidVaccinations and ordering by location and date
SELECT *
FROM [dbo].[CovidVaccinations]
Order By [location], [date] 


SELECT [location], [date], [total_cases], [new_cases], [total_deaths], [population]
FROM [dbo].[CovidDeaths]
ORDER BY 1,2

---Calculate Death Percenatge (Total_Deaths * 100 / Total Cases)
---Shows the likelihood of dying if any person contract to covid in India
SELECT [location], [date], [total_cases], [total_deaths], ROUND((total_deaths/total_cases)*100, 1) as DeathPercentage  ---Percentage figure is rounded off
FROM [dbo].[CovidDeaths]                
WHERE [location] = 'India' ---We choose to see data of India
ORDER BY 1,2

--Calculate total death percentage of each location
WITH TotalDeathPercentage ( [location], TotalCases, TotalDeaths, TotalDeathPercent)
AS (
SELECT [location], MAX([total_cases]) AS TotalCases, MAX([total_deaths]) AS TotalDeaths, CONCAT(ROUND(100*(MAX([total_deaths])/MAX([total_cases])),1), '%') AS TotalDeathPercent
FROM [dbo].[CovidDeaths] 
GROUP BY location )
SELECT location, TotalCases, TotalDeaths, TotalDeathPercent
From TotalDeathPercentage
WHERE TotalCases IS NOT NULL
AND TotalDeaths IS NOT NULL
ORDER BY TotalDeathPercent desc

---What percentage of population got covid, it means we will calculate (total_cases/population)*100
SELECT [location], [date], [total_cases], population, ROUND((total_cases/population)*100, 1) as PercentageAffected 
FROM [dbo].[CovidDeaths]
WHERE location = 'India'                 
ORDER BY 1,2

--Calculate the percentage of total people infected from COVID - 19 for all locations
WITH TotalInfected (location, TotalCases, population, TotalPercentInfected)
AS (
SELECT [location], MAX([total_cases]) AS TotalCases, [population], ROUND(100*(MAX(total_cases)/population),1) AS TotalPercentInfected
FROM [dbo].[CovidDeaths] 
GROUP BY location, population
)
SELECT location, TotalCases, population, TotalPercentInfected
FROM TotalInfected
WHERE TotalCases IS NOT NULL 
AND population IS NOT NULL
ORDER BY TotalPercentInfected desc


---Look for countries with Highest Infection Rate compared to Population
SELECT [location], [population],  MAX([total_cases]) as HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 1)) as PercentPopulationInfected     ---Here we only want to look at the highest total cases from each location, therefore we have used MAX function and we need to also add MAX to the percentage part 
FROM [dbo].[CovidDeaths]                                                                                                                                    ---because otherwise it will give the same result as above                              
Group By [location], [population]         ---The aggregate function MAX or any other aggregate function must be used along with GROUP BY or HAVING clause, so that we could able to return single value for a set of data  
ORDER BY PercentPopulationInfected desc

---Show countries with Highest Death Count per Population
SELECT [location], [population], MAX(cast([total_deaths] as int)) as HighestDeathCount   ---The result is not as per our requirement because the total deaths data type is 'nvarchar' and we need to convert it into 'int' type and for that we will use CAST function
FROM [dbo].[CovidDeaths]
Where [continent] IS NOT NULL
Group By [location], population
Order By HighestDeathCount desc   
---Here we can see that the location has output World and in some cases its showing continent, it is because in some of our continent coulmns it has 
---displayed NULL value, therefore we need to specify that we need values, where continent is not null.


---Showing continents with Highest Death Count per Population
Select continent, MAX(cast([total_deaths] as int)) as HighestDeathCount 
From [dbo].[CovidDeaths]
Where continent is not null
Group By continent
Order By HighestDeathCount desc

---Show the total population of the continents
Select continent, SUM(Distinct population) as ContinentPopulation
From [dbo].[CovidDeaths]
Where continent is not null
Group By continent


---GLOBAL NUMBERS, here we need to find the info irrespective of any location and filter cannot be done on the basis of date
---Show new cases, new deaths as per the date as well as show death percentage as per the date across the world
SELECT [date], Sum([new_cases]) as CasesPerDate, Sum(cast ([new_deaths] as int)) as DeathPerDate, 100*Sum(cast ([new_deaths] as int))/Sum([new_cases]) as DeathPercentage 
FROM [dbo].[CovidDeaths]
WHERE continent is not null
Group By date       
ORDER BY 1,2


---Join the 2 tables
Select *
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
and dea.date = vac.date

---Show the total population and whats the total amount of people in the world got vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations]
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
Order By 1,2,3

---Show the roll over addition of new vaccination per date per location i.e. we need to show the cummulative sum of new vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations], SUM(convert(bigint,vac.[new_vaccinations])) OVER (Partition by dea.location 
ORDER BY dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
Order By 2,3


Alter Table [dbo].[CovidDeaths]
Alter column[date] varchar(50)

---Show total population vs vaccinations, what we want to do is we would use the MAX number of RollingPeopleVaccinated and divide with Total population
--- to see total percentage vaccinated in different locations
---But we cannot use a Column header i.e. RollingPeopleVaccinated which we have created to create another column. So, we should use CTE or Temp Table

---Here we will show RollingVaccination Percenatge, and for that we will be creating a table using CTE i.e. PopvsVac and in that table we use the column
---which we have created to create other columns
---Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations], SUM(convert(bigint,vac.[new_vaccinations])) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3  (We cannot use Order By in CTE)
)
Select *, (RollingPeopleVaccinated/[population])*100 as RollingVaccinationPercent
From PopvsVac



---Here we showed the total vaccination percentage depending different location, and for that we have removed date coulmn so that the MAX aggregate 
--function can be used
With PopvsVac --(continent, location, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.population, vac.[new_vaccinations], SUM(convert(bigint,vac.[new_vaccinations])) OVER (Partition by dea.location 
Order by dea.location) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3  (We cannot use Order By in CTE)
)
Select continent, location, population, MAX(RollingPeopleVaccinated)/[population]*100 as RollingVaccinationPercent
From PopvsVac
Group By continent, location, population


---Using TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated  --So it will remove the table which we have created earlier and help us to make any changes in the table
Create Table #PercentPopulationVaccinated         ---Here we are creating a table
(
continent nvarchar(255),
location nvarchar(255),
date varchar(50),
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated  ---Here we are indicating that, we will insert our data into this newly created table
Select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations], SUM(convert(bigint,vac.[new_vaccinations])) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3
Select *, (RollingPeopleVaccinated/[population])*100 as RollingVaccinationPercent
From #PercentPopulationVaccinated


--Creating view to store data for later visualisation

Create View PercentPopulationVaccinated AS     
Select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations], SUM(convert(bigint,vac.[new_vaccinations])) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

---By creating a view, we have created a table using PercentPopulationVaccinated, and this is a permanent table and we can use it later for visualization


ALTER View PercentPopulationVaccinated AS     
Select dea.continent, dea.location, dea.date, dea.population, vac.[new_vaccinations],
SUM(convert(bigint,vac.[new_vaccinations])) OVER (Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated, 1 AS FLAG
From [dbo].[CovidDeaths] dea
Join [dbo].[CovidVaccinations] vac
On dea.location = vac.location
And dea.date = vac.date
Where dea.continent is not null