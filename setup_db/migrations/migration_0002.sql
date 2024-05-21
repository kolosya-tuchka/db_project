-- Добавление атрибута TotalWeaponry в таблицу Unit
ALTER TABLE Unit ADD COLUMN TotalWeaponry INT DEFAULT 0;

-- Обновление значения TotalWeaponry в таблице Unit
UPDATE Unit u
SET TotalWeaponry = (
    SELECT SUM(wi.Quantity)
    FROM WeaponryInUnit wi
    WHERE wi.UnitID = u.ID
) WHERE True;

-- Добавление атрибута TotalWeaponry в таблицу Division
ALTER TABLE Division ADD COLUMN TotalWeaponry INT DEFAULT 0;

-- Обновление значения TotalWeaponry в таблице Division
UPDATE Division d
SET TotalWeaponry = (
    SELECT SUM(u.TotalWeaponry)
    FROM Unit u
    WHERE u.DivisionID = d.ID
) WHERE True;

-- Добавление атрибута TotalWeaponry в таблицу Army
ALTER TABLE Army ADD COLUMN TotalWeaponry INT DEFAULT 0;

-- Обновление значения TotalWeaponry в таблице Army
UPDATE Army a
SET TotalWeaponry = (
    SELECT SUM(d.TotalWeaponry)
    FROM Division d
    WHERE d.ArmyID = a.ID
) WHERE True;
