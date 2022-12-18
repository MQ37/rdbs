-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: db
-- Generation Time: Dec 18, 2022 at 03:22 PM
-- Server version: 10.3.34-MariaDB-1:10.3.34+maria~focal
-- PHP Version: 8.0.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `library`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `HledaniKnih` (IN `searchTerm` VARCHAR(128))   BEGIN
  SELECT *
  FROM Books
  WHERE MATCH(name) AGAINST(searchTerm);
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `PujcKnihu` (IN `shelfbookId` INT, IN `userId` INT)   BEGIN
  START TRANSACTION;

  SELECT COUNT(*)
  INTO @shelfbookExists
  FROM ShelfBooks
  WHERE shelfbook_id = shelfbookId;

  IF @shelfbookExists = 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Kniha neexistuje';
  END IF;

  SELECT COUNT(*)
  INTO @shelfbookBorrowed
  FROM Borrowings
  WHERE shelfbook_id = shelfbookId;

  IF @shelfbookBorrowed > 0 THEN
    ROLLBACK;
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Kniha už byla zapůjčena';
  END IF;

  INSERT INTO Borrowings (bor_id, user_id, shelfbook_id, borrowed_at)
  VALUES (NULL, userId, shelfbookId, CURRENT_TIMESTAMP());

  COMMIT;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `ZapujceneKnihy` ()   BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE vsb_id INT;
DECLARE vb_id INT;
DECLARE vnazev VARCHAR(128);

DECLARE cur CURSOR FOR SELECT shelfbook_id, book_id FROM ShelfBooks;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

CREATE TEMPORARY TABLE TempZapujcene (
shelfbook_id INT PRIMARY KEY,
nazev VARCHAR(128)
);

OPEN cur;

  read_loop: LOOP
    FETCH cur INTO vsb_id, vb_id;
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    IF (SELECT vsb_id IN (SELECT shelfbook_id FROM Borrowings WHERE returned = 0)) THEN
       SELECT NazevKnihy(vb_id) INTO vnazev;
       INSERT INTO TempZapujcene VALUES (vsb_id, vnazev);
    END IF;
    
  END LOOP;

  CLOSE cur;

  SELECT COUNT(*) AS "Zapůjčené knihy" FROM TempZapujcene;
  SELECT * FROM TempZapujcene;

END$$

--
-- Functions
--
CREATE DEFINER=`root`@`%` FUNCTION `NazevKnihy` (`b_id` INT) RETURNS VARCHAR(128) CHARSET utf8  RETURN
  (SELECT name FROM Books WHERE book_id=b_id)$$

CREATE DEFINER=`root`@`%` FUNCTION `PrumerneHodnoceniAutora` (`authorId` INT) RETURNS DECIMAL(10,2)  BEGIN
  RETURN (SELECT AVG(r.rating)
  FROM RatingsAuthors r
  WHERE r.author_id = authorId);
END$$

CREATE DEFINER=`root`@`%` FUNCTION `PrumerneHodnoceniKnihy` (`bookId` INT) RETURNS DECIMAL(10,2)  BEGIN
  RETURN (SELECT AVG(r.rating) FROM RatingsBooks AS r WHERE r.book_id = bookId);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `Authors`
--

