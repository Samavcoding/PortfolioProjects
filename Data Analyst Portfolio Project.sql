
SELECT * 
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT * 
--FROM PortfolioProject..Covidvaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT location, date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..CovidDeaths
order by 1,2

--Looking at total cases vs total deaths 
--Shows likelihoood of dying if you contract covid in your country


SELECT location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..CovidDeaths
where location like '%israel%'
where continent is not null
order by 1,2

--looking at total cases vs population
--shows what percentage of population got covid

SELECT location, date,population, total_cases,(total_cases/population)*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%israel%'
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as Highestinfectioncount,MAX(total_cases/population)*100 as PercentpopulationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%israel%'
where continent is not null
Group by location,population
order by PercentpopulationInfected DESC

--showing the highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like '%israel%'
where continent is not null
Group by location,population
order by totaldeathcount DESC

----showing the continents with highest death counts

SELECT continent,MAX(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..CovidDeaths
--where location like '%israel%'
where continent is not null
Group by continent
order by totaldeathcount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths
--where location like '%israel%'
where continent is not null
--Group by date
order by 1,2


select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
, 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopVsVac (continent, location,date,population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from PopVsVac

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated 
--in case making any changes in the below query
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
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
from #PercentPopulationVaccinated



--Creating View ti store date for later visualizations


Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3