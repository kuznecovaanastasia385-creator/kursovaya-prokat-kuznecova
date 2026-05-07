CREATE DATABASE Prokat;
USE Prokat;

-- 1. Роли
CREATE TABLE [Role] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL UNIQUE
);

-- 2. Пользователи (общая аутентификация)
CREATE TABLE [User] (
    Id INT PRIMARY KEY IDENTITY,
    [Role] INT NOT NULL FOREIGN KEY REFERENCES [Role](Id),
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NULL,
    [Login] NVARCHAR(50) NOT NULL UNIQUE,
    [Password] NVARCHAR(50) NOT NULL
);

-- 3. Клиент (доп. контактные данные, привязан к пользователю)
CREATE TABLE [Client] (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES [User](Id),
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NULL,
    Phone NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    [Address] NVARCHAR(200) NULL
);

-- 4. Сотрудник (только для администраторов)
CREATE TABLE [Employee] (
    Id INT PRIMARY KEY IDENTITY,
    UserId INT NOT NULL UNIQUE FOREIGN KEY REFERENCES [User](Id),
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50) NULL,
    Position NVARCHAR(100) NULL,
    HireDate DATE NULL
);

-- 5. Банковский счёт (привязан к сотруднику)
CREATE TABLE [BankAccount] (
    Id INT PRIMARY KEY IDENTITY,
    Bank NVARCHAR(100) NOT NULL,
    AccountNumber NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) NULL,
    EmployeeId INT NOT NULL FOREIGN KEY REFERENCES [Employee](Id)
);

-- 6. Типы контента
CREATE TABLE [ContentType] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL
);

-- 7. Возрастной рейтинг
CREATE TABLE [AgeRating] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL
);

-- 8. Жанр
CREATE TABLE [Genre] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL
);

-- 9. Актер
CREATE TABLE [Actor] (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    MiddleName NVARCHAR(100) NULL
);

-- 10. Режиссер
CREATE TABLE [Director] (
    Id INT PRIMARY KEY IDENTITY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    MiddleName NVARCHAR(100) NULL
);

-- 11. Издатель (для игр)
CREATE TABLE [Publisher] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(200) NOT NULL
);

-- 12. Разработчик (для игр)
CREATE TABLE [Developer] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(200) NOT NULL
);

-- 13. Платформа (PC, PlayStation, Xbox...)
CREATE TABLE [Platform] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL
);

-- 14. Тип носителя (DVD, Blu-ray, цифра...)
CREATE TABLE [MediaType] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL
);

-- 15. Статус аренды
CREATE TABLE [RentalStatus] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL
);

-- 16. Способ оплаты
CREATE TABLE [PaymentMethod] (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(100) NOT NULL
);

-- ====================================================
-- ОСНОВНАЯ ТАБЛИЦА КОНТЕНТА (с ценой и фото)
-- ====================================================
CREATE TABLE [Content] (
    Id INT PRIMARY KEY IDENTITY,
    Title NVARCHAR(200) NOT NULL,
    ReleaseYear INT NULL,
    AgeRatingId INT NULL FOREIGN KEY REFERENCES [AgeRating](Id),
    ContentTypeId INT NOT NULL FOREIGN KEY REFERENCES [ContentType](Id),
    DurationMinutes INT NULL,
    QuantityCopies INT NOT NULL DEFAULT 1,
    Price DECIMAL(10,2) NOT NULL DEFAULT 100.00,   -- цена за 1 день аренды
    ImageData VARBINARY(MAX) NULL                  -- фото в байтах
);

-- ====================================================
-- СВЯЗИ (многие-ко-многим)
-- ====================================================
CREATE TABLE [ContentGenre] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    GenreId INT NOT NULL FOREIGN KEY REFERENCES [Genre](Id),
    PRIMARY KEY (ContentId, GenreId)
);

CREATE TABLE [ContentActor] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    ActorId INT NOT NULL FOREIGN KEY REFERENCES [Actor](Id),
    PRIMARY KEY (ContentId, ActorId)
);

