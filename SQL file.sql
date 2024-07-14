select * from newdata.table1 order by 3,4;

/* select * from newdata.table2 order by 4; */

/* we can use certain column in table 1 */

select location, `date`, population, total_cases, new_cases from newdata.table1 where continent <> "" order by 2;

update newdata.table1 set total_cases = Null where total_cases = '';

/* we going to find the percentage of total cases vs new cases */

select location, `date`, population, total_cases, new_cases,round((new_cases/total_cases)*100,3) as percentage_cases 
from newdata.table1 where continent <> "" order by 2;

/* we going to find the percentage of total cases vs population */

select location, `date`, population, total_cases, new_cases,round((total_cases+new_cases)/population*100,3) as population_case_percentage 
from newdata.table1 where continent <> "" order by 2;

 /* we going to find the country with highest cases rate compared with population */
 
select location, population, max(total_cases) as highest_cases, max(new_cases) as highest_new_cases, round(max((total_cases+new_cases)/population)*100,3) as population_case_percentage
from newdata.table1 where continent <> "" group by location,population order by population_case_percentage desc;

/* we going to find the continent with highest cases rate compare with population */

select continent, max(total_cases) as highest_cases, max(new_cases) as highest_new_cases, round(max((total_cases+new_cases)/population)*100,3) as population_case_percentage
from newdata.table1 where continent <> "" group by continent order by population_case_percentage desc;

/* we going to find the global cases numbers based on the date */

select `date`, sum(total_cases) as cases_per_day, sum(new_cases) as new_cases_per_day, 
round((sum(new_cases)/sum(total_cases))*100,3) as percentage_cases_per_day
from newdata.table1 where continent <> "" group by `date`;

/* we going to find the global cases numbers */

select sum(total_cases) as total_cases ,sum(new_cases) as new_cases, 
round((sum(new_cases)/sum(total_cases))*100,3) as percentage_cases
from newdata.table1 where continent <> "";

/* We going to table 2 */

select * from newdata.table2 order by 4;

/* we can use certain column in table 2 */

select location, `date`, total_tests, new_tests, total_vaccinations, new_vaccinations from newdata.table2 
where continent <> "" order by 2;

update newdata.table2 set total_tests = Null
where total_tests = '';

update newdata.table2 set new_tests = Null
where new_tests = '';

update newdata.table2 set total_vaccinations = Null
where total_vaccinations = '';

update newdata.table2 set new_vaccinations = Null
where new_vaccinations = '';

/* we going to find the percentage of total vaccinations vs new vaccinations */

select t1.location, t1.`date`, t2.total_tests, t2.new_tests, t2.total_vaccinations, t2.new_vaccinations, 
round((t2.new_vaccinations/t2.total_vaccinations)*100,3) as percentage_vaccinations from newdata.table1 t1 
join newdata.table2 t2 on t1.location = t2.location and t1.`date` = t2.`date` where t1.continent <> "" order by 2;

/* we going to find the sum of total vaccinations using partition by location */

select t1.location, t1.`date`, t2.total_tests, t2.new_tests, t2.total_vaccinations, t2.new_vaccinations, 
round((t2.new_vaccinations/t2.total_vaccinations)*100,3) as percentage_vaccinations,
sum(t2.total_vaccinations) over(partition by t1.location order by t1.location,t1.`date`) as vaccinations_sum from newdata.table1 t1 
join newdata.table2 t2 on t1.location = t2.location and t1.`date` = t2.`date` where t1.continent <> "" order by 2;

/* we going to use CTE */

with newthing(location, `date`, total_tests, new_tests, total_vaccinations, new_vaccinations, percentage_vaccinations, vaccinations_sum)
as
(
select t1.location, t1.`date`, t2.total_tests, t2.new_tests, t2.total_vaccinations, t2.new_vaccinations, 
round((t2.new_vaccinations/t2.total_vaccinations)*100,3) as percentage_vaccinations,
sum(t2.total_vaccinations) over(partition by t1.location order by t1.location,t1.`date`) as vaccinations_sum from newdata.table1 t1 
join newdata.table2 t2 on t1.location = t2.location and t1.`date` = t2.`date` where t1.continent <> ""
)
select *, round((vaccinations_sum/total_vaccinations)*100,3) as vaccinations_tests from newthing order by 2;

/* we going to create a temperley table */

drop table if exists newdata.tabletemp;
create table newdata.tabletemp
(
	continent varchar(250),
    location varchar(250),
    `date` text,
    total_test numeric,
    total_vaccinations numeric,
    vaccinations_sum numeric
);

insert into newdata.tabletemp
select t1.continent, t1.location, t1.`date`, t2.total_tests, t2.total_vaccinations, 
sum(t2.total_vaccinations) over(partition by t1.location order by t1.location,t1.`date`) as vaccinations_sum from newdata.table1 t1 
join newdata.table2 t2 on t1.location = t2.location and t1.`date` = t2.`date`;

select * from newdata.tabletemp order by 3;

/* we going to create view to store data for later visualizations */

create view newdata.newdataview as
select t1.continent, t1.location, t1.`date`, t2.total_tests, t2.total_vaccinations, 
sum(t2.total_vaccinations) over(partition by t1.location order by t1.location,t1.`date`) as vaccinations_sum from newdata.table1 t1 
join newdata.table2 t2 on t1.location = t2.location and t1.`date` = t2.`date`;

select * from newdata.tabletemp;

/* Have a nice day */