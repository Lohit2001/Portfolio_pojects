use Portfolio_project
--SELECT *
--FROM Portfolio_project..CovidDeaths
--ORDER BY 3, 4


--SELECT *
--FROM Portfolio_project..CovidVaccinations
--ORDER BY 3, 4

-- Selcting the data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_project..CovidDeaths
order by 1,2


--Looking at total deaths vs total cases
--Shows likelihood of dying
Select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Portfolio_project..CovidDeaths
where location like '%india%'
order by 1,2

--Now we are going to check what percentage of population has gotten covid
Select location, date, population, (total_cases/population)*100 as covid_percentage
From Portfolio_project..CovidDeaths
--where location like '%india%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as covid_affected_percentage
From Portfolio_project..CovidDeaths
--where location like '%india%'
group by location, population
order by 4 desc

--Showing countries with highes death count
Select location, MAX(total_deaths) as Total_death_count
From Portfolio_project..CovidDeaths
group by location
order by Total_death_count desc
--IN this case a weird unsorted data was seen, which was caused due to some problem with the data type of total_deaths(nvarchar255)
--The above issue can be resolved by changing the data type of this column....as shown below
Select location, MAX(cast(total_deaths as int)) as Total_death_count
From Portfolio_project..CovidDeaths
where continent is not null
group by location
order by Total_death_count desc

--Lets see the same for continents
Select continent, MAX(cast(total_deaths as int)) as Total_death_count
From Portfolio_project..CovidDeaths
where continent is not null
group by continent
order by Total_death_count desc
--But this query is not showing the exact figures for these continents......maybe because of null value non inclusion
--we can produce better results....in this particular datasets case by using :
Select location, MAX(cast(total_deaths as int)) as Total_death_count
From Portfolio_project..CovidDeaths
where continent is null
group by location
order by Total_death_count desc

--Global Numbers
Select date, SUM(new_cases) as Total_cases, SUM(CAST(new_deaths as int)) as Total_deaths,(SUM(CAST(new_deaths as int))/SUM(new_cases))*100
From Portfolio_project..CovidDeaths
Where continent is not null
Group by date
order by 1,2


---Now let us join the two tables, i.e. deaths and vaccinations
-- And looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as Rolling_People_vaccinated
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Now suppose we want to perform some further calculations using the rolling_people_vaccinated column....but we can not directly use it in the same query
--Using CTE
with popsVSvac(continent, location, date, population, new_vaccinations,  Rolling_People_vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as Rolling_People_vaccinated
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100
From popsVSvac

--Creating view
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.date) as Rolling_People_vaccinated
From Portfolio_project..CovidDeaths dea
Join Portfolio_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--Now we can use the view created for making visualizations latr....by directly accessing the table
Select*
from PercentPopulationVaccinated