CREATE TABLE [ContentDirector] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    DirectorId INT NOT NULL FOREIGN KEY REFERENCES [Director](Id),
    PRIMARY KEY (ContentId, DirectorId)
);

CREATE TABLE [GamePublisher] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    PublisherId INT NOT NULL FOREIGN KEY REFERENCES [Publisher](Id),
    PRIMARY KEY (ContentId, PublisherId)
);

CREATE TABLE [GameDeveloper] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    DeveloperId INT NOT NULL FOREIGN KEY REFERENCES [Developer](Id),
    PRIMARY KEY (ContentId, DeveloperId)
);

CREATE TABLE [GamePlatform] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    PlatformId INT NOT NULL FOREIGN KEY REFERENCES [Platform](Id),
    PRIMARY KEY (ContentId, PlatformId)
);

CREATE TABLE [ContentMedia] (
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    MediaTypeId INT NOT NULL FOREIGN KEY REFERENCES [MediaType](Id),
    PRIMARY KEY (ContentId, MediaTypeId)
);

CREATE TABLE [Rental] (
    Id INT PRIMARY KEY IDENTITY,
    ClientId INT NOT NULL FOREIGN KEY REFERENCES [Client](Id),
    EmployeeId INT NULL FOREIGN KEY REFERENCES [Employee](Id),
    RentalDate DATE NOT NULL DEFAULT GETDATE(),
    ExpectedReturnDate DATE NOT NULL,
    ActualReturnDate DATE NULL,
    [Discount] DECIMAL(5,2) NULL DEFAULT 0,
    TotalAmount DECIMAL(10,2) NOT NULL,
    StatusId INT NOT NULL FOREIGN KEY REFERENCES [RentalStatus](Id)
);

CREATE TABLE [RentalItem] (
    Id INT PRIMARY KEY IDENTITY,
    RentalId INT NOT NULL FOREIGN KEY REFERENCES [Rental](Id),
    ContentId INT NOT NULL FOREIGN KEY REFERENCES [Content](Id),
    CopyNumber INT NOT NULL DEFAULT 1
);

CREATE TABLE [Payment] (
    Id INT PRIMARY KEY IDENTITY,
    RentalId INT NOT NULL FOREIGN KEY REFERENCES [Rental](Id),
    PaymentMethodId INT NOT NULL FOREIGN KEY REFERENCES [PaymentMethod](Id),
    PaymentDate DATE NOT NULL DEFAULT GETDATE(),
    Amount DECIMAL(10,2) NOT NULL,
    Purpose NVARCHAR(MAX) NULL
);

-- Роли
INSERT INTO [Role] ([Name]) VALUES ('Администратор'), ('Пользователь');

-- Пользователи
INSERT INTO [User] ([Role], LastName, FirstName, MiddleName, [Login], [Password]) VALUES 
(1, 'Иванов', 'Админ', 'Петрович', 'admin', 'admin123'),
(2, 'Петрова', 'Мария', 'Ивановна', 'masha', 'qwerty'),
(2, 'Сидоров', 'Алексей', 'Владимирович', 'lesha', '123456');

-- Клиенты (только для пользователей)
INSERT INTO [Client] (UserId, LastName, FirstName, MiddleName, Phone, Email, [Address]) VALUES 
(2, 'Петрова', 'Мария', 'Ивановна', '+7 912 345-67-89', 'masha@example.com', 'г. Москва, ул. Ленина, 15'),
(3, 'Сидоров', 'Алексей', 'Владимирович', '+7 903 123-45-67', 'lesha@example.com', 'г. Москва, ул. Пушкина, 7');

-- Сотрудник (администратор)
INSERT INTO [Employee] (UserId, LastName, FirstName, MiddleName, [Position], HireDate) VALUES 
(1, 'Иванов', 'Админ', 'Петрович', 'Директор проката', '2023-01-15');

-- Банковский счёт
INSERT INTO [BankAccount] (Bank, AccountNumber, Status, EmployeeId) VALUES 
('Сбербанк', '40817810123456789012', 'Активен', 1);

