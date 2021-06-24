
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4
--Location includes 'Asia' and 'International' as some grouped value
--Location and Continent have 'Asia'. dont want where location is 'Asia' because those are not specific country names

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Look at total cases vs total deaths
-- Shows likelihood of dying if someone contracts covid in their country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population)*100) AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY population, location
ORDER BY PercentOfPopulationInfected DESC


-- Countries with Highest Death Counts per Population 
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Highest Death Count per Continent*
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC
-- this query returns north america as just usa numbers and excludes canada

-- Highest Death Count per Continent per Population
SELECT continent, MAX(CAST(total_deaths as INT)) AS HighestContinentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY HighestContinentDeathCount DESC


-- Global Numbers
-- Showing daily total cases, total deaths, and percentage of death 
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths
, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
 
-- Overall Total cases, total deaths, and death Percentage
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths
, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2
 


-- Joining Death and Vaccination tables

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null

-- Total Population VS Total Vaccination
-- Total number of people that have been vaccinated per day (rolling count)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition BY in previous query
With PopvsVac (continent, location, date, population, new_vaccinations, RollingCountPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingCountPeopleVaccinated/Population)*100 AS PercRollingCountVaccinated 
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition BY in previous query
DROP TABLE if exists #PercPopVac
CREATE TABLE #PercPopVac
(
Continent varchar (255), 
Location varchar (255), 
Date datetime, 
Population numeric, 
New_vaccination numeric, 
RollingCountPeopleVaccinated numeric
)

INSERT INTO #PercPopVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT * 
FROM #PercPopVac



-- Creating View to Store Date for later Visualization
CREATE VIEW PercPopVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT * FROM PercPopVac