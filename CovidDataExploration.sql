-- quick look at the data
select *
from Portfolio..CovidDeaths
where continent <>''
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
where continent <>''
order by 3,4

-- Total cases vs deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where continent <>''
--where location  like '%poland%'
order by 1,2

-- Total cases vs Population
select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from Portfolio..CovidDeaths
where continent <>''
--where location  like '%poland%'
order by 1,2

-- Highest infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from Portfolio..CovidDeaths
where continent <>''
group by location, population
order by PercentagePopulationInfected desc

-- Highest Death Count 
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent <>''
group by location
order by TotalDeathCount desc

-- CONTINENT
-- Continents with highest death count 

--select continent, max(cast(total_deaths as int)) as TotalDeathCount
--from Portfolio..CovidDeaths
--where continent <>''
--group by continent
--order by TotalDeathCount desc

-- this is more accurate
select location, max(cast(total_deaths as int)) as TotalDeathCount
from Portfolio..CovidDeaths
where continent =''
group by location
order by TotalDeathCount desc


-- GLOBAL

select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where continent <>''
group by date
order by 1,2


-- Total global cases and deaths
select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Portfolio..CovidDeaths
where continent <>''
--group by date
order by 1,2


-- VACCINATIONS

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''
order by 2,3


-- Vaccinated vs Population


-- USE CTE
with PopvsVac (Continent, Location, Date, Population, new_vaccinations, CumulativePeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''
--order by 2,3
)
select *, (CumulativePeopleVaccinated/Population*100) as CumulativeVaccinatedPercentage
from
PopvsVac


--TEMP TABLE
DROP Table if exists #PrecentPopulationVaccinated
Create table #PrecentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
CumulativePeopleVaccinated numeric
)
Insert into #PrecentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int), 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''
--order by 2,3


select *, (CumulativePeopleVaccinated/Population*100) as CumulativeVaccinatedPercentage
from
#PrecentPopulationVaccinated


-- View to store data for visualizations

Create view PrecentPopulationVaccinated as
select dea.Continent, dea.Location, dea.date, dea.Population, cast(vac.new_vaccinations as int) as NewVaccination, 
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as CumulativePeopleVaccinated
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent <>''
--order by 2,3

select * from
PrecentPopulationVaccinated