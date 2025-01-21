-- CovidDeatjhs Table

select *
from PortfolioProject01..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject01..CovidVaccinations
--order by 3,4


--select Data that we are going to using


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject01..CovidDeaths
where continent is not null
order by 1,2


-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if we contract covied in our country.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject01..CovidDeaths
where continent is not null and location like '%desh%' -- finding my country
order by 1,2



-- Looking at Total Cases Vs Population
--Shows what Parcentage of population got Covid

select location, date, population, total_cases, (total_cases/population)*100 as DeathPercentage
from PortfolioProject01..CovidDeaths
where continent is not null and location like '%desh%' -- finding my country
order by 1,2


-- Loking at Countries with Highest Infaction Rate compared to Population 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfected
from PortfolioProject01..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject01..CovidDeaths
where continent is not null
group by location
order by HighestDeathCount desc

-- LET'S BREAK THINGH DOWN BY CONTINENT

-- Showing the continents with the Highest Death Count Per Population

select Continent, MAX(cast(Total_deaths as int)) as HighestDeathCount
from PortfolioProject01..CovidDeaths
where continent is not null
group by Continent
order by HighestDeathCount desc


-- GLOBAL NUMBERS


select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject01..CovidDeaths
where continent is not null
group by date
order by 1,2


-------------------------------------------------

-- CovidVaccinations Table 

Select *
From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--- Looking At Total Population Vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac ( Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
		as RollingPeopleVaccinated
	From PortfolioProject01..CovidDeaths dea
	Join PortfolioProject01..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From PopvsVac


-- USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric,
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
	as RollingPeopleVaccinated
From PortfolioProject01..CovidDeaths dea
Join PortfolioProject01..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null




Select *
From PercentPopulationVaccinated