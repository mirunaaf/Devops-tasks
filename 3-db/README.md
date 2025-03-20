##  PostgreSQL Container with Data Import and Queries

  1. Pull and run a PostgreSQL container.
- Create a database called "company_db".
- Do not use the default user, instead use one called "ituser".
- Mount a volume for data persistance
  
```
docker run --name postgres-container -e POSTGRES_USER=ituser -e POSTGRES_PASSWORD=password -e POSTGRES_DB=company_db -p 5432:5432 -v pgdata:/var/lib/postgresql/data -d postgres
```

- Check if the container was created
  
  ```
  docker ps

  CONTAINER ID   IMAGE      COMMAND                  CREATED          STATUS          PORTS                    NAMES
    1a49e3c4625a   postgres   "docker-entrypoint.s…"   24 seconds ago   Up 23 seconds   0.0.0.0:5432->5432/tcp   postgres-container   
  ```
- Check if the database and the user were created:

```
docker exec -it postgres-container bash

psql -U ituser -d company_db

\l

 Name    | Owner  | Encoding | Locale Provider |  Collate   |   Ctype    | Locale | ICU Rules | Access privileges 
------------+--------+----------+-----------------+------------+------------+--------+-----------+-------------------
 company_db | ituser | UTF8     | libc            | en_US.utf8 | en_US.utf8 |        |           | 
```
- Copy the script inside the container

```
docker cp populatedb.sql postgres-container:/populatedb.sql
```

- Execute the populatedb.sql script to populate the database

```
docker exec -i postgres-container psql -U ituser -d company_db -f /populatedb.sql

CREATE TABLE
CREATE TABLE
CREATE TABLE
INSERT 0 8
INSERT 0 53
psql:/populatedb.sql:182: ERROR:  insert or update on table "salaries" violates foreign key constraint "salaries_employee_id_fkey"
DETAIL:  Key (employee_id)=(54) is not present in table "employees".
```
Option 1

- Fix error:
 1.drop constraint
 ```
 docker exec -it postgres-container psql -U ituser -d company_db -c "ALTER TABLE salaries DROP CONSTRAINT salaries_employee_id_fkey;" 
 ```
 2. using sed to insert all the salaries
 ```
 docker exec -it postgres-container sh -c "sed -n '/INSERT INTO salaries/,/;/p' /populatedb.sql | psql -U ituser -d company_db"          
INSERT 0 76
```
3. keep only the relevant data in the salaries table
```
docker exec -it postgres-container psql -U ituser -d company_db -c "
DELETE FROM salaries WHERE employee_id NOT IN (SELECT employee_id FROM employees);"
DELETE 23
```
4. checked the records in the salaries table
```
 docker exec -it postgres-container psql -U ituser -d company_db -c "SELECT * FROM salaries;"          
 ```
5. reintroduce the constraint
```
docker exec -it postgres-container psql -U ituser -d company_db -c "ALTER TABLE salaries                                                               
ADD CONSTRAINT salaries_employee_id_fkey
FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE;"
ALTER TABLE
```

Option 2

- Use JOIN to introduce salaries only for existent employees
```
docker exec -it postgres-container psql -U ituser -d company_db -c "
INSERT INTO salaries (employee_id, salary)
SELECT e.employee_id, s.salary
FROM (VALUES
    (1, 50000), (2, 55000), (3, 52000), (4, 58000), (5, 60000),
    (6, 70000), (7, 80000), (8, 75000), (9, 72000), (10, 67000),
    (11, 85000), (12, 88000), (13, 90000), (14, 92000), (15, 94000),
    (16, 62000), (17, 65000), (18, 68000), (19, 70000), (20, 73000),
    (21, 76000), (22, 78000), (23, 81000), (24, 83000), (25, 86000),
    (26, 89000), (27, 91000), (28, 93000), (29, 95000), (30, 98000),
    (31, 99000), (32, 102000), (33, 104000), (34, 105000), (35, 107000),
    (36, 109000), (37, 111000), (38, 113000), (39, 115000), (40, 117000),
    (41, 119000), (42, 121000), (43, 123000), (44, 125000), (45, 127000),
    (46, 129000), (47, 131000), (48, 133000), (49, 91000), (50, 137000),
    (51, 139000), (52, 141000), (53, 143000), (54, 145000), (55, 147000),
    (56, 149000), (57, 151000), (58, 153000), (59, 155000), (60, 91000),
    (61, 159000), (62, 161000), (63, 163000), (64, 165000), (65, 167000),
    (66, 169000), (67, 171000), (68, 173000), (69, 175000), (70, 177000),
    (71, 179000), (72, 181000), (73, 183000), (74, 185000), (75, 187000),
    (76, 189000)
) AS s(employee_id, salary)
JOIN employees e ON s.employee_id = e.employee_id;"
```

2. Run the following SQL queries:
- Find the total number of employees.
```
docker exec -it postgres-container psql -U ituser -d company_db -c "SELECT COUNT(*) FROM employees;"

 count 
-------
    53
(1 row)
```
- Retrieve the names of employees in a specific department(prompt for user input).
```
read -p "Enter department name: " department

docker exec -it postgres-container psql -U ituser -d company_db -c "
SELECT first_name, last_name FROM employees 
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = '$department');"

```

- Calculate the highest and lowest salaries per department.
```
docker exec -it postgres-container psql -U ituser -d company_db -c "SELECT d.department_name, MAX(s.salary) AS max_salary, MIN(s.salary) AS min_salary FROM employees e JOIN salaries s ON e.employee_id = s.employee_id JOIN departments d ON e.department_id = d.department_id GROUP BY d.department_name;"

 department_name  | max_salary | min_salary 
------------------+----------------+---------------
 Customer Support |      119000.00 |     109000.00
 Marketing        |       91000.00 |      78000.00
 Operations       |      131000.00 |     121000.00
 Sales            |      107000.00 |      93000.00
 Legal            |      143000.00 |      91000.00
 IT               |       94000.00 |      67000.00
 Finance          |       76000.00 |      62000.00
 HR               |       60000.00 |      50000.00
(8 rows)
```

3. Dump the dataset into a file (create backup on the host machine)
```
docker exec -it postgres-container pg_dump -U ituser company_db > company_db_bkp.sql   
```

4. Bash script

- Starts a PostgreSQL container (if not already running).
- Creates database (company_db) and users if they don’t exist.
- Imports dataset (populatedb.sql) only if needed.
Executes queries to retrieve employee data and salary details.
Saves results to a log file (queries.log) and creates a database backup (backup.sql).
