-- =========================================
-- GHANA CENSUS DATABASE MANAGEMENT SYSTEM
-- Oracle Database Schema Definition
-- Created: 2025-07-23 10:24:36
-- =========================================

-- Create tablespace for Census data (optional - adjust path as needed)
-- CREATE TABLESPACE CENSUS_DATA 
-- DATAFILE 'census_data.dbf' SIZE 100M AUTOEXTEND ON;

-- Drop tables in reverse dependency order if they exist
BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
        'ACTIVITY_LOG', 'EMIGRATION', 'AGRICULTURAL_ACTIVITY', 'ICT_USAGE', 
        'MORTALITY', 'FERTILITY', 'DISABILITY', 'ECONOMIC_ACTIVITY', 
        'HOUSING', 'INDIVIDUAL', 'HOUSEHOLD_MEMBERS', 'HOUSEHOLD', 
        'GEOGRAPHICAL_INFO', 'LOOKUP_TABLES'
    )) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/


-- Drop sequences if they exist
BEGIN
  FOR s IN (SELECT sequence_name FROM user_sequences WHERE sequence_name IN (
    'SEQ_GEO_INFO_ID','SEQ_HOUSEHOLD_ID','SEQ_INDIVIDUAL_ID','SEQ_HOUSING_ID',
    'SEQ_ECONOMIC_ID','SEQ_FERTILITY_ID','SEQ_MORTALITY_ID','SEQ_AGRICULTURAL_ID',
    'SEQ_EMIGRATION_ID','SEQ_ACTIVITY_LOG_ID','SEQ_DISABILITY_ID'  -- added
  )) LOOP
    EXECUTE IMMEDIATE 'DROP SEQUENCE '||s.sequence_name;
  END LOOP;
END;
/


-- Create sequences for primary keys
CREATE SEQUENCE seq_geo_info_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_household_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_individual_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_housing_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_economic_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_fertility_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_mortality_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_agricultural_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_emigration_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_activity_log_id START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_disability_id   START WITH 1 INCREMENT BY 1 NOCACHE; -- added

-- =========================================
-- 1. GEOGRAPHICAL INFORMATION TABLE
-- =========================================
CREATE TABLE GEOGRAPHICAL_INFO (
    geo_id NUMBER PRIMARY KEY,
    region_name VARCHAR2(100) NOT NULL,
    district_name VARCHAR2(100) NOT NULL,
    district_type VARCHAR2(50),
    sub_district VARCHAR2(100),
    locality_name VARCHAR2(100),
    nhis_ecg_vra_number VARCHAR2(50),
    detailed_address CLOB,
    contact_phone_1 VARCHAR2(20),
    contact_phone_2 VARCHAR2(20),
    enumeration_area_code VARCHAR2(20),
    ea_type VARCHAR2(50),
    locality_code VARCHAR2(20),
    structure_number VARCHAR2(20),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER
);

-- Create indexes for geographical info
CREATE INDEX idx_geo_region ON GEOGRAPHICAL_INFO(region_name);
CREATE INDEX idx_geo_district ON GEOGRAPHICAL_INFO(district_name);
CREATE INDEX idx_geo_locality ON GEOGRAPHICAL_INFO(locality_name);

-- =========================================
-- 2. HOUSEHOLD TABLE
-- =========================================
CREATE TABLE HOUSEHOLD (
    household_id NUMBER PRIMARY KEY,
    geo_id NUMBER NOT NULL,
    household_number_in_structure VARCHAR2(20),
    type_of_residence VARCHAR2(50),
    interview_date_started DATE,
    interview_date_completed DATE,
    total_visits NUMBER DEFAULT 1,
    form_number VARCHAR2(50),
    total_members NUMBER DEFAULT 0,
    total_males NUMBER DEFAULT 0,
    total_females NUMBER DEFAULT 0,
    housing_unit_status VARCHAR2(20) CHECK (housing_unit_status IN ('OCCUPIED', 'VACANT')),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_household_geo FOREIGN KEY (geo_id) REFERENCES GEOGRAPHICAL_INFO(geo_id)
);

-- Create indexes for household
CREATE INDEX idx_household_geo ON HOUSEHOLD(geo_id);
CREATE INDEX idx_household_status ON HOUSEHOLD(housing_unit_status);

-- =========================================
-- 3. INDIVIDUAL TABLE
-- =========================================
CREATE TABLE INDIVIDUAL (
    individual_id NUMBER PRIMARY KEY,
    household_id NUMBER NOT NULL,
    person_line_number NUMBER,
    full_name VARCHAR2(200) NOT NULL,
    relationship_to_head VARCHAR2(50),
    sex CHAR(1) CHECK (sex IN ('M', 'F')),
    date_of_birth DATE,
    age NUMBER,
    nationality VARCHAR2(100),
    ethnicity VARCHAR2(100),
    ethnicity_code VARCHAR2(10),
    born_in_current_location CHAR(1) CHECK (born_in_current_location IN ('Y', 'N')),
    birthplace_region VARCHAR2(100),
    birthplace_country VARCHAR2(100),
    lived_here_since_birth CHAR(1) CHECK (lived_here_since_birth IN ('Y', 'N')),
    years_lived_here NUMBER,
    religion VARCHAR2(100),
    religion_code VARCHAR2(10),
    marital_status VARCHAR2(50),
    literacy_language VARCHAR2(100),
    literacy_code VARCHAR2(10),
    ever_attended_school CHAR(1) CHECK (ever_attended_school IN ('Y', 'N')),
    highest_education_level VARCHAR2(100),
    highest_grade_completed VARCHAR2(50),
    status_on_census_night VARCHAR2(10) CHECK (status_on_census_night IN ('PRESENT', 'ABSENT', 'VISITOR')),
    months_absent NUMBER,
    absence_destination VARCHAR2(200),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_individual_household FOREIGN KEY (household_id) REFERENCES HOUSEHOLD(household_id)
);

-- Create indexes for individual
CREATE INDEX idx_individual_household ON INDIVIDUAL(household_id);
CREATE INDEX idx_individual_sex ON INDIVIDUAL(sex);
CREATE INDEX idx_individual_age ON INDIVIDUAL(age);
CREATE INDEX idx_individual_status ON INDIVIDUAL(status_on_census_night);

-- =========================================
-- 4. HOUSING CONDITIONS TABLE
-- =========================================
CREATE TABLE HOUSING (
    housing_id NUMBER PRIMARY KEY,
    household_id NUMBER NOT NULL,
    dwelling_type VARCHAR2(100),
    outer_wall_material VARCHAR2(100),
    floor_material VARCHAR2(100),
    roof_material VARCHAR2(100),
    tenure_arrangement VARCHAR2(100),
    ownership_type VARCHAR2(100),
    rooms_occupied NUMBER,
    rooms_for_sleeping NUMBER,
    rooms_shared_with_others CHAR(1) CHECK (rooms_shared_with_others IN ('Y', 'N')),
    households_sharing_rooms NUMBER,
    main_lighting_source VARCHAR2(100),
    main_drinking_water_source VARCHAR2(100),
    main_domestic_water_source VARCHAR2(100),
    main_cooking_fuel VARCHAR2(100),
    cooking_space_type VARCHAR2(100),
    bathing_facility_type VARCHAR2(100),
    toilet_facility_type VARCHAR2(100),
    toilet_shared CHAR(1) CHECK (toilet_shared IN ('Y', 'N')),
    households_sharing_toilet NUMBER,
    solid_waste_disposal VARCHAR2(100),
    liquid_waste_disposal VARCHAR2(100),
    has_fixed_telephone CHAR(1) CHECK (has_fixed_telephone IN ('Y', 'N')),
    has_computer CHAR(1) CHECK (has_computer IN ('Y', 'N')),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_housing_household FOREIGN KEY (household_id) REFERENCES HOUSEHOLD(household_id)
);

-- Create indexes for housing
CREATE INDEX idx_housing_household ON HOUSING(household_id);
CREATE INDEX idx_housing_dwelling_type ON HOUSING(dwelling_type);

-- =========================================
-- 5. ECONOMIC ACTIVITY TABLE
-- =========================================
CREATE TABLE ECONOMIC_ACTIVITY (
    economic_id NUMBER PRIMARY KEY,
    individual_id NUMBER NOT NULL,
    engaged_in_economic_activity CHAR(1) CHECK (engaged_in_economic_activity IN ('Y', 'N')),
    occupation_description VARCHAR2(500),
    occupation_code VARCHAR2(20),
    workplace_name VARCHAR2(200),
    workplace_location VARCHAR2(200),
    main_product_service VARCHAR2(200),
    main_product_code VARCHAR2(20),
    employment_status VARCHAR2(100),
    employment_status_code VARCHAR2(20),
    employment_sector VARCHAR2(100),
    employment_sector_code VARCHAR2(20),
    reason_not_working VARCHAR2(200),
    reason_not_working_code VARCHAR2(20),
    owns_mobile_phone CHAR(1) CHECK (owns_mobile_phone IN ('Y', 'N')),
    uses_internet CHAR(1) CHECK (uses_internet IN ('Y', 'N')),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_economic_individual FOREIGN KEY (individual_id) REFERENCES INDIVIDUAL(individual_id)
);

-- Create indexes for economic activity
CREATE INDEX idx_economic_individual ON ECONOMIC_ACTIVITY(individual_id);
CREATE INDEX idx_economic_status ON ECONOMIC_ACTIVITY(employment_status);

-- =========================================
-- 6. DISABILITY TABLE
-- =========================================
CREATE TABLE DISABILITY (
    disability_id NUMBER PRIMARY KEY,
    individual_id NUMBER NOT NULL,
    sight_disability CHAR(1) DEFAULT 'N' CHECK (sight_disability IN ('Y', 'N')),
    hearing_disability CHAR(1) DEFAULT 'N' CHECK (hearing_disability IN ('Y', 'N')),
    speech_disability CHAR(1) DEFAULT 'N' CHECK (speech_disability IN ('Y', 'N')),
    physical_disability CHAR(1) DEFAULT 'N' CHECK (physical_disability IN ('Y', 'N')),
    intellectual_disability CHAR(1) DEFAULT 'N' CHECK (intellectual_disability IN ('Y', 'N')),
    emotional_disability CHAR(1) DEFAULT 'N' CHECK (emotional_disability IN ('Y', 'N')),
    other_disability_specify VARCHAR2(255),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_disability_individual FOREIGN KEY (individual_id) REFERENCES INDIVIDUAL(individual_id) ON DELETE CASCADE
);

-- Create indexes for disability
CREATE INDEX idx_disability_individual ON DISABILITY(individual_id);

-- =========================================
-- 7. FERTILITY TABLE (for females 12+ years)
-- =========================================
CREATE TABLE FERTILITY (
    fertility_id NUMBER PRIMARY KEY,
    individual_id NUMBER NOT NULL,
    children_born_boys NUMBER DEFAULT 0,
    children_born_girls NUMBER DEFAULT 0,
    children_surviving_boys NUMBER DEFAULT 0,
    children_surviving_girls NUMBER DEFAULT 0,
    children_born_last_12months_boys NUMBER DEFAULT 0,
    children_born_last_12months_girls NUMBER DEFAULT 0,
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_fertility_individual FOREIGN KEY (individual_id) REFERENCES INDIVIDUAL(individual_id)
);

-- Create indexes for fertility
CREATE INDEX idx_fertility_individual ON FERTILITY(individual_id);

-- =========================================
-- 8. MORTALITY TABLE
-- =========================================
CREATE TABLE MORTALITY (
    mortality_id NUMBER PRIMARY KEY,
    household_id NUMBER NOT NULL,
    deceased_name VARCHAR2(200),
    deceased_sex CHAR(1) CHECK (deceased_sex IN ('M', 'F')),
    age_at_death NUMBER,
    death_due_to_accident CHAR(1) CHECK (death_due_to_accident IN ('Y', 'N')),
    death_due_to_violence CHAR(1) CHECK (death_due_to_violence IN ('Y', 'N')),
    death_due_to_homicide CHAR(1) CHECK (death_due_to_homicide IN ('Y', 'N')),
    death_due_to_suicide CHAR(1) CHECK (death_due_to_suicide IN ('Y', 'N')),
    death_during_pregnancy CHAR(1) CHECK (death_during_pregnancy IN ('Y', 'N')),
    death_during_delivery CHAR(1) CHECK (death_during_delivery IN ('Y', 'N')),
    death_postpartum CHAR(1) CHECK (death_postpartum IN ('Y', 'N')),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_mortality_household FOREIGN KEY (household_id) REFERENCES HOUSEHOLD(household_id)
);

-- Create indexes for mortality
CREATE INDEX idx_mortality_household ON MORTALITY(household_id);
CREATE INDEX idx_mortality_sex ON MORTALITY(deceased_sex);

-- =========================================
-- 9. AGRICULTURAL ACTIVITY TABLE
-- =========================================
CREATE TABLE AGRICULTURAL_ACTIVITY (
    agricultural_id NUMBER PRIMARY KEY,
    household_id NUMBER NOT NULL,
    crop_farming CHAR(1) DEFAULT 'N' CHECK (crop_farming IN ('Y', 'N')),
    tree_growing CHAR(1) DEFAULT 'N' CHECK (tree_growing IN ('Y', 'N')),
    livestock_rearing CHAR(1) DEFAULT 'N' CHECK (livestock_rearing IN ('Y', 'N')),
    fish_farming CHAR(1) DEFAULT 'N' CHECK (fish_farming IN ('Y', 'N')),
    members_in_agriculture_male NUMBER DEFAULT 0,
    members_in_agriculture_female NUMBER DEFAULT 0,
    crop_type VARCHAR2(200),
    crop_code VARCHAR2(20),
    farm_size NUMBER,
    farm_size_unit VARCHAR2(20),
    cropping_type VARCHAR2(100),
    livestock_type VARCHAR2(200),
    livestock_code VARCHAR2(20),
    livestock_number NUMBER,
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_agricultural_household FOREIGN KEY (household_id) REFERENCES HOUSEHOLD(household_id) ON DELETE CASCADE
);

-- Create indexes for agricultural activity
CREATE INDEX idx_agricultural_household ON AGRICULTURAL_ACTIVITY(household_id);

-- =========================================
-- 10. EMIGRATION TABLE
-- =========================================
CREATE TABLE EMIGRATION (
    emigration_id NUMBER PRIMARY KEY,
    household_id NUMBER NOT NULL,
    emigrant_name VARCHAR2(200),
    relationship_to_head VARCHAR2(50),
    emigrant_sex CHAR(1) CHECK (emigrant_sex IN ('M', 'F')),
    emigrant_age NUMBER,
    destination_country VARCHAR2(100),
    destination_country_code VARCHAR2(10),
    year_of_departure NUMBER,
    activity_abroad VARCHAR2(200),
    activity_code VARCHAR2(20),
    other_activity_description VARCHAR2(500),
    date_created DATE DEFAULT SYSDATE,
    date_modified DATE DEFAULT SYSDATE,
    created_by VARCHAR2(100) DEFAULT USER,
    modified_by VARCHAR2(100) DEFAULT USER,
    CONSTRAINT fk_emigration_household FOREIGN KEY (household_id) REFERENCES HOUSEHOLD(household_id)
);

-- Create indexes for emigration
CREATE INDEX idx_emigration_household ON EMIGRATION(household_id);
CREATE INDEX idx_emigration_country ON EMIGRATION(destination_country);

-- =========================================
-- 11. ACTIVITY LOG TABLE (for tracking user activities)
-- =========================================
CREATE TABLE ACTIVITY_LOG (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(100) NOT NULL,
    operation_type VARCHAR2(20) CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id NUMBER,
    old_values CLOB,
    new_values CLOB,
    user_name VARCHAR2(100) DEFAULT USER,
    session_id VARCHAR2(100),
    ip_address VARCHAR2(50),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    application_name VARCHAR2(100) DEFAULT 'CENSUS_DBMS'
);

-- Create indexes for activity log
CREATE INDEX idx_activity_log_table ON ACTIVITY_LOG(table_name);
CREATE INDEX idx_activity_log_operation ON ACTIVITY_LOG(operation_type);
CREATE INDEX idx_activity_log_timestamp ON ACTIVITY_LOG(operation_timestamp);
CREATE INDEX idx_activity_log_user ON ACTIVITY_LOG(user_name);

-- =========================================
-- CREATE VIEWS FOR COMMON QUERIES
-- =========================================

-- View for household summary with geographical information
CREATE OR REPLACE VIEW VW_HOUSEHOLD_SUMMARY AS
SELECT 
    h.household_id,
    h.household_number_in_structure,
    h.total_members,
    h.total_males,
    h.total_females,
    g.region_name,
    g.district_name,
    g.locality_name,
    g.detailed_address,
    h.housing_unit_status,
    h.interview_date_started,
    h.interview_date_completed
FROM HOUSEHOLD h
JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id;

-- View for individual demographics with household info
CREATE OR REPLACE VIEW VW_INDIVIDUAL_DEMOGRAPHICS AS
SELECT 
    i.individual_id,
    i.full_name,
    i.sex,
    i.age,
    i.relationship_to_head,
    i.marital_status,
    i.highest_education_level,
    h.household_id,
    g.region_name,
    g.district_name,
    g.locality_name
FROM INDIVIDUAL i
JOIN HOUSEHOLD h ON i.household_id = h.household_id
JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id;

-- View for economic activity summary
CREATE OR REPLACE VIEW VW_ECONOMIC_SUMMARY AS
SELECT 
    i.individual_id,
    i.full_name,
    i.sex,
    i.age,
    e.engaged_in_economic_activity,
    e.occupation_description,
    e.employment_status,
    e.employment_sector,
    g.region_name,
    g.district_name
FROM INDIVIDUAL i
LEFT JOIN ECONOMIC_ACTIVITY e ON i.individual_id = e.individual_id
JOIN HOUSEHOLD h ON i.household_id = h.household_id
JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id
WHERE i.age >= 5;

-- View for housing conditions summary
CREATE OR REPLACE VIEW VW_HOUSING_SUMMARY AS
SELECT 
    hs.housing_id,
    h.household_id,
    hs.dwelling_type,
    hs.outer_wall_material,
    hs.floor_material,
    hs.roof_material,
    hs.main_lighting_source,
    hs.main_drinking_water_source,
    hs.toilet_facility_type,
    g.region_name,
    g.district_name
FROM HOUSING hs
JOIN HOUSEHOLD h ON hs.household_id = h.household_id
JOIN GEOGRAPHICAL_INFO g ON h.geo_id = g.geo_id;

-- =========================================
-- GRANT PERMISSIONS (adjust as needed)
-- =========================================
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES TO CENSUS_USER;
-- GRANT EXECUTE ON ALL PROCEDURES TO CENSUS_USER;

COMMIT;

-- Display success message
SELECT 'Census Database Schema Created Successfully!' AS MESSAGE FROM DUAL;