CREATE TABLE `Authors` (
  `author_id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL,
  `born` smallint(6) NOT NULL,
  `died` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Authors`
--

INSERT INTO `Authors` (`author_id`, `name`, `born`, `died`) VALUES
(1, 'J. R. R. Tolkien', 1892, 1973),
(2, 'George Orwell', 1903, 1950),
(3, 'Karel Čapek', 1890, 1938),
(4, 'Stephen King', 1947, NULL),
(5, 'Karel Hynek Mácha', 1810, 1836),
(6, 'Božena Němcová', 1820, 1862),
(7, 'Ernest Hemingway', 1899, 1961),
(8, 'Jack London', 1876, 1916),
(9, 'Jan Werich', 1905, 1980),
(10, 'Charles Dickens', 1812, 1870),
(11, 'Halina Pawlowská', 1955, NULL),
(12, 'Alois Jirásek', 1851, 1930),
(13, 'Ota Pavel', 1930, 1973),
(14, 'Jan Amos Komenský', 1592, 1670),
(15, 'Zdeněk Svěrák', 1936, NULL),
(16, 'Victor Hugo', 1802, 1885),
(17, 'Carl Gustav Jung', 1875, 1961),
(18, 'Karel Poláček', 1892, 1945),
(19, 'Jan Neruda', 1834, 1891),
(20, 'Karel Havlíček Borovský', 1821, 1856),
(21, 'Erich Maria Remarque', 1898, 1970),
(22, 'Jaroslav Hašek', 1883, 1923);

-- --------------------------------------------------------

--
-- Table structure for table `Books`
--

CREATE TABLE `Books` (
  `book_id` int(11) NOT NULL,
  `lang_id` int(11) NOT NULL,
  `name` varchar(128) NOT NULL,
  `released` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Books`
--

INSERT INTO `Books` (`book_id`, `lang_id`, `name`, `released`) VALUES
(1, 1, 'Bílá nemoc', NULL),
(2, 1, 'Pán prstenů: Společenstvo Prstenu', NULL),
(3, 1, 'Pán prstenů: Dvě věže', NULL),
(4, 1, 'Pán prstenů: Návrat krále', NULL),
(5, 1, 'Hobit', NULL),
(6, 1, 'Húrinovy děti', NULL),
(7, 1, 'To', NULL),
(8, 1, 'Carrie', NULL),
(9, 1, 'Máj', NULL),
(10, 1, 'Babička', NULL),
(11, 1, 'Komu zvoní hrana', NULL),
(12, 1, 'Stařec a moře', NULL),
(13, 1, 'Bílý tesák', NULL),
(14, 1, 'Fimfárum', NULL),
(15, 1, 'Oliver Twist', NULL),
(16, 1, 'Zážitky z karantény', NULL),
(17, 1, 'Staré pověsti české', NULL),
(18, 1, 'Smrt krásných srnců', NULL),
(19, 1, 'Štěstí národa', NULL),
(20, 1, 'Kolja', NULL),
(21, 1, 'Chrám Matky Boží v Paříži', NULL),
(22, 1, 'Červená kniha', NULL),
(23, 1, 'Bylo nás pět', NULL),
(24, 1, 'Povídky malostranské', NULL),
(25, 1, 'Král Lávra', NULL),
(26, 1, 'Na západní frontě klid', NULL),
(27, 1, 'Osudy dobrého vojáka Švejka za světové války', NULL),
(28, 1, '1984', NULL),
(29, 1, 'Farma zvířat', NULL),
(30, 1, 'Moje kniha', NULL),
(32, 1, 'Pán prstenů Vol. X', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `BooksAuthors`
--

CREATE TABLE `BooksAuthors` (
  `author_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `BooksAuthors`
--

INSERT INTO `BooksAuthors` (`author_id`, `book_id`) VALUES
(3, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(4, 7),
(4, 8),
(5, 9),
(6, 10),
(7, 11),
(7, 12),
(8, 13),
(9, 14),
(10, 15),
(11, 16),
(12, 17),
(13, 18),
(14, 19),
(15, 20),
(16, 21),
(17, 22),
(18, 23),
(19, 24),
(20, 25),
(21, 26),
(22, 27),
(2, 28),
(2, 29),
(1, 32);

-- --------------------------------------------------------

--
-- Table structure for table `BooksGenres`
--

CREATE TABLE `BooksGenres` (
  `book_id` int(11) NOT NULL,
  `genre_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `BooksGenres`
--

INSERT INTO `BooksGenres` (`book_id`, `genre_id`) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 3),
(4, 3),
(5, 3),
(7, 4),
(8, 4),
(9, 5),
(16, 6),
(15, 8),
(21, 9),
(15, 9),
(23, 10),
(22, 11),
(10, 12),
(12, 9),
(27, 9),
(26, 9),
(25, 13),
(25, 5),
(28, 9),
(28, 8),
(28, 14),
(29, 9),
(29, 15);

-- --------------------------------------------------------

--
-- Table structure for table `Borrowings`
--

CREATE TABLE `Borrowings` (
  `bor_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `shelfbook_id` int(11) NOT NULL,
  `borrowed_at` date NOT NULL DEFAULT current_timestamp(),
  `returned` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Borrowings`
--

INSERT INTO `Borrowings` (`bor_id`, `user_id`, `shelfbook_id`, `borrowed_at`, `returned`) VALUES
(1, 1, 1, '2022-06-13', 1),
(2, 2, 2, '2022-06-13', 0),
(3, 3, 3, '2022-06-13', 0),
(4, 4, 4, '2022-06-13', 0),
(5, 5, 5, '2022-06-13', 0),
(6, 6, 6, '2022-06-13', 0),
(7, 7, 7, '2022-06-13', 0),
(8, 8, 8, '2022-06-13', 0),
(9, 9, 9, '2022-06-13', 0),
(10, 10, 10, '2022-06-13', 0),
(11, 11, 11, '2022-06-13', 0),
(12, 12, 12, '2022-06-13', 0),
(13, 13, 13, '2022-06-13', 0),
(14, 14, 14, '2022-06-13', 0),
(15, 15, 15, '2022-06-13', 0),
(16, 16, 16, '2022-06-13', 0),
(17, 17, 17, '2022-06-13', 0),
(18, 18, 18, '2022-06-13', 0),
(19, 19, 19, '2022-06-13', 0),
(20, 20, 20, '2022-06-13', 0),
(21, 1, 25, '2022-12-08', 0),
(22, 1, 24, '2022-12-08', 1);

--
-- Triggers `Borrowings`
--
DELIMITER $$
CREATE TRIGGER `borrowings_borrowed` AFTER INSERT ON `Borrowings` FOR EACH ROW BEGIN

	IF NEW.returned = 0 THEN
    	INSERT INTO BorrowingsLog(bor_id, state) VALUES (NEW.bor_id, "borrowed");
    END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `borrowings_returned` AFTER UPDATE ON `Borrowings` FOR EACH ROW BEGIN

	IF NEW.returned = 1 THEN
    	INSERT INTO BorrowingsLog(bor_id, returned_at, state) VALUES (OLD.bor_id, NOW(), "returned");
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `BorrowingsLog`
--

CREATE TABLE `BorrowingsLog` (
  `id` int(11) NOT NULL,
  `bor_id` int(11) DEFAULT NULL,
  `returned_at` date DEFAULT NULL,
  `state` varchar(32) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `BorrowingsLog`
--

INSERT INTO `BorrowingsLog` (`id`, `bor_id`, `returned_at`, `state`) VALUES
(1, 1, '2022-11-26', 'returned'),
(2, 22, NULL, 'borrowed'),
(3, 22, '2022-12-08', 'returned');

-- --------------------------------------------------------

--
-- Table structure for table `Genres`
--

CREATE TABLE `Genres` (
  `genre_id` int(11) NOT NULL,
  `genre` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Genres`
--

INSERT INTO `Genres` (`genre_id`, `genre`) VALUES
(1, 'Drama'),
(2, 'Divadelní hra'),
(3, 'Fantasy'),
(4, 'Horror'),
(5, 'Poezie'),
(6, 'Fejeton'),
(7, 'Americká literatura'),
(8, 'Anglická literatura'),
(9, 'Román'),
(10, 'Komedie'),
(11, 'Psychologie'),
(12, 'Povídka'),
(13, 'Pověst'),
(14, 'Antiutopie/Dystopie'),
(15, 'Satira'),
(16, 'Sci-fi'),
(17, 'Detektivní'),
(18, 'Cestopis'),
(19, 'Komiks'),
(20, 'Western');

-- --------------------------------------------------------

--
-- Table structure for table `Languages`
--

CREATE TABLE `Languages` (
  `lang_id` int(11) NOT NULL,
  `lang` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Languages`
--

INSERT INTO `Languages` (`lang_id`, `lang`) VALUES
(1, 'Čeština');

-- --------------------------------------------------------

--
-- Table structure for table `RatingsAuthors`
--

CREATE TABLE `RatingsAuthors` (
  `user_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `rating` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `RatingsAuthors`
--

INSERT INTO `RatingsAuthors` (`user_id`, `author_id`, `rating`) VALUES
(1, 4, 2),
(1, 12, 5),
(1, 17, 3),
(2, 12, 8),
(2, 22, 0),
(3, 5, 1),
(3, 20, 9),
(4, 8, 3),
(4, 21, 9),
(5, 8, 7),
(5, 16, 6),
(6, 9, 0),
(6, 17, 9),
(7, 9, 0),
(7, 11, 4),
(8, 18, 8),
(8, 22, 9),
(9, 7, 1),
(9, 21, 0),
(10, 9, 7),
(10, 22, 2),
(11, 10, 2),
(11, 11, 7),
(12, 1, 9),
(12, 14, 1),
(13, 13, 3),
(13, 16, 7),
(14, 7, 3),
(14, 14, 5),
(15, 4, 5),
(15, 5, 2),
(16, 17, 3),
(17, 20, 3),
(18, 8, 8),
(18, 10, 0),
(19, 3, 8),
(19, 19, 8),
(20, 2, 3),
(20, 5, 6);

-- --------------------------------------------------------

--
-- Table structure for table `RatingsBooks`
--

CREATE TABLE `RatingsBooks` (
  `user_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `rating` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `RatingsBooks`
--

INSERT INTO `RatingsBooks` (`user_id`, `book_id`, `rating`) VALUES
(1, 13, 5),
(1, 20, 3),
(2, 17, 8),
(2, 29, 2),
(3, 24, 6),
(3, 26, 8),
(4, 23, 7),
(5, 21, 1),
(5, 22, 7),
(6, 10, 5),
(6, 20, 1),
(7, 5, 1),
(7, 11, 0),
(8, 7, 4),
(8, 12, 5),
(9, 16, 3),
(9, 17, 1),
(10, 1, 4),
(10, 26, 4),
(11, 22, 7),
(11, 25, 5),
(12, 20, 5),
(12, 23, 0),
(13, 7, 0),
(13, 18, 0),
(14, 15, 3),
(14, 29, 7),
(15, 7, 8),
(15, 14, 7),
(16, 7, 4),
(16, 19, 3),
(17, 17, 0),
(17, 24, 0),
(18, 19, 0),
(18, 23, 9),
(19, 19, 7),
(19, 24, 5),
(20, 3, 3),
(20, 5, 9);

-- --------------------------------------------------------

--
-- Table structure for table `ShelfBooks`
--

CREATE TABLE `ShelfBooks` (
  `shelfbook_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `stocked_at` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `ShelfBooks`
--

INSERT INTO `ShelfBooks` (`shelfbook_id`, `book_id`, `stocked_at`) VALUES
(1, 1, '2022-06-13'),
(2, 2, '2022-06-13'),
(3, 3, '2022-06-13'),
(4, 4, '2022-06-13'),
(5, 5, '2022-06-13'),
(6, 6, '2022-06-13'),
(7, 7, '2022-06-13'),
(8, 8, '2022-06-13'),
(9, 9, '2022-06-13'),
(10, 10, '2022-06-13'),
(11, 11, '2022-06-13'),
(12, 12, '2022-06-13'),
(13, 13, '2022-06-13'),
(14, 14, '2022-06-13'),
(15, 15, '2022-06-13'),
(16, 16, '2022-06-13'),
(17, 17, '2022-06-13'),
(18, 18, '2022-06-13'),
(19, 19, '2022-06-13'),
(20, 20, '2022-06-13'),
(21, 21, '2022-06-13'),
(22, 22, '2022-06-13'),
(23, 23, '2022-06-13'),
(24, 24, '2022-06-13'),
(25, 25, '2022-06-13'),
(26, 26, '2022-06-13'),
(27, 27, '2022-06-13'),
(28, 28, '2022-06-13'),
(29, 29, '2022-06-13');

-- --------------------------------------------------------

--
-- Table structure for table `Users`
--

CREATE TABLE `Users` (
  `user_id` int(11) NOT NULL,
  `first_name` varchar(32) NOT NULL,
  `last_name` varchar(32) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `Users`
--

INSERT INTO `Users` (`user_id`, `first_name`, `last_name`, `created_at`) VALUES
(1, 'Tonda', 'Vomáčka', '2022-06-12 10:47:56'),
(2, 'Lojza', 'Truhlík', '2022-06-12 10:48:09'),
(3, 'John', 'Doe', '2022-06-13 17:22:24'),
(4, 'Do', 'Kwon', '2022-06-13 17:22:44'),
(5, 'Nataša', 'Novotná', '2022-06-13 17:23:32'),
(6, 'Radek', 'Černý', '2022-06-13 17:23:38'),
(7, 'Tomáš', 'Bobek', '2022-06-13 17:23:49'),
(8, 'Miluše', 'Nová', '2022-06-13 17:23:59'),
(9, 'Lubomír', 'Starý', '2022-06-13 17:24:07'),
(10, 'Diana', 'Šťastná', '2022-06-13 17:24:23'),
(11, 'Nina', 'Krásná', '2022-06-13 17:24:52'),
(12, 'Šimon', 'Škuta', '2022-06-13 17:25:23'),
(13, 'Sandra', 'Stará', '2022-06-13 17:25:39'),
(14, 'Leopold', 'Nový', '2022-06-13 17:25:46'),
(15, 'Květuše', 'Počepková', '2022-06-13 17:26:18'),
(16, 'Leonardo', 'Kapr', '2022-06-13 17:26:26'),
(17, 'Pavel', 'Pravý', '2022-06-13 17:26:37'),
(18, 'Aneta', 'Jasná', '2022-06-13 17:26:49'),
(19, 'Zuzana', 'Rychlá', '2022-06-13 17:27:01'),
(20, 'Anežka', 'Vomáčková', '2022-06-13 17:28:26');

-- --------------------------------------------------------

--
-- Stand-in structure for view `ZapujceneKnihy`
-- (See below for the actual view)
--
CREATE TABLE `ZapujceneKnihy` (
`Název knihy` varchar(128)
,`ID knihy` int(11)
,`Zapůjčeno` date
,`Jméno` varchar(32)
,`Přijmení` varchar(32)
,`ID uživatele` int(11)
);

-- --------------------------------------------------------

--
-- Structure for view `ZapujceneKnihy`
--
DROP TABLE IF EXISTS `ZapujceneKnihy`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `ZapujceneKnihy`  AS SELECT `bk`.`name` AS `Název knihy`, `b`.`shelfbook_id` AS `ID knihy`, `b`.`borrowed_at` AS `Zapůjčeno`, `u`.`first_name` AS `Jméno`, `u`.`last_name` AS `Přijmení`, `u`.`user_id` AS `ID uživatele` FROM (((`Borrowings` `b` join `ShelfBooks` `sb` on(`b`.`shelfbook_id` = `sb`.`shelfbook_id`)) join `Books` `bk` on(`sb`.`book_id` = `bk`.`book_id`)) join `Users` `u` on(`b`.`user_id` = `u`.`user_id`)) WHERE `b`.`returned` = 00  ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `Authors`
--
ALTER TABLE `Authors`
  ADD PRIMARY KEY (`author_id`);

--
-- Indexes for table `Books`
--
ALTER TABLE `Books`
  ADD PRIMARY KEY (`book_id`),
  ADD KEY `lang_id` (`lang_id`);
ALTER TABLE `Books` ADD FULLTEXT KEY `book_name_ft` (`name`);

--
-- Indexes for table `BooksAuthors`
--
ALTER TABLE `BooksAuthors`
  ADD KEY `author_id` (`author_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `BooksGenres`
--
ALTER TABLE `BooksGenres`
  ADD KEY `book_id` (`book_id`),
  ADD KEY `genre_id` (`genre_id`);

--
-- Indexes for table `Borrowings`
--
ALTER TABLE `Borrowings`
  ADD PRIMARY KEY (`bor_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `shelfbook_id` (`shelfbook_id`);

--
-- Indexes for table `BorrowingsLog`
--
ALTER TABLE `BorrowingsLog`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bor_id` (`bor_id`);

--
-- Indexes for table `Genres`
--
ALTER TABLE `Genres`
  ADD PRIMARY KEY (`genre_id`);

--
-- Indexes for table `Languages`
--
ALTER TABLE `Languages`
  ADD PRIMARY KEY (`lang_id`);

--
-- Indexes for table `RatingsAuthors`
--
ALTER TABLE `RatingsAuthors`
  ADD PRIMARY KEY (`user_id`,`author_id`),
  ADD KEY `author_id` (`author_id`);

--
-- Indexes for table `RatingsBooks`
--
ALTER TABLE `RatingsBooks`
  ADD PRIMARY KEY (`user_id`,`book_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `ShelfBooks`
--
ALTER TABLE `ShelfBooks`
  ADD PRIMARY KEY (`shelfbook_id`),
  ADD KEY `book_id` (`book_id`);

--
-- Indexes for table `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `Authors`
--
ALTER TABLE `Authors`
  MODIFY `author_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `Books`
--
ALTER TABLE `Books`
  MODIFY `book_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `Borrowings`
--
ALTER TABLE `Borrowings`
  MODIFY `bor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `BorrowingsLog`
--
ALTER TABLE `BorrowingsLog`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `Genres`
--
ALTER TABLE `Genres`
  MODIFY `genre_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `Languages`
--
ALTER TABLE `Languages`
  MODIFY `lang_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `ShelfBooks`
--
ALTER TABLE `ShelfBooks`
  MODIFY `shelfbook_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `Users`
--
ALTER TABLE `Users`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `Books`
--
ALTER TABLE `Books`
  ADD CONSTRAINT `Books_ibfk_2` FOREIGN KEY (`lang_id`) REFERENCES `Languages` (`lang_id`);

--
-- Constraints for table `BooksAuthors`
--
ALTER TABLE `BooksAuthors`
  ADD CONSTRAINT `BooksAuthors_ibfk_1` FOREIGN KEY (`author_id`) REFERENCES `Authors` (`author_id`),
  ADD CONSTRAINT `BooksAuthors_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`);

--
-- Constraints for table `BooksGenres`
--
ALTER TABLE `BooksGenres`
  ADD CONSTRAINT `BooksGenres_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`),
  ADD CONSTRAINT `BooksGenres_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `Genres` (`genre_id`);

--
-- Constraints for table `Borrowings`
--
ALTER TABLE `Borrowings`
  ADD CONSTRAINT `Borrowings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  ADD CONSTRAINT `Borrowings_ibfk_2` FOREIGN KEY (`shelfbook_id`) REFERENCES `ShelfBooks` (`shelfbook_id`);

--
-- Constraints for table `BorrowingsLog`
--
ALTER TABLE `BorrowingsLog`
  ADD CONSTRAINT `BorrowingsLog_ibfk_1` FOREIGN KEY (`bor_id`) REFERENCES `Borrowings` (`bor_id`);

--
-- Constraints for table `RatingsAuthors`
--
ALTER TABLE `RatingsAuthors`
  ADD CONSTRAINT `RatingsAuthors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  ADD CONSTRAINT `RatingsAuthors_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `Authors` (`author_id`);

--
-- Constraints for table `RatingsBooks`
--
ALTER TABLE `RatingsBooks`
  ADD CONSTRAINT `RatingsBooks_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  ADD CONSTRAINT `RatingsBooks_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`);

--
-- Constraints for table `ShelfBooks`
--
ALTER TABLE `ShelfBooks`
  ADD CONSTRAINT `ShelfBooks_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
