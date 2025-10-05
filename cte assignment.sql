-- 1) Hello, Employees (staging CTE)
-- Task: Build a CTE that returns EMPLOYEE_ID, full_name, JOB_ID, DEPARTMENT_ID, SALARY.
--  Output: employee_id, full_name, job_id, department_id, salary.
--  Hint: CONCAT(COALESCE(FIRST_NAME,''),' ',LAST_NAME). 

with my_cte as
(
	select employee_id,CONCAT(COALESCE(FIRST_NAME,''),' ',LAST_NAME)as full_name,department_id,salary,job_id from employees
)
select c.employee_id, c.full_name, c.job_id, c.department_id, c.salary from my_cte as c;

with my_cte as 
(
	select EMPLOYEE_ID, concat(first_name," ",last_name) as full_name, JOB_ID, DEPARTMENT_ID, SALARY
    from employees 
)
select employee_id, c.full_name, c.job_id, c.department_id, c.salary from my_cte as c;


-- 2) Department Headcount (include 0)
-- Task: CTE with employees grouped by DEPARTMENT_ID. Left-join to departments to show all departments.
--  Output: department_id, department_name, headcount.
--  Hint: COALESCE(headcount,0).

with cte as (
	select count(e.employee_id) as headcount
    ,d.department_id,d.department_name 
    from employees e
    inner join departments d
    on e.department_id=d.department_id    
    group by department_id ,department_name
)
select department_id, department_name, headcount from cte
ORDER BY department_id;

-- 3) Avg Salary by Job
-- Task: CTE aggregates average salary per JOB_ID; join to jobs for titles.
--  Output: job_id, job_title, emp_count, avg_salary.
--  Hint: ROUND(AVG(SALARY),2).

with my_cte as
( 
	select j.job_id,j.job_title,count(employee_id) as emp_count,ROUND(AVG(SALARY),2) as avg_salary 
    from jobs j
    join employees e 
    on e.job_id=j.job_id
    group by job_id,job_title

)
select job_id, job_title, emp_count, avg_salary from my_cte;

-- 4) Employee → Manager (1 hop)
-- Task: Stage employees in a CTE; self-join to get direct manager name.
--  Output: employee_id, employee_name, manager_id, manager_name.
--  Hint: Left join; top boss may have MANAGER_ID = 0 or NULL.



with cte_eight as (
    select 
        e.employee_id,
        concat(e.first_name, ' ', e.last_name) as employee_name,
        e.manager_id,
        concat(em.first_name, ' ', em.last_name) as manager_name
    from employees e
    left join employees em
        on e.manager_id = em.employee_id   
)
select employee_id, employee_name, manager_id, manager_name
from cte_eight;

-- 5) Employees Without a Department
-- Task: Use a CTE to list employees where DEPARTMENT_ID IS NULL OR DEPARTMENT_ID=0.
--  Output: employee_id, full_name, job_id, department_id.
use hr;
with my_cte as (
	select  employee_id, concat(first_name," ",last_name) as full_name , job_id, department_id from employees e  where department_id = 0 or department_id is null
)
select  employee_id, full_name, job_id, department_id from my_cte;

-- 6) Departments Without Employees
-- Task: Distinct DEPARTMENT_ID from employees in a CTE; anti-join to departments.
--  Output: department_id, department_name.

with my_cte as(

select distinct e.department_id,d.department_name 
from employees e
left join departments d
on e.department_id =d.department_id
)
select  department_id, department_name from my_cte;

-- 7) Map Employees to Region (clean text)
-- Task: CTE joins employees → departments → locations → countries → regions and trims REGION_NAME.
--  Output: employee_id, full_name, department_name, city, country_name, region_name.
--  Hint: TRIM(REPLACE(REGION_NAME,'\r','')).

with my_cte as
(
	select TRIM(REPLACE(REGION_NAME,'\r','')) as region_name,
    e.employee_id, concat(e.first_name," ",e.last_name) as full_name,d.department_name,l.city,c.country_name
    from employees e
    join departments d 
    on e.department_id=d.department_id
    join locations l
    on l.location_id=d.location_id
    join countries c
    on c.country_id = l.country_id
    join regions r
    on r.region_id = c.region_id
)
select  employee_id, full_name, department_name, city, country_name, region_name from my_cte ;



-- 8) Simple Pay-Band Check
-- Task: CTE joins employees to jobs; return rows where salary < min_salary OR salary > max_salary.
--  Output: employee_id, full_name, job_title, salary, min_salary, max_salary.

with cte as (

select employee_id,concat(first_name," ",last_name) as full_name,salary,job_title, min_salary, max_salary
from employees e
join jobs j
on e.job_id = j.job_id
where salary<min_salary or salary>max_salary
)
select employee_id, full_name, job_title, salary, min_salary, max_salary from cte;


