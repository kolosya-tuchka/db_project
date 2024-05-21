DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS CheckUserLogin(IN p_username VARCHAR(255), IN p_user_type VARCHAR(255))
BEGIN
    SELECT ID, Password
    FROM User
    WHERE Username = p_username AND UserType = p_user_type;
END$$
DELIMITER ;

-- Процедура для обновления пароля пользователя
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS UpdateUserPassword(IN p_hashed_password VARCHAR(255), IN p_user_id INT)
BEGIN
    UPDATE User
    SET Password = p_hashed_password
    WHERE ID = p_user_id;
END$$
DELIMITER ;

-- Процедура для получения информации о солдате
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetSoldierInfo(IN p_user_id INT)
BEGIN
    SELECT s.Name, r.Name AS `Rank`, u.Name AS Unit, o.Name AS Commander
    FROM Soldier s
    JOIN `Rank` r ON s.RankID = r.ID
    JOIN Unit u ON s.UnitID = u.ID
    JOIN Officer o ON u.CommanderID = o.ID
    WHERE s.UserID = p_user_id;
END$$
DELIMITER ;

-- Процедура для получения специальностей солдата
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetSoldierSpecialties(IN p_user_id INT)
BEGIN
    SELECT ms.Name
    FROM SoldierSpecialties ss
    JOIN MilitarySpecialties ms ON ss.SpecialityID = ms.ID
    WHERE ss.SoldierID = (
        SELECT ID FROM Soldier WHERE UserID = p_user_id
    );
END$$
DELIMITER ;

-- Процедура для получения информации об офицере
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetOfficerInfo(IN p_user_id INT)
BEGIN
    SELECT o.Name, r.Name AS `Rank`
    FROM Officer o
    JOIN `Rank` r ON o.RankID = r.ID
    WHERE o.UserID = p_user_id;
END$$
DELIMITER ;

-- Процедура для получения специальностей офицера
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetOfficerSpecialties(IN p_user_id INT)
BEGIN
    SELECT ms.Name
    FROM OfficerSpecialties os
    JOIN MilitarySpecialties ms ON os.SpecialityID = ms.ID
    WHERE os.OfficerID = (
        SELECT ID FROM Officer WHERE UserID = p_user_id
    );
END$$
DELIMITER ;

-- Процедура для получения информации о подразделении
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetUnitInfo(IN p_user_id INT)
BEGIN
    SELECT u.Name, o.Name AS Commander, d.Name AS Division, a.Name AS Army, u.ID, u.SoldierCount, u.TotalWeaponry
    FROM Unit u
    JOIN Officer o ON u.CommanderID = o.ID
    JOIN Division d ON u.DivisionID = d.ID
    JOIN Army a ON d.ArmyID = a.ID
    WHERE o.UserID = p_user_id;
END$$
DELIMITER ;

-- Процедура для получения солдат в подразделении
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetSoldiersInUnit(IN p_unit_id INT)
BEGIN
    SELECT s.ID, s.Name, r.Name AS `Rank`
    FROM Soldier s
    JOIN `Rank` r ON s.RankID = r.ID
    WHERE s.UnitID = p_unit_id;
END$$
DELIMITER ;

-- Процедура для получения сводки по специальностям в подразделении
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetSpecialtySummaryForUnit(IN p_unit_id INT)
BEGIN
    SELECT ms.Name, COUNT(*) AS count
    FROM SoldierSpecialties ss
    JOIN MilitarySpecialties ms ON ss.SpecialityID = ms.ID
    JOIN Soldier s ON ss.SoldierID = s.ID
    WHERE s.UnitID = p_unit_id
    GROUP BY ms.Name;
END$$
DELIMITER ;

-- Процедура для получения информации о дивизии
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetDivisionInfo(IN p_user_id INT)
BEGIN
    SELECT d.Name, o.Name AS Commander, a.Name AS Army, l.Name AS Location, d.ID, d.SoldierCount, d.TotalWeaponry
    FROM Division d
    JOIN Officer o ON d.CommanderID = o.ID
    JOIN Army a ON d.ArmyID = a.ID
    JOIN Location l ON d.LocationID = l.ID
    WHERE o.UserID = p_user_id;
END$$
DELIMITER ;

-- Процедура для получения подразделений в дивизии
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetUnitsInDivision(IN p_division_id INT)
BEGIN
    SELECT u.ID, u.Name
    FROM Unit u
    WHERE u.DivisionID = p_division_id;
