Select *
From Portfolio_Project..[CovidDeaths$]
where continent is not null
order by 3,4

--Select *
--From Portfolio_Project..[Covid Vaccination]
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..[CovidDeaths$]
order by 1,2

-- Percentage Death
Select location, date, total_cases, total_deaths,  (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
From Portfolio_Project..[CovidDeaths$]
Where location like '%Nigeria%'
order by 1,2

-- Percentage of Population with Covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PecentofPopulationInfected
From Portfolio_Project..[CovidDeaths$]
Where location like '%Nigeria%'
order by 1,2

-- Countries with Highest infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PecentofPopulationIfected
From Portfolio_Project..[CovidDeaths$]
-- Where location like '%Nigeria%'
group by location, population
order by PecentofPopulationIfected desc


-- countries with the Highest Death count with population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..[CovidDeaths$]
-- Where locatio like '%Nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc

-- Breaking Things down by Continent

-- Continent with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..[CovidDeaths$]
-- Where locatio like '%Nigeria%'
where continent is null
group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeath, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..[CovidDeaths$]
-- Where location like '%Nigeria%'
where continent is not null
-- group by date
order by 1,2


-- Total Population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
, --(RollingPeopleVaccination)*100
from Portfolio_Project ..CovidDeaths$ dea
join Portfolio_Project ..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated --(RollingPeopleVaccination)*100
from Portfolio_Project ..CovidDeaths$ dea
join Portfolio_Project ..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location
, dea.Date) as RollingPeopleVaccinated 
--(RollingPeopleVaccination)*100
from Portfolio_Project ..CovidDeaths$ dea
join Portfolio_Project ..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
--  where dea.continent is not null
--order by 2,3 

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for latervisualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location
, dea.Date) as RollingPeopleVaccinated 
--(RollingPeopleVaccination)*100
from Portfolio_Project ..CovidDeaths$ dea
join Portfolio_Project ..[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3 