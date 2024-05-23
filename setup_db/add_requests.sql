CREATE TABLE Request (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    UserType ENUM('soldier', 'officer') NOT NULL,
    RequestType ENUM('add_speciality', 'add_soldier', 'promote_to_officer', 'add_weaponry') NOT NULL,
    RequestDetails JSON NOT NULL,
    Status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(ID)
);