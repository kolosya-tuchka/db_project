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
    DECLARE divisionID INT;
    DECLARE armyID INT;

    -- Находим ID дивизии, в которой находится данная часть
    SELECT DivisionID INTO divisionID FROM Unit WHERE ID = NEW.UnitID;
    -- Находим ID армии, в которой находится эта дивизия
    SELECT ArmyID INTO armyID FROM Division WHERE ID = divisionID;

    -- Обновляем количество вооружения в части
    UPDATE Unit SET TotalWeaponry = TotalWeaponry + NEW.Quantity WHERE ID = NEW.UnitID;
    -- Обновляем количество вооружения в дивизии
    UPDATE Division SET TotalWeaponry = TotalWeaponry + NEW.Quantity WHERE ID = divisionID;
    -- Обновляем количество вооружения в армии
    UPDATE Army SET TotalWeaponry = TotalWeaponry + NEW.Quantity WHERE ID = armyID;
END;