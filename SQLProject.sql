--I am using Oracle SQL Developer for creating this database
SELECT *
FROM coviddeaths
WHERE continent IS NOT NULL;

-- Selecting data that we are going to manipulate/analyze later on
SELECT location, actual_date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent IS NOT NULL; 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the Philippines

SELECT location, actual_date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location = 'Philippines' AND continent IS NOT NULL
ORDER BY actual_date ASC;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, actual_date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
FROM coviddeaths
ORDER BY 1,2;

-- showing countries with Highest Infection Rate compared to respective population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
WHERE total_cases IS NOT NULL AND population IS NOT NULL
Group BY location, population
ORDER BY PercentPopulationInfected DESC;

-- showing countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL AND total_deaths IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC;

-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
Where continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--total of cases worldwide as of July 22, 2021
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT death.continent, death.location, death.actual_date, death.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.actual_date) as RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vacc
ON death.location = vacc.location
AND death.actual_date = vacc.actual_date
WHERE death.continent IS NOT NULL
ORDER BY 2,3;

-- i created a table and a view with the same data for visualization later
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Actual_date date,
Population number,
New_vaccinations number,
RollingPeopleVaccinated number
);

INSERT INTO PercentPopulationVaccinated
SELECT death.continent, death.location, death.actual_date, death.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.actual_date) as RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vacc
ON death.location = vacc.location
AND death.actual_date = vacc.actual_date

SELECT continent,location,actual_date,population,new_vaccinations,rollingpeoplevaccinated,
(rollingpeoplevaccinated/population)*100 AS VaccPercentage
FROM PercentPopulationVaccinated;

--creating view for visualizations (later)

CREATE VIEW PopulationVaccinated AS
SELECT death.continent, death.location, death.actual_date, death.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.actual_date) as RollingPeopleVaccinated
FROM coviddeaths death
JOIN covidvaccinations vacc
ON death.location = vacc.location
AND death.actual_date = vacc.actual_date
WHERE death.continent IS NOT NULL
ORDER BY 2,3;


