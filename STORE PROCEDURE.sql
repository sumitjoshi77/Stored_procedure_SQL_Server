-------STORE PROCEDURE----------------------
SELECT * from employee_information_tab

USE SQL_Basics_20230628
GO
CREATE PROC get_emp_with_low_salary
AS
BEGIN --- Start your stored procedure
WITH category_salary -- This creates the common table expression
AS
(
SELECT
 *,
 CASE  -- this is the start of the case stamement
  WHEN salary < 35000 THEN 'low'
  WHEN salary >= 35000 AND salary < 45000 THEN 'medium'
  ELSE 'high' 
 END AS salary_category -- end of the case statement, here we are giving the column an alias name
FROM
 employee_information_tab
)
SELECT * FROM category_salary WHERE salary_category  = 'low'
ORDER BY salary
END --- end your stored procedure



-----------------ALTER-----------


GO
ALTER PROC get_emp_with_low_salary
AS
BEGIN --- Start your stored procedure
WITH category_salary -- This creates the common table expression
AS
(
SELECT
 *,
 CASE  -- this is the start of the case stamement
  WHEN salary < 35000 THEN 'low'
  WHEN salary >= 35000 AND salary < 45000 THEN 'medium'
  ELSE 'high' 
 END AS salary_category -- end of the case statement, here we are giving the column an alias name
FROM
 employee_information_tab
)
SELECT * FROM category_salary WHERE salary_category  = 'low'
ORDER BY salary DESC
END --- end your stored procedure



EXECUTE get_emp_with_low_salary




-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------

--2) find the all poroduct sold more in term of total sales compare to precovid----
-----OR---- What are the product names for products that have sold more in terms of total sales compared to pre-COVID?
SELECT * FROM sales_order

USE SQL_Basics_20230628


WITH
sales_data_classified
AS
(
SELECT 
	*,
	YEAR( sales_date) AS year_sales_date,
	MONTH( sales_date) AS month_sales_date,
	YEAR(sales_date ) * 100 + MONTH(sales_date) AS year_month_sales_date,
	CONVERT(CHAR(4), YEAR( sales_date)) +CONVERT( CHAR(2), MONTH( sales_date )) AS concat_val,
	--- Classify as pre covid or post covid
	CASE
		WHEN YEAR(sales_date ) * 100 + MONTH(sales_date) < 202003  THEN 'Pre Covid'
		ELSE 'Post Covid'
	END AS is_pre_covid   -- end marks the end of the CASE statement
FROM
sales_order
),

--- Break the data into two parts, part1 will be records that belong to PRE COVID
-- part 2 will be records that belong to Post Covid
post_covid_data
AS
(
SELECT * FROM sales_data_classified
WHERE
is_pre_covid = 'Post Covid'
)
,
pre_covid_data
AS
(
SELECT * FROM sales_data_classified
WHERE
is_pre_covid = 'Pre Covid'
)
,

-- get the total sale of each item post covid
item_name_total_sales_post_covid
AS
(
SELECT
item_name,
SUM( quantity * item_price) AS total_sale
FROM
post_covid_data
GROUP BY item_name
),

-- get the total sale of each item PRE covid
item_name_total_sales_pre_covid
AS
(
SELECT
item_name,
SUM( quantity * item_price) AS total_sale
FROM
pre_covid_data
GROUP BY item_name
)

SELECT 
pre_covid.item_name AS pre_covid_item_name,
pre_covid.total_sale AS pre_covid_total_sale,
pos_covid.item_name AS post_item_name,
pos_covid.total_sale AS post_covid_total_sale,
COALESCE(pos_covid.total_sale, 0) - 
COALESCE(pre_covid.total_sale, 0) AS sales_difference
FROM item_name_total_sales_post_covid as pos_covid
FULL OUTER JOIN
item_name_total_sales_pre_covid AS pre_covid
ON
pos_covid.item_name = pre_covid.item_name
ORDER BY sales_difference DESC ;





------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

CREATE PROC get_emp_with_salary_categorization(

	@salary_category AS VARCHAR(10) --- @salary_category = 'high'
	)-- This was the name you gave to the SP
AS 

BEGIN --- Start your stored procedure

WITH category_salary -- This creates the common table expression
AS
(
SELECT
 *,
 CASE  -- this is the start of the case stamement
  WHEN salary < 35000 THEN 'low'
  WHEN salary >= 35000 AND salary < 45000 THEN 'medium'
  ELSE 'high' 
 END AS salary_category -- end of the case statement, here we are giving the column an alias name
FROM
 employee_information_tab
)
SELECT * FROM category_salary WHERE salary_category  = @salary_category 
ORDER BY salary DESC -- this is the change done on 17-01-2023, changed to DESC


