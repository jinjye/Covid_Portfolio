-- Taking a look at the covid cases in ASEAN in view of the opening of borders 
-- data is taken from https://ourworldindata.org/coronavirus 
-- Countries that are in ASEAN are Brunei, Cambodia, Indonesia, Loas, Malaysia, Myanmar, Phillipines, Singapore, Thailand and Vietnam 


-- Update SQL table to show ASEAN for the following countries 
Update covidproject..CovidDeaths
SET continent = 'ASEAN'
WHERE location in ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')

Update covidproject..CovidVaccinations
SET continent = 'ASEAN'
WHERE location in ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam')


-- Exploring the data, the data consists of worldwide data, so we will just use the ASEAN Countries.
SELECT Location, total_tests, positive_rate, people_vaccinated, people_fully_vaccinated, gdp_per_capita
FROM covidproject..CovidVaccinations
WHERE continent = 'ASEAN'
ORDER BY location


SELECT location, population, total_cases, total_deaths, hosp_patients, icu_patients
FROM covidproject..CovidDeaths
WHERE continent = 'ASEAN'
ORDER BY location


--Looking at the country with the highest covid count 
SELECT location, max(total_cases) as CovidCaseCount, population, MAX(ROUND((total_cases/population)*100,2)) AS CovidPercentage
From covidproject..CovidDeaths
WHERE continent = 'ASEAN'
group by location, population 
order by CovidCaseCount DESC

--Looking at the country with the highest covid rate
SELECT location, max(total_cases) as CovidCaseCount, population, MAX(ROUND((total_cases/population)*100,2)) AS CovidPercentage
From covidproject..CovidDeaths
WHERE continent = 'ASEAN'
group by location, population 
order by CovidPercentage DESC


--Looking at the country with the highest covid count worldwide
SELECT location, max(total_cases) as CovidCaseCount, population, MAX(ROUND((total_cases/population)*100,2)) AS CovidPercentage
From covidproject..CovidDeaths
Where continent is not null
group by location, population 
order by CovidCaseCount DESC

--Looking at the country with the highest covid rate worldwide
SELECT location, max(total_cases) as CovidCaseCount, population, MAX(ROUND((total_cases/population)*100,2)) AS CovidPercentage
From covidproject..CovidDeaths
Where continent is not null
group by location, population 
order by CovidPercentage DESC

-- Learnings:
-- As shown, having the highest covid count does not mean that they have the highest covid percentage. This could be contributed to the fact that the countries are tackling the issue with vaccinations and covid measures 
-- Good to note that, the covid percentage in ASEAN is relatively low as compared to the world 


--Looking at the country with the highest death count
-- realsied that the total_deaths is nvarchar so, cast it to INT
SELECT location, max(cast(total_deaths AS INT)) as CovidDeathCount, population, MAX(ROUND((cast(total_deaths AS INT)/population)*100,2)) AS DeathPercentage
From covidproject..CovidDeaths
WHERE continent = 'ASEAN'
group by location, population 
order by CovidDeathCount DESC

--Looking at the country with the highest death rate
SELECT location, max(cast(total_deaths AS INT)) as CovidDeathCount, population, MAX(ROUND((cast(total_deaths AS INT)/population)*100,2)) AS DeathPercentage
From covidproject..CovidDeaths
WHERE continent = 'ASEAN'
group by location, population 
order by DeathPercentage DESC

-- Looking at country with the highest death count worldwide
SELECT location, max(cast(total_deaths AS INT)) as CovidDeathCount, population, MAX(ROUND((cast(total_deaths AS INT)/population)*100,2)) AS DeathPercentage
From covidproject..CovidDeaths
Where continent is not null
group by location, population 
order by CovidDeathCount DESC

--Looking at the country with the highest death rate worldwide
SELECT location, max(cast(total_deaths AS INT)) as CovidDeathCount, population, MAX(ROUND((cast(total_deaths AS INT)/population)*100,2)) AS DeathPercentage
From covidproject..CovidDeaths
Where continent is not null
group by location, population 
order by DeathPercentage DESC

