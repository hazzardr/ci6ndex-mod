INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES
    ('PLAYER_CAN_SEE_ALUMINUM_CIVDEX'	, 	'REQUIREMENTSET_TEST_ALL'),
    ('PLAYER_CAN_SEE_COAL_CIVDEX'	, 	'REQUIREMENTSET_TEST_ALL'),
    ('PLAYER_CAN_SEE_OIL_CIVDEX'		, 	'REQUIREMENTSET_TEST_ALL');

-- only trigger when player can see resource, even if built before
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES
    ('PLAYER_CAN_SEE_ALUMINUM_CIVDEX'	, 'REQUIRES_PLAYER_CAN_SEE_ALUMINUM'),
    ('PLAYER_CAN_SEE_COAL_CIVDEX'	, 'REQUIRES_PLAYER_CAN_SEE_COAL'),
    ('PLAYER_CAN_SEE_OIL_CIVDEX'		, 'REQUIRES_PLAYER_CAN_SEE_OIL');

-- +1 coal for seaports
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
    ('BUILDING_SEAPORT', 'COAL_FROM_SEAPORT_CIVDEX');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
    ('COAL_FROM_SEAPORT_CIVDEX', 'MODIFIER_PLAYER_ADJUST_FREE_RESOURCE_IMPORT_EXTRACTION', 'PLAYER_CAN_SEE_COAL_CIVDEX');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('COAL_FROM_SEAPORT_CIVDEX', 'ResourceType', 'RESOURCE_COAL'),
    ('COAL_FROM_SEAPORT_CIVDEX', 'Amount', '1');
-- +1 oil from mil acadamies
INSERT INTO BuildingModifiers (BuildingType, ModifierId) 
VALUES
    ('BUILDING_MILITARY_ACADEMY', 'OIL_FROM_MIL_ACAD_CIVDEX');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) 
VALUES
    ('OIL_FROM_MIL_ACAD_CIVDEX', 'MODIFIER_PLAYER_ADJUST_FREE_RESOURCE_IMPORT_EXTRACTION', 'PLAYER_CAN_SEE_OIL_CIVDEX');
INSERT INTO ModifierArguments (ModifierId, Name, Value) 
VALUES
    ('OIL_FROM_MIL_ACAD_CIVDEX', 'ResourceType', 'RESOURCE_OIL'),
    ('OIL_FROM_MIL_ACAD_CIVDEX', 'Amount', '1');

-- +1 alum from airports
INSERT INTO BuildingModifiers (BuildingType, ModifierId) 
VALUES
    ('BUILDING_AIRPORT', 'ALUM_FROM_AIRPORT_CIVDEX');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) 
VALUES
    ('ALUM_FROM_AIRPORT_CIVDEX', 'MODIFIER_PLAYER_ADJUST_FREE_RESOURCE_IMPORT_EXTRACTION', 'PLAYER_CAN_SEE_ALUMINUM_CIVDEX');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES
    ('ALUM_FROM_AIRPORT_CIVDEX', 'ResourceType', 'RESOURCE_ALUMINUM'),
    ('ALUM_FROM_AIRPORT_CIVDEX', 'Amount', '1');

-- 
-- [766238.837] [Gameplay]: Validating Foreign Key Constraints...
-- [766238.845] [Gameplay] ERROR: Invalid Reference on Modifiers.SubjectRequirementSetId - "PLAYER_CAN_SEE_OIL_CIVDEX" does not exist in RequirementSets
-- [766238.845] [Gameplay] ERROR: Invalid Reference on Modifiers.SubjectRequirementSetId - "PLAYER_CAN_SEE_ALUMINUM_CIVDEX" does not exist in RequirementSets
-- [766238.849] [Gameplay] ERROR: Invalid Reference on RequirementSetRequirements.RequirementSetId - "PLAYER_CAN_SEE_ALUMINUM_CIVDEX" does not exist in RequirementSets
-- [766238.849] [Gameplay] ERROR: Invalid Reference on RequirementSetRequirements.RequirementSetId - "PLAYER_CAN_SEE_OIL_CIVDEX" does not exist in RequirementSets