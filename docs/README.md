# Census Database Management System - Oracle Edition

A comprehensive Census Database Management System built with **Oracle PL/SQL** and **Python FastAPI**, designed for the Ghana Statistical Service to manage population and housing census data.

## 🏗️ Architecture

- **Backend Database**: Oracle Database with PL/SQL
- **API Framework**: FastAPI (Python)
- **ORM**: SQLAlchemy with Oracle drivers
- **CLI Interface**: Click with Rich formatting
- **Data Validation**: Pydantic models
- **Database Features**: Stored procedures, triggers, cursors

## 📋 Project Requirements Fulfilled

✅ **Entity-Relationship Analysis** - Complete analysis of Ghana Census questionnaire  
✅ **E/R Model** - Normalized database design with proper relationships  
✅ **Oracle Database Implementation** - Full schema with constraints  
✅ **Object-Oriented Programming** - Python with FastAPI framework  
✅ **User Interface** - Both web API and command-line interfaces  
✅ **CRUD Operations** - Complete Create, Read, Update, Delete functionality  
✅ **Stored Procedures** - Oracle PL/SQL procedures for backend operations  
✅ **Cursors** - Used for retrieving complex result sets  
✅ **JOIN Statements** - Multi-table queries throughout the system  
✅ **Triggers** - Automatic activity logging on all tables  

## 🗄️ Database Entities

### Core Entities
- **GEOGRAPHICAL_INFO** - Regions, districts, localities
- **HOUSEHOLD** - Household-level census data
- **INDIVIDUAL** - Personal demographic information
- **HOUSING** - Housing conditions and amenities
- **ECONOMIC_ACTIVITY** - Employment and economic data
- **FERTILITY** - Reproductive health data (females 12+)
- **MORTALITY** - Death records and causes
- **AGRICULTURAL_ACTIVITY** - Farming and livestock data
- **EMIGRATION** - Migration and emigrant data
- **DISABILITY** - Disability information
- **ACTIVITY_LOG** - System audit trail

### Key Features
- **Referential Integrity** - Proper foreign key relationships
- **Data Validation** - Check constraints and data types
- **Automatic Timestamps** - Created/modified dates
- **User Tracking** - Who created/modified records
- **Activity Logging** - Complete audit trail via triggers

## 🚀 Quick Start

### 1. Prerequisites
- Oracle Database (11g or later)
- Python 3.8+
- Oracle Instant Client

### 2. Installation
```bash
# Clone or extract the project
cd CensusDBMS_Oracle_Project

# Install Python dependencies
pip install -r requirements.txt

# Configure database connection
cp config/.env.template .env
# Edit .env with your Oracle database details
```

### 3. Database Setup
Execute the SQL scripts in this order:
```sql
-- 1. Create schema and tables
@sql/schemas/oracle_schema.sql

-- 2. Create stored procedures
@sql/procedures/oracle_procedures.sql

-- 3. Create triggers
@sql/triggers/oracle_triggers.sql

-- 4. Load sample data
@sql/sample_data/oracle_sample_data.sql
```

### 4. Test Connection
```bash
python cli/census_cli.py test-connection
```

### 5. Start the Application

#### Web API (FastAPI)
```bash
python app/main.py
# Visit http://localhost:8000/docs for API documentation
```

#### Command Line Interface
```bash
python cli/census_cli.py --help
python cli/census_cli.py init-help  # Show detailed setup guide
```

## 📖 Usage Examples

### Web API Examples

#### Create Geographical Information
```bash
POST /api/v1/geographical-info/
{
  "region_name": "Greater Accra",
  "district_name": "Accra Metropolitan",
  "district_type": "Metropolitan",
  "locality_name": "Osu"
}
```

#### Get Regional Statistics
```bash
GET /api/v1/analytics/regional-statistics?region_name=Ashanti
```

#### Search Individuals
```bash
POST /api/v1/search/individuals
{
  "region_name": "Greater Accra",
  "sex": "F",
  "min_age": 18,
  "max_age": 65
}
```

### CLI Examples

#### Create Geographical Info
```bash
python cli/census_cli.py geo create \
  --region "Northern" \
  --district "Tamale Metropolitan" \
  --locality "Tamale Central"
```

#### Create Household
```bash
python cli/census_cli.py household create \
  --geo-id 1 \
  --household-number "HH001" \
  --residence-type "Permanent"
```

#### Create Individual
```bash
python cli/census_cli.py individual create \
  --household-id 1 \
  --name "Kwame Asante" \
  --relationship "Head" \
  --sex M \
  --age 45 \
  --nationality "Ghanaian"
```

#### View Analytics
```bash
# Database statistics
python cli/census_cli.py analytics database-stats

# Household demographics
python cli/census_cli.py analytics demographics --household-id 1

# Regional statistics
python cli/census_cli.py analytics regional-stats --region "Ashanti"
```

## 🛠️ API Endpoints

### Core CRUD Operations
- `POST /api/v1/geographical-info/` - Create geographical information
- `GET /api/v1/geographical-info/` - List geographical information
- `PUT /api/v1/geographical-info/{id}` - Update geographical information
- `DELETE /api/v1/geographical-info/{id}` - Delete geographical information

