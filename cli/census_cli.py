#!/usr/bin/env python3
# =========================================
# COMMAND LINE INTERFACE
# Census Database Management System - Oracle Edition
# Created: 2025-07-23 10:34:43
# =========================================

import click
import sys
import os
from datetime import date
from tabulate import tabulate
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.progress import track
import json

# Add the project root to Python path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

try:
    from app.utils.db_service import census_service
    from app.models.pydantic_models import *
    from app.database.oracle_connection import connection_manager
except ImportError as e:
    print(f"Error importing modules: {e}")
    print("Please make sure you're running this from the project root directory")
    sys.exit(1)

# Initialize rich console
console = Console()

def print_success(message):
    """Print success message"""
    console.print(f"✅ {message}", style="green")

def print_error(message):
    """Print error message"""
    console.print(f"❌ {message}", style="red")

def print_info(message):
    """Print info message"""
    console.print(f"ℹ️  {message}", style="blue")

def print_table(data, title=None):
    """Print data as a formatted table"""
    if not data:
        print_info("No data found")
        return

    if isinstance(data, list) and len(data) > 0:
        # Create table
        table = Table(title=title)

        # Add columns
        if isinstance(data[0], dict):
            for key in data[0].keys():
                table.add_column(str(key), style="cyan")

            # Add rows
            for row in data:
                table.add_row(*[str(v) if v is not None else "" for v in row.values()])

        console.print(table)
    else:
        console.print(data)

@click.group()
@click.version_option(version="1.0.0")
def cli():
    """
    Census Database Management System - Command Line Interface

    A comprehensive CLI for managing census data with Oracle PL/SQL backend.
    """
    # Test database connection
    try:
        if not connection_manager.test_connection():
            print_error("Database connection failed. Please check your configuration.")
            sys.exit(1)
    except Exception as e:
        print_error(f"Database connection error: {e}")
        sys.exit(1)

# =========================================
# GEOGRAPHICAL INFORMATION COMMANDS
# =========================================

@cli.group()
def geo():
    """Manage geographical information"""
    pass

@geo.command()
@click.option('--region', required=True, help='Region name')
@click.option('--district', required=True, help='District name') 
@click.option('--district-type', help='District type')
@click.option('--locality', help='Locality name')
@click.option('--address', help='Detailed address')
@click.option('--phone', help='Contact phone number')
def create(region, district, district_type, locality, address, phone):
    """Create new geographical information"""
    try:
        geo_data = GeographicalInfoCreate(
            region_name=region,
            district_name=district,
            district_type=district_type,
            locality_name=locality,
            detailed_address=address,
            contact_phone_1=phone
        )

        geo_id = census_service.create_geographical_info(geo_data)
        print_success(f"Geographical information created with ID: {geo_id}")

    except Exception as e:
        print_error(f"Error creating geographical information: {e}")

@geo.command()
@click.option('--geo-id', type=int, help='Geographical information ID')
def list(geo_id):
    """List geographical information"""
    try:
        data = census_service.get_geographical_info(geo_id)
        print_table(data, "Geographical Information")

    except Exception as e:
        print_error(f"Error retrieving geographical information: {e}")

# =========================================
# HOUSEHOLD COMMANDS
# =========================================

@cli.group()
def household():
    """Manage households"""
    pass

@household.command()
@click.option('--geo-id', required=True, type=int, help='Geographical information ID')
@click.option('--household-number', help='Household number in structure')
@click.option('--residence-type', help='Type of residence')
@click.option('--form-number', help='Form number')
def create(geo_id, household_number, residence_type, form_number):
    """Create new household"""
    try:
        household_data = HouseholdCreate(
            geo_id=geo_id,
            household_number_in_structure=household_number,
            type_of_residence=residence_type,
            form_number=form_number,
            interview_date_started=date.today()
        )

        household_id = census_service.create_household(household_data)
        print_success(f"Household created with ID: {household_id}")

    except Exception as e:
        print_error(f"Error creating household: {e}")

@household.command()
@click.option('--household-id', type=int, help='Household ID')
@click.option('--geo-id', type=int, help='Geographical information ID')
def list(household_id, geo_id):
    """List households"""
    try:
        data = census_service.get_households(household_id, geo_id)
        print_table(data, "Households")

    except Exception as e:
        print_error(f"Error retrieving households: {e}")