-- 9) Top Earners (overall)
-- Task: CTE selecting employee_id, full_name, salary, then order and limit to top 5.
--  Output: employee_id, full_name, salary.
--  Hint: Use the CTE just to keep the final SELECT clean.

with cte as(
	select employee_id, concat(first_name," ",last_name) as full_name, salary
    from employees
    order by employee_id
    limit 5
    
)
select employee_id, full_name, salary from cte;


-- 10) Jobs Present in Each Department
-- Task: CTE groups employees by DEPARTMENT_ID, JOB_ID and counts. Join jobs for title.
--  Output: department_name, job_title, employees_in_role.

with cte as
(
	select d.department_name,j.job_title,count(employee_id) as employees_in_role
    from employees e 
    join jobs j
    on e.job_id=j.job_id 
    join departments d
    on d.department_id =e.department_id
    group by d.department_id,j.job_title
    
)
select department_name, job_title, employees_in_role from cte 
;

-- 11) Headcount by Region
-- Task: Reuse the “map to region” idea in a CTE; then group by region.
--  Output: region_name, headcount.
--  Hint: Handle NULL region as “Unknown".
use hr;
with region_mapping as (
select employee_id,coalesce(region,"unknown") as region_name
from employees e
join departments d 
on e.department_id=d.department_id
join locations l
on l.location_id=d.location_id
join countries c
on c.country_id=l.country_id 
join regions r
on c.region_id=r.region_id
)
 select region_name,count(*) as headcount from region_mapping
 group by region_name
 order by region_name;
 





-- 12) Commission Snapshot
-- Task: In a CTE, compute a flag has_commission = commission_pct > 0. Then count by flag.
--  Output: has_commission, headcount.
--  Optional: Break down by department as well.

WITH commission_flag AS (
  SELECT 
    CASE 
      WHEN commission_pct > 0 THEN 'Y'
      ELSE 'N'
    END AS has_commission
  FROM employees
)
SELECT 
  has_commission,
  COUNT(*) AS headcount
FROM commission_flag
GROUP BY has_commission;


-- 13) Employees with Any Job History
-- Task: CTE with distinct EMPLOYEE_ID from job_history (exclude dummy row). Join to employees.
--  Output: employee_id, full_name, history_row_count.
--  Hint: COUNT(*) OVER (PARTITION BY EMPLOYEE_ID) or aggregate before join.

WITH job_history_flag AS (
  SELECT DISTINCT employee_id
  FROM job_history
  WHERE employee_id IS NOT NULL  -- exclude dummy rows
),
history_counts AS (
  SELECT 
    employee_id,
    COUNT(*) OVER (PARTITION BY employee_id) AS history_row_count
  FROM job_history
  WHERE employee_id IS NOT NULL
)
SELECT 
  e.employee_id,
  e.first_name || ' ' || e.last_name AS full_name,
  hc.history_row_count
FROM employees e
JOIN job_history_flag jhf ON e.employee_id = jhf.employee_id
JOIN history_counts hc ON e.employee_id = hc.employee_id;


-- 14) Latest History Row (gentle)
-- Task: Clean job_history in a CTE (exclude zero/invalid dates) and pick the latest row per employee using ROW_NUMBER.
--  Output: employee_id, last_hist_job_id, last_hist_department_id, last_hist_end_date.
--  Hint: Order by END_DATE DESC, START_DATE DESC.

WITH cleaned_history AS (
  SELECT *
  FROM job_history
  WHERE end_date IS NOT NULL
    AND end_date > start_date  -- exclude zero or invalid ranges
),
ranked_history AS (
  SELECT 
    employee_id,
    job_id AS last_hist_job_id,
    department_id AS last_hist_department_id,
    end_date AS last_hist_end_date,
    ROW_NUMBER() OVER (
      PARTITION BY employee_id
      ORDER BY end_date DESC, start_date DESC
    ) AS rn
  FROM cleaned_history
)
SELECT 
  employee_id,
  last_hist_job_id,
  last_hist_department_id,
  last_hist_end_date
FROM ranked_history
WHERE rn = 1;

-------------------------------------------------------------------------------------------------
-- 15) Locations per Country
-- Task: CTE groups locations by COUNTRY_ID; join to countries.
--  Output: country_id, country_name, location_count.
--  Hint: COALESCE(country_name,'Unknown').

WITH location_summary AS (
  SELECT 
    country_id,
    COUNT(*) AS location_count
  FROM locations
  GROUP BY country_id
)
SELECT 
  ls.country_id,
  COALESCE(c.country_name, 'Unknown') AS country_name,
  ls.location_count
