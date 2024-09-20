use covid_db;

--To fetch all the table names in the database
 SELECT TABLE_NAME 
 FROM INFORMATION_SCHEMA.TABLES 
 WHERE TABLE_TYPE = 'BASE TABLE';


--1. To find out the death percentage locally and globally

/*
@Author: Rahul 
@Date: 2024-09-18
@Last Modified by: Rahul
@Last Modified: 2024-09-18
@Title : To find out the death percentage locally and globally

*/

--Death percentage locally
SELECT 
    [State UnionTerritory],
    SUM(CAST(Confirmed AS FLOAT)) AS Total_Confirmed,
    SUM(CAST(Deaths AS FLOAT)) AS Total_Deaths,
    CASE 
        WHEN SUM(CAST(Confirmed AS FLOAT)) = 0 THEN 0
        ELSE ROUND((SUM(CAST(Deaths AS FLOAT)) / SUM(CAST(Confirmed AS FLOAT)) * 100), 2)
    END AS death_percentage_locally
FROM 
    covid_19_india
GROUP BY 
    [State UnionTerritory]
ORDER BY
	death_percentage_locally DESC;


-- Death percentage Globally
SELECT 
	[Country Region],
	Confirmed,
	Deaths,
	CASE
		WHEN CAST(Confirmed AS FLOAT) = 0 THEN 0
		ELSE ROUND((CAST(Deaths AS FLOAT) / CAST(Confirmed AS FLOAT) * 100),2)
	END AS death_percentage_globally
FROM
	country_wise_latest;




--2. To find out the infected population percentage locally and globally

/*
@Author: Rahul 
@Date: 2024-09-18
@Last Modified by: Rahul
@Last Modified: 2024-09-18
@Title : To find out the infected population percentage locally and globally

*/

--Locally
SELECT
	SUM(CAST(TotalSamples AS float)),
	SUM(CAST(Positive AS float)),
    ROUND((SUM(CAST(Positive AS float)) / NULLIF(SUM(CAST(TotalSamples AS float)), 0) * 100), 2) AS total_infected_population_locally
FROM 
    StatewiseTestingDetails;


--Globally
SELECT 
	SUM(CAST(Population AS bigint)),
	SUM(CAST(TotalCases AS bigint)),
	ROUND((SUM(CAST(TotalCases AS float))/SUM(CAST(Population AS bigint))*100),2) AS total_infected_population_globally
FROM
	worldometer_data;	




--3. To find out the countries with the highest infection rates

/*
@Author: Rahul 
@Date: 2024-09-18
@Last Modified by: Rahul
@Last Modified: 2024-09-18
@Title : To find out the countries with the highest infection rates

*/

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
    infection_rate DESC;




--4. To find out the countries and continents with the highest death counts

/*
@Author: Rahul 
@Date: 2024-09-19
@Last Modified by: Rahul
@Last Modified: 2024-09-19
@Title : To find out the countries and continents with the highest death counts

*/


--For Continents
SELECT
    Continent, 
    SUM(CAST(TotalDeaths AS INT)) AS total_deaths
FROM 
    worldometer_data
GROUP BY 
    Continent
ORDER BY 
    total_deaths DESC;


--For Countries
SELECT 
    [Country Region], 
    SUM(CAST(TotalDeaths AS INT)) AS total_deaths
FROM 
    worldometer_data
GROUP BY 
    [Country Region]
ORDER BY 
    total_deaths DESC;



--5. Average number of deaths by day (Continents and Countries) 

/*
@Author: Rahul 
@Date: 2024-09-19
@Last Modified by: Rahul
@Last Modified: 2024-09-19
@Title : To find out the average number of deaths by day (Continents and Countries) 

*/

-- For Countries
SELECT 
    [Country Region], 
    SUM(CAST(Deaths AS BIGINT)) / COUNT(DISTINCT Date) AS avg_deaths_per_day
FROM 
    covid_19_clean_complete
GROUP BY 
    [Country Region]
ORDER BY 
    avg_deaths_per_day DESC;


-- For Continents
SELECT 
    w.Continent,
    SUM(CAST(c.Deaths AS BIGINT)) / COUNT(DISTINCT c.Date) AS avg_deaths_per_day
FROM 
    covid_19_clean_complete c
JOIN 
    worldometer_data w
ON 
    c.[Country Region] = w.[Country Region]
GROUP BY 
    w.Continent
ORDER BY 
    w.Continent;


--6. Average of cases divided by the number of population of each country (TOP 10) 

/*
@Author: Rahul 
@Date: 2024-09-19
@Last Modified by: Rahul
@Last Modified: 2024-09-19
@Title : To find out the average of cases divided by the number of population of each country (TOP 10) 

*/

SELECT 
	TOP 10
    [Country Region], 
    ROUND(AVG(CAST(TotalCases AS float)) / NULLIF(SUM(CAST(Population AS float)), 0),2) AS cases_per_population
