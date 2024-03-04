create database HR;
use HR;
select * from hr_new;

alter table hr_new 
change column ï»¿id emp_id varchar(20)  null;
describe hr_new;

set sql_safe_updates=0;

update hr_new
set birthdate = case
  when birthdate like '%-%' then str_to_date(birthdate, '%d-%m-%y') 
  when birthdate like '%/%' then str_to_date(birthdate, '%m/%d/%Y') 
  else null
end;

alter table hr_new
modify column birthdate date;

update hr_new
set hire_date = case
	when hire_date like '%/%' then str_to_date(hire_date, '%m/%d/%Y')
    when hire_date like '%-%' then str_to_date(hire_date, '%d-%m-%y')
    else null
end;

alter table hr_new
modify column hire_date date;

update hr_new
set termdate=date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s'))
where termdate is not null and termdate!='';

update hr_new
set termdate=null
where termdate='';


alter table hr_new
modify column termdate date;

alter table hr_new
add column age int;

update hr_new
set age=timestampdiff(year,birthdate,curdate());

select
	min(age) as youngest,
    max(age) as oldest
from hr_new;

select count(*) from hr_new
where age <18;  

-- Gender breakdown of the Emplopyees

select gender, count(*) as count
from hr_new
where age >=18 and termdate is null
group by gender;

-- race breakdown of the Employees

select race, count(*) as count 
from hr_new
where age >=18 and termdate is null
group by race
order by count(*) desc;

-- Breakdown of Age groups

select
	case
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        else '55+'
        end as age_group,
        count(*) as count
from hr_new
where age >=18 and termdate is null
group by age_group
order by age_group asc;

select
	case
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
        else '55+'
        end as age_group,gender,
        count(*) as count
from hr_new
where age >=18 and termdate is null
group by age_group,gender
order by age_group,gender asc;

-- number of employees work at headquaters vs Remote

select location, count(*) as count
from hr_new
where age >=18 and termdate is null
group by location;

-- gender distribution across departments

select gender,department, count(*) as count
from hr_new
where age >=18 and termdate is null
group by department, gender
order by department;

-- distribution of job titles across the company

select jobtitle, count(*)
from hr_new
where age >=18 and termdate is null
group by jobtitle
order by jobtitle desc;

-- which departments have the highest termination rate

select department,
	total_count,
    terminated_count,
    total_count/terminated_count as termination_rate
from (
	select 
		department,
		count(*) as total_count,
		sum(case when termdate is not null and termdate <=curdate() then '1'else '0' end) as terminated_count
    from hr_new
    where age >=18
    group by department
) as subquery
order by termination_rate desc;

-- distribution of employess across location by city and state

select location_state, count(*) as count
from hr_new
where age >=18 and termdate is null
group by location_state
order by count desc;

-- employee count change over the time based on hire and terminate dates

select
	year,
    hires,
    termination,
    hires - termination as net_change,
	round((hires-termination)/100,2) as net_change_percent
from(
	select
		year(hire_date) as year,
        count(*) as hires,
        sum(case when termdate is not null and termdate <= curdate() then '1' else '0' end) as termination
	from hr_new
    where age >=18
    group by year(hire_date)
)as subquery
order by year asc;
	
    -- tenure distribution for each department
    
    select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
    from hr_new
    where termdate<= curdate() and termdate is not null and age>=18
    group by department;

    


