import streamlit as st
import pandas as pd
import os
from datetime import date

# Set up paths to import from the 'app' module
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '.')))

from app.utils.db_service import census_service
from app.models.pydantic_models import (
    GeographicalInfoCreate, 
    HouseholdCreate, 
    IndividualCreate, 
    Sex, 
    SearchFilters,
    PaginationParams
)

# --- Database Connection ---
@st.cache_resource
def get_db_service():
    """Initializes and returns the CensusService, caching the resource."""
    # This function can be simplified as census_service is already imported
    return census_service

service = get_db_service()

# --- UI Layout ---
st.set_page_config(page_title="Census DBMS", layout="wide")
st.title("📊 Census Database Management System")

st.sidebar.title("Navigation")
page = st.sidebar.radio("Go to", ["Dashboard", "Data Management", "Analytics & Reporting", "Search", "Activity Log"])

# --- Page: Dashboard ---
if page == "Dashboard":
    st.header("📈 Dashboard")
    st.markdown("An overview of the census data.")

    try:
        stats = service.get_database_statistics()
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric(label="Total Individuals", value=stats.get('TOTAL_INDIVIDUALS', 0))
        with col2:
            st.metric(label="Total Households", value=stats.get('TOTAL_HOUSEHOLDS', 0))
        with col3:
            st.metric(label="Total Geographical Areas", value=stats.get('TOTAL_GEOGRAPHICAL_AREAS', 0))

        st.divider()
        
        st.subheader("Recent Individuals")
        recent_individuals_df = pd.DataFrame(service.get_individuals(limit=10))
        st.dataframe(recent_individuals_df, use_container_width=True)

    except Exception as e:
        st.error(f"Could not load dashboard: {e}")


# --- Page: Data Management ---
elif page == "Data Management":
    st.header("🗃️ Data Management")
    
    entity_type = st.selectbox("Select Entity to Manage", ["Individuals", "Households", "Geographical Info"])
    
    if entity_type == "Individuals":
        st.subheader("Manage Individuals")
        
        # Create
        with st.expander("Add New Individual", expanded=False):
            with st.form("new_individual_form", clear_on_submit=True):
                st.write("Enter details for the new individual:")
                household_id = st.number_input("Household ID", min_value=1, step=1)
                full_name = st.text_input("Full Name", help="Enter the full name of the person.")
                relationship_to_head = st.text_input("Relationship to Head", "Head")
                sex = st.selectbox("Gender", [s.value for s in Sex])
                dob = st.date_input("Date of Birth", min_value=date(1900, 1, 1), max_value=date.today())
                nationality = st.text_input("Nationality", "Ghanaian")
                marital_status = st.selectbox("Marital Status", ["Single", "Married", "Divorced", "Widowed", "Separated"])
                occupation = st.text_input("Occupation")
                
                submitted = st.form_submit_button("Add Individual")
                if submitted:
                    try:
                        new_individual = IndividualCreate(
                            household_id=household_id,
                            full_name=full_name,
                            relationship_to_head=relationship_to_head,
                            sex=sex,
                            date_of_birth=dob,
                            nationality=nationality,
                            marital_status=marital_status,
                            occupation=occupation
                        )
                        service.create_individual(new_individual)
                        st.success("Successfully added new individual!")
                    except Exception as e:
                        st.error(f"Error creating individual: {e}")
            
            # Read
            st.subheader("View Individuals")
            individuals_df = pd.DataFrame(service.get_individuals())
            st.dataframe(individuals_df, use_container_width=True)

    elif entity_type == "Households":
        st.subheader("Manage Households")
        with st.expander("Add New Household", expanded=False):
            with st.form("new_household_form", clear_on_submit=True):
                st.write("Enter details for the new household:")
                geo_id = st.number_input("Geographical ID", min_value=1, step=1)
                household_number = st.text_input("Household Number", "H001")
                type_of_residence = st.text_input("Type of Residence", "Separate House")
                
                submitted = st.form_submit_button("Add Household")
                if submitted:
                    try:
                        new_household = HouseholdCreate(
                            geo_id=geo_id,
                            household_number_in_structure=household_number,
                            type_of_residence=type_of_residence
                        )
                        service.create_household(new_household)
                        st.success("Successfully added new household!")
                    except Exception as e:
                        st.error(f"Error creating household: {e}")
    
            st.subheader("View Households")
            households_df = pd.DataFrame(service.get_households())
            st.dataframe(households_df, use_container_width=True)

    elif entity_type == "Geographical Info":
        st.subheader("Manage Geographical Info")
        with st.expander("Add New Geographical Region", expanded=False):
            with st.form("new_geo_form", clear_on_submit=True):
                st.write("Enter details for the new geographical region:")
                region_name = st.text_input("Region Name")
                district_name = st.text_input("District Name")
                locality_name = st.text_input("Locality Name")
                enumeration_area_code = st.text_input("Enumeration Area Code", help="e.g., GA-001-001")

                submitted = st.form_submit_button("Add Region")
                if submitted:
                    try:
                        new_geo = GeographicalInfoCreate(
                            region_name=region_name,
                            district_name=district_name,
                            locality_name=locality_name,
                            enumeration_area_code=enumeration_area_code
                        )
                        service.create_geographical_info(new_geo)
                        st.success("Successfully added new region!")
                    except Exception as e:
                        st.error(f"Error creating region: {e}")
    
            st.subheader("View Geographical Info")
            geo_df = pd.DataFrame(service.get_geographical_info())
            st.dataframe(geo_df, use_container_width=True)

