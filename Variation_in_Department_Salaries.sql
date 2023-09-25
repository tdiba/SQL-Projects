--Check the data in the table
select* from Employee_Salaries

--Group by Department and obtain the standard deviation and average of the Salary
select department, STDEV(Salary) as Standard_Deviation, AVG(Salary) as Average
from PortfolioProject..Employee_Salaries
where Salary>=10000
Group by Department

--Create a table out of the above query using a CTE
with DepartmentStats as 
(select department, STDEV(Salary) as Standard_Deviation, AVG(Salary) as Average
from PortfolioProject..Employee_Salaries
where Salary>=10000
Group by Department)
select* from DepartmentStats

--You are now able to query off that query and perform other functions on it

--Create a Departmental Outliers Table
with DepartmentStats as 
(select department, STDEV(Salary) as Standard_Deviation, AVG(Salary) as Average
from PortfolioProject..Employee_Salaries
where Salary>=10000
Group by Department)
select emp.Department, emp.Salary, dt.Standard_Deviation, dt.Average, (emp.Salary - dt.Average)/dt.Standard_Deviation as zscore
from Employee_Salaries emp
join DepartmentStats dt
on emp.Department = dt.Department
where Salary>= 10000

--The result allows us to identify outliers

with DepartmentStats as 
(Select Department, STDEV(Salary) as Standard_Deviation, AVG(Salary) as Average
from Employee_Salaries
where Salary >=10000
Group by Department),
DepartmentOutliers as
(select emp.Department, emp.Salary, dt.Standard_Deviation, dt.Average, (emp.Salary - dt.Average)/dt.Standard_Deviation as zscore
from Employee_Salaries emp
join DepartmentStats dt
on emp.Department = dt.Department
where Salary>= 10000)
select dt.Department, ROUND(dt.Standard_Deviation,2) as Standard_Deviation, ROUND(dt.Average,2) as Salary_Average,
ROUND((dt.Standard_Deviation/dt.Average),2)*100 as Coefficient_Of_Variation,
SUM(CASE WHEN (do.zscore>1.96 or do.zscore<-1.96) THEN 1 ELSE 0 END) AS Outlier_Count
from DepartmentStats dt
Left Join DepartmentOutliers do 
on dt.Department=do.Department
Group By dt.Department, dt.Standard_Deviation, dt.Average, dt.Standard_Deviation/dt.Average
Order by Coefficient_Of_Variation DESC