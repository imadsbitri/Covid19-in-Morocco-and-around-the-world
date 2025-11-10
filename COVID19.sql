DROP TABLE IF EXISTS covid_deaths;

CREATE TABLE covid_deaths (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    population BIGINT,
    total_cases NUMERIC,
    new_cases NUMERIC,
    new_cases_smoothed NUMERIC,
    total_deaths NUMERIC,
    new_deaths NUMERIC,
    new_deaths_smoothed NUMERIC,
    total_cases_per_million NUMERIC,
    new_cases_per_million NUMERIC,
    new_cases_smoothed_per_million NUMERIC,
    total_deaths_per_million NUMERIC,
    new_deaths_per_million NUMERIC,
    new_deaths_smoothed_per_million NUMERIC,
    reproduction_rate NUMERIC,
    icu_patients NUMERIC,
    icu_patients_per_million NUMERIC,
    hosp_patients NUMERIC,
    hosp_patients_per_million NUMERIC,
    weekly_icu_admissions NUMERIC,
    weekly_icu_admissions_per_million NUMERIC,
    weekly_hosp_admissions NUMERIC,
    weekly_hosp_admissions_per_million NUMERIC
);

DROP TABLE IF EXISTS covid_vaccinations;

CREATE TABLE covid_vaccinations (
    iso_code VARCHAR(10),
    continent VARCHAR(50),
    location VARCHAR(100),
    date DATE,
    new_tests NUMERIC,
    total_tests NUMERIC,
    total_tests_per_thousand NUMERIC,
    new_tests_per_thousand NUMERIC,
    new_tests_smoothed NUMERIC,
    new_tests_smoothed_per_thousand NUMERIC,
    positive_rate NUMERIC,
    tests_per_case NUMERIC,
    tests_units VARCHAR(50),
    total_vaccinations NUMERIC,
    people_vaccinated NUMERIC,
    people_fully_vaccinated NUMERIC,
    new_vaccinations NUMERIC,
    new_vaccinations_smoothed NUMERIC,
    total_vaccinations_per_hundred NUMERIC,
    people_vaccinated_per_hundred NUMERIC,
    people_fully_vaccinated_per_hundred NUMERIC,
    new_vaccinations_smoothed_per_million NUMERIC,
    stringency_index NUMERIC,
    population_density NUMERIC,
    median_age NUMERIC,
    aged_65_older NUMERIC,
    aged_70_older NUMERIC,
    gdp_per_capita NUMERIC,
    extreme_poverty NUMERIC,
    cardiovasc_death_rate NUMERIC,
    diabetes_prevalence NUMERIC,
    female_smokers NUMERIC,
    male_smokers NUMERIC,
    handwashing_facilities NUMERIC,
    hospital_beds_per_thousand NUMERIC,
    life_expectancy NUMERIC,
    human_development_index NUMERIC
);

-- select data

select location , date , total_cases, new_cases,total_deaths , population
from covid_deaths;

--Total cases vs Total deaths

select location , date , total_cases, total_deaths , (total_deaths/total_cases)*100 AS Death_percentage
from covid_deaths;

--Percentage of population that got covid 

select location , date , total_cases, total_deaths , population, (total_cases/population)*100 AS Total_cases_per_population
from covid_deaths
Where location like 'Morocco';

--Countries with highest Rate infection per population 

SELECT 
  location,
  MAX((total_cases / population) * 100) AS total_cases_per_population
FROM covid_deaths
WHERE date = '2021-04-30'
GROUP BY location
ORDER BY total_cases_per_population DESC;

--Countries with highest death count per population 

SELECT 
  location,
  MAX((total_deaths / population) * 100) AS deaths_per_population
FROM covid_deaths
WHERE date = '2021-04-30' 
GROUP BY location
ORDER BY deaths_per_population DESC;

-- Covid vaccination around the world 

select*
from covid_vaccinations;

--Vaccinations per country 

SELECT 
  location,
  MAX((total_deaths / population) * 100) AS deaths_per_population
FROM covid_vaccinations
WHERE date = '2021-04-30' 
GROUP BY location
ORDER BY deaths_per_population DESC;

--Join deaths and vaccinations to get vaccination rate

SELECT d.location, d.date, d.population,
       v.people_vaccinated, 
       (v.people_vaccinated/d.population)*100 AS vaccination_percentage
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date;

--Total vaccinations for a specific country over time

SELECT date, total_vaccinations
FROM covid_vaccinations
WHERE location = 'Morocco'
ORDER BY date;

--Top 5 countries by vaccination percentage on a specific date

SELECT d.location, (v.people_vaccinated/d.population)*100 AS vaccination_percentage
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.date = '2021-04-30'
ORDER BY vaccination_percentage DESC
LIMIT 5;

--Total cases and deaths worldwide on a specific date

SELECT SUM(total_cases) AS total_cases_worldwide, 
       SUM(total_deaths) AS total_deaths_worldwide
FROM covid_deaths
WHERE date = '2021-04-30';

-- Morocco vaccination status (High/Medium/Low) on each date
SELECT v.date, v.people_vaccinated, d.population,
       (v.people_vaccinated/d.population)*100 AS vaccination_percentage,
       CASE 
           WHEN (v.people_vaccinated/d.population)*100 > 50 THEN 'High'
           WHEN (v.people_vaccinated/d.population)*100 BETWEEN 20 AND 50 THEN 'Medium'
           ELSE 'Low'
       END AS vaccination_status
FROM covid_vaccinations v
JOIN covid_deaths d
ON v.location = d.location AND v.date = d.date
WHERE v.location ILIKE 'morocco'
ORDER BY v.date;

--Deaths per 100 people in Morocco over time

SELECT d.date, (d.total_deaths/d.population)*100 AS deaths_per_100
FROM covid_deaths d
WHERE d.location ILIKE 'morocco'
ORDER BY d.date;

--Total cases, deaths, and fully vaccinated percentage on latest date

SELECT d.location, d.total_cases, d.total_deaths,
       (v.people_fully_vaccinated/d.population)*100 AS fully_vaccinated_percentage
FROM covid_deaths d
JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.location ILIKE 'morocco'
ORDER BY d.date DESC
LIMIT 1;