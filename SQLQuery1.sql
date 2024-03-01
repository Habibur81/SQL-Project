SELECT * FROM PortfolioProject..CovidDeaths


--Query for Total Covid Cases VS Deaths

SELECT continent, location, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2, 0) AS Total_Case_VS_Death 
FROM PortfolioProject..CovidDeaths 
WHERE total_deaths IS NOT NULL AND location LIKE '%Bangladesh%'
ORDER BY Total_Case_VS_Death


--Query for Total Covid Cases VS Population

SELECT continent, location, date, population, total_cases, (total_cases/population)*100 AS Total_Population_VS_Case 
FROM PortfolioProject..CovidDeaths 
WHERE total_cases IS NOT NULL AND location LIKE '%Bangladesh%'
ORDER BY Total_Population_VS_Case

--Highest infection rate VS Population
SELECT location, population, MAX(total_cases) AS Max_Cases, MAX((total_cases/population))*100 AS TCasesVSPopu FROM PortfolioProject..CovidDeaths
WHERE total_cases IS NOT NULL
GROUP BY location, population
HAVING MAX((total_cases/population))*100 IS NOT NULL
ORDER BY TCasesVSPopu DESC


--Break things down by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS Max_deaths FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Max_deaths DESC

--Highest death VS Population
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS Max_deaths FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
HAVING MAX(CAST(total_deaths AS INT)) IS NOT NULL
ORDER BY Max_deaths DESC

-- Continents Highest death count per population
-- Break down by Continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
HAVING MAX(CAST(total_deaths AS INT)) IS NOT NULL
ORDER BY TotalDeathCount DESC


--Global cases and death number

SELECT SUM(total_cases) AS Global_Cases, SUM(CAST(total_deaths AS int)) AS Global_Deaths, 
ROUND((SUM(CAST(total_deaths AS int))/SUM(total_cases)) * 100, 2) AS Percentage
FROM PortfolioProject..CovidDeaths


---Total population VS Vaccination

SELECT * FROM PortfolioProject..CovidDeaths

SELECT * FROM PortfolioProject..CovidVaccinations

--SELECT a.continent, a.location, a.date,  a.population, b.new_vaccinations,
--SUM(CONVERT(bigint, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.population, a.date) AS RollingPeopleVaccination,
--(SUM(CONVERT(bigint, b.new_vaccinations))/a.population) *100 AS Percentage
--FROM PortfolioProject..CovidDeaths AS a
--FULL JOIN PortfolioProject..CovidVaccinations AS b 
--ON a.location = b.location AND a.date = b.date
--WHERE a.continent IS NOT NULL
--GROUP BY a.continent, a.location, a.date,  a.population, b.new_vaccinations
--HAVING SUM(CONVERT(bigint, b.new_vaccinations)) IS NOT NULL
--ORDER BY 1, 2

SELECT a.continent, a.location, a.date,  a.population, b.new_vaccinations,
SUM(CONVERT(bigint, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.population, a.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS a
FULL JOIN PortfolioProject..CovidVaccinations AS b 
ON a.location = b.location AND a.date = b.date
WHERE a.continent IS NOT NULL
ORDER BY 1, 2

--CTEs

WITH PopVSVacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccination) 
AS 
(
SELECT a.continent, a.location, a.date,  a.population, b.new_vaccinations,
SUM(CONVERT(bigint, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.population, a.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS a
FULL JOIN PortfolioProject..CovidVaccinations AS b 
ON a.location = b.location AND a.date = b.date
--WHERE a.continent IS NOT NULL
--ORDER BY 1, 2
)

SELECT *, (RollingPeopleVaccination/Population)*100
FROM PopVSVacc
WHERE RollingPeopleVaccination IS NOT NULL

--TEMP Table

DROP TABLE IF EXISTS #PercentagePopulationVaccination

CREATE TABLE #PercentagePopulationVaccination
(
	Continent nvarchar (255),
	Location nvarchar (255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccination numeric
)

INSERT INTO #PercentagePopulationVaccination
SELECT a.continent, a.location, a.date,  a.population, b.new_vaccinations,
SUM(CONVERT(bigint, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.population, a.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS a
FULL JOIN PortfolioProject..CovidVaccinations AS b 
ON a.location = b.location AND a.date = b.date
--WHERE a.continent IS NOT NULL
--ORDER BY 1, 2

SELECT *, (RollingPeopleVaccination/Population)*100 AS Percentage
FROM #PercentagePopulationVaccination
WHERE RollingPeopleVaccination IS NOT NULL AND Continent IS NOT NULL

---View
CREATE VIEW  PercentagePopulationVaccination  AS
SELECT a.continent, a.location, a.date,  a.population, b.new_vaccinations,
SUM(CONVERT(bigint, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.population, a.date) AS RollingPeopleVaccination
FROM PortfolioProject..CovidDeaths AS a
FULL JOIN PortfolioProject..CovidVaccinations AS b 
ON a.location = b.location AND a.date = b.date
WHERE a.continent IS NOT NULL

SELECT * FROM PercentagePopulationVaccination