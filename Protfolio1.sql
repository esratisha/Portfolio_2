  

Select *
From dbo.CovidVaccination
--where continent is not null
Order by 3,4
  
 --Looking at total_cases vs population
 --Indicates the percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
From Project_1..CovidDeaths
--Where location like '%Canada%'
Order by 5 DESC

--Highest cases in location 

Select location, population, MAX(total_cases) as Highest_cases, MAX((total_cases/population))*100 as CovidPercentage
From Project_1..CovidDeaths
--Where location like '%Canada%'
Group by location, population
Order by 3 DESC

--Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as Highest_deaths
From Project_1..CovidDeaths
--Where location like '%Canada%'
Where continent is not null
Group by location
Order by 2 DESC

--Continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as Highest_deaths
From Project_1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by 2

--World count
--Death percentage by location

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project_1..CovidDeaths
--Where location like '%Canada%'
where continent is not null
Order by 5 DESC

--Death percentage by date

Select date, SUM(new_cases), SUM(cast(new_deaths as int)),SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project_1..CovidDeaths
--Where location like '%Canada%'
where continent is not null
Group by date
Order by 4 DESC

--Death percentage

Select SUM(new_cases), SUM(cast(new_deaths as int)),SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Project_1..CovidDeaths
--Where location like '%Canada%'
where continent is not null
--Group by date
Order by 1,2

--Looking for vaccinations

Select dea.continent, dea.location, dea.population, vac.new_vaccinations
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2

--Total people vaccinated

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_people_vaccinated
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
Group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
order by 6 DESC

--Looking for duplicates

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
Row_number() OVER (partition by dea.location, dea.date, dea.population, vac.new_vaccinations Order by dea.location, dea.date) row_num
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations


--Making CTE--total_people_vaccinated per population

With newtable (continent, location,date,population,new_vaccinations,totalpeoplevaccinated)
as
(Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as totalpeoplevaccinated
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations

)
Select *, (totalpeoplevaccinated/population)*100 as vaccinations_percentage
From newtable
where location like '%Canad%'

Order by 7 

--total_people_vaccinated per population in Canada

Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as totalpeoplevaccinated
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and dea.location like '%Canada%'
Group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
order by 6 

--TEMP Table

Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_people_vaccinated numeric
)

Insert into #Percent_Population_Vaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_people_vaccinated
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
Group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
order by 6

Select *, (total_people_vaccinated/population)*100 as vaccinations_percentage
From #Percent_Population_Vaccinated
Order by 6

--Creating view to store data for late visualization

create view Percent_Population_Vaccinated as
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as total_people_vaccinated
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac n 
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
Group by dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 6

Select *
From Percent_Population_Vaccinated

--people_fully_vaccinated

Select dea.continent,dea.location, dea.date, dea.population, vac.people_fully_vaccinated, (vac.people_fully_vaccinated/population)*100 as percent_fully_vaccinated
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null and dea.location = 'Canada'
Group by dea.continent,dea.location, dea.date, dea.population, vac.people_fully_vaccinated
order by 6 DESC

--People Vaccinate with booster dose

Select dea.continent,dea.location, dea.date, dea.population, vac.total_boosters, (vac.total_boosters/population)*100 as percent_boosters
From Project_1..CovidDeaths  dea
Join Project_1..CovidVaccination  vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null 
--and dea.location = 'Canada'
Group by dea.continent,dea.location, dea.date, dea.population, vac.total_boosters
order by 6 DESC