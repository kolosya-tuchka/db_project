CREATE DATABASE IF NOT EXISTS military;

USE military;

CREATE TABLE `Rank` (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Officer (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    RankID INT,
    Date_of_Commission DATE,
    FOREIGN KEY (RankID) REFERENCES `Rank`(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Location (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS Army (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    CommanderID INT,
    FOREIGN KEY (CommanderID) REFERENCES Officer(ID) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS Division (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    CommanderID INT,
    ArmyID INT,
    LocationID INT,
    FOREIGN KEY (CommanderID) REFERENCES Officer(ID) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (ArmyID) REFERENCES Army(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (LocationID) REFERENCES Location(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Unit (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    CommanderID INT,
    DivisionID INT,
    FOREIGN KEY (CommanderID) REFERENCES Officer(ID) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (DivisionID) REFERENCES Division(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Soldier (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255),
    RankID INT,
    UnitID INT,
    FOREIGN KEY (RankID) REFERENCES `Rank`(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (UnitID) REFERENCES Unit(ID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE WeaponryType (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Weaponry (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    WeaponryTypeID INT,
    Model VARCHAR(255),
    FOREIGN KEY (WeaponryTypeID) REFERENCES WeaponryType(ID) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS WeaponryInUnit (
    UnitID INT,
    WeaponryID INT,
    Quantity INT NOT NULL,
    PRIMARY KEY (UnitID, WeaponryID),
    FOREIGN KEY (UnitID) REFERENCES Unit(ID) ON UPDATE CASCADE,
    FOREIGN KEY (WeaponryID) REFERENCES Weaponry(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MilitarySpecialties (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS SoldierSpecialties (
    SoldierID INT,
    SpecialityID INT,
    PRIMARY KEY (SoldierID, SpecialityID),
    FOREIGN KEY (SoldierID) REFERENCES Soldier(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (SpecialityID) REFERENCES MilitarySpecialties(ID) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS OfficerSpecialties (
    OfficerID INT,
    SpecialityID INT,
    PRIMARY KEY (OfficerID, SpecialityID),
    FOREIGN KEY (OfficerID) REFERENCES Officer(ID) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (SpecialityID) REFERENCES MilitarySpecialties(ID) ON UPDATE CASCADE ON DELETE CASCADE
);