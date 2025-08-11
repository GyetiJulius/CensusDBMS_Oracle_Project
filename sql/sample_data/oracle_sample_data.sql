-- =========================================
-- CENSUS SAMPLE DATA SCRIPT (CORRECTED)
-- =========================================

SET SERVEROUTPUT ON;
SET VERIFY OFF;

-- =========================================
-- 1. CLEANUP AND SETUP
-- =========================================
PROMPT Cleaning up existing data...
DECLARE
    PROCEDURE truncate_table(p_table_name IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || p_table_name;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE != -942 THEN RAISE; END IF; -- Ignore "table does not exist"
    END;
BEGIN
    truncate_table('FERTILITY');
    truncate_table('DISABILITY');
    truncate_table('ECONOMIC_ACTIVITY');
    truncate_table('AGRICULTURAL_ACTIVITY');
    truncate_table('MORTALITY');
    truncate_table('EMIGRATION');
    truncate_table('ICT_USAGE');
    truncate_table('INDIVIDUAL');
    truncate_table('HOUSING');
    truncate_table('HOUSEHOLD');
    truncate_table('GEOGRAPHICAL_INFO');
END;
/

PROMPT Resetting sequences...
DECLARE
    PROCEDURE reset_sequence(p_seq_name IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || p_seq_name;
    EXCEPTION
        WHEN OTHERS THEN NULL; -- Ignore error if sequence doesn't exist
    END;
BEGIN
    reset_sequence('seq_geo_info_id');
    reset_sequence('seq_household_id');
    reset_sequence('seq_individual_id');
    reset_sequence('seq_housing_id');
    reset_sequence('seq_economic_id');
    reset_sequence('seq_disability_id');
    reset_sequence('seq_fertility_id');
    
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_geo_info_id START WITH 1';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_household_id START WITH 1';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_individual_id START WITH 1';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_housing_id START WITH 1';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_economic_id START WITH 1';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_disability_id START WITH 1';
    EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_fertility_id START WITH 1';
END;
/

-- =========================================
-- 2. INSERT DATA
-- =========================================
PROMPT Inserting Geographical Information...
INSERT INTO GEOGRAPHICAL_INFO (geo_id, region_name, district_name, locality_name, enumeration_area_code) VALUES (seq_geo_info_id.NEXTVAL, 'Greater Accra', 'Accra Metropolis', 'Osu', 'GA-001-001');
INSERT INTO GEOGRAPHICAL_INFO (geo_id, region_name, district_name, locality_name, enumeration_area_code) VALUES (seq_geo_info_id.NEXTVAL, 'Ashanti', 'Kumasi Metropolis', 'Adum', 'AS-001-001');
INSERT INTO GEOGRAPHICAL_INFO (geo_id, region_name, district_name, locality_name, enumeration_area_code) VALUES (seq_geo_info_id.NEXTVAL, 'Western', 'Sekondi-Takoradi Metropolis', 'Takoradi', 'WR-001-001');

PROMPT Inserting Households and all related data...
DECLARE
    v_geo_id_1 NUMBER;
    v_geo_id_2 NUMBER;
    v_geo_id_3 NUMBER;
    v_household_id NUMBER;
    v_individual_id NUMBER;
BEGIN
    -- Get geo_ids
    SELECT geo_id INTO v_geo_id_1 FROM GEOGRAPHICAL_INFO WHERE enumeration_area_code = 'GA-001-001';
    SELECT geo_id INTO v_geo_id_2 FROM GEOGRAPHICAL_INFO WHERE enumeration_area_code = 'AS-001-001';
    SELECT geo_id INTO v_geo_id_3 FROM GEOGRAPHICAL_INFO WHERE enumeration_area_code = 'WR-001-001';

    -- Household 1 (Accra)
    INSERT INTO HOUSEHOLD (household_id, geo_id, household_number_in_structure, housing_unit_status) VALUES (seq_household_id.NEXTVAL, v_geo_id_1, 'H001', 'OCCUPIED') RETURNING household_id INTO v_household_id;
    
    INSERT INTO HOUSING (housing_id, household_id, dwelling_type, outer_wall_material, roof_material, floor_material) VALUES (seq_housing_id.NEXTVAL, v_household_id, 'Separate House', 'Cement Blocks', 'Metal Sheet', 'Cement');
    
    -- Member 1.1 (Head)
    INSERT INTO INDIVIDUAL (individual_id, household_id, full_name, relationship_to_head, sex, date_of_birth, age, marital_status, nationality) VALUES (seq_individual_id.NEXTVAL, v_household_id, 'Kwame Asante', 'Head', 'M', DATE '1975-06-15', TRUNC(MONTHS_BETWEEN(SYSDATE, DATE '1975-06-15')/12), 'Married', 'Ghanaian') RETURNING individual_id INTO v_individual_id;
    -- Corrected column name to OCCUPATION_DESCRIPTION
    INSERT INTO ECONOMIC_ACTIVITY (economic_id, individual_id, employment_status, occupation_description) VALUES (seq_economic_id.NEXTVAL, v_individual_id, 'Employed', 'Software Engineer');
    
    -- Member 1.2 (Spouse)
    INSERT INTO INDIVIDUAL (individual_id, household_id, full_name, relationship_to_head, sex, date_of_birth, age, marital_status, nationality) VALUES (seq_individual_id.NEXTVAL, v_household_id, 'Ama Asante', 'Spouse', 'F', DATE '1980-02-20', TRUNC(MONTHS_BETWEEN(SYSDATE, DATE '1980-02-20')/12), 'Married', 'Ghanaian') RETURNING individual_id INTO v_individual_id;
    -- Corrected column names
    INSERT INTO ECONOMIC_ACTIVITY (economic_id, individual_id, employment_status, occupation_description) VALUES (seq_economic_id.NEXTVAL, v_individual_id, 'Employed', 'Trader');
    INSERT INTO FERTILITY (fertility_id, individual_id, children_born_boys, children_born_girls, children_surviving_boys, children_surviving_girls) VALUES (seq_fertility_id.NEXTVAL, v_individual_id, 1, 1, 1, 1);

    -- Household 2 (Kumasi)
    INSERT INTO HOUSEHOLD (household_id, geo_id, housing_unit_status) VALUES (seq_household_id.NEXTVAL, v_geo_id_2, 'VACANT') RETURNING household_id INTO v_household_id;
    INSERT INTO HOUSING (housing_id, household_id, dwelling_type, outer_wall_material) VALUES (seq_housing_id.NEXTVAL, v_household_id, 'Flat/Apartment', 'Bricks');

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Census Sample Data Created Successfully!');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error creating sample data: ' || SQLERRM);
        RAISE;
END;
/

-- =========================================
-- 4. DATA VERIFICATION
-- =========================================
PROMPT Sample Data Insertion Summary:
SELECT 'Geographical Info' AS table_name, COUNT(*) AS record_count FROM GEOGRAPHICAL_INFO
UNION ALL
SELECT 'Households', COUNT(*) FROM HOUSEHOLD
UNION ALL
SELECT 'Individuals', COUNT(*) FROM INDIVIDUAL
UNION ALL
SELECT 'Housing', COUNT(*) FROM HOUSING
UNION ALL
SELECT 'Economic Activity', COUNT(*) FROM ECONOMIC_ACTIVITY
UNION ALL
SELECT 'Fertility', COUNT(*) FROM FERTILITY
UNION ALL
SELECT 'Disability', COUNT(*) FROM DISABILITY
UNION ALL
SELECT 'Agricultural Activity', COUNT(*) FROM AGRICULTURAL_ACTIVITY
;

PROMPT 
PROMPT Census Sample Data Created Successfully!
PROMPT
