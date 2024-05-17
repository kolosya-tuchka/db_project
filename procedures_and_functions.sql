DELIMITER //

CREATE PROCEDURE IF NOT EXISTS UpdateWeaponryCount(IN unitID INT, IN quantity INT)
BEGIN
    DECLARE divisionID INT;
    DECLARE armyID INT;

    -- Находим ID дивизии, в которой находится данная часть
    SELECT DivisionID INTO divisionID FROM Unit WHERE ID = unitID;
    -- Находим ID армии, в которой находится эта дивизия
    SELECT ArmyID INTO armyID FROM Division WHERE ID = divisionID;

    -- Обновляем количество вооружения в части
    UPDATE Unit SET TotalWeaponry = TotalWeaponry + quantity WHERE ID = unitID;
    -- Обновляем количество вооружения в дивизии
    UPDATE Division SET TotalWeaponry = TotalWeaponry + quantity WHERE ID = divisionID;
    -- Обновляем количество вооружения в армии
    UPDATE Army SET TotalWeaponry = TotalWeaponry + quantity WHERE ID = armyID;
END //

DELIMITER ;

CREATE FUNCTION IF NOT EXISTS SoldiersWithSpecialty(unit_id INT, specialty_id INT) RETURNS INT READS SQL DATA
BEGIN
    DECLARE soldiers_count INT;

    SELECT COUNT(*) INTO soldiers_count
    FROM SoldierSpecialties ss
    JOIN Soldier s ON ss.SoldierID = s.ID
    WHERE ss.SpecialityID = specialty_id AND s.UnitID = unit_id;

    RETURN soldiers_count;
END;