- `POST /api/v1/households/` - Create household
- `GET /api/v1/households/` - List households
- `PUT /api/v1/households/{id}` - Update household
- `DELETE /api/v1/households/{id}` - Delete household

- `POST /api/v1/individuals/` - Create individual
- `GET /api/v1/individuals/` - List individuals
- `PUT /api/v1/individuals/{id}` - Update individual
- `DELETE /api/v1/individuals/{id}` - Delete individual

### Analytics & Reporting
- `GET /api/v1/analytics/household-demographics/{id}` - Household demographics
- `GET /api/v1/analytics/regional-statistics` - Regional statistics
- `GET /api/v1/analytics/housing-conditions` - Housing conditions
- `GET /api/v1/analytics/database-statistics` - Database statistics

### Search & Filtering
- `POST /api/v1/search/individuals` - Search individuals with filters

### Activity Monitoring
- `GET /api/v1/activity-log` - View activity logs
- `GET /api/v1/health` - Health check

## 🔧 Configuration

### Environment Variables (.env)
```env
# Oracle Database Configuration
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_SID=XE
ORACLE_USERNAME=census_user
ORACLE_PASSWORD=census_password

# Application Settings
DEBUG=true
API_HOST=0.0.0.0
API_PORT=8000

# Security
SECRET_KEY=your-secret-key-here
```

### Connection Pool Settings
- Pool Size: 5 connections
- Max Overflow: 10 connections
- Pool Timeout: 30 seconds
- Pool Recycle: 3600 seconds

## 📊 Database Design

### Entity Relationships
```
GEOGRAPHICAL_INFO 1 ── * HOUSEHOLD
                         │
                         1 ── * INDIVIDUAL
                         │         │
                         1         1
                         │         │
                      HOUSING  ECONOMIC_ACTIVITY
                              FERTILITY
                              DISABILITY
```

### Key Features
- **Normalization**: 3NF database design
- **Referential Integrity**: Foreign key constraints
- **Data Validation**: Check constraints and triggers
- **Activity Logging**: Audit triggers on all tables
- **Performance**: Indexed columns for fast queries

## 🧪 Testing

### Test Database Connection
```bash
python cli/census_cli.py test-connection
```

### View Sample Data
```bash
python cli/census_cli.py geo list
python cli/census_cli.py household list
python cli/census_cli.py individual list
```

### API Testing
Visit `http://localhost:8000/docs` for interactive API documentation with built-in testing interface.

## 📈 Performance Features

- **Connection Pooling**: Efficient database connection management
- **Prepared Statements**: Protection against SQL injection
- **Indexed Queries**: Fast data retrieval
- **Pagination**: Efficient handling of large result sets
- **Caching**: Oracle result set caching

## 🔒 Security Features

- **Input Validation**: Pydantic model validation
- **SQL Injection Protection**: Parameterized queries
- **Activity Logging**: Complete audit trail
- **Error Handling**: Secure error messages
- **Connection Security**: Encrypted database connections

## 📚 Technical Stack

- **Database**: Oracle Database 11g+
- **Backend**: Python 3.8+ with FastAPI
- **ORM**: SQLAlchemy with oracledb driver
- **Validation**: Pydantic models
- **CLI**: Click with Rich formatting
- **API Documentation**: OpenAPI/Swagger
- **Logging**: Python logging with custom formatters

## 🎓 Academic Features

This project demonstrates mastery of:
- **Database Design**: Normalization, relationships, constraints
- **Oracle PL/SQL**: Stored procedures, triggers, cursors
- **Python Programming**: Object-oriented design, frameworks
- **API Development**: RESTful APIs, documentation
- **Software Engineering**: Modular design, error handling
- **Data Analysis**: Statistical queries, reporting

## 📝 Project Structure

```
CensusDBMS_Oracle_Project/
├── sql/                    # Database scripts
│   ├── schemas/           # Table definitions
│   ├── procedures/        # Stored procedures
│   ├── triggers/          # Database triggers
│   └── sample_data/       # Test data
├── app/                   # Python application
│   ├── database/          # Database connections
│   ├── models/            # Pydantic models
│   ├── routes/            # API endpoints
│   ├── utils/             # Database services
│   └── main.py           # FastAPI application
├── cli/                   # Command-line interface
├── config/                # Configuration files
├── docs/                  # Documentation
└── requirements.txt       # Python dependencies
```

## 🤝 Contributing

This project follows academic standards and includes:
- Comprehensive documentation
- Clean, commented code
- Proper error handling
- Testing capabilities
- Performance considerations

## 📞 Support

For technical issues or questions:
1. Check the initialization guide: `python cli/census_cli.py init-help`
2. Test database connection: `python cli/census_cli.py test-connection`
3. View API documentation: `http://localhost:8000/docs`
4. Check activity logs for debugging

---

**Built for Ghana Statistical Service Census Data Management**
*Demonstrating enterprise-level database design and implementation*