# =========================================
# INDIVIDUAL COMMANDS
# =========================================

@cli.group()
def individual():
    """Manage individuals"""
    pass

@individual.command()
@click.option('--household-id', required=True, type=int, help='Household ID')
@click.option('--name', required=True, help='Full name')
@click.option('--relationship', help='Relationship to head')
@click.option('--sex', type=click.Choice(['M', 'F']), help='Sex (M/F)')
@click.option('--age', type=int, help='Age')
@click.option('--nationality', help='Nationality')
@click.option('--ethnicity', help='Ethnicity')
@click.option('--religion', help='Religion')
@click.option('--marital-status', help='Marital status')
@click.option('--education', help='Highest education level')
def create(household_id, name, relationship, sex, age, nationality, ethnicity, religion, marital_status, education):
    """Create new individual"""
    try:
        individual_data = IndividualCreate(
            household_id=household_id,
            full_name=name,
            relationship_to_head=relationship,
            sex=Sex(sex) if sex else None,
            age=age,
            nationality=nationality,
            ethnicity=ethnicity,
            religion=religion,
            marital_status=marital_status,
            highest_education_level=education
        )

        individual_id = census_service.create_individual(individual_data)
        print_success(f"Individual created with ID: {individual_id}")

    except Exception as e:
        print_error(f"Error creating individual: {e}")

@individual.command()
@click.option('--individual-id', type=int, help='Individual ID')
@click.option('--household-id', type=int, help='Household ID')
def list(individual_id, household_id):
    """List individuals"""
    try:
        data = census_service.get_individuals(individual_id, household_id)
        print_table(data, "Individuals")

    except Exception as e:
        print_error(f"Error retrieving individuals: {e}")

# =========================================
# HOUSING COMMANDS
# =========================================

@cli.group()
def housing():
    """Manage housing information"""
    pass

@housing.command()
@click.option('--household-id', required=True, type=int, help='Household ID')
@click.option('--dwelling-type', help='Type of dwelling')
@click.option('--wall-material', help='Outer wall material')
@click.option('--floor-material', help='Floor material')
@click.option('--roof-material', help='Roof material')
@click.option('--rooms', type=int, help='Number of rooms occupied')
@click.option('--lighting', help='Main lighting source')
@click.option('--water-source', help='Main drinking water source')
@click.option('--toilet-type', help='Type of toilet facility')
def create(household_id, dwelling_type, wall_material, floor_material, roof_material, rooms, lighting, water_source, toilet_type):
    """Create housing information"""
    try:
        housing_data = HousingCreate(
            household_id=household_id,
            dwelling_type=dwelling_type,
            outer_wall_material=wall_material,
            floor_material=floor_material,
            roof_material=roof_material,
            rooms_occupied=rooms,
            main_lighting_source=lighting,
            main_drinking_water_source=water_source,
            toilet_facility_type=toilet_type
        )

        housing_id = census_service.create_housing(housing_data)
        print_success(f"Housing information created with ID: {housing_id}")

    except Exception as e:
        print_error(f"Error creating housing information: {e}")

# =========================================
# ANALYTICS COMMANDS
# =========================================

@cli.group()
def analytics():
    """View analytics and reports"""
    pass

@analytics.command()
@click.option('--household-id', required=True, type=int, help='Household ID')
def demographics(household_id):
    """View household demographics"""
    try:
        data = census_service.get_household_demographics(household_id)
        print_table(data, f"Household {household_id} Demographics")

    except Exception as e:
        print_error(f"Error retrieving household demographics: {e}")

@analytics.command()
@click.option('--region', help='Region name filter')
def regional_stats(region):
    """View regional statistics"""
    try:
        data = census_service.get_regional_statistics(region)
        print_table(data, f"Regional Statistics{' - ' + region if region else ''}")

    except Exception as e:
        print_error(f"Error retrieving regional statistics: {e}")

@analytics.command()
@click.option('--district', help='District name filter')
def housing_conditions(district):
    """View housing conditions"""
    try:
        data = census_service.get_housing_conditions(district)
        print_table(data, f"Housing Conditions{' - ' + district if district else ''}")

    except Exception as e:
        print_error(f"Error retrieving housing conditions: {e}")