END --- end your stored procedure

EXECUTE get_emp_with_salary_categorization 'high' ;

EXECUTE get_emp_with_salary_categorization @salary_category = 'high' ;

----------------------------------------------------------------------------------
---------------------------------ALTER--high-for--48000-above-------------------------------
GO
ALTER PROC get_emp_with_salary_categorization(

	@salary_category AS VARCHAR(10) --- @salary_category = 'high'
	)-- This was the name you gave to the SP
AS

BEGIN --- Start your stored procedure

WITH category_salary -- This creates the common table expression
AS
(
SELECT
 *,
 CASE  -- this is the start of the case stamement
  WHEN salary < 35000 THEN 'low'
  WHEN salary >= 35000 AND salary < 45000 THEN 'medium'
  WHEN salary >= 48000 THEN  'high' 
 END AS salary_category -- end of the case statement, here we are giving the column an alias name
FROM
 employee_information_tab
)
SELECT * FROM category_salary WHERE salary_category  = @salary_category 
ORDER BY salary DESC -- this is the change done on 17-01-2023, changed to DESC


END --- end your stored procedure

EXECUTE get_emp_with_salary_categorization 'high' ;

EXECUTE get_emp_with_salary_categorization @salary_category = 'high' ;
---------------------------------------------------------------------------
-------------------------------------------------------------------

SELECT * from employee_information_tab
--- write a stored procedure
--- to return records from the employee information table where dept_id is provided by the user
--- and the part of the emp name  is provided
'an'  'SD-DB'



GO
ALTER PROC get_emp_with_an (

	@emp_name AS VARCHAR(30), 
	@dept_id_ip AS VARCHAR(10)
	)
AS

BEGIN 

WITH employee_name 
AS
(
SELECT *
FROM 
employee_information_tab
WHERE
emp_name LIKE '%' + @emp_name + '%'
AND
(dept_id = @dept_id_ip)
)
SELECT *
FROM
employee_name
END

EXECUTE get_emp_with_an @emp_name = 'an', @dept_id_ip = 'SD-DB'


------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
/*
Create a Stored procedure
that will take the emp_dept_id as an input
and a percentage as an input (could be a floating point number )
and will show all the emp's whose salary is between -percenta and +percentage from the average salary */

SELECT * From employee_information_tab

CREATE PROC employees_by_salary_range(

  @dept_id VARCHAR(60),
  @percentage FLOAT(5)
)
AS
BEGIN
SELECT employee_id, emp_name,dept_id, salary
FROM employee_information_tab
WHERE dept_id = @dept_id
AND salary BETWEEN
(SELECT AVG(salary) - @percentage * AVG(salary)
FROM employee_information_tab)
AND (SELECT AVG(salary) + @percentage * AVG(salary)
FROM employee_information_tab);

END

EXEC employees_by_salary_range @dept_id = 'SD-MOBILE', @percentage = 0.10;


DROP PROCEDURE dbo.find_employees_by_salary_range
----------------------------------------------------------------
------------------------------VIJAYA----------------------------------------------

CREATE PROC get_salrary_in_perctange_range(
       @dept_id AS VARCHAR(60),
	   @percentage AS FLOAT(5)
)
AS

BEGIN
WITH avg_salary
AS

(SELECT *,
AVG(salary) OVER(PARTITION BY dept_id) as avg_salary 
FROM employee_information_tab)

SELECT * FROM avg_salary where  salary > (avg_salary * ((100 - @percentage)/100))
AND salary < (avg_salary * ((100 + @percentage)/100)) AND dept_id = @dept_id

END

EXEC get_salrary_in_perctange_range 'SD-MOBILE',10


-------------------------------------------------------------------------
---------------------------------------OR--------------------------------------


GO  -- Go will create a new Batch
ALTER PROCEDURE get_emp_details_around_avg_sal(
					@department_id AS  VARCHAR(10)
)
AS
	BEGIN
WITH salary_calculations
AS
(
	SELECT
		AVG(salary) AS average_salary
		, AVG(salary) * (100 - 10)/ 100 AS average_salary_90
		,  AVG(salary) * (100 + 10)/ 100 AS average_salary_110
		FROM employee_information_tab
		WHERE
		dept_id = @department_id
)

SELECT employee_information_tab.*,
salary_calculations.*
FROM
employee_information_tab
INNER JOIN
salary_calculations
ON
(employee_information_tab.salary >=  salary_calculations.average_salary_90)
AND
( employee_information_tab.salary <=  salary_calculations.average_salary_110)
WHERE
dept_id = @department_id

END -- End of procedure  get_emp_details_around_avg_sal

EXEC get_emp_details_around_avg_sal  @department_id = 'SD-Mobile'