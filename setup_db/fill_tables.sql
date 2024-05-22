-- Заполнение таблицы User 20 пользователями для солдат
INSERT INTO User (Username, Password, UserType) VALUES
('soldier1', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier2', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier3', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier4', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier5', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier6', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier7', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier8', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier9', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier10', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier11', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier12', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier13', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier14', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier15', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier16', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier17', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier18', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier19', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier'),
('soldier20', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'soldier');

-- Заполнение таблицы User 7 пользователями для офицеров
INSERT INTO User (Username, Password, UserType) VALUES
('officer1', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer'),
('officer2', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer'),
('officer3', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer'),
('officer4', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer'),
('officer5', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer'),
('officer6', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer'),
('officer7', '$2b$12$D60A78Pg6DTnUE9DKsukdOCisqszEnerPIByarZClmpWLQiK8J1Ti', 'officer');


-- Заполнение таблицы Звания
INSERT INTO `Rank` (Name) VALUES
('Майор'),
('Капитан'),
('Подполковник'),
('Полковник'),
('Рядовой'),
('Ефрейтор'),
('Сержант'),
('Младший сержант'),
('Старший сержант'),
('Старшина');

-- Заполнение таблицы Офицеры
INSERT INTO Officer (Name, RankID, Date_of_Commission, UserID) VALUES
('Иванов И.И.', 1, '2023-01-01', 21),
('Петров П.П.', 2, '2022-05-15', 22),
('Сидоров С.С.', 3, '2024-03-10', 23),
('Козлов К.К.', 4, '2023-09-20', 24),
('Смирнов С.С.', 5, '2022-12-05', 25),
('Морозов М.М.', 3, '2023-07-18', 26),
('Николаев Н.Н.', 2, '2024-02-28', 27);

-- Заполнение таблицы Виды вооружений
INSERT INTO WeaponryType (Name) VALUES
('Автомат'),
('Пистолет'),
('Пулемет'),
('Гранатомет');

-- Заполнение таблицы Вооружение
INSERT INTO Weaponry (WeaponryTypeID, Model) VALUES
(1, 'AK-47'),
(2, 'ПМ'),
(3, 'ПКМ'),
(4, 'РПГ-7');

INSERT INTO Army (Name, CommanderID) VALUES ('Первая армия', 1);

-- Заполнение таблицы Локации
INSERT INTO Location (Name) VALUES
('База 1'),
('База 2'),
('Полигон 1'),
('Полигон 2'),
('Тренировочное поле');

-- Заполнение таблицы Дивизия
INSERT INTO Division (Name, CommanderID, ArmyID, LocationID) VALUES
('Первая дивизия', 2, 1, 1),
('Вторая дивизия', 3, 1, 2);

-- Заполнение таблицы Части
INSERT INTO Unit (Name, CommanderID, DivisionID) VALUES
('1-я часть', 4, 1),
('2-я часть', 5, 2),
('3-я часть', 6, 1),
('4-я часть', 7, 2);

INSERT INTO WeaponryInUnit (UnitID, WeaponryID, Quantity) VALUES
(1, 1, 20),
(2, 2, 15),
(3, 3, 10),
(4, 4, 5);

-- Заполнение таблицы Рядовые
INSERT INTO Soldier (Name, RankID, UnitID, UserID) VALUES
('Смирнов Алексей Иванович', 5, 1, 1),
('Кузнецов Дмитрий Александрович', 6, 1, 2),
('Иванов Андрей Петрович', 7, 1, 3),
('Соколов Сергей Алексеевич', 8, 1, 4),
('Попов Александр Владимирович', 9, 2, 5),
('Алексеев Денис Васильевич', 10, 2, 6),
('Лебедев Артем Викторович', 5, 2, 7),
('Семенов Владимир Андреевич', 6, 2, 8),
('Егоров Максим Александрович', 7, 3, 9),
('Павлов Илья Алексеевич', 8, 3, 10),
('Козлов Владислав Дмитриевич', 9, 3, 11),
('Новиков Никита Михайлович', 10, 3, 12),
('Морозов Артем Евгеньевич', 5, 4, 13),
('Волков Даниил Андреевич', 6, 4, 14),
('Александров Алексей Дмитриевич', 7, 4, 15),
('Смирнов Артем Сергеевич', 8, 4, 16),
('Марков Артем Владимирович', 9, 4, 17),
('Андреев Илья Викторович', 10, 4, 18),
('Попов Артем Николаевич', 5, 4, 19),
('Сорокин Артем Сергеевич', 6, 4, 20);

INSERT INTO MilitarySpecialties (Name) VALUES
('Снайпер'),
('Медик'),
('Инженер'),
('Штурман'),
('Моторист');

INSERT INTO OfficerSpecialties (OfficerID, SpecialityID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 1),
(7, 2);

INSERT INTO SoldierSpecialties (SoldierID, SpecialityID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 1),
(7, 2),
(8, 3),
(9, 4),
(10, 5),
(11, 1),
(12, 2),
(13, 3),
(14, 4),
(15, 5),
(16, 1),
(17, 2),
(18, 3),
(19, 4),
(20, 5);

INSERT INTO User (Username, Password, UserType) VALUES ('admin', '$2b$12$uoCb8hte4iKVU93WGykQnuTWwwUf2lYVYYr9X2Me1CvqHyL9Q0eJy', 'admin');