-- =========================================
-- ORACLE DATABASE TRIGGERS
-- Census Database Management System
-- Activity Logging Triggers
-- Created: 2025-07-23 10:27:34
-- =========================================

-- =========================================
-- GEOGRAPHICAL_INFO TRIGGERS
-- =========================================

-- Trigger for GEOGRAPHICAL_INFO table
CREATE OR REPLACE TRIGGER TRG_GEOGRAPHICAL_INFO_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON GEOGRAPHICAL_INFO
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.geo_id;
        v_new_values := 'geo_id:' || :NEW.geo_id || 
                       '|region_name:' || :NEW.region_name ||
                       '|district_name:' || :NEW.district_name ||
                       '|locality_name:' || :NEW.locality_name ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.geo_id;
        v_old_values := 'geo_id:' || :OLD.geo_id || 
                       '|region_name:' || :OLD.region_name ||
                       '|district_name:' || :OLD.district_name ||
                       '|locality_name:' || :OLD.locality_name ||
                       '|modified_by:' || :OLD.modified_by;
        v_new_values := 'geo_id:' || :NEW.geo_id || 
                       '|region_name:' || :NEW.region_name ||
                       '|district_name:' || :NEW.district_name ||
                       '|locality_name:' || :NEW.locality_name ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.geo_id;
        v_old_values := 'geo_id:' || :OLD.geo_id || 
                       '|region_name:' || :OLD.region_name ||
                       '|district_name:' || :OLD.district_name ||
                       '|locality_name:' || :OLD.locality_name;
    END IF;

    -- Insert into activity log
    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'GEOGRAPHICAL_INFO', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        -- Don't let logging errors affect the main transaction
        NULL;
END TRG_GEOGRAPHICAL_INFO_AUDIT;
/

-- =========================================
-- HOUSEHOLD TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_HOUSEHOLD_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON HOUSEHOLD
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.household_id;
        v_new_values := 'household_id:' || :NEW.household_id || 
                       '|geo_id:' || :NEW.geo_id ||
                       '|total_members:' || :NEW.total_members ||
                       '|total_males:' || :NEW.total_males ||
                       '|total_females:' || :NEW.total_females ||
                       '|housing_unit_status:' || :NEW.housing_unit_status ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.household_id;
        v_old_values := 'household_id:' || :OLD.household_id || 
                       '|total_members:' || :OLD.total_members ||
                       '|total_males:' || :OLD.total_males ||
                       '|total_females:' || :OLD.total_females ||
                       '|housing_unit_status:' || :OLD.housing_unit_status;
        v_new_values := 'household_id:' || :NEW.household_id || 
                       '|total_members:' || :NEW.total_members ||
                       '|total_males:' || :NEW.total_males ||
                       '|total_females:' || :NEW.total_females ||
                       '|housing_unit_status:' || :NEW.housing_unit_status ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.household_id;
        v_old_values := 'household_id:' || :OLD.household_id || 
                       '|geo_id:' || :OLD.geo_id ||
                       '|total_members:' || :OLD.total_members;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'HOUSEHOLD', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_HOUSEHOLD_AUDIT;
/

-- =========================================
-- INDIVIDUAL TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_INDIVIDUAL_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON INDIVIDUAL
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.individual_id;
        v_new_values := 'individual_id:' || :NEW.individual_id || 
                       '|household_id:' || :NEW.household_id ||
                       '|full_name:' || :NEW.full_name ||
                       '|sex:' || :NEW.sex ||
                       '|age:' || :NEW.age ||
                       '|relationship_to_head:' || :NEW.relationship_to_head ||
                       '|marital_status:' || :NEW.marital_status ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.individual_id;
        v_old_values := 'individual_id:' || :OLD.individual_id || 
                       '|full_name:' || :OLD.full_name ||
                       '|sex:' || :OLD.sex ||
                       '|age:' || :OLD.age ||
                       '|relationship_to_head:' || :OLD.relationship_to_head ||
                       '|marital_status:' || :OLD.marital_status;
        v_new_values := 'individual_id:' || :NEW.individual_id || 
                       '|full_name:' || :NEW.full_name ||
                       '|sex:' || :NEW.sex ||
                       '|age:' || :NEW.age ||
                       '|relationship_to_head:' || :NEW.relationship_to_head ||
                       '|marital_status:' || :NEW.marital_status ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.individual_id;
        v_old_values := 'individual_id:' || :OLD.individual_id || 
                       '|household_id:' || :OLD.household_id ||
                       '|full_name:' || :OLD.full_name ||
                       '|sex:' || :OLD.sex ||
                       '|age:' || :OLD.age;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'INDIVIDUAL', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_INDIVIDUAL_AUDIT;
