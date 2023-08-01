select *
from PortfolioProject..CovidDeaths
order by 3,4
select *
from PortfolioProject..CovidVaccinations
--where new_tests is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- total cases vs total deaths 
select location, max(total_cases) as Totalcases, max (total_deaths) as Totaldeaths
from PortfolioProject..CovidDeaths
group by location
--order by Maxdeaths desc

drop table #temp_total
create table #temp_total (
location varchar(100), Totalcases int,Totaldeaths int)
insert into #temp_total
select location, max(total_cases) as Totalcases, max (total_deaths) as Totaldeaths
from PortfolioProject..CovidDeaths
group by location

select count (Totalcases) as AllCases, count (Totaldeaths) as Alldeaths
from #temp_total

select*, (Totaldeaths/Totalcases)*100
from #temp_total



-----
update PortfolioProject..CovidDeaths
set total_deaths= 0
where total_deaths is null
update PortfolioProject..CovidDeaths
set total_cases= 0
where total_cases is null

select location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as Deathrate
from PortfolioProject..CovidDeaths
where location like '%states%'

select location, max(total_cases), max(total_deaths),count(new_cases)
from PortfolioProject..CovidDeaths
where location like '%states%' --and total_deaths > 100000
group by location  -- I can't get the max of max(total_deaths), count(new_cases)!!!!!


---looking at total cases vs population

select location, max(total_cases),population, (max(total_cases)/population)
from PortfolioProject..CovidDeaths
group by location, population

select location, population
from PortfolioProject..CovidDeaths


--26-07-2023
--start all over again 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


-- looking at total cases vs total deaths

select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathRate
from PortfolioProject..CovidDeaths
where total_cases is not null and total_cases <> 0 and location like '%morocco%'
-------division over 0 
update PortfolioProject..CovidDeaths
set total_deaths= 'NULL'
where total_deaths= 0
update PortfolioProject..CovidDeaths
set total_cases= 'NULL'
where total_cases=0
update PortfolioProject..CovidDeaths
set new_cases= 'NULL'
where total_cases=0
---- -----------------------------------------------------can"t convert nvarchar (null) to int (0) ==> solution
UPDATE PortfolioProject..CovidDeaths
SET total_cases = CONVERT(INT, COALESCE(total_cases, '0'))

UPDATE PortfolioProject..CovidDeaths
--SET total_deaths = Cast(INT, COALESCE(total_deaths, '0'))
--SET total_deaths = CAST(COALESCE(total_deaths, '0') AS INT);
SET total_deaths = CAST(COALESCE(NULLIF(total_deaths, 'NULL'), '0') AS INT) -- this one works !
UPDATE PortfolioProject..CovidDeaths
--SET new_cases = CAST(COALESCE(NULLIF(new_cases, 'NULL'), '0') AS INT) 
SET new_cases = CONVERT(INT, COALESCE(new_cases, '0'))



--looking at total case svs population


select location, date, total_cases, population, (total_cases/population)*100 as Percetnpopulationinfected
from PortfolioProject..CovidDeaths
where location like '%states%'

-- what country has the highest infection rate 
select location,   max (total_cases),max( (total_cases/population)*100) as MaxPercetnpopulationinfected
from PortfolioProject..CovidDeaths
group by location, population
order by 3 desc



-- Death retae regarding to population
select location,   max (total_cases),max( (total_cases/population)*100) as MaxPercetnpopulationinfected
from PortfolioProject..CovidDeaths
group by location, population
order by 3 desc


select location, population, max(total_deaths) as MaxTotalDeaths, max( (total_deaths/population)*100) as MaxPercetnpopulationdied
from PortfolioProject..CovidDeaths
group by location, population
order by 3 desc
---=> we don't get the max of total death because some data is a nvarchar and not numeric. we got (austria,9997) while Europe got more deaths
--=> solution: cast

select location, population, max(cast(total_deaths as int)) as MaxTotalDeaths, max( (total_deaths/population)*100) as MaxPercetnpopulationdied
from PortfolioProject..CovidDeaths
where Continent is not null
group by location, population
order by 3 desc

----Let's break things down by continent
select  Continent, location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths

where Continent is not null
order by 1,2

drop table if exists #temp_Continent
create table #temp_Continent
(temp_Continent varchar(100),
temp_maxdeaths int,
temp_population int)

insert into #temp_Continent
select  Continent, max(total_deaths) as Maxdeaths,  population
from PortfolioProject..CovidDeaths
where Continent is not null
group by Continent, population
order by 1

select *
from #temp_Continent
order by 1

select temp_Continent, sum(cast(temp_maxdeaths as BIGINT)) as SumCases, sum(cast (temp_population as BIGINT)) as SumPopulation
from #temp_Continent
where temp_population is not null
group by temp_Continent

---reference code
select Continent, location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


select location, max(cast(total_deaths as bigint)), population
from PortfolioProject..CovidDeaths
where Continent is null
group by location, population
order by 2  desc







--showing continents with the highest death count per population

select Continent, location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

drop table if exists #temp_deathcountperpopulation
create table #temp_deathcountperpopulation
(temp_continent varchar (100), temp_location varchar (100), temp_totaldeaths int, temp_population int)

insert into #temp_deathcountperpopulation
select Continent, location, max(cast (total_deaths as bigint)) as TotalDeathsPerLocation, population
from PortfolioProject..CovidDeaths
where Continent is not null
group by Continent, location, population
order by 1

