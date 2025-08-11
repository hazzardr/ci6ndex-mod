INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES
    ('PLAYER_CAN_SEE_NITER_CIVDEX'	, 	'REQUIREMENTSET_TEST_ALL'),
    ('PLAYER_CAN_SEE_ALUMINUM_CIVDEX'	, 	'REQUIREMENTSET_TEST_ALL'),
    ('PLAYER_CAN_SEE_COAL_CIVDEX'	, 	'REQUIREMENTSET_TEST_ALL'),
    ('PLAYER_CAN_SEE_OIL_CIVDEX'		, 	'REQUIREMENTSET_TEST_ALL');

-- only trigger when player can see resource, even if built before
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES
    ('PLAYER_CAN_SEE_NITER_CIVDEX'	, 'REQUIRES_PLAYER_CAN_SEE_NITER'),
    ('PLAYER_CAN_SEE_ALUMINUM_CIVDEX'	, 'REQUIRES_PLAYER_CAN_SEE_ALUMINUM'),
    ('PLAYER_CAN_SEE_COAL_CIVDEX'	, 'REQUIRES_PLAYER_CAN_SEE_COAL'),
    ('PLAYER_CAN_SEE_OIL_CIVDEX'		, 'REQUIRES_PLAYER_CAN_SEE_OIL');

-- +1 niter for armory
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
    ('BUILDING_ARMORY', 'NITER_FROM_ARMORY_CIVDEX');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
    ('NITER_FROM_ARMORY_CIVDEX', 'MODIFIER_PLAYER_ADJUST_FREE_RESOURCE_IMPORT_EXTRACTION', 'PLAYER_CAN_SEE_NITER_CIVDEX');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('NITER_FROM_ARMORY_CIVDEX', 'ResourceType', 'RESOURCE_NITER'),
    ('NITER_FROM_ARMORY_CIVDEX', 'Amount', '1');

-- +1 coal for shipyards
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
    ('BUILDING_SHIPYARD', 'COAL_FROM_SHIPYARD_CIVDEX');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
    ('COAL_FROM_SHIPYARD_CIVDEX', 'MODIFIER_PLAYER_ADJUST_FREE_RESOURCE_IMPORT_EXTRACTION', 'PLAYER_CAN_SEE_COAL_CIVDEX');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
    ('COAL_FROM_SHIPYARD_CIVDEX', 'ResourceType', 'RESOURCE_COAL'),
    ('COAL_FROM_SHIPYARD_CIVDEX', 'Amount', '1');

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

-- +1 alum from hangars
INSERT INTO BuildingModifiers (BuildingType, ModifierId) 
VALUES
    ('BUILDING_HANGAR', 'ALUM_FROM_HANGAR_CIVDEX');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) 
VALUES
    ('ALUM_FROM_HANGAR_CIVDEX', 'MODIFIER_PLAYER_ADJUST_FREE_RESOURCE_IMPORT_EXTRACTION', 'PLAYER_CAN_SEE_ALUMINUM_CIVDEX');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES
    ('ALUM_FROM_HANGAR_CIVDEX', 'ResourceType', 'RESOURCE_ALUMINUM'),
    ('ALUM_FROM_HANGAR_CIVDEX', 'Amount', '1');
