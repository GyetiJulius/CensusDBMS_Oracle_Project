-- =========================================
-- ORACLE PL/SQL STORED PROCEDURES
-- Census Database Management System
-- Created: 2025-07-23 10:26:09
-- =========================================

-- =========================================
-- GEOGRAPHICAL INFORMATION PROCEDURES
-- =========================================

-- Insert Geographical Information
CREATE OR REPLACE PROCEDURE SP_INSERT_GEOGRAPHICAL_INFO (
    p_region_name IN VARCHAR2,
    p_district_name IN VARCHAR2,
    p_district_type IN VARCHAR2 DEFAULT NULL,
    p_sub_district IN VARCHAR2 DEFAULT NULL,
    p_locality_name IN VARCHAR2 DEFAULT NULL,
    p_nhis_ecg_vra_number IN VARCHAR2 DEFAULT NULL,
    p_detailed_address IN CLOB DEFAULT NULL,
    p_contact_phone_1 IN VARCHAR2 DEFAULT NULL,
    p_contact_phone_2 IN VARCHAR2 DEFAULT NULL,
    p_enumeration_area_code IN VARCHAR2 DEFAULT NULL,
    p_ea_type IN VARCHAR2 DEFAULT NULL,
    p_locality_code IN VARCHAR2 DEFAULT NULL,
    p_structure_number IN VARCHAR2 DEFAULT NULL,
    p_geo_id OUT NUMBER
) AS
BEGIN
    INSERT INTO GEOGRAPHICAL_INFO (
        geo_id, region_name, district_name, district_type, sub_district,
        locality_name, nhis_ecg_vra_number, detailed_address, contact_phone_1,
        contact_phone_2, enumeration_area_code, ea_type, locality_code, structure_number
    ) VALUES (
        seq_geo_info_id.NEXTVAL, p_region_name, p_district_name, p_district_type,
        p_sub_district, p_locality_name, p_nhis_ecg_vra_number, p_detailed_address,
        p_contact_phone_1, p_contact_phone_2, p_enumeration_area_code, p_ea_type,
        p_locality_code, p_structure_number
    ) RETURNING geo_id INTO p_geo_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Geographical information inserted successfully. ID: ' || p_geo_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting geographical information: ' || SQLERRM);
        RAISE;
END SP_INSERT_GEOGRAPHICAL_INFO;
/

-- Update Geographical Information
CREATE OR REPLACE PROCEDURE SP_UPDATE_GEOGRAPHICAL_INFO (
    p_geo_id IN NUMBER,
    p_region_name IN VARCHAR2 DEFAULT NULL,
    p_district_name IN VARCHAR2 DEFAULT NULL,
    p_district_type IN VARCHAR2 DEFAULT NULL,
    p_sub_district IN VARCHAR2 DEFAULT NULL,
    p_locality_name IN VARCHAR2 DEFAULT NULL,
    p_detailed_address IN CLOB DEFAULT NULL,
    p_contact_phone_1 IN VARCHAR2 DEFAULT NULL,
    p_contact_phone_2 IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    UPDATE GEOGRAPHICAL_INFO SET
        region_name = NVL(p_region_name, region_name),
        district_name = NVL(p_district_name, district_name),
        district_type = NVL(p_district_type, district_type),
        sub_district = NVL(p_sub_district, sub_district),
        locality_name = NVL(p_locality_name, locality_name),
        detailed_address = NVL(p_detailed_address, detailed_address),
        contact_phone_1 = NVL(p_contact_phone_1, contact_phone_1),
        contact_phone_2 = NVL(p_contact_phone_2, contact_phone_2),
        date_modified = SYSDATE,
        modified_by = USER
    WHERE geo_id = p_geo_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Geographical information not found with ID: ' || p_geo_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Geographical information updated successfully. ID: ' || p_geo_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating geographical information: ' || SQLERRM);
        RAISE;
END SP_UPDATE_GEOGRAPHICAL_INFO;
/

-- Delete Geographical Information
CREATE OR REPLACE PROCEDURE SP_DELETE_GEOGRAPHICAL_INFO (
    p_geo_id IN NUMBER
) AS
BEGIN
    DELETE FROM GEOGRAPHICAL_INFO WHERE geo_id = p_geo_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Geographical information not found with ID: ' || p_geo_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Geographical information deleted successfully. ID: ' || p_geo_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error deleting geographical information: ' || SQLERRM);
        RAISE;
END SP_DELETE_GEOGRAPHICAL_INFO;
/

-- =========================================
-- HOUSEHOLD PROCEDURES
-- =========================================

-- Insert Household
CREATE OR REPLACE PROCEDURE SP_INSERT_HOUSEHOLD (
    p_geo_id IN NUMBER,
    p_household_number_in_structure IN VARCHAR2 DEFAULT NULL,
    p_type_of_residence IN VARCHAR2 DEFAULT NULL,
    p_interview_date_started IN DATE DEFAULT NULL,
    p_interview_date_completed IN DATE DEFAULT NULL,
    p_total_visits IN NUMBER DEFAULT 1,
    p_form_number IN VARCHAR2 DEFAULT NULL,
    p_housing_unit_status IN VARCHAR2 DEFAULT 'OCCUPIED',
    p_household_id OUT NUMBER
) AS
BEGIN
    INSERT INTO HOUSEHOLD (
        household_id, geo_id, household_number_in_structure, type_of_residence,
        interview_date_started, interview_date_completed, total_visits, form_number,
        housing_unit_status
    ) VALUES (
        seq_household_id.NEXTVAL, p_geo_id, p_household_number_in_structure,
        p_type_of_residence, p_interview_date_started, p_interview_date_completed,
        p_total_visits, p_form_number, p_housing_unit_status
    ) RETURNING household_id INTO p_household_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Household inserted successfully. ID: ' || p_household_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting household: ' || SQLERRM);
        RAISE;
