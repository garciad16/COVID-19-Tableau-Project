SELECT * 
FROM PortfolioProject.dbo.CovidDeaths
--WHERE continent is NOT NULL
order by 3, 4

--SELECT * 
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3, 4


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%canada' AND continent is NOT NULL
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%canada' AND continent is NOT NULL
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population, date
order by  date DESC, PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, date, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, date
order by  date DESC, TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths AS int)) AS TotalNewDeaths,  SUM(cast(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%canada' AND 
WHERE continent is NOT NULL
order by 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
order by 2, 3


-- USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 AS RollingPeopleVaccinatedPerPopulationPercent
From PopvsVac


-- Use Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2, 3

SELECT *, (RollingPeopleVaccinated/Population) * 100 AS RollingPeopleVaccinatedPerPopulationPercent
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS dea
JOIN PortfolioProject.dbo.CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2, 3

Select *
From PercentPopulationVaccinated