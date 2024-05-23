-- Создание таблицы User
CREATE TABLE IF NOT EXISTS User (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(255) NOT NULL UNIQUE,
    Password VARCHAR(255) NOT NULL,
    UserType ENUM('admin', 'officer', 'soldier') NOT NULL
);

-- Добавление поля UserID в таблицу Officer
ALTER TABLE Officer ADD COLUMN UserID INT;

-- Добавление поля UserID в таблицу Soldier
ALTER TABLE Soldier ADD COLUMN UserID INT;

-- Установка внешнего ключа для UserID в таблице Officer
ALTER TABLE Officer ADD CONSTRAINT FK_User_Officer FOREIGN KEY (UserID) REFERENCES User(ID);

-- Установка внешнего ключа для UserID в таблице Soldier
ALTER TABLE Soldier ADD CONSTRAINT FK_User_Soldier FOREIGN KEY (UserID) REFERENCES User(ID);