END SP_INSERT_HOUSEHOLD;
/

-- Update Household
CREATE OR REPLACE PROCEDURE SP_UPDATE_HOUSEHOLD (
    p_household_id IN NUMBER,
    p_type_of_residence IN VARCHAR2 DEFAULT NULL,
    p_interview_date_completed IN DATE DEFAULT NULL,
    p_total_visits IN NUMBER DEFAULT NULL,
    p_housing_unit_status IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    UPDATE HOUSEHOLD SET
        type_of_residence = NVL(p_type_of_residence, type_of_residence),
        interview_date_completed = NVL(p_interview_date_completed, interview_date_completed),
        total_visits = NVL(p_total_visits, total_visits),
        housing_unit_status = NVL(p_housing_unit_status, housing_unit_status),
        date_modified = SYSDATE,
        modified_by = USER
    WHERE household_id = p_household_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Household not found with ID: ' || p_household_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Household updated successfully. ID: ' || p_household_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating household: ' || SQLERRM);
        RAISE;
END SP_UPDATE_HOUSEHOLD;
/

-- Delete Household
CREATE OR REPLACE PROCEDURE SP_DELETE_HOUSEHOLD (
    p_household_id IN NUMBER
) AS
BEGIN
    DELETE FROM HOUSEHOLD WHERE household_id = p_household_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Household not found with ID: ' || p_household_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Household deleted successfully. ID: ' || p_household_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error deleting household: ' || SQLERRM);
        RAISE;
END SP_DELETE_HOUSEHOLD;
/

-- =========================================
-- INDIVIDUAL PROCEDURES
-- =========================================

-- Insert Individual
CREATE OR REPLACE PROCEDURE SP_INSERT_INDIVIDUAL (
    p_household_id IN NUMBER,
    p_person_line_number IN NUMBER DEFAULT NULL,
    p_full_name IN VARCHAR2,
    p_relationship_to_head IN VARCHAR2 DEFAULT NULL,
    p_sex IN CHAR DEFAULT NULL,
    p_date_of_birth IN DATE DEFAULT NULL,
    p_age IN NUMBER DEFAULT NULL,
    p_nationality IN VARCHAR2 DEFAULT NULL,
    p_ethnicity IN VARCHAR2 DEFAULT NULL,
    p_religion IN VARCHAR2 DEFAULT NULL,
    p_marital_status IN VARCHAR2 DEFAULT NULL,
    p_highest_education_level IN VARCHAR2 DEFAULT NULL,
    p_status_on_census_night IN VARCHAR2 DEFAULT 'PRESENT',
    p_individual_id OUT NUMBER
) AS
BEGIN
    INSERT INTO INDIVIDUAL (
        individual_id, household_id, person_line_number, full_name, relationship_to_head,
        sex, date_of_birth, age, nationality, ethnicity, religion, marital_status,
        highest_education_level, status_on_census_night
    ) VALUES (
        seq_individual_id.NEXTVAL, p_household_id, p_person_line_number, p_full_name,
        p_relationship_to_head, p_sex, p_date_of_birth, p_age, p_nationality,
        p_ethnicity, p_religion, p_marital_status, p_highest_education_level,
        p_status_on_census_night
    ) RETURNING individual_id INTO p_individual_id;

    -- Update household member counts
    UPDATE HOUSEHOLD SET
        total_members = total_members + 1,
        total_males = CASE WHEN p_sex = 'M' THEN total_males + 1 ELSE total_males END,
        total_females = CASE WHEN p_sex = 'F' THEN total_females + 1 ELSE total_females END,
        date_modified = SYSDATE,
        modified_by = USER
    WHERE household_id = p_household_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Individual inserted successfully. ID: ' || p_individual_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting individual: ' || SQLERRM);
        RAISE;
