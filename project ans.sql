
select count(*),'department' as table_name from employees.department union all
select count(*),'department_employee' as table_name from employees.department_employee union all
select count(*),'department_manager' as table_name from employees.department_manager union all
select count(*),'employee' as table_name from employees.employee union all
select count(*),'salary' as table_name from employees.salary union all
select count(*),'title' as table_name from employees.title;


select * from employees.department_employee;
select * from employees.department;
select * from employees.department_manager;
select * from employees.employee;
select * from employees.salary;
select * from employees.title;

-- 1. Check for data inconsistency.
 
--2. Which department has the highest average salary of active employees ? 
--Give some plots to show the avg salary department-wise.

select dept_name, avg(s.amount) as avg_salary from employees.employee e
join employees.salary s on e.id = s.employee_id
join employees.department_employee de on e.id = de.employee_id
join employees.department d on de.department_id = d.id
where s.to_date = '9999-01-01'
group by d.dept_name 
order by avg_salary desc;

--3. Which title has the highest avg salary? Give some plots to show the avg salary title-wise.
select tab.title,avg(tab.amount) from (select s.amount,t.title from employees.employee e
									  left join employees.title t on t.employee_id = e.id
									  left join employees.salary s on s.employee_id = e.id
									  where date_part('year',s.to_date)=9999
									  and date_part('year',t.to_date)=9999) tab group by tab.title;
--                   or

select title, avg(s.amount) as avg_salary from employees.employee e
join employees.salary s on e.id = s.employee_id
join employees.title t on e.id = t.employee_id
where s.to_date = '9999-01-01'
group by t.title 
order by avg_salary desc;

--4. Distribution of salary across titles.

select ti.title, s.amount from employees.title ti
left join employees.salary s on ti.employee_id = s.employee_id 
where date_part('year', ti.to_date) = 9999 and date_part('year', s.to_date) = 9999
group by ti.title, s.amount;

--5. Distribution of salary across departments.

SELECT d.dept_name, s.amount
    FROM employees.salary s
    LEFT JOIN employees.department_employee de ON s.employee_id = de.employee_id
    LEFT JOIN employees.department d ON d.id = de.department_id
    WHERE date_part('year', de.to_date) = 9999
    AND date_part('year', s.to_date) = 9999;
	
--6. How many active managers in each department. Is there any department with no manager?
select d.dept_name, count(dm.employee_id) as manager_counts from employees.department d
left join employees.department_manager dm on d.id = dm.department_id
left join employees.employee e on dm.employee_id = e.id
where date_part('year', dm.to_date) = 9999
group by d.dept_name;

--7. Composition of titles department-wise. Appropriate plots.
 SELECT t.title, d.dept_name
    FROM employees.title t
    LEFT JOIN employees.department_employee de ON de.employee_id = t.employee_id
    LEFT JOIN employees.department d ON d.id = de.department_id 
    WHERE date_part('year', de.to_date) = 9999
    AND date_part('year', t.to_date) = 9999;
--8. Composition of departments title-wise. Appropriate plots.
 SELECT t.title, d.dept_name
    FROM employees.title t
    LEFT JOIN employees.department_employee de ON de.employee_id = t.employee_id
    LEFT JOIN employees.department d ON d.id = de.department_id 
    WHERE date_part('year', de.to_date) = 9999
    AND date_part('year', t.to_date) = 9999;
    

--9. Salaries of active department managers. Which department's manager who is active earns the most?
    select d.dept_name, s.amount from employees.department_manager dm
    inner join employees.salary s on dm.employee_id = s.employee_id
    inner join employees.department d on d.id = dm.department_id
    where date_part('year',dm.to_date) = 9999 and date_part('year',s.to_date)=9999;
	
--10. What are the titles of active department managers? Are they managers only?
select d.dept_name, tit.title from employees.department_manager dm
            join employees.title tit on dm.employee_id = tit.employee_id
            join employees.department d on d.id = dm.Department_id
            where date_part('year', dm.to_date) = 9999 and date_part('year', tit.to_date) = 9999

--11. Past history of salaries of managers across department (yearly)
select dm.employee_id, d.dept_name,s.amount,s.from_date, s.to_date 
from employees.department_manager dm
join employees.salary s on dm.employee_id= s.employee_id
join employees.department d on  d.id = dm.department_id
where s.from_date >= dm.from_date
and s.to_date <= dm.to_date;

--12. Distribution of salaries of active employees working for more than 10 years vs 4 years vs 1 year.
select s.amount, date_part('year',de.to_date)-  date_part('year',de.from_date) as years 
from employees.department_employee de
join employees.salary s on s.employee_id = de.employee_id
where date_part('year',de.to_date)- date_part('year',de.from_date) <= 60 and date_part('year',s.to_date)=9999;


--13. Average number of years employees work in the company before leaving (title wise).

select ti.title, date_part('year',de.to_date)- date_part('year',de.from_date) as leaving  
from employees.department_employee de 
join employees.title ti on ti.employee_id = de.employee_id
where date_part('year',de.to_date) != 9999;

--14. Average number of years employees work in the company before leaving (Dept wise).

select d.dept_name, date_part('year',de.to_date)- date_part('year',de.from_date) as leaving  
from employees.department_employee de 
join employees.department d on d.id = de.department_id
where date_part('year',de.to_date) != 9999;

--15. Median annual salary increment department wise.
 
with salary_increment as 
                    (select d.dept_name, date_part('year', s.from_date) as start, 
                    date_part('year', s.to_date) as end, max(s.amount) - min(s.amount) as annual_increment
                    from employees.department d join employees.department_employee de 
                    on d.id = de.department_id
                    join employees.salary s on de.employee_id =s.employee_id
                    group by d.dept_name, date_part('year', s.from_date), date_part('year', s.to_date))
                select dept_name, percentile_cont(0.5) WITHIN GROUP (ORDER BY annual_increment) as median_annual_salary_increment
                from salary_increment 
                group by dept_name
                order by median_annual_salary_increment;