# --- Page: Analytics & Reporting ---
elif page == "Analytics & Reporting":
    st.header("📊 Analytics & Reporting")
    
    report_type = st.selectbox("Select Report", ["Regional Statistics", "Household Demographics", "Housing Conditions"])

    if report_type == "Regional Statistics":
        st.subheader("Regional Statistics")
        try:
            region = st.text_input("Filter by Region Name (optional)")
            data = service.get_regional_statistics(region if region else None)
            if data:
                df = pd.DataFrame(data)
                st.bar_chart(df.set_index('REGION_NAME')[['TOTAL_POPULATION', 'TOTAL_MALES', 'TOTAL_FEMALES']])
                st.dataframe(df, use_container_width=True)
            else:
                st.info("No data available for this report.")
        except Exception as e:
            st.error(f"Could not generate report: {e}")

    elif report_type == "Household Demographics":
        st.subheader("Household Demographics")
        household_id = st.number_input("Enter Household ID", min_value=1, step=1)
        if st.button("Get Demographics"):
            try:
                data = service.get_household_demographics(household_id)
                if data:
                    df = pd.DataFrame(data)
                    st.dataframe(df, use_container_width=True)
                else:
                    st.info("No data available for this household.")
            except Exception as e:
                st.error(f"Could not generate report: {e}")

    elif report_type == "Housing Conditions":
        st.subheader("Housing Conditions by District")
        try:
            district = st.text_input("Filter by District Name (optional)")
            data = service.get_housing_conditions(district if district else None)
            if data:
                df = pd.DataFrame(data)
                st.dataframe(df, use_container_width=True)
            else:
                st.info("No data available for this report.")
        except Exception as e:
            st.error(f"Could not generate report: {e}")

# --- Page: Search ---
elif page == "Search":
    st.header("🔍 Search Individuals")
    
    with st.form("search_form"):
        region_name = st.text_input("Region Name")
        district_name = st.text_input("District Name")
        sex = st.selectbox("Gender", ["", "M", "F"])
        min_age = st.number_input("Min Age", min_value=0, max_value=150, value=0)
        max_age = st.number_input("Max Age", min_value=0, max_value=150, value=150)
        marital_status = st.selectbox("Marital Status", ["", "Single", "Married", "Divorced", "Widowed", "Separated"])
        
        page_num = st.number_input("Page", min_value=1, value=1)
        page_size = st.number_input("Results per page", min_value=1, max_value=100, value=20)

        search_submitted = st.form_submit_button("Search")

    if search_submitted:
        try:
            filters = SearchFilters(
                region_name=region_name or None,
                district_name=district_name or None,
                sex=sex or None,
                min_age=min_age,
                max_age=max_age,
                marital_status=marital_status or None
            )
            pagination = PaginationParams(page=page_num, size=page_size)
            
            results, total_count = service.search_individuals(filters, pagination)
            
            st.success(f"Found {total_count} individuals. Displaying page {page_num}.")
            if results:
                results_df = pd.DataFrame(results)
                st.dataframe(results_df, use_container_width=True)
            else:
                st.info("No individuals found matching your criteria.")
        except Exception as e:
            st.error(f"An error occurred during search: {e}")

# --- Page: Activity Log ---
elif page == "Activity Log":
    st.header("📜 Activity Log")
    st.subheader("View recent database activities")

    days_back = st.slider("Days to look back", 1, 30, 7)
    table_name = st.text_input("Filter by Table Name (e.g., INDIVIDUAL)")
    operation_type = st.selectbox("Filter by Operation", ["", "INSERT", "UPDATE", "DELETE"])

    if st.button("Fetch Logs"):
        try:
            logs = service.get_activity_log(
                table_name=table_name or None,
                operation_type=operation_type or None,
                days_back=days_back
            )
            if logs:
                log_df = pd.DataFrame(logs)
                st.dataframe(log_df, use_container_width=True)
            else:
                st.info("No activity logs found for the selected criteria.")
        except Exception as e:
            st.error(f"Failed to retrieve activity logs: {e}")

# --- How to Run ---
st.sidebar.divider()
st.sidebar.info(
    """
    **To run this app:**
    1. Ensure your `.env` file is configured with:
       `DB_DSN`, `DB_USER`, `DB_PASSWORD`
    2. Open your terminal and run:
       `streamlit run streamlit_app.py`
    """
)