@analytics.command()
def database_stats():
    """View database statistics"""
    try:
        data = census_service.get_database_statistics()

        # Format statistics nicely
        console.print(Panel.fit(
            f"""Database Statistics:

📊 Total Geographical Areas: {data.get('TOTAL_GEOGRAPHICAL_AREAS', 0)}
🏠 Total Households: {data.get('TOTAL_HOUSEHOLDS', 0)}
👥 Total Individuals: {data.get('TOTAL_INDIVIDUALS', 0)}
🏘️  Total Housing Records: {data.get('TOTAL_HOUSING_RECORDS', 0)}
💼 Total Economic Records: {data.get('TOTAL_ECONOMIC_RECORDS', 0)}
📝 Total Activity Log Entries: {data.get('TOTAL_LOG_ENTRIES', 0)}
            """,
            title="Census Database Statistics",
            style="green"
        ))

    except Exception as e:
        print_error(f"Error retrieving database statistics: {e}")

# =========================================
# SEARCH COMMANDS
# =========================================

@cli.group()
def search():
    """Search census data"""
    pass

@search.command()
@click.option('--region', help='Region name')
@click.option('--district', help='District name')
@click.option('--sex', type=click.Choice(['M', 'F']), help='Sex (M/F)')
@click.option('--min-age', type=int, help='Minimum age')
@click.option('--max-age', type=int, help='Maximum age')
@click.option('--marital-status', help='Marital status')
@click.option('--education', help='Education level')
@click.option('--page', default=1, help='Page number')
@click.option('--size', default=20, help='Page size')
def individuals(region, district, sex, min_age, max_age, marital_status, education, page, size):
    """Search individuals with filters"""
    try:
        filters = SearchFilters(
            region_name=region,
            district_name=district,
            sex=Sex(sex) if sex else None,
            min_age=min_age,
            max_age=max_age,
            marital_status=marital_status,
            education_level=education
        )

        pagination = PaginationParams(page=page, size=size)
        data, total_count = census_service.search_individuals(filters, pagination)

        print_info(f"Found {total_count} individuals matching criteria")
        print_info(f"Showing page {page} of {(total_count + size - 1) // size}")
        print_table(data, "Search Results - Individuals")

    except Exception as e:
        print_error(f"Error searching individuals: {e}")

# =========================================
# ACTIVITY LOG COMMANDS
# =========================================

@cli.group()
def logs():
    """View activity logs"""
    pass

@logs.command()
@click.option('--table', help='Table name filter')
@click.option('--operation', type=click.Choice(['INSERT', 'UPDATE', 'DELETE']), help='Operation type')
@click.option('--user', help='User name filter')
@click.option('--days', default=7, help='Days back to search')
def activity(table, operation, user, days):
    """View recent activity logs"""
    try:
        data = census_service.get_activity_log(table, operation, user, days)
        print_table(data, f"Activity Log - Last {days} days")

    except Exception as e:
        print_error(f"Error retrieving activity log: {e}")

# =========================================
# UTILITY COMMANDS
# =========================================

@cli.command()
def test_connection():
    """Test database connection"""
    try:
        if connection_manager.test_connection():
            print_success("Database connection is working properly!")

            # Get some basic info
            stats = census_service.get_database_statistics()
            print_info(f"Total records in system: {sum(stats.values())}")
        else:
            print_error("Database connection failed!")

    except Exception as e:
        print_error(f"Connection test failed: {e}")

@cli.command()
def init_help():
    """Show initialization help"""
    console.print(Panel.fit(
        """Initialization Steps:

1. 📋 Configure Database Connection:
   - Copy config/.env.template to .env
   - Update Oracle connection details

2. 🗄️  Setup Database Schema:
   - sql/schemas/oracle_schema.sql
   - sql/procedures/oracle_procedures.sql
   - sql/triggers/oracle_triggers.sql
   - sql/sample_data/oracle_sample_data.sql

3. 🐍 Install Dependencies:
   - pip install -r requirements.txt

4. 🧪 Test Connection:
   - python cli/census_cli.py test-connection

5. 🚀 Start Using:   
   - python cli/census_cli.py --help
   - python app/main.py (for web API)

6. 📖 View Documentation:
   - Visit http://localhost:8000/docs
        """,
        title="Census DBMS - Initialization Guide",
        style="blue"
    ))

if __name__ == '__main__':
    cli()
