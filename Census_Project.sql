----This project is an analysis of Indian Population Census

select *
from Census_data..Growth;

select *
from Census_data..Population;


---Total number of rows in dataset

select count (*)
from Census_data..Growth;

select count (*)
from Census_data..Population;


--- Dataset for specific states say 2 states; jharkhand and bihar

select *
from Census_data..Growth
where state in ('jharkhand', 'bihar')
order by 2; 


---Total popultion in India

select SUM(population) as TotalPopulation
from Census_data..Population;

---Total population by State

select state, SUM(population) as TotalPopulation
from Census_data..Population
group by State
order by 1 asc;


---Average growth of India

select round(AVG(Growth)*100, 2) as avg_growth
from Census_data..Growth;

---Average growth per state

select state, round(AVG(Growth)*100,2) as avg_growth
from Census_data..Growth
group by State
order by 2 desc;


---Average sex ratio

select state, round(AVG(Sex_Ratio),0) as avg_sex_ratio
from Census_data..Growth
group by State
order by 2 desc;


---Average literacy rate

select state, round(AVG(Literacy),0) as avg_literacy_rate
from Census_data..Growth
group by State
having round(AVG(Literacy),0) >80
order by 2 desc;


---Top 5 States showing highest growth ratio

select top 5 state, round(AVG(Growth)*100, 2) as avg_growth
from Census_data..Growth
group by State
order by 2 desc;


---Botom 5 states with lowest sex ratio


select top 5 state, round(AVG(Sex_Ratio),0) as avg_sex_ratio
from Census_data..Growth
group by State
order by 2 asc;


---Top and bottom 5 states in literacy rate

drop table if exists #topstates
create table #topstates
(state nvarchar(255),
	topstates float
	)

	insert into #topstates
	select top 5 state, round(AVG(Literacy),0) as avg_literacy_ratio
from Census_data..Growth
group by State
order by 2 desc;

select *
from #topstates

drop table if exists #bottomstates
create table #bottomstates
(state nvarchar(255),
	bottomstates float
	)

	insert into #bottomstates
	select top 5 state, round(AVG(Literacy),0) as avg_literacy_ratio
from Census_data..Growth
group by State
order by 2 asc;

select *
from #bottomstates

---Using Union operator to combine both tables (top and bottom 5 states)

select *
from #topstates
union
select *
from #bottomstates
order by 2 desc;


---List of States starting with letter A or B

select distinct state
from Census_data..Growth
where lower(state) like 'A%' or lower(state) like 'B%';


---List of States starting with letter A and ending with letter H

select distinct state
from Census_data..Growth
where lower(state) like 'A%' and lower(state) like '%H';


--- Joining both tables to get the individual state population by male and female.

select d.state, sum(d.male_population) as Total_male_population, sum(d.female_population) as Total_female_population, (sum(d.male_population)+sum(d.female_population)) as Total_Population
from
(select c.district, c.state, round(c.population/(c.sex_ratio+1),0) as male_population, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as female_population
from
(select a.district, a.state, a.sex_ratio/1000 as sex_ratio, b.population
from Census_data..Growth a
inner join Census_data..Population b
on a.district=b.district) as c) as d
group by d.state;


---Total literacy rate by state

select d.state, sum(literate_population) as Total_literate_population, sum(illiterate_population) as Total_illiterate_population, (sum(literate_population)+sum(illiterate_population)) as Total_Population
from
(select c.district, c.state, round(c.literacy_ratio*c.population,0) as literate_population, round((1-c.literacy_ratio)*c.population,0) as illiterate_population
from
(select a.district, a.state, a.literacy/100 as literacy_ratio, b.population
from Census_data..Growth as a
inner join Census_data..Population as b
on a.district=b.district) as c) as d
group by d.state


---Population from previous census by state

select d.state, sum(d.previous_census_population) as previous_census_population, sum(d.currect_census_population) currect_census_population
from
(select c.district, c.state, round(c.population/(1+c.Growth_rate),0) as previous_census_population, c.population as currect_census_population
from
(select a.district, a.state, a.Growth as Growth_rate, b.population
from Census_data..Growth a
inner join Census_data..Population b
on a.district=b.district) as c) as d
group by d.state


---Total India's Population from previous and current census

select sum(e.previous_census_population) as Total_Previous_population, sum(e.currect_census_population) as Total_current_population
from
(select d.state, sum(d.previous_census_population) as previous_census_population, sum(d.currect_census_population) currect_census_population
from
(select c.district, c.state, round(c.population/(1+c.Growth_rate),0) as previous_census_population, c.population as currect_census_population
from
(select a.district, a.state, a.Growth as Growth_rate, b.population
from Census_data..Growth a
inner join Census_data..Population b
on a.district=b.district) as c) as d
group by d.state) as e


---Population vs Area

select n.total_area/n.Total_Previous_population as previous_population_per_area, n.total_area/n.Total_current_population as current_population_per_area
from
(select h.*, m.total_area
from
(select '1' as keyy, f.*
from
(select sum(e.previous_census_population) as Total_Previous_population, sum(e.currect_census_population) as Total_current_population
from
(select d.state, sum(d.previous_census_population) as previous_census_population, sum(d.currect_census_population) currect_census_population
from
(select c.district, c.state, round(c.population/(1+c.Growth_rate),0) as previous_census_population, c.population as currect_census_population
from
(select a.district, a.state, a.Growth as Growth_rate, b.population
from Census_data..Growth a
inner join Census_data..Population b
on a.district=b.district) as c) as d
group by d.state) as e) as f) as h
inner join

(select '1' as keyy, g.*
from
(select sum(area_km2) as total_area
from Census_data..Population) as g)as m on h.keyy=m.keyy) as n; 


---Window function (This would give an output of top 3 district from each state with highest literacy rate)

select a.*
from
(select district, state, literacy, rank() 
over(partition by state
order by literacy desc) as Rnk
from Census_data..Growth) as a
where a.Rnk in (1,2,3)
order by State
