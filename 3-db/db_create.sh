#!/bin/bash

# Variables
CONTAINER_NAME="postgres-container"
DB_USER="ituser"
DB_NAME="company_db"
INITIAL_DB="postgres" # Use "postgres" so we can create company_db later
ADMIN_USER="admin_cee"
LOG_FILE="queries.log"
DUMP_FILE="backup.sql"
SQL_SCRIPT="populatedb.sql"
CONTAINER_SQL_PATH="/populatedb.sql"

# Start the container if it's not running already
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "Starting PostgreSQL container..."
    docker run --name $CONTAINER_NAME -e POSTGRES_USER=$DB_USER -e POSTGRES_PASSWORD="password" -e POSTGRES_DB=$INITIAL_DB -p 5432:5432 -d postgres
    sleep 5  
else
    echo "Container $CONTAINER_NAME is already running."
fi

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until docker exec -it $CONTAINER_NAME pg_isready -U $DB_USER; do
    sleep 2
done

# Grant ituser permission to create databases
echo "Ensuring 'ituser' has database creation privileges..."
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $INITIAL_DB -c "
ALTER USER $DB_USER CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE $INITIAL_DB TO $DB_USER;"


# Drop database if it exists and recreate it
echo "Checking if database $DB_NAME exists..."
DB_EXISTS=$(docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';")

if [[ "$DB_EXISTS" == "1" ]]; then
    echo "Database $DB_NAME exists. Dropping it..."
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -c "
    SELECT pg_terminate_backend(pg_stat_activity.pid)
    FROM pg_stat_activity
    WHERE pg_stat_activity.datname = '$DB_NAME';"

    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -c "DROP DATABASE $DB_NAME;"
fi

echo "Creating database $DB_NAME..."
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"

# Create the second admin user
echo "Creating admin_cee user "
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
CREATE ROLE $ADMIN_USER WITH LOGIN PASSWORD 'password2';
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $ADMIN_USER;"

# Check if populatedb.sql is already in the container
echo "Checking if dataset file exists in container..."
FILE_EXISTS=$(docker exec -i $CONTAINER_NAME sh -c "[ -f $CONTAINER_SQL_PATH ] && echo 'yes' || echo 'no'")

if [[ "$FILE_EXISTS" == "no" ]]; then
    echo "Copying dataset into the container"
    docker cp $SQL_SCRIPT $CONTAINER_NAME:$CONTAINER_SQL_PATH
else
    echo "Dataset file already exists in the container. Skipping copy."
fi

# Import the dataset into the database
echo "Importing dataset"
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -f $CONTAINER_SQL_PATH

# Include foreign key error correction
docker exec -it $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
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

# Execute required queries and save results in a log file
echo "Executing queries and saving results..."
{
  echo "Total Employees:"
  docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
  SELECT COUNT(*) AS total_employees FROM employees;"

  echo -e "\n Salaries per Department (Min & Max):"
  docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
  SELECT d.department_name, MIN(s.salary) AS min_salary, MAX(s.salary) AS max_salary
  FROM salaries s
  JOIN employees e ON s.employee_id = e.employee_id
  JOIN departments d ON e.department_id = d.department_id
  GROUP BY d.department_name;"

  # Prompt for department name (fixes script getting stuck)
echo -n "Enter department name: "
read department  # Get user input before passing to Docker

echo -e "\n Names of employees in the '$department' department:"
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
SELECT first_name, last_name FROM employees 
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = '$department');"

} > $LOG_FILE

# Dump the database into a backup file
echo "Dumping database..."
docker exec -i $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $DUMP_FILE

echo "Script completed! Results saved in $LOG_FILE and backup saved in $DUMP_FILE."