END SP_INSERT_INDIVIDUAL;
/

-- Update Individual
CREATE OR REPLACE PROCEDURE SP_UPDATE_INDIVIDUAL (
    p_individual_id IN NUMBER,
    p_full_name IN VARCHAR2 DEFAULT NULL,
    p_relationship_to_head IN VARCHAR2 DEFAULT NULL,
    p_sex IN CHAR DEFAULT NULL,
    p_age IN NUMBER DEFAULT NULL,
    p_nationality IN VARCHAR2 DEFAULT NULL,
    p_ethnicity IN VARCHAR2 DEFAULT NULL,
    p_religion IN VARCHAR2 DEFAULT NULL,
    p_marital_status IN VARCHAR2 DEFAULT NULL,
    p_highest_education_level IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    UPDATE INDIVIDUAL SET
        full_name = NVL(p_full_name, full_name),
        relationship_to_head = NVL(p_relationship_to_head, relationship_to_head),
        sex = NVL(p_sex, sex),
        age = NVL(p_age, age),
        nationality = NVL(p_nationality, nationality),
        ethnicity = NVL(p_ethnicity, ethnicity),
        religion = NVL(p_religion, religion),
        marital_status = NVL(p_marital_status, marital_status),
        highest_education_level = NVL(p_highest_education_level, highest_education_level),
        date_modified = SYSDATE,
        modified_by = USER
    WHERE individual_id = p_individual_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Individual not found with ID: ' || p_individual_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Individual updated successfully. ID: ' || p_individual_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating individual: ' || SQLERRM);
        RAISE;
END SP_UPDATE_INDIVIDUAL;
/

-- Delete Individual
CREATE OR REPLACE PROCEDURE SP_DELETE_INDIVIDUAL (
    p_individual_id IN NUMBER
) AS
    v_household_id NUMBER;
    v_sex CHAR(1);
BEGIN
    -- Get household_id and sex before deletion for updating counts
    SELECT household_id, sex INTO v_household_id, v_sex
    FROM INDIVIDUAL WHERE individual_id = p_individual_id;

    DELETE FROM INDIVIDUAL WHERE individual_id = p_individual_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Individual not found with ID: ' || p_individual_id);
    END IF;

    -- Update household member counts
    UPDATE HOUSEHOLD SET
        total_members = total_members - 1,
        total_males = CASE WHEN v_sex = 'M' THEN total_males - 1 ELSE total_males END,
        total_females = CASE WHEN v_sex = 'F' THEN total_females - 1 ELSE total_females END,
        date_modified = SYSDATE,
        modified_by = USER
    WHERE household_id = v_household_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Individual deleted successfully. ID: ' || p_individual_id);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Individual not found with ID: ' || p_individual_id);
        RAISE_APPLICATION_ERROR(-20003, 'Individual not found with ID: ' || p_individual_id);
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error deleting individual: ' || SQLERRM);
        RAISE;
END SP_DELETE_INDIVIDUAL;
/

-- =========================================
-- HOUSING PROCEDURES
-- =========================================