/

-- =========================================
-- HOUSING TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_HOUSING_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON HOUSING
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.housing_id;
        v_new_values := 'housing_id:' || :NEW.housing_id || 
                       '|household_id:' || :NEW.household_id ||
                       '|dwelling_type:' || :NEW.dwelling_type ||
                       '|outer_wall_material:' || :NEW.outer_wall_material ||
                       '|floor_material:' || :NEW.floor_material ||
                       '|roof_material:' || :NEW.roof_material ||
                       '|rooms_occupied:' || :NEW.rooms_occupied ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.housing_id;
        v_old_values := 'housing_id:' || :OLD.housing_id || 
                       '|dwelling_type:' || :OLD.dwelling_type ||
                       '|rooms_occupied:' || :OLD.rooms_occupied ||
                       '|main_lighting_source:' || :OLD.main_lighting_source ||
                       '|main_drinking_water_source:' || :OLD.main_drinking_water_source;
        v_new_values := 'housing_id:' || :NEW.housing_id || 
                       '|dwelling_type:' || :NEW.dwelling_type ||
                       '|rooms_occupied:' || :NEW.rooms_occupied ||
                       '|main_lighting_source:' || :NEW.main_lighting_source ||
                       '|main_drinking_water_source:' || :NEW.main_drinking_water_source ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.housing_id;
        v_old_values := 'housing_id:' || :OLD.housing_id || 
                       '|household_id:' || :OLD.household_id ||
                       '|dwelling_type:' || :OLD.dwelling_type;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'HOUSING', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_HOUSING_AUDIT;
/

-- =========================================
-- ECONOMIC_ACTIVITY TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_ECONOMIC_ACTIVITY_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON ECONOMIC_ACTIVITY
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.economic_id;
        v_new_values := 'economic_id:' || :NEW.economic_id || 
                       '|individual_id:' || :NEW.individual_id ||
                       '|engaged_in_economic_activity:' || :NEW.engaged_in_economic_activity ||
                       '|occupation_description:' || :NEW.occupation_description ||
                       '|employment_status:' || :NEW.employment_status ||
                       '|employment_sector:' || :NEW.employment_sector ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.economic_id;
        v_old_values := 'economic_id:' || :OLD.economic_id || 
                       '|engaged_in_economic_activity:' || :OLD.engaged_in_economic_activity ||
                       '|occupation_description:' || :OLD.occupation_description ||
                       '|employment_status:' || :OLD.employment_status ||
                       '|employment_sector:' || :OLD.employment_sector;
        v_new_values := 'economic_id:' || :NEW.economic_id || 
                       '|engaged_in_economic_activity:' || :NEW.engaged_in_economic_activity ||
                       '|occupation_description:' || :NEW.occupation_description ||
                       '|employment_status:' || :NEW.employment_status ||
                       '|employment_sector:' || :NEW.employment_sector ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.economic_id;
        v_old_values := 'economic_id:' || :OLD.economic_id || 
                       '|individual_id:' || :OLD.individual_id ||
                       '|occupation_description:' || :OLD.occupation_description;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'ECONOMIC_ACTIVITY', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_ECONOMIC_ACTIVITY_AUDIT;