-- Справочники
INSERT INTO [ContentType] ([Name]) VALUES ('Фильм'), ('Игра');
INSERT INTO [AgeRating] ([Name]) VALUES ('0+'), ('6+'), ('12+'), ('16+'), ('18+');
INSERT INTO [Genre] ([Name]) VALUES ('Боевик'), ('Комедия'), ('Драма'), ('Фантастика'), ('Спорт'), ('Приключения');
INSERT INTO [Actor] (FirstName, LastName, MiddleName) VALUES 
('Иван', 'Иванов', 'Алексеевич'),
('Петр', 'Петров', 'Сергеевич'),
('Анна', 'Сидорова', 'Викторовна');
INSERT INTO [Director] (FirstName, LastName, MiddleName) VALUES 
('Сергей', 'Бондарчук', 'Фёдорович'),
('Алексей', 'Балабанов', 'Олегович');
INSERT INTO [Publisher] ([Name]) VALUES ('Electronic Arts'), ('Ubisoft'), ('Microsoft Studios');
INSERT INTO [Developer] ([Name]) VALUES ('DICE'), ('Ubisoft Montreal'), ('343 Industries');
INSERT INTO [Platform] ([Name]) VALUES ('PC'), ('PlayStation 5'), ('Xbox Series X'), ('Nintendo Switch');
INSERT INTO [MediaType] ([Name]) VALUES ('DVD'), ('Blu-ray'), ('Цифровая копия');
INSERT INTO [RentalStatus] ([Name]) VALUES ('Активна'), ('Просрочена'), ('Возвращена'), ('Отменена');
INSERT INTO [PaymentMethod] ([Name]) VALUES ('Наличные'), ('Банковская карта'), ('Электронные деньги (PayPal)');

-- Контент (фильмы и игры) с ценами
INSERT INTO [Content] (Title, ReleaseYear, AgeRatingId, ContentTypeId, DurationMinutes, QuantityCopies, Price, ImageData) VALUES 
('Зеленая миля', 1999, (SELECT Id FROM [AgeRating] WHERE [Name]='16+'), 1, 189, 2, 150.00, NULL),
('Начало', 2010, (SELECT Id FROM [AgeRating] WHERE [Name]='12+'), 1, 148, 3, 180.00, NULL),
('Матрица', 1999, (SELECT Id FROM [AgeRating] WHERE [Name]='16+'), 1, 136, 1, 200.00, NULL),
('Форсаж 9', 2021, (SELECT Id FROM [AgeRating] WHERE [Name]='12+'), 1, 145, 2, 170.00, NULL),
('FIFA 24', 2023, (SELECT Id FROM [AgeRating] WHERE [Name]='0+'), 2, NULL, 5, 250.00, NULL),
('Cyberpunk 2077', 2020, (SELECT Id FROM [AgeRating] WHERE [Name]='18+'), 2, NULL, 3, 300.00, NULL),
('Halo Infinite', 2021, (SELECT Id FROM [AgeRating] WHERE [Name]='16+'), 2, NULL, 2, 280.00, NULL);

-- Связи контента с жанрами
INSERT INTO [ContentGenre] (ContentId, GenreId) VALUES 
(1, (SELECT Id FROM [Genre] WHERE [Name]='Драма')),
(2, (SELECT Id FROM [Genre] WHERE [Name]='Фантастика')),
(3, (SELECT Id FROM [Genre] WHERE [Name]='Фантастика')),
(3, (SELECT Id FROM [Genre] WHERE [Name]='Боевик')),
(4, (SELECT Id FROM [Genre] WHERE [Name]='Боевик')),
(5, (SELECT Id FROM [Genre] WHERE [Name]='Спорт')),
(6, (SELECT Id FROM [Genre] WHERE [Name]='Фантастика')),
(6, (SELECT Id FROM [Genre] WHERE [Name]='Приключения')),
(7, (SELECT Id FROM [Genre] WHERE [Name]='Боевик'));

-- Связи контента с актерами (фильмы)
INSERT INTO [ContentActor] (ContentId, ActorId) VALUES 
(1,1), (1,2), (2,3), (3,1), (3,2);

-- Связи контента с режиссёрами (фильмы)
INSERT INTO [ContentDirector] (ContentId, DirectorId) VALUES 
(1,1), (2,2), (3,2);

