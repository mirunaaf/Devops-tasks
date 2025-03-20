#!/bin/bash

# Variables
CONTAINER_NAME="postgres-container"
DB_USER="ituser"
DB_NAME="company_db"
INITIAL_DB="postgres"
ADMIN_USER="admin_cee"
LOG_FILE="queries.log"
DUMP_FILE="backup.sql"
SQL_SCRIPT="populatedb.sql"
CONTAINER_SQL_PATH="/populatedb.sql"

# Check if the container exists (running or stopped)
if docker ps -a --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    if docker ps --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
        echo "Container $CONTAINER_NAME is already running."
    else
        echo "Starting existing stopped container: $CONTAINER_NAME"
        docker start $CONTAINER_NAME
    fi
else
    echo "Creating and starting new PostgreSQL container..."
    docker run --name $CONTAINER_NAME -e POSTGRES_USER=$DB_USER -e POSTGRES_PASSWORD="password" -e POSTGRES_DB=$INITIAL_DB -p 5432:5432 -v pgdata:/var/lib/postgresql/data -d postgres
    sleep 5  
fi

# Grant ituser permission to create databases (Only if necessary)
echo "Ensuring 'ituser' has database creation privileges..."
docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $INITIAL_DB -c "
ALTER USER $DB_USER CREATEDB;
GRANT ALL PRIVILEGES ON DATABASE $INITIAL_DB TO $DB_USER;"

# Check if the database exists before attempting to create it
echo "Checking if database $DB_NAME exists..."
DB_EXISTS=$(docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $INITIAL_DB -tAc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME';")

if [[ "$DB_EXISTS" == "1" ]]; then
    echo "Database $DB_NAME already exists. Skipping creation."
else
    echo "Creating database $DB_NAME..."
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $INITIAL_DB -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;"
fi

# Check if admin user exists before creating
echo "Checking if admin user $ADMIN_USER exists..."
ADMIN_EXISTS=$(docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -tAc "SELECT 1 FROM pg_roles WHERE rolname='$ADMIN_USER';")

if [[ "$ADMIN_EXISTS" != "1" ]]; then
    echo "Creating admin_cee user..."
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
    CREATE ROLE $ADMIN_USER WITH LOGIN PASSWORD 'password2';
    GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $ADMIN_USER;"
else
    echo "Admin user $ADMIN_USER already exists. Skipping creation."
fi

# Check if dataset exists by counting tables
TABLES_COUNT=$(docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';")

if [[ "$TABLES_COUNT" -gt 0 ]]; then
    echo "Dataset already loaded. Skipping import."
else
    echo "Dataset not found. Importing dataset..."
    
    # Copy dataset file if missing
    echo "Checking if dataset file exists in container..."
    FILE_EXISTS=$(docker exec -i $CONTAINER_NAME sh -c "[ -f $CONTAINER_SQL_PATH ] && echo 'yes' || echo 'no'")

    if [[ "$FILE_EXISTS" == "no" ]]; then
        echo "Copying dataset into the container"
        docker cp $SQL_SCRIPT $CONTAINER_NAME:$CONTAINER_SQL_PATH
    else
        echo "Dataset file already exists in the container. Skipping copy."
    fi

    # Import the dataset
    echo "Importing dataset into the database..."
    docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -f $CONTAINER_SQL_PATH
fi

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

  # Prompt for department name
  read -p "Enter department name: " department

  echo -e "\n Names of employees in the '$department' department:"
  docker exec -i $CONTAINER_NAME psql -U $DB_USER -d $DB_NAME -c "
  SELECT first_name, last_name FROM employees 
  WHERE department_id = (SELECT department_id FROM departments WHERE department_name = '$department');"

} > $LOG_FILE
# Dump the database into a backup file
echo "Dumping database..."
docker exec -i $CONTAINER_NAME pg_dump -U $DB_USER $DB_NAME > $DUMP_FILE

echo "Script completed! Results saved in $LOG_FILE and backup saved in $DUMP_FILE."
