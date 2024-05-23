-- Триггер для увеличения счетчика при добавлении солдата
CREATE TRIGGER IF NOT EXISTS IncreaseSoldierCount
AFTER INSERT ON Soldier
FOR EACH ROW
BEGIN
    -- Увеличение счетчика солдат в части
    UPDATE Unit
    SET SoldierCount = SoldierCount + 1
    WHERE ID = NEW.UnitID;

    -- Увеличение счетчика солдат в дивизии
    UPDATE Division
    SET SoldierCount = SoldierCount + 1
    WHERE ID = (SELECT DivisionID FROM Unit WHERE ID = NEW.UnitID);

    -- Увеличение счетчика солдат в армии
    UPDATE Army
    SET SoldierCount = SoldierCount + 1
    WHERE ID = (SELECT ArmyID FROM Division WHERE ID = (SELECT DivisionID FROM Unit WHERE ID = NEW.UnitID));
END;

-- Триггер для уменьшения счетчика при удалении солдата
CREATE TRIGGER IF NOT EXISTS DecreaseSoldierCount
AFTER DELETE ON Soldier
FOR EACH ROW
BEGIN
    -- Уменьшение счетчика солдат в части
    UPDATE Unit
    SET SoldierCount = SoldierCount - 1
    WHERE ID = OLD.UnitID;

    -- Уменьшение счетчика солдат в дивизии
    UPDATE Division
    SET SoldierCount = SoldierCount - 1
    WHERE ID = (SELECT DivisionID FROM Unit WHERE ID = OLD.UnitID);

    -- Уменьшение счетчика солдат в армии
    UPDATE Army
    SET SoldierCount = SoldierCount - 1
    WHERE ID = (SELECT ArmyID FROM Division WHERE ID = (SELECT DivisionID FROM Unit WHERE ID = OLD.UnitID));
END;

CREATE TRIGGER IF NOT EXISTS AfterInsertWeaponry
AFTER INSERT ON WeaponryInUnit
FOR EACH ROW
BEGIN
    DECLARE p_divisionID INT;
    DECLARE p_armyID INT;

    -- Находим ID дивизии, в которой находится данная часть
    SELECT DivisionID INTO p_divisionID FROM Unit WHERE ID = NEW.UnitID;
    -- Находим ID армии, в которой находится эта дивизия
    SELECT ArmyID INTO p_armyID FROM Division WHERE ID = p_divisionID;

    -- Обновляем количество вооружения в части
    UPDATE Unit SET TotalWeaponry = TotalWeaponry + NEW.Quantity WHERE ID = NEW.UnitID;
    -- Обновляем количество вооружения в дивизии
    UPDATE Division SET TotalWeaponry = TotalWeaponry + NEW.Quantity WHERE ID = p_divisionID;
    -- Обновляем количество вооружения в армии
    UPDATE Army SET TotalWeaponry = TotalWeaponry + NEW.Quantity WHERE ID = p_armyID;
END;

CREATE TRIGGER IF NOT EXISTS AfterUpdateWeaponry
AFTER UPDATE ON WeaponryInUnit
FOR EACH ROW
BEGIN
    DECLARE p_divisionID INT;
    DECLARE p_armyID INT;
    DECLARE quantity_difference INT;

    -- Получаем разницу в количестве вооружения
    SET quantity_difference = NEW.Quantity - OLD.Quantity;

    -- Находим ID дивизии, в которой находится данная часть
    SELECT DivisionID INTO p_divisionID FROM Unit WHERE ID = NEW.UnitID;
    -- Находим ID армии, в которой находится эта дивизия
    SELECT ArmyID INTO p_armyID FROM Division WHERE ID = p_divisionID;

    -- Обновляем количество вооружения в части
    UPDATE Unit SET TotalWeaponry = TotalWeaponry + quantity_difference WHERE ID = NEW.UnitID;
    -- Обновляем количество вооружения в дивизии
    UPDATE Division SET TotalWeaponry = TotalWeaponry + quantity_difference WHERE ID = p_divisionID;
    -- Обновляем количество вооружения в армии
    UPDATE Army SET TotalWeaponry = TotalWeaponry + quantity_difference WHERE ID = p_armyID;
END;

CREATE TRIGGER IF NOT EXISTS OnUpdateSoldierUnit
BEFORE UPDATE ON Soldier
FOR EACH ROW
BEGIN
    DECLARE oldDivisionID INT;
    DECLARE newDivisionID INT;
    DECLARE oldArmyID INT;
    DECLARE newArmyID INT;

    -- Получаем DivisionID и ArmyID для старой и новой части
    SELECT DivisionID INTO oldDivisionID FROM Unit WHERE ID = OLD.UnitID;
    SELECT DivisionID INTO newDivisionID FROM Unit WHERE ID = NEW.UnitID;

    SELECT ArmyID INTO oldArmyID FROM Division WHERE ID = oldDivisionID;
    SELECT ArmyID INTO newArmyID FROM Division WHERE ID = newDivisionID;

    -- Обновляем количество солдат в старой части
    UPDATE Unit SET SoldierCount = SoldierCount - 1 WHERE ID = OLD.UnitID;
    -- Обновляем количество солдат в новой части
    UPDATE Unit SET SoldierCount = SoldierCount + 1 WHERE ID = NEW.UnitID;

    -- Если дивизии разные, обновляем количество солдат в старой и новой дивизии
    IF oldDivisionID != newDivisionID THEN
        UPDATE Division SET SoldierCount = SoldierCount - 1 WHERE ID = oldDivisionID;
        UPDATE Division SET SoldierCount = SoldierCount + 1 WHERE ID = newDivisionID;
    END IF;

    -- Если армии разные, обновляем количество солдат в старой и новой армии
    IF oldArmyID != newArmyID THEN
        UPDATE Army SET SoldierCount = SoldierCount - 1 WHERE ID = oldArmyID;
        UPDATE Army SET SoldierCount = SoldierCount + 1 WHERE ID = newArmyID;
    END IF;
END;