create table #temp2
(temp_continent2 varchar (100), maxdeathpercontinent2 int)

insert into #temp2
select temp_continent, max(cast(temp_totaldeaths as int)) as maxdeathpercontinent
from #temp_deathcountperpopulation
group by temp_continent
order by 2 desc
------------need to siplay the location related to this max

select *
from #temp_deathcountperpopulation
select *
from #temp2

select *
from #temp_deathcountperpopulation t1
inner join #temp2 t2
on t1.temp_totaldeaths=t2.maxdeathpercontinent2

----------solution ,  by using inner join 
-------------first , create the first table (t1) with all the info 
-------------second, create table t2 with only 2 columns (continent and max) to avoid group by problems
-------------third, join t1 and t2 based On the column of max 



--Global numbers 
---per day
select date, sum (cast (new_cases as int )) as TotalCases, sum (cast (new_deaths as int )) as Totaldeaths, 
(sum (cast (new_deaths as int ))*1.0) /(sum (cast (new_cases as int ))*1.0)*100  as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1

---per day
select sum (cast (new_cases as int )) as TotalCases, sum (cast (new_deaths as int )) as Totaldeaths, 
(sum (cast (new_deaths as int ))*1.0) /(sum (cast (new_cases as int ))*1.0)*100  as DeathRate
from PortfolioProject..CovidDeaths
where continent is not null
order by 1



--Covid vaccinatio table. looking at total vaccinations per population 
select t1.continent, t1.location, t1.date, t1.population, t2.total_vaccinations, t2.new_vaccinations
from PortfolioProject..CovidDeaths t1
full outer join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
where t1.continent is not null and t1.location like '%alb%'
order by 1




select t1.location, t1.population, max (cast(t2.total_vaccinations as int)) as totalvacc,  
max (cast(t2.total_vaccinations as int))/t1.population *100 as vaccinationRate,sum(cast(t2.new_vaccinations as int))
from PortfolioProject..CovidDeaths t1
full outer join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
--where t1.continent is null 
where t1.continent is not null 
group by t1.population, t1.location
order by 1

-----new vaccinations per day. This code snippet gives the sum of all vaccinations per location
Select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
--, (SUM(cast(t2.new_vaccinations as int)))  OVER (Partition by t1.Location) as TotalPeopleVaccinated
----Never put SUM btw () , otherwise the code snippet won't work !!!!
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.Location ) as TotalPeopleVaccinated
From PortfolioProject..CovidDeaths t1
join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
--where t1.continent is null 
where t1.continent is not null --and t1.location like 'canada'
order by 1


-----new vaccinations per day. This code snippet gives, at a specific day, the sum of all vaccinations per location, until this day => called Rolling 
-----Rolling count => use order by date within Partition 

Select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.Location order by t1.date, t1.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths t1
join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
where t1.continent is not null and t1.location like 'albania'
order by 1
---=> using temp table. like you create a genuine table (means a real table)
drop table if exists #temp_rollingcount
Create table #temp_rollingcount
(C varchar (100),
l varchar (100),
d varchar (100),
p int,
new int, 
rolling int)

insert into #temp_rollingcount
Select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.Location order by t1.date, t1.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths t1
join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
where t1.continent is not null --and t1.location like 'albania'
order by 1

--select *, (max(rolling)/p*100)  over (partition by l) as VaccPercent
-- this will never work (max(rolling)/p*100) => corrected max(rolling) over (partition by l) /p*100. create column first then do operations
select *, max(cast(rolling as float)) over (partition by l) /p*100 as VaccPercent
from #temp_rollingcount

---Golden rules
--1. when getting 0 whene we should get non 0 => change cast ( value as int) to float. we get 0 because is the integer part of the division a/b
--2. when using CTE or temp tables: when you create a new column (doesn't already exists in your table) and you want to performe calculations on it. 
--to make this new column 'official' you take the same code to create cte or temp table then you perform calculations. 
--3.
--select *, (max(rolling)/p*100)  over (partition by l) as VaccPercent
-- this will never work (max(rolling)/p*100) => corrected max(rolling) over (partition by l) /p*100. create column first then do operations

select *, cast(rolling as float)/p*100 as VaccPercent
from #temp_rollingcount
where l like 'albania'



----=>using cte. Always use with table () as (..) Select from. otherwise error 
with popvsvacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.Location order by t1.date, t1.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths t1
join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
where t1.continent is not null --and t1.location like 'albania' I don't thinsk we can go any further 
--order by 1
)
select *, (RollingPeopleVaccinated/population)*100 as VaccPercent
from popvsvacc
where location like 'albania'


--Create view forlater visualisation
--drop view if exists rollingcountPurcentpopulationvaccinated
-----Drop the existing view if it already exists
IF OBJECT_ID('rollingcountPurcentpopulationvaccinated', 'V') IS NOT NULL
    DROP VIEW rollingcountPurcentpopulationvaccinated;
-----Specifiy the data base. I cant see the view on objects explorere though refreshed 
USE PortfolioProject
create view rollingcountPurcentpopulationvaccinated
as 
Select t1.continent, t1.location, t1.date, t1.population, t2.new_vaccinations
, SUM(cast(t2.new_vaccinations as int)) OVER (Partition by t1.Location order by t1.date, t1.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths t1
join PortfolioProject..CovidVaccinations t2
on t1.location=t2.location
and t1.date=t2.date
where t1.continent is not null --and t1.location like 'albania'
--order by 1