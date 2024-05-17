-- 1. Добавление поля SoldierCount
ALTER TABLE Unit
ADD COLUMN SoldierCount INT DEFAULT 0;

-- 2. Обновление значения SoldierCount
UPDATE Unit
SET SoldierCount = (SELECT COUNT(*) FROM Soldier WHERE UnitID = Unit.ID) WHERE TRUE;

-- 3. Добавление поля SoldierCount в таблицу Division
ALTER TABLE Division
ADD COLUMN SoldierCount INT DEFAULT 0;

-- 4. Обновление значения SoldierCount для всех существующих записей в таблице Division
UPDATE Division
SET SoldierCount = (SELECT SUM(Unit.SoldierCount) FROM Unit WHERE DivisionID = Division.ID) WHERE TRUE;

-- 5. Добавление поля SoldierCount в таблицу Army
ALTER TABLE Army
ADD COLUMN SoldierCount INT DEFAULT 0;

-- 6. Обновление значения SoldierCount для всех существующих записей в таблице Army
UPDATE Army
SET SoldierCount = (SELECT SUM(Division.SoldierCount) FROM Division WHERE ArmyID = Army.ID) WHERE TRUE;