-- Insert Housing Information
CREATE OR REPLACE PROCEDURE SP_INSERT_HOUSING (
    p_household_id IN NUMBER,
    p_dwelling_type IN VARCHAR2 DEFAULT NULL,
    p_outer_wall_material IN VARCHAR2 DEFAULT NULL,
    p_floor_material IN VARCHAR2 DEFAULT NULL,
    p_roof_material IN VARCHAR2 DEFAULT NULL,
    p_rooms_occupied IN NUMBER DEFAULT NULL,
    p_rooms_for_sleeping IN NUMBER DEFAULT NULL,
    p_main_lighting_source IN VARCHAR2 DEFAULT NULL,
    p_main_drinking_water_source IN VARCHAR2 DEFAULT NULL,
    p_toilet_facility_type IN VARCHAR2 DEFAULT NULL,
    p_housing_id OUT NUMBER
) AS
BEGIN
    INSERT INTO HOUSING (
        housing_id, household_id, dwelling_type, outer_wall_material, floor_material,
        roof_material, rooms_occupied, rooms_for_sleeping, main_lighting_source,
        main_drinking_water_source, toilet_facility_type
    ) VALUES (
        seq_housing_id.NEXTVAL, p_household_id, p_dwelling_type, p_outer_wall_material,
        p_floor_material, p_roof_material, p_rooms_occupied, p_rooms_for_sleeping,
        p_main_lighting_source, p_main_drinking_water_source, p_toilet_facility_type
    ) RETURNING housing_id INTO p_housing_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Housing information inserted successfully. ID: ' || p_housing_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting housing information: ' || SQLERRM);
        RAISE;
END SP_INSERT_HOUSING;
/

-- Update Housing Information
CREATE OR REPLACE PROCEDURE SP_UPDATE_HOUSING (
    p_housing_id IN NUMBER,
    p_dwelling_type IN VARCHAR2 DEFAULT NULL,
    p_outer_wall_material IN VARCHAR2 DEFAULT NULL,
    p_floor_material IN VARCHAR2 DEFAULT NULL,
    p_roof_material IN VARCHAR2 DEFAULT NULL,
    p_rooms_occupied IN NUMBER DEFAULT NULL,
    p_main_lighting_source IN VARCHAR2 DEFAULT NULL,
    p_main_drinking_water_source IN VARCHAR2 DEFAULT NULL,
    p_toilet_facility_type IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    UPDATE HOUSING SET
        dwelling_type = NVL(p_dwelling_type, dwelling_type),
        outer_wall_material = NVL(p_outer_wall_material, outer_wall_material),
        floor_material = NVL(p_floor_material, floor_material),
        roof_material = NVL(p_roof_material, roof_material),
        rooms_occupied = NVL(p_rooms_occupied, rooms_occupied),
        main_lighting_source = NVL(p_main_lighting_source, main_lighting_source),
        main_drinking_water_source = NVL(p_main_drinking_water_source, main_drinking_water_source),
        toilet_facility_type = NVL(p_toilet_facility_type, toilet_facility_type),
        date_modified = SYSDATE,
        modified_by = USER
    WHERE housing_id = p_housing_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Housing information not found with ID: ' || p_housing_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Housing information updated successfully. ID: ' || p_housing_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating housing information: ' || SQLERRM);
        RAISE;
END SP_UPDATE_HOUSING;
/

-- Delete Housing Information
CREATE OR REPLACE PROCEDURE SP_DELETE_HOUSING (
    p_housing_id IN NUMBER
) AS
BEGIN
    DELETE FROM HOUSING WHERE housing_id = p_housing_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Housing information not found with ID: ' || p_housing_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Housing information deleted successfully. ID: ' || p_housing_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error deleting housing information: ' || SQLERRM);
        RAISE;
END SP_DELETE_HOUSING;
/

-- =========================================
-- ECONOMIC ACTIVITY PROCEDURES
-- =========================================

-- Insert Economic Activity
CREATE OR REPLACE PROCEDURE SP_INSERT_ECONOMIC_ACTIVITY (
    p_individual_id IN NUMBER,
    p_engaged_in_economic_activity IN CHAR DEFAULT 'N',
    p_occupation_description IN VARCHAR2 DEFAULT NULL,
    p_occupation_code IN VARCHAR2 DEFAULT NULL,
    p_workplace_name IN VARCHAR2 DEFAULT NULL,
    p_employment_status IN VARCHAR2 DEFAULT NULL,
    p_employment_sector IN VARCHAR2 DEFAULT NULL,
    p_owns_mobile_phone IN CHAR DEFAULT 'N',
    p_uses_internet IN CHAR DEFAULT 'N',
    p_economic_id OUT NUMBER
) AS
BEGIN
    INSERT INTO ECONOMIC_ACTIVITY (
        economic_id, individual_id, engaged_in_economic_activity, occupation_description,
        occupation_code, workplace_name, employment_status, employment_sector,
        owns_mobile_phone, uses_internet
    ) VALUES (
        seq_economic_id.NEXTVAL, p_individual_id, p_engaged_in_economic_activity,
        p_occupation_description, p_occupation_code, p_workplace_name,
        p_employment_status, p_employment_sector, p_owns_mobile_phone, p_uses_internet
    ) RETURNING economic_id INTO p_economic_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Economic activity inserted successfully. ID: ' || p_economic_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inserting economic activity: ' || SQLERRM);
        RAISE;
