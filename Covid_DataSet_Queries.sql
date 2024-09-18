use covid_db;

 SELECT TABLE_NAME 
 FROM INFORMATION_SCHEMA.TABLES 
 WHERE TABLE_TYPE = 'BASE TABLE';


--1. To find out the death percentage locally and globally

SELECT 
    Deaths,
    Confirmed,
    CASE 
        WHEN CAST(Confirmed AS FLOAT) = 0 THEN 0
        ELSE ROUND((CAST(Deaths AS FLOAT) / CAST(Confirmed AS FLOAT) * 100), 0)
    END AS death_percentage_locally
FROM 
    covid_19_india;

SELECT 
	Deaths,
	Confirmed,
	CASE
		WHEN CAST(Confirmed AS FLOAT) = 0 THEN 0
		ELSE ROUND((CAST(Deaths AS FLOAT) / CAST(Confirmed AS FLOAT) * 100),0)
	END AS death_percentage_globally
FROM
	country_wise_latest;


--2. To find out the infected population percentage locally and globally

SELECT 
    SUM(CAST(Confirmed AS BIGINT)) AS total_infected_population
FROM 
    covid_19_india;

SELECT 
	    SUM(CAST(Confirmed AS BIGINT)) AS total_infected_population
FROM
	country_wise_latest;	


--3. To find out the countries with the highest infection rates

SELECT 
    [Country Region], 
    TotalCases, 
    Population, 
    CASE 
        WHEN Population = 0 THEN 0 
        ELSE ROUND((CAST(TotalCases AS FLOAT) / CAST(Population AS FLOAT) * 100), 2)
    END AS infection_rate
FROM 
    worldometer_data 
ORDER BY 
    infection_rate DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 


--4. To find out the countries and continents with the highest death counts

SELECT 
    Continent, 
    SUM(CAST(TotalDeaths AS BIGINT)) AS total_deaths
FROM 
    worldometer_data
GROUP BY 
    Continent
ORDER BY 
    total_deaths DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 


SELECT 
    [Country Region], 
    SUM(CAST(TotalDeaths AS BIGINT)) AS total_deaths
FROM 
    worldometer_data
GROUP BY 
    [Country Region]
ORDER BY 
    total_deaths DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 


--5. Average number of deaths by day (Continents and Countries) 

SELECT 
    [Country Region], 
    SUM(CAST(Deaths AS BIGINT)) / COUNT(DISTINCT Date) AS avg_deaths_per_day
FROM 
    covid_19_clean_complete
GROUP BY 
    [Country Region]
ORDER BY 
    avg_deaths_per_day DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY; 


--6. Average of cases divided by the number of population of each country (TOP 10) 

SELECT 
    [Country Region], 
    ROUND(SUM(CAST(TotalCases AS FLOAT)) / NULLIF(SUM(CAST(Population AS FLOAT)), 0),2) AS cases_per_population
FROM 
    worldometer_data
WHERE 
    Population > 0 AND TotalCases IS NOT NULL
GROUP BY 
    [Country Region]
ORDER BY 
    cases_per_population DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;



--7. Considering the highest value of total cases, which countries have the highest rate of infection in relation to population? 

WITH MaxTotalCases AS (
    SELECT 
        MAX(CAST(TotalCases AS BIGINT)) AS max_total_cases
    FROM 
        worldometer_data
    WHERE 
        TotalCases IS NOT NULL
),
InfectionRate AS (
    SELECT 
        [Country Region], 
        CAST(TotalCases AS FLOAT) / NULLIF(CAST(Population AS FLOAT), 0) * 100 AS cases_per_population
    FROM 
        worldometer_data
    WHERE 
        TotalCases = (SELECT max_total_cases FROM MaxTotalCases)
        AND Population > 0
)

SELECT 
    [Country Region],
    cases_per_population
FROM 
    InfectionRate
ORDER BY 
    cases_per_population DESC;



--Using JOINS to combine the covid_deaths and covid_vaccine tables :

--1. To find out the population vs the number of people vaccinated

-- Aggregate population and vaccinated individuals
WITH PopulationData AS (
    SELECT 
        [State UnionTerritory] AS State,
        SUM(ConfirmedIndianNational + ConfirmedForeignNational) AS TotalPopulation
    FROM 
        covid_data
    GROUP BY 
        [State UnionTerritory]
),
VaccinationData AS (
    SELECT 
        State,
        SUM(TotalIndividualsVaccinated) AS TotalVaccinated
    FROM 
		covid_vaccine_statewise	
    GROUP BY 
        State
)

-- Join the aggregated data
SELECT 
    p.State,
    p.TotalPopulation,
    v.TotalVaccinated,
    CASE
        WHEN p.TotalPopulation = 0 THEN 0
        ELSE ROUND((CAST(v.TotalVaccinated AS FLOAT) / CAST(p.TotalPopulation AS FLOAT) * 100), 2)
    END AS VaccinationRatePercentage
FROM 
    covid_19_india p
LEFT JOIN 
    covid_vaccine_statewise v
ON 
    p.State = v.State
ORDER BY 
    VaccinationRatePercentage DESC;

















