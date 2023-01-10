--Select *
--From PortfolioProject..CovidDeaths
--order by location, date

--Select *
--From PortfolioProject..CovidVaccinations
--order by location, date


-- Select specified column from CovidDeaths Table
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by location, date


-- Calculate Total cases Vs Total Deaths
--Shows likelihood of death rate for a specific country
Select location, date, total_cases,total_deaths, (total_deaths / total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Canada'
order by location, date

-- Calculate Total cases Vs Population
-- % of population who contracted covid
Select location, date, total_cases, population, (total_cases / population)*100 as AffPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by location, date

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highestcount, MAX(total_cases/ population)*100 as PercentPop
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPop desc

-- Showing Countries with highest Death Count per population (selecting only countries and not continents)
Select location, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
group by location
order by TotalDeathcount desc


--Showing continents with highest Death Count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathcount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
group by continent
order by TotalDeathcount desc

-- GLobal numbers
Select SUM(new_cases) total_cases ,SUM(CAST(new_deaths as int)) total_deaths, SUM(CAST(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2



--Select *
--from PortfolioProject..CovidDeaths dea
--join PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date

--Looking at total population VS Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	and dea.continent is not null
order by 1, 2, 3

--Add a running total of new vaccinations without using total vaccinations column
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as rollingSumPop
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	and dea.continent is not null
order by 2, 3

--Calculate the % of population vaccinated (using CTE)
With PopVsVac (Continent, Location, Date, Population, NewVaccine, rollingSumPop)
AS
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as rollingSumPop
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (rollingSumPop / Population)*100
from PopVsVac
order by 2, 3

-- Creating view to store data for visualization
Create View PopVsVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location, dea.date) as rollingSumPop
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
