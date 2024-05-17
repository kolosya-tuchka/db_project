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