/

-- =========================================
-- FERTILITY TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_FERTILITY_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON FERTILITY
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.fertility_id;
        v_new_values := 'fertility_id:' || :NEW.fertility_id || 
                       '|individual_id:' || :NEW.individual_id ||
                       '|children_born_boys:' || :NEW.children_born_boys ||
                       '|children_born_girls:' || :NEW.children_born_girls ||
                       '|children_surviving_boys:' || :NEW.children_surviving_boys ||
                       '|children_surviving_girls:' || :NEW.children_surviving_girls ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.fertility_id;
        v_old_values := 'fertility_id:' || :OLD.fertility_id || 
                       '|children_born_boys:' || :OLD.children_born_boys ||
                       '|children_born_girls:' || :OLD.children_born_girls ||
                       '|children_surviving_boys:' || :OLD.children_surviving_boys ||
                       '|children_surviving_girls:' || :OLD.children_surviving_girls;
        v_new_values := 'fertility_id:' || :NEW.fertility_id || 
                       '|children_born_boys:' || :NEW.children_born_boys ||
                       '|children_born_girls:' || :NEW.children_born_girls ||
                       '|children_surviving_boys:' || :NEW.children_surviving_boys ||
                       '|children_surviving_girls:' || :NEW.children_surviving_girls ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.fertility_id;
        v_old_values := 'fertility_id:' || :OLD.fertility_id || 
                       '|individual_id:' || :OLD.individual_id;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'FERTILITY', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_FERTILITY_AUDIT;
/

-- =========================================
-- MORTALITY TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_MORTALITY_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON MORTALITY
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.mortality_id;
        v_new_values := 'mortality_id:' || :NEW.mortality_id || 
                       '|household_id:' || :NEW.household_id ||
                       '|deceased_name:' || :NEW.deceased_name ||
                       '|deceased_sex:' || :NEW.deceased_sex ||
                       '|age_at_death:' || :NEW.age_at_death ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.mortality_id;
        v_old_values := 'mortality_id:' || :OLD.mortality_id || 
                       '|deceased_name:' || :OLD.deceased_name ||
                       '|age_at_death:' || :OLD.age_at_death;
        v_new_values := 'mortality_id:' || :NEW.mortality_id || 
                       '|deceased_name:' || :NEW.deceased_name ||
                       '|age_at_death:' || :NEW.age_at_death ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.mortality_id;
        v_old_values := 'mortality_id:' || :OLD.mortality_id || 
                       '|household_id:' || :OLD.household_id ||
                       '|deceased_name:' || :OLD.deceased_name;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'MORTALITY', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_MORTALITY_AUDIT;
/

-- =========================================
-- AGRICULTURAL_ACTIVITY TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_AGRICULTURAL_ACTIVITY_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON AGRICULTURAL_ACTIVITY
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.agricultural_id;
        v_new_values := 'agricultural_id:' || :NEW.agricultural_id || 
                       '|household_id:' || :NEW.household_id ||
                       '|crop_farming:' || :NEW.crop_farming ||
                       '|tree_growing:' || :NEW.tree_growing ||
                       '|livestock_rearing:' || :NEW.livestock_rearing ||
                       '|fish_farming:' || :NEW.fish_farming ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.agricultural_id;
        v_old_values := 'agricultural_id:' || :OLD.agricultural_id || 
                       '|crop_farming:' || :OLD.crop_farming ||
                       '|livestock_rearing:' || :OLD.livestock_rearing;
        v_new_values := 'agricultural_id:' || :NEW.agricultural_id || 
                       '|crop_farming:' || :NEW.crop_farming ||
                       '|livestock_rearing:' || :NEW.livestock_rearing ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.agricultural_id;
        v_old_values := 'agricultural_id:' || :OLD.agricultural_id || 
                       '|household_id:' || :OLD.household_id;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'AGRICULTURAL_ACTIVITY', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_AGRICULTURAL_ACTIVITY_AUDIT;