END$$
DELIMITER ;

-- Процедура для получения информации об армии
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetArmyInfo(IN p_user_id INT)
BEGIN
    SELECT a.Name, o.Name AS Commander, a.ID, a.SoldierCount, a.TotalWeaponry
    FROM Army a
    JOIN Officer o ON a.CommanderID = o.ID
    WHERE o.UserID = p_user_id;
END$$
DELIMITER ;

-- Процедура для получения дивизий в армии
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetDivisionsInArmy(IN p_army_id INT)
BEGIN
    SELECT d.ID, d.Name
    FROM Division d
    WHERE d.ArmyID = p_army_id;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetCommandedUnitInfo(
    IN unit_id INT,
    IN user_id INT
)
BEGIN
    SELECT
        u.Name AS UnitName,
        o1.Name AS UnitCommander,
        d.Name AS DivisionName,
        a.Name AS ArmyName,
        u.ID AS UnitID,
        u.SoldierCount,
        u.TotalWeaponry
    FROM Unit u
    JOIN Division d ON u.DivisionID = d.ID
    JOIN Army a ON d.ArmyID = a.ID
    JOIN Officer o1 ON u.CommanderID = o1.ID
    JOIN Officer o2 ON d.CommanderID = o2.ID
    JOIN Officer o3 ON a.CommanderID = o3.ID
    WHERE u.ID = unit_id AND (o1.UserID = user_id OR o2.UserID = user_id OR o3.UserID = user_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetCommandedDivisionInfo(
    IN division_id INT,
    IN user_id INT
)
BEGIN
    SELECT d.Name, o1.Name, a.Name, l.Name, d.ID, d.SoldierCount, d.TotalWeaponry
        FROM Division d
        JOIN Army a ON d.ArmyID = a.ID
        JOIN Location l ON d.LocationID = l.ID
        JOIN Officer o1 ON d.CommanderID = o1.ID
        JOIN Officer o2 ON a.CommanderID = o2.ID
    WHERE d.ID = division_id AND (o1.UserID = user_id OR o2.UserID = user_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS CheckOfficerCommandingSoldier(
    IN soldier_id INT,
    IN user_id INT
)
BEGIN
    SELECT
        s.Name AS SoldierName,
        r.Name AS RankName,
        u.Name AS UnitName,
        o1.Name AS UnitCommander
    FROM Soldier s
    JOIN `Rank` r ON s.RankID = r.ID
    JOIN Unit u ON s.UnitID = u.ID
    JOIN Division d ON d.ID = u.DivisionID
    JOIN Army a ON a.ID = d.ArmyID
    JOIN Officer o1 ON u.CommanderID = o1.ID
    JOIN Officer o2 ON d.CommanderID = o2.ID
    JOIN Officer o3 ON a.CommanderID = o3.ID
    WHERE s.ID = soldier_id AND (o1.UserID = user_id OR o2.UserID = user_id OR o3.UserID = user_id);
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetUnits()
BEGIN
    SELECT
        u.ID AS UnitID,
        u.Name AS UnitName,
        d.Name AS DivisionName,
        a.Name AS ArmyName,
        o.Name AS OfficerName
    FROM Unit u
    LEFT JOIN Division d ON u.DivisionID = d.ID
    LEFT JOIN Army a ON d.ArmyID = a.ID
    LEFT JOIN Officer o ON u.CommanderID = o.ID;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetDivisions()
BEGIN
    SELECT d.ID, d.Name, a.Name, o.Name, l.Name
        FROM Division d
        LEFT JOIN Army a ON d.ArmyID = a.ID
        LEFT JOIN Officer o ON d.CommanderID = o.ID
        LEFT JOIN Location l on l.ID = d.LocationID;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetSoldiers()
BEGIN
    SELECT Soldier.ID, Soldier.Name, `Rank`.Name, Unit.Name, User.Username
        FROM Soldier
        JOIN `Rank` ON Soldier.RankID = `Rank`.ID
        LEFT JOIN Unit ON Soldier.UnitID = Unit.ID
        LEFT JOIN User ON Soldier.UserID = User.ID;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS GetOfficers()
BEGIN
SELECT Officer.ID, Officer.Name, `Rank`.Name, User.Username
        FROM Officer
        JOIN `Rank` ON Officer.RankID = `Rank`.ID
        LEFT JOIN User ON Officer.UserID = User.ID;
END$$
DELIMITER ;