END SP_INSERT_ECONOMIC_ACTIVITY;
/

-- Update Economic Activity
CREATE OR REPLACE PROCEDURE SP_UPDATE_ECONOMIC_ACTIVITY (
    p_economic_id IN NUMBER,
    p_engaged_in_economic_activity IN CHAR DEFAULT NULL,
    p_occupation_description IN VARCHAR2 DEFAULT NULL,
    p_workplace_name IN VARCHAR2 DEFAULT NULL,
    p_employment_status IN VARCHAR2 DEFAULT NULL,
    p_employment_sector IN VARCHAR2 DEFAULT NULL,
    p_owns_mobile_phone IN CHAR DEFAULT NULL,
    p_uses_internet IN CHAR DEFAULT NULL
) AS
BEGIN
    UPDATE ECONOMIC_ACTIVITY SET
        engaged_in_economic_activity = NVL(p_engaged_in_economic_activity, engaged_in_economic_activity),
        occupation_description = NVL(p_occupation_description, occupation_description),
        workplace_name = NVL(p_workplace_name, workplace_name),
        employment_status = NVL(p_employment_status, employment_status),
        employment_sector = NVL(p_employment_sector, employment_sector),
        owns_mobile_phone = NVL(p_owns_mobile_phone, owns_mobile_phone),
        uses_internet = NVL(p_uses_internet, uses_internet),
        date_modified = SYSDATE,
        modified_by = USER
    WHERE economic_id = p_economic_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Economic activity not found with ID: ' || p_economic_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Economic activity updated successfully. ID: ' || p_economic_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error updating economic activity: ' || SQLERRM);
        RAISE;
END SP_UPDATE_ECONOMIC_ACTIVITY;
/

-- Delete Economic Activity
CREATE OR REPLACE PROCEDURE SP_DELETE_ECONOMIC_ACTIVITY (
    p_economic_id IN NUMBER
) AS
BEGIN
    DELETE FROM ECONOMIC_ACTIVITY WHERE economic_id = p_economic_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Economic activity not found with ID: ' || p_economic_id);
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Economic activity deleted successfully. ID: ' || p_economic_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error deleting economic activity: ' || SQLERRM);
        RAISE;
END SP_DELETE_ECONOMIC_ACTIVITY;
/

-- =========================================
-- COMPLEX QUERY PROCEDURES WITH CURSORS
-- =========================================

