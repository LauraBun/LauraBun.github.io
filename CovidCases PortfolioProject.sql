SELECT * 
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4

-- Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid per country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolio..CovidDeaths
WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- looking at the total cases vs population
-- shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 AS CovidInfectionPercentage	
FROM Portfolio..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2


-- looking at countries where highest infection rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS CovidInfectionPercentage	
FROM Portfolio..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY CovidInfectionPercentage DESC

-- Showing countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Portfolio..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- showing continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Portfolio..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent IS  NULL 
GROUP BY location
ORDER BY TotalDeathsCount DESC

-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1, 2

-- total cases worldwide 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
--WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- let's look at our second table 
SELECT * 
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
ORDER BY 3, 4

-- looking at Total Population vs Vaccinations

With PopvsVac(continent, location, date, population, new_vaccinations, RollingVaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
--(RollingVaccinations/dea.population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)

SELECT *, (RollingVaccinations/population)*100 AS VaccinationPercentage
FROM PopvsVac

-- Temp table
DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255), location nvarchar(255), date datetime, population numeric,
new_vaccinations numeric, RollingVaccinations numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
--(RollingVaccinations/dea.population)*100
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingVaccinations/population)*100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated


--creating view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) AS RollingVaccinations
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
