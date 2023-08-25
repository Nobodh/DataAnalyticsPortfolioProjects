/* 
COVID-19 Death and Vaccination Data Exploration
*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

Select *
From PortfolioProject..CovidVaccinations
Order By 3,4

-- Select pertinent data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths in US

SELECT location, date, total_cases, total_deaths, (Cast(total_deaths as float) / Cast(total_cases as float))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2
 
-- Total Cases vs Population in US

SELECT location, date, total_cases, population, (Cast(total_cases as float) / Cast(population as float))*100 as InfectionPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2

-- Countries with Highest Infection Percentage

SELECT location, population, MAX(total_cases) as CurrentCaseCount, MAX((Cast(total_cases as float) / Cast(population as float)))*100 as PopulationInfectionPercent
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationInfectionPercent DESC

-- Countries with Highest Death Percentage (out of Total Population)

SELECT location, population, MAX(total_deaths) as CurrentDeathCount, MAX((Cast(total_deaths as float) / Cast(population as float)))*100 as PopulationDeathPercent
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PopulationDeathPercent DESC

-- Countries with Highest Death Count

SELECT location, population, MAX(Cast(total_deaths as float)) as CurrentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY CurrentDeathCount DESC

-- Continents with Highest Death Count

SELECT location, population, MAX(Cast(total_deaths as float)) as CurrentDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL AND location NOT LIKE '%income%'
GROUP BY location, population
ORDER BY CurrentDeathCount DESC

-- WORLDWIDE DATA

-- By date
SELECT date, SUM(Cast(new_cases as float)) as TotalCases, SUM(Cast(new_deaths as float)) as TotalDeaths, 
	SUM(Cast(new_deaths as float))/NULLIF(SUM(Cast(new_cases as float)),0)*100 as WorldDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2

-- Overall

SELECT SUM(Cast(new_cases as float)) as TotalCases, SUM(Cast(new_deaths as float)) as TotalDeaths, 
	SUM(Cast(new_deaths as float))/NULLIF(SUM(Cast(new_cases as float)),0)*100 as WorldDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

-- New Vaccinations by Country and Date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Running Total of Vaccinations by Country

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RunningVaccinationTotal
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- CTE Utilization

WITH RunningVacTotals (continent, location, date, population, new_vaccinations, RunningVaccinationTotal)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RunningVaccinationTotal
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)

SELECT *, (RunningVaccinationTotal/population)*100 as RunningVaccinationPercent
FROM RunningVacTotals

-- Temp Table Utilization

DROP TABLE if EXISTS
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RunningVaccinationTotal numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RunningVaccinationTotal
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RunningVaccinationTotal/population)*100 as RunningVaccinationPercent
FROM #PercentPopulationVaccinated
ORDER BY 2

-- Creating View for Visualizations

DROP VIEW PercentPopulationVaccinated

USE PortfolioProject
GO
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RunningVaccinationTotal
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
