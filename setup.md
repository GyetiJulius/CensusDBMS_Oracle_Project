# CensusDBMS Oracle Project - Setup & Usage Guide

## Prerequisites

- **Python 3.10+** (recommended)
- **Oracle Database** (tested on Oracle 23ai, XE, or FreePDB1)
- **pip** (Python package manager)
- **Oracle client libraries** (for `oracledb` Python package)

## 1. Clone the Repository

```sh
git clone https://github.com/your-org/CensusDBMS_Oracle_Project.git
cd CensusDBMS_Oracle_Project
```

## 2. Install Python Dependencies

Create a virtual environment (optional but recommended):

```sh
python -m venv .venv
.\.venv\Scripts\activate  # Windows
source .venv/bin/activate # Linux/macOS
```

Install requirements:

```sh
pip install -r requirements.txt
```

## 3. Oracle Database Setup

### a. Get Oracle Credentials

You need:
- **Host**: e.g. `localhost`
- **Port**: e.g. `1521`
- **Service Name**: e.g. `FREEPDB1`
- **Username**: e.g. `python_user`
- **Password**: e.g. `pythonuser`

If you don't have an Oracle user, create one (as DBA):

```sql
CREATE USER python_user IDENTIFIED BY pythonuser;
GRANT CONNECT, RESOURCE TO python_user;
ALTER USER python_user QUOTA UNLIMITED ON USERS;
```

### b. Create Database Objects

Run all setup scripts using SQL*Plus or Oracle SQL Developer:

```sql
-- Connect as python_user
sqlplus python_user/pythonuser@localhost:1521/FREEPDB1

-- Run the master setup script
a. Create the schema (tables and sequences):
  SQL> @sql\schemas\oracle_schema.sql

b. Create the stored procedures:
  SQL> @sql\procedures\oracle_procedures.sql

c. Create the triggers:
  SQL> @sql\triggers\oracle_triggers.sql

d. (Optional) Load the sample data:
  SQL> @sql\sample_data\oracle_sample_data.sql
```

This will create tables, views, procedures, triggers, and sample data.

## 4. Configure Environment Variables

Copy `.env` template and update with your Oracle credentials:

```sh
cp .env .env.local
```

Edit `.env.local` (or `.env`) and set:

```
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_SERVICE_NAME=FREEPDB1
ORACLE_USERNAME=python_user
ORACLE_PASSWORD=pythonuser
```

## 5. Run the Streamlit Frontend

Activate your virtual environment if not already active.

```sh
streamlit run streamlit_app.py
```

## 6. Access the Application

- Open your browser and go to: [http://localhost:8501](http://localhost:8501)
- Use the sidebar to navigate between Dashboard, Data Management, Analytics, Search, and Activity Log.

## 7. Troubleshooting

- **ORA-00942**: Run all SQL scripts to ensure views/tables exist.
- **ORA-02291**: Add households before adding individuals.
- **ValidationError**: Ensure `.env` matches your Oracle credentials and only contains expected variables.

## 8. Getting Oracle Credentials

If you don’t have access:
- Contact your DBA or system administrator.
- For local XE/FreePDB1, default credentials may be:
  - Username: `system` or `python_user`
  - Password: set during installation
  - Host: `localhost`
  - Port: `1521`
  - Service Name: `XE` or `FREEPDB1`

## 9. Useful SQL Commands

List all households:
```sql
SELECT household_id, household_number_in_structure FROM household;
```

List all individuals:
```sql
SELECT * FROM individual;
```

Check if a view exists:
```sql
SELECT view_name FROM user_views WHERE view_name = 'V_INDIVIDUAL_DETAILS';
```

---

**For further help:**  
- Check the README in the repo  
- Contact your project administrator  
- Refer to Oracle documentation for database setup