-- Связи игр с издателями
INSERT INTO [GamePublisher] (ContentId, PublisherId) VALUES 
(5,(SELECT Id FROM [Publisher] WHERE [Name]='Electronic Arts')),
(6,(SELECT Id FROM [Publisher] WHERE [Name]='Microsoft Studios')),
(7,(SELECT Id FROM [Publisher] WHERE [Name]='Microsoft Studios'));

-- Связи игр с разработчиками
INSERT INTO [GameDeveloper] (ContentId, DeveloperId) VALUES 
(5,(SELECT Id FROM [Developer] WHERE [Name]='DICE')),
(6,(SELECT Id FROM [Developer] WHERE [Name]='Ubisoft Montreal')),
(7,(SELECT Id FROM [Developer] WHERE [Name]='343 Industries'));

-- Связи игр с платформами
INSERT INTO [GamePlatform] (ContentId, PlatformId) VALUES 
(5,(SELECT Id FROM [Platform] WHERE [Name]='PC')),
(5,(SELECT Id FROM [Platform] WHERE [Name]='PlayStation 5')),
(6,(SELECT Id FROM [Platform] WHERE [Name]='PC')),
(6,(SELECT Id FROM [Platform] WHERE [Name]='Xbox Series X')),
(7,(SELECT Id FROM [Platform] WHERE [Name]='Xbox Series X'));

-- Связи контента с носителями
INSERT INTO [ContentMedia] (ContentId, MediaTypeId) VALUES 
(1,(SELECT Id FROM [MediaType] WHERE [Name]='DVD')),
(2,(SELECT Id FROM [MediaType] WHERE [Name]='Blu-ray')),
(3,(SELECT Id FROM [MediaType] WHERE [Name]='Blu-ray')),
(4,(SELECT Id FROM [MediaType] WHERE [Name]='DVD')),
(5,(SELECT Id FROM [MediaType] WHERE [Name]='Цифровая копия')),
(6,(SELECT Id FROM [MediaType] WHERE [Name]='Цифровая копия')),
(7,(SELECT Id FROM [MediaType] WHERE [Name]='Цифровая копия'));

-- Аренды
INSERT INTO [Rental] (ClientId, EmployeeId, RentalDate, ExpectedReturnDate, ActualReturnDate, Discount, TotalAmount, StatusId) VALUES 
(1, 1, '2025-01-20', '2025-01-27', NULL, 0, 350.00, (SELECT Id FROM [RentalStatus] WHERE [Name]='Активна')),
(2, 1, '2025-01-15', '2025-01-18', '2025-01-18', 10, 540.00, (SELECT Id FROM [RentalStatus] WHERE [Name]='Возвращена')),
(1, 1, '2025-01-22', '2025-01-29', NULL, 5, 475.00, (SELECT Id FROM [RentalStatus] WHERE [Name]='Активна')),
(2, 1, '2025-01-10', '2025-01-17', NULL, 0, 800.00, (SELECT Id FROM [RentalStatus] WHERE [Name]='Просрочена'));

INSERT INTO [RentalItem] (RentalId, ContentId, CopyNumber) VALUES 
(1,2,1), (2,7,1), (3,5,1), (3,5,2), (4,6,1);

-- Платежи
INSERT INTO [Payment] (RentalId, PaymentMethodId, PaymentDate, Amount, Purpose) VALUES 
(1, (SELECT Id FROM [PaymentMethod] WHERE [Name]='Банковская карта'), '2025-01-20', 350.00, 'Оплата аренды (Начало)'),
(2, (SELECT Id FROM [PaymentMethod] WHERE [Name]='Электронные деньги (PayPal)'), '2025-01-15', 540.00, 'Аренда Halo Infinite'),
(3, (SELECT Id FROM [PaymentMethod] WHERE [Name]='Наличные'), '2025-01-22', 475.00, 'Аренда двух копий FIFA 24'),
(4, (SELECT Id FROM [PaymentMethod] WHERE [Name]='Банковская карта'), '2025-01-10', 800.00, 'Аренда Cyberpunk 2077');