# =========================================
# DATABASE SERVICE LAYER
# Census Database Management System - Oracle Edition
# Created: 2025-07-23 10:32:25
# =========================================

import oracledb
from typing import Optional, List, Dict, Any, Tuple
from app.database.oracle_connection import DirectOracleConnection, connection_manager
from app.models.pydantic_models import *
import logging

logger = logging.getLogger(__name__)

class CensusService:
    """
    Service class to handle database operations for the Census system.
    """

    # =========================================
    # GEOGRAPHICAL INFORMATION SERVICES
    # =========================================

    @staticmethod
    def create_geographical_info(geo_data: GeographicalInfoCreate) -> int:
        """Create geographical information using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            geo_id = cursor.var(oracledb.DB_TYPE_NUMBER)

            try:
                cursor.callproc('SP_INSERT_GEOGRAPHICAL_INFO', [
                    geo_data.region_name,
                    geo_data.district_name,
                    geo_data.district_type,
                    geo_data.sub_district,
                    geo_data.locality_name,
                    geo_data.nhis_ecg_vra_number,
                    geo_data.detailed_address,
                    geo_data.contact_phone_1,
                    geo_data.contact_phone_2,
                    geo_data.enumeration_area_code,
                    geo_data.ea_type,
                    geo_data.locality_code,
                    geo_data.structure_number,
                    geo_id
                ])
                connection.commit()
                return geo_id.getvalue()
            finally:
                cursor.close()

    @staticmethod
    def update_geographical_info(geo_id: int, geo_data: GeographicalInfoUpdate) -> bool:
        """Update geographical information using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_UPDATE_GEOGRAPHICAL_INFO', [
                    geo_id,
                    geo_data.region_name,
                    geo_data.district_name,
                    geo_data.district_type,
                    geo_data.sub_district,
                    geo_data.locality_name,
                    geo_data.detailed_address,
                    geo_data.contact_phone_1,
                    geo_data.contact_phone_2
                ])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error updating geographical info: {e}")
                return False
            finally:
                cursor.close()

    @staticmethod
    def delete_geographical_info(geo_id: int) -> bool:
        """Delete geographical information using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_DELETE_GEOGRAPHICAL_INFO', [geo_id])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error deleting geographical info: {e}")
                return False
            finally:
                cursor.close()

    @staticmethod
    def get_geographical_info(geo_id: Optional[int] = None) -> List[Dict]:
        """Get geographical information"""
        sql = """
        SELECT geo_id, region_name, district_name, district_type, sub_district,
               locality_name, detailed_address, contact_phone_1, contact_phone_2,
               date_created, created_by
        FROM GEOGRAPHICAL_INFO
        """

        params = {}
        if geo_id:
            sql += " WHERE geo_id = :geo_id"
            params['geo_id'] = geo_id

        sql += " ORDER BY region_name, district_name"

        return connection_manager.execute_raw_sql(sql, params)

    # =========================================
    # HOUSEHOLD SERVICES
    # =========================================

    @staticmethod
    def create_household(household_data: HouseholdCreate) -> int:
        """Create household using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            household_id = cursor.var(oracledb.DB_TYPE_NUMBER)

            try:
                cursor.callproc('SP_INSERT_HOUSEHOLD', [
                    household_data.geo_id,
                    household_data.household_number_in_structure,
                    household_data.type_of_residence,
                    household_data.interview_date_started,
                    household_data.interview_date_completed,
                    household_data.total_visits or 1,
                    household_data.form_number,
                    household_data.housing_unit_status.value if household_data.housing_unit_status else 'OCCUPIED',
                    household_id
                ])
                connection.commit()
                return household_id.getvalue()
            finally:
                cursor.close()

    @staticmethod
    def update_household(household_id: int, household_data: HouseholdUpdate) -> bool:
        """Update household using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_UPDATE_HOUSEHOLD', [
                    household_id,
                    household_data.type_of_residence,
                    household_data.interview_date_completed,
                    household_data.total_visits,
                    household_data.housing_unit_status.value if household_data.housing_unit_status else None
                ])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error updating household: {e}")
                return False
            finally:
                cursor.close()

    @staticmethod
    def delete_household(household_id: int) -> bool:
        """Delete household using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_DELETE_HOUSEHOLD', [household_id])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error deleting household: {e}")
                return False
            finally:
                cursor.close()

    @staticmethod
    def get_households(household_id: Optional[int] = None, geo_id: Optional[int] = None) -> List[Dict]:
        """Get households with geographical information"""
        sql = """
        SELECT h.household_id, h.geo_id, h.household_number_in_structure,
               h.type_of_residence, h.total_members, h.total_males, h.total_females,
               h.housing_unit_status, h.interview_date_started, h.interview_date_completed,
               g.region_name, g.district_name, g.locality_name
        FROM HOUSEHOLD h
        JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id
        WHERE 1=1
        """

        params = {}
        if household_id:
            sql += " AND h.household_id = :household_id"
            params['household_id'] = household_id
        if geo_id:
            sql += " AND h.geo_id = :geo_id"
            params['geo_id'] = geo_id

        sql += " ORDER BY g.region_name, g.district_name, h.household_id"

        return connection_manager.execute_raw_sql(sql, params)

    # =========================================
    # INDIVIDUAL SERVICES
    # =========================================

    @staticmethod
    def create_individual(individual_data: IndividualCreate) -> int:
        """Create individual using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            individual_id = cursor.var(oracledb.DB_TYPE_NUMBER)

            try:
                cursor.callproc('SP_INSERT_INDIVIDUAL', [
                    individual_data.household_id,
                    individual_data.person_line_number,
                    individual_data.full_name,
                    individual_data.relationship_to_head,
                    individual_data.sex.value if individual_data.sex else None,
                    individual_data.date_of_birth,
                    individual_data.age,
                    individual_data.nationality,
                    individual_data.ethnicity,
                    individual_data.religion,
                    individual_data.marital_status,
                    individual_data.highest_education_level,
                    individual_data.status_on_census_night.value if individual_data.status_on_census_night else 'PRESENT',
                    individual_id
                ])
                connection.commit()
                return individual_id.getvalue()
            finally:
                cursor.close()

    @staticmethod
    def update_individual(individual_id: int, individual_data: IndividualUpdate) -> bool:
        """Update individual using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_UPDATE_INDIVIDUAL', [
                    individual_id,
                    individual_data.full_name,
                    individual_data.relationship_to_head,
                    individual_data.sex.value if individual_data.sex else None,
                    individual_data.age,
                    individual_data.nationality,
                    individual_data.ethnicity,
                    individual_data.religion,
                    individual_data.marital_status,
                    individual_data.highest_education_level
                ])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error updating individual: {e}")
                return False
            finally:
                cursor.close()

    @staticmethod
    def delete_individual(individual_id: int) -> bool:
        """Delete individual using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            success = cursor.var(bool)
            try:
                cursor.callproc('SP_DELETE_INDIVIDUAL', [individual_id, success])
                return success.getvalue()
            except oracledb.DatabaseError as e:
                logger.error(f"Error deleting individual: {e}")
                return False

    @staticmethod
    def get_individuals(individual_id: Optional[int] = None, household_id: Optional[int] = None, limit: Optional[int] = None) -> List[Dict]:
        """Retrieve individuals with optional filtering and limit"""
        base_sql = "SELECT * FROM V_INDIVIDUAL_DETAILS"
        filters = []
        params = {}

        if individual_id is not None:
            filters.append("INDIVIDUAL_ID = :individual_id")
            params['individual_id'] = individual_id
        
        if household_id is not None:
            filters.append("HOUSEHOLD_ID = :household_id")
            params['household_id'] = household_id

        if filters:
            base_sql += " WHERE " + " AND ".join(filters)
            
        base_sql += " ORDER BY INDIVIDUAL_ID DESC"

        if limit is not None:
            # Use Oracle's row limiting clause
            base_sql += " FETCH FIRST :limit ROWS ONLY"
            params['limit'] = limit

        return connection_manager.execute_raw_sql(base_sql, params)

    # =========================================
    # HOUSING SERVICES
    # =========================================

    @staticmethod
    def create_housing(housing_data: HousingCreate) -> int:
        """Create housing information using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            housing_id = cursor.var(oracledb.DB_TYPE_NUMBER)

            try:
                cursor.callproc('SP_INSERT_HOUSING', [
                    housing_data.household_id,
                    housing_data.dwelling_type,
                    housing_data.outer_wall_material,
                    housing_data.floor_material,
                    housing_data.roof_material,
                    housing_data.rooms_occupied,
                    housing_data.rooms_for_sleeping,
                    housing_data.main_lighting_source,
                    housing_data.main_drinking_water_source,
                    housing_data.toilet_facility_type,
                    housing_id
                ])
                connection.commit()
                return housing_id.getvalue()
            finally:
                cursor.close()

    @staticmethod
    def update_housing(housing_id: int, housing_data: HousingUpdate) -> bool:
        """Update housing information using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_UPDATE_HOUSING', [
                    housing_id,
                    housing_data.dwelling_type,
                    housing_data.outer_wall_material,
                    housing_data.floor_material,
                    housing_data.roof_material,
                    housing_data.rooms_occupied,
                    housing_data.main_lighting_source,
                    housing_data.main_drinking_water_source,
                    housing_data.toilet_facility_type
                ])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error updating housing: {e}")
                return False
            finally:
                cursor.close()

    @staticmethod
    def delete_housing(housing_id: int) -> bool:
        """Delete housing information using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()

            try:
                cursor.callproc('SP_DELETE_HOUSING', [housing_id])
                connection.commit()
                return True
            except Exception as e:
                logger.error(f"Error deleting housing: {e}")
                return False
            finally:
                cursor.close()

    # =========================================
    # ECONOMIC ACTIVITY SERVICES
    # =========================================

    @staticmethod
    def create_economic_activity(economic_data: EconomicActivityCreate) -> int:
        """Create economic activity using stored procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            economic_id = cursor.var(oracledb.DB_TYPE_NUMBER)

            try:
                cursor.callproc('SP_INSERT_ECONOMIC_ACTIVITY', [
                    economic_data.individual_id,
                    economic_data.engaged_in_economic_activity.value if economic_data.engaged_in_economic_activity else 'N',
                    economic_data.occupation_description,
                    economic_data.occupation_code,
                    economic_data.workplace_name,
                    economic_data.employment_status,
                    economic_data.employment_sector,
                    economic_data.owns_mobile_phone.value if economic_data.owns_mobile_phone else 'N',
                    economic_data.uses_internet.value if economic_data.uses_internet else 'N',
                    economic_id
                ])
                connection.commit()
                return economic_id.getvalue()
            finally:
                cursor.close()

    # =========================================
    # COMPLEX QUERY SERVICES (using cursors)
    # =========================================

    @staticmethod
    def get_household_demographics(household_id: int) -> List[Dict]:
        """Get household demographics using cursor procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            result_cursor = connection.cursor()

            try:
                cursor.callproc('SP_GET_HOUSEHOLD_DEMOGRAPHICS', [household_id, result_cursor])

                # Fetch results from cursor
                columns = [desc[0] for desc in result_cursor.description]
                results = []
                for row in result_cursor:
                    results.append(dict(zip(columns, row)))

                return results
            finally:
                result_cursor.close()
                cursor.close()

    @staticmethod
    def get_regional_statistics(region_name: Optional[str] = None) -> List[Dict]:
        """Get regional statistics using cursor procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            result_cursor = connection.cursor()

            try:
                cursor.callproc('SP_GET_REGIONAL_STATISTICS', [region_name, result_cursor])

                # Fetch results from cursor
                columns = [desc[0] for desc in result_cursor.description]
                results = []
                for row in result_cursor:
                    results.append(dict(zip(columns, row)))

                return results
            finally:
                result_cursor.close()
                cursor.close()

    @staticmethod
    def get_housing_conditions(district_name: Optional[str] = None) -> List[Dict]:
        """Get housing conditions using cursor procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            result_cursor = connection.cursor()

            try:
                cursor.callproc('SP_GET_HOUSING_CONDITIONS', [district_name, result_cursor])

                # Fetch results from cursor
                columns = [desc[0] for desc in result_cursor.description]
                results = []
                for row in result_cursor:
                    results.append(dict(zip(columns, row)))

                return results
            finally:
                result_cursor.close()
                cursor.close()

    # =========================================
    # ACTIVITY LOG SERVICES
    # =========================================

    @staticmethod
    def get_activity_log(table_name: Optional[str] = None, 
                        operation_type: Optional[str] = None,
                        user_name: Optional[str] = None,
                        days_back: int = 7) -> List[Dict]:
        """Get activity log using cursor procedure"""
        with DirectOracleConnection.get_connection() as connection:
            cursor = connection.cursor()
            result_cursor = connection.cursor()

            try:
                cursor.callproc('SP_GET_ACTIVITY_LOGS', [
                    table_name, operation_type, user_name, days_back, result_cursor
                ])

                # Fetch results from cursor
                columns = [desc[0] for desc in result_cursor.description]
                results = []
                for row in result_cursor:
                    row_dict = dict(zip(columns, row))
                    # Convert timestamp to string for JSON serialization
                    if 'OPERATION_TIMESTAMP' in row_dict and row_dict['OPERATION_TIMESTAMP']:
                        row_dict['OPERATION_TIMESTAMP'] = row_dict['OPERATION_TIMESTAMP'].isoformat()
                    results.append(row_dict)

                return results
            finally:
                result_cursor.close()
                cursor.close()

    # =========================================
    # UTILITY SERVICES
    # =========================================

    @staticmethod
    def get_database_statistics() -> Dict[str, Any]:
        """Get general database statistics"""
        sql = """
        SELECT 
            (SELECT COUNT(*) FROM GEOGRAPHICAL_INFO) as total_geographical_areas,
            (SELECT COUNT(*) FROM HOUSEHOLD) as total_households,
            (SELECT COUNT(*) FROM INDIVIDUAL) as total_individuals,
            (SELECT COUNT(*) FROM HOUSING) as total_housing_records,
            (SELECT COUNT(*) FROM ECONOMIC_ACTIVITY) as total_economic_records,
            (SELECT COUNT(*) FROM ACTIVITY_LOG) as total_log_entries
        FROM DUAL
        """

        result = connection_manager.execute_raw_sql(sql)
        return result[0] if result else {}

    @staticmethod
    def search_individuals(filters: SearchFilters, pagination: PaginationParams) -> Tuple[List[Dict], int]:
        """Search individuals with filters and pagination"""
        # Build WHERE clause based on filters
        where_conditions = []
        params = {}

        if filters.region_name:
            where_conditions.append("g.region_name = :region_name")
            params['region_name'] = filters.region_name

        if filters.district_name:
            where_conditions.append("g.district_name = :district_name")
            params['district_name'] = filters.district_name

        if filters.sex:
            where_conditions.append("i.sex = :sex")
            params['sex'] = filters.sex.value

        if filters.min_age is not None:
            where_conditions.append("i.age >= :min_age")
            params['min_age'] = filters.min_age

        if filters.max_age is not None:
            where_conditions.append("i.age <= :max_age")
            params['max_age'] = filters.max_age

        if filters.marital_status:
            where_conditions.append("i.marital_status = :marital_status")
            params['marital_status'] = filters.marital_status

        if filters.education_level:
            where_conditions.append("i.highest_education_level = :education_level")
            params['education_level'] = filters.education_level

        where_clause = " AND ".join(where_conditions) if where_conditions else "1=1"

        # Count query
        count_sql = f"""
        SELECT COUNT(*) as total_count
        FROM INDIVIDUAL i
        JOIN HOUSEHOLD h ON i.household_id = h.household_id
        JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id
        WHERE {where_clause}
        """

        count_result = connection_manager.execute_raw_sql(count_sql, params)
        total_count = count_result[0]['TOTAL_COUNT'] if count_result else 0

        # Data query with pagination
        data_sql = f"""
        SELECT * FROM (
            SELECT i.*, g.region_name, g.district_name, g.locality_name,
                   ROW_NUMBER() OVER (ORDER BY i.individual_id) as rn
            FROM INDIVIDUAL i
            JOIN HOUSEHOLD h ON i.household_id = h.household_id
            JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id
            WHERE {where_clause}
        ) WHERE rn BETWEEN :start_row AND :end_row
        """

        params['start_row'] = pagination.offset + 1
        params['end_row'] = pagination.offset + pagination.size

        data_result = connection_manager.execute_raw_sql(data_sql, params)

        return data_result, total_count

# Global service instance
census_service = CensusService()