/

-- =========================================
-- EMIGRATION TRIGGERS
-- =========================================

CREATE OR REPLACE TRIGGER TRG_EMIGRATION_AUDIT
    AFTER INSERT OR UPDATE OR DELETE ON EMIGRATION
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_record_id NUMBER;
BEGIN
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_record_id := :NEW.emigration_id;
        v_new_values := 'emigration_id:' || :NEW.emigration_id || 
                       '|household_id:' || :NEW.household_id ||
                       '|emigrant_name:' || :NEW.emigrant_name ||
                       '|emigrant_sex:' || :NEW.emigrant_sex ||
                       '|destination_country:' || :NEW.destination_country ||
                       '|year_of_departure:' || :NEW.year_of_departure ||
                       '|created_by:' || :NEW.created_by;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_record_id := :NEW.emigration_id;
        v_old_values := 'emigration_id:' || :OLD.emigration_id || 
                       '|emigrant_name:' || :OLD.emigrant_name ||
                       '|destination_country:' || :OLD.destination_country;
        v_new_values := 'emigration_id:' || :NEW.emigration_id || 
                       '|emigrant_name:' || :NEW.emigrant_name ||
                       '|destination_country:' || :NEW.destination_country ||
                       '|modified_by:' || :NEW.modified_by;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_record_id := :OLD.emigration_id;
        v_old_values := 'emigration_id:' || :OLD.emigration_id || 
                       '|household_id:' || :OLD.household_id ||
                       '|emigrant_name:' || :OLD.emigrant_name;
    END IF;

    INSERT INTO ACTIVITY_LOG (
        log_id, table_name, operation_type, record_id, 
        old_values, new_values, user_name, session_id,
        operation_timestamp, application_name
    ) VALUES (
        seq_activity_log_id.NEXTVAL, 'EMIGRATION', v_operation, v_record_id,
        v_old_values, v_new_values, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
        CURRENT_TIMESTAMP, 'CENSUS_DBMS'
    );
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END TRG_EMIGRATION_AUDIT;
/

-- =========================================
-- DATA VALIDATION TRIGGERS
-- =========================================

-- Trigger to update household statistics (total members, males, females)
CREATE OR REPLACE TRIGGER TRG_HOUSEHOLD_STATS_UPDATE
FOR INSERT OR DELETE OR UPDATE ON INDIVIDUAL
COMPOUND TRIGGER
    -- Collection to store affected household_id's
    TYPE household_id_t IS TABLE OF HOUSEHOLD.household_id%TYPE INDEX BY PLS_INTEGER;
    g_household_ids household_id_t;

    -- Executed after each row is affected
    AFTER EACH ROW IS
    BEGIN
        -- Store the household_id from the old and new row
        IF :new.household_id IS NOT NULL THEN
            g_household_ids(g_household_ids.COUNT + 1) := :new.household_id;
        END IF;
        IF :old.household_id IS NOT NULL THEN
            g_household_ids(g_household_ids.COUNT + 1) := :old.household_id;
        END IF;
    END AFTER EACH ROW;

    -- Executed once after the statement has finished
    AFTER STATEMENT IS
    BEGIN
        -- Update stats for each unique affected household
        FOR i IN 1..g_household_ids.COUNT LOOP
            UPDATE HOUSEHOLD h
            SET
                h.total_members = (SELECT COUNT(*) FROM INDIVIDUAL i WHERE i.household_id = g_household_ids(i)),
                h.total_males = (SELECT COUNT(*) FROM INDIVIDUAL i WHERE i.household_id = g_household_ids(i) AND i.sex = 'M'),
                h.total_females = (SELECT COUNT(*) FROM INDIVIDUAL i WHERE i.household_id = g_household_ids(i) AND i.sex = 'F')
            WHERE h.household_id = g_household_ids(i);
        END LOOP;
    END AFTER STATEMENT;
END TRG_HOUSEHOLD_STATS_UPDATE;
/
