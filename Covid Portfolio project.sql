select * from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

select * from PortfolioProject..CovidVaccinations
order by 3,4

-- select data we will USE

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at the total cases vs total_deaths
-- shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases, new_cases, total_deaths, 
(total_deaths/total_cases)*100 as Death Percentage
from PortfolioProject..CovidDeaths
where location in ('Mauritius','France')
order by 1,2

-- Looking at the total cases vs Population
select Location, date, total_cases, Population, 
(total_cases/population)*100 as PercentagePopulation
from PortfolioProject..CovidDeaths
where location in ('Mauritius','France')
order by 1,2

-- Looking at countries with highest infection rate compared to population

select Location, date, MAX(total_cases) as HighestInfectionCount, Population, 
MAX(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location in ('Mauritius','France')
and continent is not NULL
group by location, population
order by PercentPopulationInfected DESC

-- Showing countries with the highest death count per population

SELECT continent,location, date, MAX(CAST(total_deaths)as int) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location in ('Mauritius','France')
where continent is not NULL
group by location
order by TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents wuth the highest death count population
SELECT continent, MAX(CAST(total_deaths)as int) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int) as total_deaths, 
sum(cast(new_deaths as int)/sum(new_cases)*100 as death percentage
from PortfolioProject..CovidDeaths
where continent is not NULL
Group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
innerjoin PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where continent is not NULL
order by 2,3


-- USE CTE
With PopvsVac (Continent, location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
innerjoin PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

)

select * (RollingPeopleVaccinated/Population)*100
from PopvsVac


--TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
innerjoin PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

select * (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--creating view to store data for later
Create View #PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,
vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations dea
innerjoin PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not NULL

select * from PercentPopulationVaccinated