FROM location_summary ls
LEFT JOIN countries c ON ls.country_id = c.country_id
ORDER BY ls.location_count DESC;

-----------------------------------------------------------------------------------------------------------

WITH emp_map AS (
  SELECT e.employee_id, e.salary, d.department_name, l.location_id, l.country_id, c.region_id
  FROM employees e
  JOIN departments d ON e.department_id = d.department_id
  JOIN locations l ON d.location_id = l.location_id
  JOIN countries c ON l.country_id = c.country_id
),
region_map AS (
  SELECT r.region_id, r.region_name FROM regions r
)
SELECT 
  rm.region_name,
  em.department_name,
  COUNT(*) AS headcount,
  ROUND(AVG(em.salary), 2) AS avg_salary,
  MIN(em.salary) AS min_salary,
  MAX(em.salary) AS max_salary
FROM emp_map em
JOIN region_map rm ON em.region_id = rm.region_id
GROUP BY rm.region_name, em.department_name
ORDER BY rm.region_name, em.department_name;

---------------------------------------------------------------------------------------------

WITH region_dept_counts AS (
  SELECT 
    r.region_name,
    d.department_name,
    COUNT(*) AS headcount
  FROM employees e
  JOIN departments d ON e.department_id = d.department_id
  JOIN locations l ON d.location_id = l.location_id
  JOIN countries c ON l.country_id = c.country_id
  JOIN regions r ON c.region_id = r.region_id
  GROUP BY r.region_name, d.department_name
)
SELECT 
  region_name,
  department_name,
  headcount,
  ROUND(100.0 * headcount / SUM(headcount) OVER (PARTITION BY region_name), 2) AS pct_share
FROM region_dept_counts
ORDER BY region_name, department_name;
-------------------------------------------------------------------------------------------
WITH joined AS (
  SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.salary,
    j.job_id,
    j.job_title,
    j.min_salary,
    j.max_salary
  FROM employees e
  JOIN jobs j ON e.job_id = j.job_id
),
violations AS (
  SELECT *,
    salary - min_salary AS deviation_below,
    salary - max_salary AS deviation_above,
    ABS(salary - min_salary) AS abs_dev_below,
    ABS(salary - max_salary) AS abs_dev_above
  FROM joined
)
-- a) Below Range
SELECT 
  employee_id, full_name, job_id, job_title, salary, min_salary,
  deviation_below AS deviation_amount,
  RANK() OVER (PARTITION BY job_id ORDER BY abs_dev_below DESC) AS rank_within_job
FROM violations
WHERE salary < min_salary;

-- b) Above Range
SELECT 
  employee_id, full_name, job_id, job_title, salary, max_salary,
  deviation_above AS deviation_amount,
  RANK() OVER (PARTITION BY job_id ORDER BY abs_dev_above DESC) AS rank_within_job
FROM violations
WHERE salary > max_salary;

---------------------------------------------------------------------------
WITH RECURSIVE org_chart AS (
  SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    manager_id,
    job_id,
    0 AS level_from_president
  FROM employees
  WHERE job_id = 'AD_PRES'

  UNION ALL

  SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name,
    e.manager_id,
    e.job_id,
    oc.level_from_president + 1
  FROM employees e
  JOIN org_chart oc ON e.manager_id = oc.employee_id
)
-- Full chart
SELECT 
  level_from_president,
  manager_id,
  employee_id,
  employee_name,
  job_id
FROM org_chart;

-- Summary table
SELECT 
  level_from_president,
  COUNT(*) AS count_of_employees
FROM org_chart
GROUP BY level_from_president
ORDER BY level_from_president;

-- Deepest level
SELECT *
FROM org_chart
WHERE level_from_president = (
  SELECT MAX(level_from_president) FROM org_chart
);
------------------------------------------------------

WITH RECURSIVE sales_tree AS (
  SELECT 
    employee_id,
    first_name || ' ' || last_name AS name,
    manager_id,
    job_id,
    employee_id AS root_manager_id,
    first_name || ' ' || last_name AS root_manager_name,
    0 AS level_in_sales_tree
  FROM employees
  WHERE job_id = 'SA_MAN'

  UNION ALL

  SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name,
    e.manager_id,
    e.job_id,
    st.root_manager_id,
    st.root_manager_name,
    st.level_in_sales_tree + 1
  FROM employees e
  JOIN sales_tree st ON e.manager_id = st.employee_id
  WHERE e.job_id LIKE 'SA_%'
)
-- Tree view
SELECT * FROM sales_tree;

-- Summary
SELECT 
  root_manager_id,
  root_manager_name,
  COUNT(*) AS total_team_size
FROM sales_tree
GROUP BY root_manager_id, root_manager_name;
-----------------------------------------------------------------------------------------