-- Get Household Demographics with Cursor
CREATE OR REPLACE PROCEDURE SP_GET_HOUSEHOLD_DEMOGRAPHICS (
    p_household_id IN NUMBER,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            i.individual_id,
            i.full_name,
            i.sex,
            i.age,
            i.relationship_to_head,
            i.marital_status,
            i.highest_education_level,
            e.occupation_description,
            e.employment_status,
            h.total_members,
            g.region_name,
            g.district_name,
            g.locality_name
        FROM INDIVIDUAL i
        JOIN HOUSEHOLD h ON i.household_id = h.household_id
        JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id
        LEFT JOIN ECONOMIC_ACTIVITY e ON i.individual_id = e.individual_id
        WHERE i.household_id = p_household_id
        ORDER BY i.person_line_number, i.age DESC;

    DBMS_OUTPUT.PUT_LINE('Household demographics cursor opened for household ID: ' || p_household_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error retrieving household demographics: ' || SQLERRM);
        RAISE;
END SP_GET_HOUSEHOLD_DEMOGRAPHICS;
/

-- Get Regional Summary Statistics
CREATE OR REPLACE PROCEDURE SP_GET_REGIONAL_STATISTICS (
    p_region_name IN VARCHAR2 DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            g.region_name,
            g.district_name,
            COUNT(DISTINCT h.household_id) as total_households,
            COUNT(i.individual_id) as total_population,
            SUM(CASE WHEN i.sex = 'M' THEN 1 ELSE 0 END) as total_males,
            SUM(CASE WHEN i.sex = 'F' THEN 1 ELSE 0 END) as total_females,
            ROUND(AVG(i.age), 2) as average_age,
            COUNT(CASE WHEN e.engaged_in_economic_activity = 'Y' THEN 1 END) as employed_count,
            COUNT(CASE WHEN i.highest_education_level IS NOT NULL THEN 1 END) as educated_count
        FROM GEOGRAPHICAL_INFO g
        JOIN HOUSEHOLD h ON g.geo_id = h.geo_id
        LEFT JOIN INDIVIDUAL i ON h.household_id = i.household_id
        LEFT JOIN ECONOMIC_ACTIVITY e ON i.individual_id = e.individual_id
        WHERE (p_region_name IS NULL OR g.region_name = p_region_name)
        GROUP BY g.region_name, g.district_name
        ORDER BY g.region_name, g.district_name;

    DBMS_OUTPUT.PUT_LINE('Regional statistics cursor opened for region: ' || NVL(p_region_name, 'ALL'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error retrieving regional statistics: ' || SQLERRM);
        RAISE;
END SP_GET_REGIONAL_STATISTICS;
/

-- Get Housing Conditions Summary
CREATE OR REPLACE PROCEDURE SP_GET_HOUSING_CONDITIONS (
    p_district_name IN VARCHAR2 DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            g.region_name,
            g.district_name,
            hs.dwelling_type,
            hs.main_drinking_water_source,
            hs.toilet_facility_type,
            hs.main_lighting_source,
            COUNT(*) as household_count,
            ROUND(AVG(hs.rooms_occupied), 2) as avg_rooms_occupied
        FROM HOUSING hs
        JOIN HOUSEHOLD h ON hs.household_id = h.household_id
        JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id
        WHERE (p_district_name IS NULL OR g.district_name = p_district_name)
        GROUP BY g.region_name, g.district_name, hs.dwelling_type, 
                 hs.main_drinking_water_source, hs.toilet_facility_type, hs.main_lighting_source
        ORDER BY g.region_name, g.district_name, household_count DESC;

    DBMS_OUTPUT.PUT_LINE('Housing conditions cursor opened for district: ' || NVL(p_district_name, 'ALL'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error retrieving housing conditions: ' || SQLERRM);
        RAISE;
END SP_GET_HOUSING_CONDITIONS;
/

-- =========================================
-- UTILITY PROCEDURES
-- =========================================

-- Log User Activity
CREATE OR REPLACE PROCEDURE SP_LOG_ACTIVITY (
    p_table_name IN VARCHAR2,
    p_operation_type IN VARCHAR2,
    p_record_id IN NUMBER,
    p_old_values IN CLOB DEFAULT NULL,
    p_new_values IN CLOB DEFAULT NULL,
    p_session_id IN VARCHAR2 DEFAULT NULL,
    p_ip_address IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, old_values, new_values,
        session_id, ip_address
    ) VALUES (
        seq_activity_log_id.NEXTVAL, p_table_name, p_operation_type, p_record_id,
        p_old_values, p_new_values, p_session_id, p_ip_address
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        -- Don't raise errors for logging failures to avoid disrupting main operations
        DBMS_OUTPUT.PUT_LINE('Warning: Failed to log activity: ' || SQLERRM);
END SP_LOG_ACTIVITY;
/

-- Get Activity Log
CREATE OR REPLACE PROCEDURE SP_GET_ACTIVITY_LOGS (
    p_table_name      IN VARCHAR2 DEFAULT NULL,
    p_operation_type  IN VARCHAR2 DEFAULT NULL,
    p_user_name       IN VARCHAR2 DEFAULT NULL,
    p_days_back       IN NUMBER   DEFAULT 7,
    p_cursor          OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            log_id,
            table_name,
            operation_type,
            record_id,
            user_name,
            operation_timestamp,
            session_id,
            ip_address,
            application_name
        FROM ACTIVITY_LOG
        WHERE (p_table_name IS NULL OR table_name = p_table_name)
          AND (p_operation_type IS NULL OR operation_type = p_operation_type)
          AND (p_user_name IS NULL OR user_name = p_user_name)
          AND operation_timestamp >= SYSDATE - p_days_back
        ORDER BY operation_timestamp DESC;
EXCEPTION
    WHEN OTHERS THEN
        -- Optional: log or re-raise
        RAISE;
END SP_GET_ACTIVITY_LOGS;
/

-- Success message
SELECT 'Census Database Stored Procedures Created Successfully!' AS MESSAGE FROM DUAL;
