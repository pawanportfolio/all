SELECT * FROM Portfolio..COVIDDEATH
where continent is not null
ORDER BY 3,4

--SELECT * FROM PORTFOLIO..COVIDVACCINATION
--ORDER BY 3, 4

--Selet Data that we are using

select  Location, date, total_cases, new_cases, total_deaths, population 
from Portfolio..CovidDeath
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

--Shows the likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/Total_cases)*100 as 'DeathPercentage'
from Portfolio..CovidDeath
where location like '%states%'
and continent is not null
order by 1,2

--Looking at the Total Cases vs the Population
Select Location, date, total_cases, population, (total_cases/population)*100 PopulationInfected
from portfolio..coviddeath
where location like '%states%'
and continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population
select  Location, population, max(total_cases)as HighstInfectionCount, max(total_cases/population)*100 as Infectionrate
from portfolio..coviddeath 
group by location, population
order by infectionrate desc

--showing Countries with Highest Death Count per Population
select Location,  max(cast (Total_deaths as int)) as TotalDeathCount
from portfolio..coviddeath
where continent is not null
group by location,population
order by TotalDeathCount desc

-- Showing the Continents with Highest Death Counts
select continent, max(cast(Total_deaths as int)) as TotalDeathCount
from portfolio..coviddeath
where continent is not null
group by continent
order by totaldeathcount desc

-- Global Numbers

Select   sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio..coviddeath 
where continent is not null
--group by date
order by 1,2


select *
from portfolio..coviddeath dea
join portfolio..covidvaccination  vac
	on dea.location = vac.location 
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
from portfolio..coviddeath dea
join portfolio..covidvaccination  vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with popvsvac (Continent, loaction, date, Population,new_vaccinations, Rolling_Vaccination_Count)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations )) over (Partition by dea.location, dea.date) as Rolling_Vaccination_count
from portfolio..coviddeath dea
join portfolio..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

)

select * ,(Rolling_Vaccination_count)from popvsvac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent varchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Vaccination_Count numeric
)

insert into  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations )) over (Partition by dea.location, dea.date) as Rolling_Vaccination_count
from portfolio..coviddeath dea
join portfolio..covidvaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * ,(Rolling_Vaccination_count/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_Count
from portfolio..coviddeath dea
join portfolio..covidvaccination vac
	on dea.location=vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select top (1000) [continent],
	[location],
	[date],
	[population],
	[new_vaccinations],
	[rolling_vaccination_count]
from [master].[dbo].[PercentPopulationVaccinated]