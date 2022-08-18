SELECT *
FROM Covid_Case..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM Covid_Cases..Covid_Vaccinations
--ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Case..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Total Cases vs Total Deaths
-- Mortarility Rate

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Case..Covid_Deaths
WHERE location='Philippines' AND continent IS NOT NULL
ORDER BY 1,2



-- Total Cases vs Population
-- Shows what percentage of the population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM Covid_Case..Covid_Deaths
--WHERE location='Philippines'
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, max(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_Case..Covid_Deaths
--WHERE location='Philippines'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC



-- Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid_Case..Covid_Deaths
--WHERE location='Philippines'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY  TotalDeathCount DESC



-- Continent with Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid_Case..Covid_Deaths
--WHERE location='Philippines'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC



-- Global Numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM Covid_Case..Covid_Deaths
--WHERE location='Philippines' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



-- JOIN Covid_Deaths and Covid_Vaccinations

SELECT *
FROM Covid_Case..Covid_Deaths death
JOIN Covid_Case..Covid_Vaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date



-- Total Population vs Total Vaccinated People

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
FROM Covid_Case..Covid_Deaths death
JOIN Covid_Case..Covid_Vaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3



SELECT death.location, SUM(CAST(vaccine.new_vaccinations AS BIGINT)) AS Total_Vaccinated
FROM Covid_Case..Covid_Deaths death
JOIN Covid_Case..Covid_Vaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
GROUP BY death.location
ORDER BY Total_Vaccinated DESC



-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(BIGINT, vaccine.new_vaccinations)) OVER (PARTITION BY death.Location ORDER BY death.Location, death.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Covid_Case..Covid_Deaths death
JOIN Covid_Case..Covid_Vaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(BIGINT, vaccine.new_vaccinations)) OVER (PARTITION BY death.Location ORDER BY death.Location, death.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Covid_Case..Covid_Deaths death
JOIN Covid_Case..Covid_Vaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(BIGINT, vaccine.new_vaccinations)) OVER (PARTITION BY death.Location ORDER BY death.Location, death.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Covid_Case..Covid_Deaths death
JOIN Covid_Case..Covid_Vaccinations vaccine
ON death.location = vaccine.location AND death.date = vaccine.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated