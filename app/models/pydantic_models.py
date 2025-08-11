# =========================================
# PYDANTIC MODELS FOR DATA VALIDATION
# Census Database Management System - Oracle Edition
# Created: 2025-07-23 10:31:12
# =========================================

from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import date, datetime
from enum import Enum

# =========================================
# ENUMS FOR VALIDATION
# =========================================

class Sex(str, Enum):
    MALE = "M"
    FEMALE = "F"

class HousingUnitStatus(str, Enum):
    OCCUPIED = "OCCUPIED"
    VACANT = "VACANT"

class CensusNightStatus(str, Enum):
    PRESENT = "PRESENT"
    ABSENT = "ABSENT"
    VISITOR = "VISITOR"

class YesNo(str, Enum):
    YES = "Y"
    NO = "N"

# =========================================
# BASE MODELS
# =========================================

class BaseModelWithId(BaseModel):
    """Base model with common fields"""
    date_created: Optional[datetime] = None
    date_modified: Optional[datetime] = None
    created_by: Optional[str] = None
    modified_by: Optional[str] = None

    class Config:
        from_attributes = True
        use_enum_values = True

# =========================================
# GEOGRAPHICAL INFORMATION MODELS
# =========================================

class GeographicalInfoBase(BaseModel):
    """Base model for geographical information"""
    region_name: str = Field(..., min_length=1, max_length=100)
    district_name: str = Field(..., min_length=1, max_length=100)
    district_type: Optional[str] = Field(None, max_length=50)
    sub_district: Optional[str] = Field(None, max_length=100)
    locality_name: Optional[str] = Field(None, max_length=100)
    nhis_ecg_vra_number: Optional[str] = Field(None, max_length=50)
    detailed_address: Optional[str] = None
    contact_phone_1: Optional[str] = Field(None, max_length=20)
    contact_phone_2: Optional[str] = Field(None, max_length=20)
    enumeration_area_code: Optional[str] = Field(None, max_length=20)
    ea_type: Optional[str] = Field(None, max_length=50)
    locality_code: Optional[str] = Field(None, max_length=20)
    structure_number: Optional[str] = Field(None, max_length=20)

class GeographicalInfoCreate(GeographicalInfoBase):
    """Model for creating geographical information"""
    pass

class GeographicalInfoUpdate(BaseModel):
    """Model for updating geographical information"""
    region_name: Optional[str] = Field(None, min_length=1, max_length=100)
    district_name: Optional[str] = Field(None, min_length=1, max_length=100)
    district_type: Optional[str] = Field(None, max_length=50)
    detailed_address: Optional[str] = None
    contact_phone_1: Optional[str] = Field(None, max_length=20)
    contact_phone_2: Optional[str] = Field(None, max_length=20)

class GeographicalInfoResponse(GeographicalInfoBase, BaseModelWithId):
    """Model for geographical information response"""
    geo_id: int

# =========================================
# HOUSEHOLD MODELS
# =========================================

class HouseholdBase(BaseModel):
    """Base model for household"""
    geo_id: int
    household_number_in_structure: Optional[str] = Field(None, max_length=20)
    type_of_residence: Optional[str] = Field(None, max_length=50)
    interview_date_started: Optional[date] = None
    interview_date_completed: Optional[date] = None
    total_visits: Optional[int] = Field(1, ge=1)
    form_number: Optional[str] = Field(None, max_length=50)
    housing_unit_status: Optional[HousingUnitStatus] = HousingUnitStatus.OCCUPIED

class HouseholdCreate(HouseholdBase):
    """Model for creating household"""
    pass

class HouseholdUpdate(BaseModel):
    """Model for updating household"""
    type_of_residence: Optional[str] = Field(None, max_length=50)
    interview_date_completed: Optional[date] = None
    total_visits: Optional[int] = Field(None, ge=1)
    housing_unit_status: Optional[HousingUnitStatus] = None

class HouseholdResponse(HouseholdBase, BaseModelWithId):
    """Model for household response"""
    household_id: int
    total_members: Optional[int] = 0
    total_males: Optional[int] = 0
    total_females: Optional[int] = 0

# =========================================
# INDIVIDUAL MODELS
# =========================================

class IndividualBase(BaseModel):
    """Base model for individual"""
    household_id: int
    person_line_number: Optional[int] = None
    full_name: str = Field(..., min_length=1, max_length=200)
    relationship_to_head: Optional[str] = Field(None, max_length=50)
    sex: Optional[Sex] = None
    date_of_birth: Optional[date] = None
    age: Optional[int] = Field(None, ge=0, le=150)
    nationality: Optional[str] = Field(None, max_length=100)
    ethnicity: Optional[str] = Field(None, max_length=100)
    ethnicity_code: Optional[str] = Field(None, max_length=10)
    born_in_current_location: Optional[YesNo] = None
    birthplace_region: Optional[str] = Field(None, max_length=100)
    birthplace_country: Optional[str] = Field(None, max_length=100)
    lived_here_since_birth: Optional[YesNo] = None
    years_lived_here: Optional[int] = Field(None, ge=0)
    religion: Optional[str] = Field(None, max_length=100)
    religion_code: Optional[str] = Field(None, max_length=10)
    marital_status: Optional[str] = Field(None, max_length=50)
    literacy_language: Optional[str] = Field(None, max_length=100)
    literacy_code: Optional[str] = Field(None, max_length=10)
    ever_attended_school: Optional[YesNo] = None
    highest_education_level: Optional[str] = Field(None, max_length=100)
    highest_grade_completed: Optional[str] = Field(None, max_length=50)
    status_on_census_night: Optional[CensusNightStatus] = CensusNightStatus.PRESENT
    months_absent: Optional[int] = Field(None, ge=0, le=12)
    absence_destination: Optional[str] = Field(None, max_length=200)

    @validator('age', 'date_of_birth')
    def validate_age_consistency(cls, v, values):
        """Validate age consistency with date of birth"""
        if 'date_of_birth' in values and values['date_of_birth'] and v:
            from datetime import date
            calculated_age = (date.today() - values['date_of_birth']).days // 365
            if abs(calculated_age - v) > 1:  # Allow 1 year difference
                raise ValueError('Age does not match date of birth')
        return v

class IndividualCreate(IndividualBase):
    """Model for creating individual"""
    pass

class IndividualUpdate(BaseModel):
    """Model for updating individual"""
    full_name: Optional[str] = Field(None, min_length=1, max_length=200)
    relationship_to_head: Optional[str] = Field(None, max_length=50)
    sex: Optional[Sex] = None
    age: Optional[int] = Field(None, ge=0, le=150)
    nationality: Optional[str] = Field(None, max_length=100)
    ethnicity: Optional[str] = Field(None, max_length=100)
    religion: Optional[str] = Field(None, max_length=100)
    marital_status: Optional[str] = Field(None, max_length=50)
    highest_education_level: Optional[str] = Field(None, max_length=100)

class IndividualResponse(IndividualBase, BaseModelWithId):
    """Model for individual response"""
    individual_id: int

# =========================================
# HOUSING MODELS
# =========================================

class HousingBase(BaseModel):
    """Base model for housing"""
    household_id: int
    dwelling_type: Optional[str] = Field(None, max_length=100)
    outer_wall_material: Optional[str] = Field(None, max_length=100)
    floor_material: Optional[str] = Field(None, max_length=100)
    roof_material: Optional[str] = Field(None, max_length=100)
    tenure_arrangement: Optional[str] = Field(None, max_length=100)
    ownership_type: Optional[str] = Field(None, max_length=100)
    rooms_occupied: Optional[int] = Field(None, ge=0)
    rooms_for_sleeping: Optional[int] = Field(None, ge=0)
    rooms_shared_with_others: Optional[YesNo] = None
    households_sharing_rooms: Optional[int] = Field(None, ge=0)
    main_lighting_source: Optional[str] = Field(None, max_length=100)
    main_drinking_water_source: Optional[str] = Field(None, max_length=100)
    main_domestic_water_source: Optional[str] = Field(None, max_length=100)
    main_cooking_fuel: Optional[str] = Field(None, max_length=100)
    cooking_space_type: Optional[str] = Field(None, max_length=100)
    bathing_facility_type: Optional[str] = Field(None, max_length=100)
    toilet_facility_type: Optional[str] = Field(None, max_length=100)
    toilet_shared: Optional[YesNo] = None
    households_sharing_toilet: Optional[int] = Field(None, ge=0)
    solid_waste_disposal: Optional[str] = Field(None, max_length=100)
    liquid_waste_disposal: Optional[str] = Field(None, max_length=100)
    has_fixed_telephone: Optional[YesNo] = None
    has_computer: Optional[YesNo] = None

class HousingCreate(HousingBase):
    """Model for creating housing"""
    pass

class HousingUpdate(BaseModel):
    """Model for updating housing"""
    dwelling_type: Optional[str] = Field(None, max_length=100)
    outer_wall_material: Optional[str] = Field(None, max_length=100)
    floor_material: Optional[str] = Field(None, max_length=100)
    roof_material: Optional[str] = Field(None, max_length=100)
    rooms_occupied: Optional[int] = Field(None, ge=0)
    main_lighting_source: Optional[str] = Field(None, max_length=100)
    main_drinking_water_source: Optional[str] = Field(None, max_length=100)
    toilet_facility_type: Optional[str] = Field(None, max_length=100)

class HousingResponse(HousingBase, BaseModelWithId):
    """Model for housing response"""
    housing_id: int

# =========================================
# ECONOMIC ACTIVITY MODELS
# =========================================

class EconomicActivityBase(BaseModel):
    """Base model for economic activity"""
    individual_id: int
    engaged_in_economic_activity: Optional[YesNo] = YesNo.NO
    occupation_description: Optional[str] = Field(None, max_length=500)
    occupation_code: Optional[str] = Field(None, max_length=20)
    workplace_name: Optional[str] = Field(None, max_length=200)
    workplace_location: Optional[str] = Field(None, max_length=200)
    main_product_service: Optional[str] = Field(None, max_length=200)
    main_product_code: Optional[str] = Field(None, max_length=20)
    employment_status: Optional[str] = Field(None, max_length=100)
    employment_status_code: Optional[str] = Field(None, max_length=20)
    employment_sector: Optional[str] = Field(None, max_length=100)
    employment_sector_code: Optional[str] = Field(None, max_length=20)
    reason_not_working: Optional[str] = Field(None, max_length=200)
    reason_not_working_code: Optional[str] = Field(None, max_length=20)
    owns_mobile_phone: Optional[YesNo] = YesNo.NO
    uses_internet: Optional[YesNo] = YesNo.NO

class EconomicActivityCreate(EconomicActivityBase):
    """Model for creating economic activity"""
    pass

class EconomicActivityUpdate(BaseModel):
    """Model for updating economic activity"""
    engaged_in_economic_activity: Optional[YesNo] = None
    occupation_description: Optional[str] = Field(None, max_length=500)
    workplace_name: Optional[str] = Field(None, max_length=200)
    employment_status: Optional[str] = Field(None, max_length=100)
    employment_sector: Optional[str] = Field(None, max_length=100)
    owns_mobile_phone: Optional[YesNo] = None
    uses_internet: Optional[YesNo] = None

class EconomicActivityResponse(EconomicActivityBase, BaseModelWithId):
    """Model for economic activity response"""
    economic_id: int

# =========================================
# FERTILITY MODELS
# =========================================

class FertilityBase(BaseModel):
    """Base model for fertility (females 12+ years)"""
    individual_id: int
    children_born_boys: Optional[int] = Field(0, ge=0)
    children_born_girls: Optional[int] = Field(0, ge=0)
    children_surviving_boys: Optional[int] = Field(0, ge=0)
    children_surviving_girls: Optional[int] = Field(0, ge=0)
    children_born_last_12months_boys: Optional[int] = Field(0, ge=0)
    children_born_last_12months_girls: Optional[int] = Field(0, ge=0)

class FertilityCreate(FertilityBase):
    """Model for creating fertility record"""
    pass

class FertilityUpdate(BaseModel):
    """Model for updating fertility record"""
    children_born_boys: Optional[int] = Field(None, ge=0)
    children_born_girls: Optional[int] = Field(None, ge=0)
    children_surviving_boys: Optional[int] = Field(None, ge=0)
    children_surviving_girls: Optional[int] = Field(None, ge=0)

class FertilityResponse(FertilityBase, BaseModelWithId):
    """Model for fertility response"""
    fertility_id: int

# =========================================
# RESPONSE MODELS FOR COMPLEX QUERIES
# =========================================

class HouseholdDemographicsResponse(BaseModel):
    """Response model for household demographics"""
    individual_id: int
    full_name: str
    sex: Optional[str]
    age: Optional[int]
    relationship_to_head: Optional[str]
    marital_status: Optional[str]
    highest_education_level: Optional[str]
    occupation_description: Optional[str]
    employment_status: Optional[str]
    total_members: Optional[int]
    region_name: str
    district_name: str
    locality_name: Optional[str]

class RegionalStatisticsResponse(BaseModel):
    """Response model for regional statistics"""
    region_name: str
    district_name: str
    total_households: int
    total_population: int
    total_males: int
    total_females: int
    average_age: Optional[float]
    employed_count: int
    educated_count: int

class HousingConditionsResponse(BaseModel):
    """Response model for housing conditions"""
    region_name: str
    district_name: str
    dwelling_type: Optional[str]
    main_drinking_water_source: Optional[str]
    toilet_facility_type: Optional[str]
    main_lighting_source: Optional[str]
    household_count: int
    avg_rooms_occupied: Optional[float]

# =========================================
# UTILITY MODELS
# =========================================

class APIResponse(BaseModel):
    """Generic API response model"""
    success: bool = True
    message: str
    data: Optional[dict] = None
    count: Optional[int] = None

class PaginationParams(BaseModel):
    """Pagination parameters"""
    page: int = Field(1, ge=1)
    size: int = Field(20, ge=1, le=100)

    @property
    def offset(self) -> int:
        return (self.page - 1) * self.size

class SearchFilters(BaseModel):
    """Search filters for census data"""
    region_name: Optional[str] = None
    district_name: Optional[str] = None
    sex: Optional[Sex] = None
    min_age: Optional[int] = Field(None, ge=0)
    max_age: Optional[int] = Field(None, le=150)
    marital_status: Optional[str] = None
    education_level: Optional[str] = None
