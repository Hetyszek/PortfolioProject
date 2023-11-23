Select *
from PortfolioProject..CovidDeaths$
order by 3, 4

--Select *
--from PortfolioProject..CovidVaccinations$
--order by 3, 4

-- select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$ 
order by 1, 2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in yout country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$ 
where location like 'Poland'
order by 1, 2

--shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentInfectedPopulation
from PortfolioProject..CovidDeaths$ 
where location like 'Poland'
order by 1, 2

--looking at highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentInfectedPopulation
from PortfolioProject..CovidDeaths$		
--where location like 'Poland'
group by location, population
order by PercentInfectedPopulation desc

-- showing countries with highest death count per population
Select Location, population, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$		
--where location like 'Poland'
where continent is not null
group by location, population
order by TotalDeathCount desc

--Let's break thing's down by continent
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$		
--where location like 'Poland'
where continent is null
group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) as DeathPercentage * 100 as 
from PortfolioProject..CovidDeaths$		
--where location like 'Poland'
where continent is not null
group by date
order by 1,2 

--Looking at population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as bigint), sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Use PortfolioProject
GO
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later data visualizations
drop view if exists PercentPopulationVaccinated

Use PortfolioProject
GO
Create view PercentPopulationVaccinated123 as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) 
over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)