-- Learning 
-- For ASEAN, the Higher Death Count and Death percentage is held by Indoneisa, however is does not mean that There is a correlation between death count and death percentage
-- Generally the covid deaths counts are very low, lower than 1% worldwide, with ASEAN lower than 0.05% 


-- Toatl value for overall - total vaccination, 1st dose and 2nd dose 
Select continent, location, MAX(CAST(total_vaccinations AS INT)) as TotalVaccination, MAX(CAST(people_vaccinated AS INT)) as FirstDoseCompleted,  MAX(CAST(people_fully_vaccinated AS INT)) as SecondDoseCompleted
FROM covidproject..CovidVaccinations
WHERE continent = 'ASEAN'
Group by continent, location



-- Add rolling number to the overall result for total vaccination -- sidenotes, this does not take into account of type of vaccine 
Select date, continent, new_vaccinations, sum(cast(new_vaccinations as int)) over (partition by continent order by continent, date) as TotalVaccinationToDate
From covidproject..CovidVaccinations
where continent = 'ASEAN'
order by date


-- add rolling number to the overall result for total covid 
Select date, continent, new_cases, sum(cast(new_cases as int)) over (partition by continent order by continent, date) as TotalNewCasesToDate
From covidproject..CovidDeaths
where continent = 'ASEAN'
order by date 

-- add rolling number to the overall result for total deaths 
Select date, continent, new_deaths, sum(cast(new_deaths as int)) over (partition by continent order by continent, date) as TotalDeathToDate
From covidproject..CovidDeaths
where continent = 'ASEAN'
order by date 




--Create temp view 
Create View ASEANCovidVacDeath as
select dea.date, dea.continent, sum(cast(dea.new_cases as int)) over (partition by dea.continent order by dea.continent, dea.date) as TotalNewCasesToDate, sum(cast(dea.new_deaths as int)) over (partition by dea.continent order by dea.continent, dea.date) as TotalDeathToDate, sum(cast(vac.new_vaccinations as int)) over (partition by dea.continent order by dea.continent, dea.date) as TotalVaccinationToDate
From covidproject..CovidDeaths dea
join covidproject..CovidVaccinations vac
	ON dea.continent = vac.continent
	AND dea.date = vac.date
WHERE dea.continent = 'ASEAN'


Select * From ASEANCovidVacDeath



-- Total Value for overall. - Total Cases and Deaths 
-- Used for virtualisation
SELECT dea.continent, dea.location, MAX(dea.total_cases) as TotalCases, MAX(CAST(dea.total_deaths AS INT)) as TotalDeaths, MAX(CAST(vac.total_vaccinations AS INT)) as TotalVaccinations
FROM covidproject..CovidDeaths dea
JOIN covidproject..CovidVaccinations vac 
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent = 'ASEAN'
Group by dea.continent, dea.location


-- look at the total cases, death from total cases and the total population vaccinated 
-- used for virtualisation
Select dea.Location, dea.Population, dea.date, Max((dea.total_cases/population))*100 as PercentPopulationInfected, Max((dea.total_deaths/dea.total_cases))*100 as PercentPopulationDeath,  Max((vac.people_vaccinated/population))*100 as PercentPopulationVaccinated
From covidproject..CovidDeaths dea
JOIN covidproject..CovidVaccinations vac
	On	dea.location = vac.location
	AND dea.date = vac.date
where dea.continent = 'ASEAN'
Group by dea.Location, dea.Population, dea.date

-- look at the day to day new cases, new deaths and new vaccinations
--used for virtualisation
select dea.location, dea.date, dea.new_cases, dea.new_deaths, vac.new_vaccinations
From covidproject..CovidDeaths dea
JOIN covidproject..CovidVaccinations vac
	On	dea.location = vac.location
	AND dea.date = vac.date
where dea.continent = 'ASEAN'
Group by dea.Location, dea.date, dea.new_cases,dea.new_deaths, vac.new_vaccinations