FROM 
    worldometer_data
WHERE 
    Population > 0 AND TotalCases IS NOT NULL
GROUP BY 
    [Country Region]
ORDER BY 
    cases_per_population DESC;




--7. Considering the highest value of total cases, which countries have the highest rate of infection in relation to population? 

/*
@Author: Rahul 
@Date: 2024-09-19
@Last Modified by: Rahul
@Last Modified: 2024-09-19
@Title : To find out highest value of total cases, which countries have the highest rate of infection in relation to population

*/

WITH InfectionRate AS (
    SELECT 
        [Country Region], 
        ROUND(CAST(TotalCases AS FLOAT) / NULLIF(CAST(Population AS FLOAT), 0) * 100, 3) AS cases_per_population
    FROM 
        worldometer_data
    WHERE 
        TotalCases IS NOT NULL
        AND Population > 0
)

-- Final query to return countries with the highest infection rate
SELECT 
    TOP 10
    [Country Region],
    cases_per_population
FROM 
    InfectionRate
ORDER BY 
    cases_per_population DESC;




--Using JOINS to combine the covid_deaths and covid_vaccine tables :

--1. To find out the population vs the number of people vaccinated

-- Aggregate population and vaccinated individuals

WITH InfectionRates AS (
    SELECT 
        [Country Region] AS Country,
        CAST(TotalCases AS FLOAT) / NULLIF(CAST(Population AS FLOAT), 0) * 100 AS InfectionRate,  -- Calculate infection rate as a percentage
        TotalCases
    FROM 
        dbo.worldometer_data
    WHERE 
        TotalCases IS NOT NULL
        AND Population > 0  -- Only consider countries with valid population data
)
SELECT 
    Country,
    InfectionRate,
    TotalCases
FROM 
    InfectionRates
ORDER BY 
    InfectionRate DESC;



--2. To find out the percentage of different vaccine taken by people in a country
/*
@Author: Rahul 
@Date: 2024-09-19
@Last Modified by: Rahul
@Last Modified: 2024-09-19
@Title : To find out the population vs the number of people vaccinated

*/


WITH HighestPopulationCTE AS (
    SELECT 
        TRY_CAST(MAX(Population) AS BIGINT) AS HighestPopulation
    FROM 
        worldometer_data
    WHERE 
        Continent = 'Asia'
        AND TRY_CAST(Population AS BIGINT) IS NOT NULL
),

LatestDoses AS (
    SELECT 
        TRY_CAST([Total Doses Administered] AS BIGINT) AS TotalDosesAdministered
    FROM 
        covid_vaccine_statewise
    WHERE 
        State = 'India' 
        AND [Updated On] = (
            SELECT 
                MAX([Updated On])
            FROM 
                covid_vaccine_statewise
            WHERE 
                State = 'India'
                AND TRY_CAST([Total Doses Administered] AS BIGINT) IS NOT NULL
        )
    AND TRY_CAST([Total Doses Administered] AS BIGINT) IS NOT NULL
)

SELECT 
    ROUND(TRY_CAST(ld.TotalDosesAdministered AS FLOAT) * 100.0 / TRY_CAST(hp.HighestPopulation AS FLOAT), 2) AS Percentage
	
FROM 
   LatestDoses ld
CROSS JOIN 
    HighestPopulationCTE hp;





--3. To find out percentage of people who took both the doses

/*
@Author: Rahul 
@Date: 2024-09-19
@Last Modified by: Rahul
@Last Modified: 2024-09-19
@Title : To find out the percentage of people who took both the doses

*/


SELECT 
    [Updated On] AS Date,
    State,
    CASE 
        WHEN NULLIF(TRY_CAST([Total Doses Administered] AS FLOAT), 0) IS NULL THEN NULL
        ELSE ROUND((TRY_CAST([ Covaxin (Doses Administered)] AS FLOAT) * 100.0 / TRY_CAST([Total Doses Administered] AS FLOAT)), 2)
    END AS [Covaxin_Percentage],
    CASE 
        WHEN NULLIF(TRY_CAST([Total Doses Administered] AS FLOAT), 0) IS NULL THEN NULL
        ELSE ROUND((TRY_CAST([CoviShield (Doses Administered)] AS FLOAT) * 100.0 / TRY_CAST([Total Doses Administered] AS FLOAT)), 2)
    END AS [CoviShield_Percentage],
    CASE 
        WHEN NULLIF(TRY_CAST([Total Doses Administered] AS FLOAT), 0) IS NULL THEN NULL
        ELSE ROUND((TRY_CAST([Sputnik V (Doses Administered)] AS FLOAT) * 100.0 / TRY_CAST([Total Doses Administered] AS FLOAT)), 2)
    END AS [Sputnik_V_Percentage]
FROM 
    covid_vaccine_statewise
ORDER BY 
    Date ASC;



















