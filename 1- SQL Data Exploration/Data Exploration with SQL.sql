-- Show The Two Tables

Select * From PortfolioProject..CovidDeaths
Order by 3,4

Select * From PortfolioProject..CovidVaccinations
Order by 3,4

-- Show the Data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
-- because when continent is null, the location is replaced by the continent name
order by 1,2

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if someone contracts covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows percentages of the population infected with Covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, total_cases
From PortfolioProject..CovidDeaths
Where continent is not null 

Select Location, Population, MAX(total_cases) as HighestNumberOfInfections
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population
order by HighestNumberOfInfections desc

Select Location, Population, MAX(total_cases) as HighestNumberOfInfections,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, Population, MAX(cast(total_deaths as int)) as HighestNumberOfDeaths,  Max((total_deaths/population))*100 as PercentPopulationDead
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location, Population
order by PercentPopulationDead desc

Select Location, MAX(cast(Total_deaths as int))as TotalDeathCount
-- cast : total_deaths is nvarchar, there are sme issus dealing with the numeric data
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Let's Group by Continent
-- Showing contintents with the highest death count per population
Select Continent, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null 
Group by Continent
order by TotalDeathCount desc

Select Location, MAX(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
Group by Location
order by TotalDeathCount desc

---- Global Statistics

-- The percentage of new deaths/new cases per day across the world
Select  date, sum(new_cases) as TotalCases,
sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as float))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where continent is not null 
Group by date
order by Date desc

-- The total percentage of new deaths/new cases across the world
Select sum(new_cases) as TotalCases,
sum(cast(new_deaths as int)) as TotalDeaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- where continent is not null 
-- Group by date
--order by Date desc


Select * From PortfolioProject..CovidVaccinations
Order by 3,4

-- Join the two tables 
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
-- , (SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100 as PercentPopulationVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE (Common Table Expression) to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated
order by 2,3


------ Using Temp Table to store the result of the previous query
--SELECT 
--    *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
--INTO 
--	#PercentPopulationVaccinated2
--FROM 
--	#PercentPopulationVaccinated
--
--SELECT * From #PercentPopulationVaccinated2


-- Creating View to store data for later visualizations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

-- 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 