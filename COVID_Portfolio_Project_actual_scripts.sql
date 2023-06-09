Select *
From PortfolioProject..CovidDeaths
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select data to be used
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2

--Looking at total cases vs total deaths
--shows the likelihood of dying if you contact covid in Nigeria (your country)
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location = 'Nigeria' --where location like '%states%'
Order By 1,2

--Looking at the total cases vs the population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where location = 'Nigeria' --where location like '%states%'
Order By 1,2

--Looking at Countries with highest infection rates compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'Nigeria' --where location like '%states%'
Group By location, population
Order By 4 DESC

--Showing Countries with highest death count per population
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
Group By location
Order By 2 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
Group By continent
Order By 2 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT(Update)
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NULL
Group By location
Order By 2 DESC

--Showing Continent with highest death count per population
Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
Group By continent
Order By 2 DESC

--GLOBAL NUMBERS
Select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
GROUP BY date
Order By 1,2

Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent IS NOT NULL
--GROUP BY date
Order By 1,2

Select *
From PortfolioProject..CovidVaccinations

--Looing at total population vs vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent IS NOT NULL
Order By 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent IS NOT NULL
Order By 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.population, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent IS NOT NULL
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

 --as CurrentTotalVaccination
--TEMP TABLE

DROP Table If EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.population, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--where dea.continent IS NOT NULL
--Order By 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATING VIEWS

Create View PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.population, dea.date) As RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent IS NOT NULL
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated