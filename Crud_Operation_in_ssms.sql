
-- Creating database
create database library_management_system;


-- Connecting to database
use library_management_system;


-- Creating table
create table books(
	ID int not null,
	Book_Name varchar(255) ,
	Author varchar(255),
	Genre varchar(255)
);


--Altering table
alter table books
alter column ID int not null;

alter table books
add constraint pk_Books_ID primary key(ID);

EXEC sp_rename 'books.Id', 'Book_Id', 'COLUMN';


--Inserting into table
insert into books(ID,Book_Name,Author,Genre)
values
(1,'The Great Gatsby','F. Scott Fitzgerald','classic'),
(2,'1984','George Orwell','Dystopian'),
(3,'The Catcher in the Rye','J.D. Salinger','classic'),
(4, 'The Catcher in the Rye', 'J.D. Salinger', 'Classic'),
(5, 'The Hobbit', 'J.R.R. Tolkien', 'Fantasy'),
(6, 'Pride and Prejudice', 'Jane Austen', 'Romance'),
(7, 'Moby-Dick', 'Herman Melville', 'Adventure'),
(8, 'War and Peace', 'Leo Tolstoy', 'Historical Fiction'),
(9, 'The Da Vinci Code', 'Dan Brown', 'Thriller'),
(10, 'Brave New World', 'Aldous Huxley', 'Dystopian');


--Read from the table
select * from library_management_system.dbo.books;

--Updating record in the table
update books
set Book_Name = 'To Kill a Mockingbird',Author = 'Harper Lee',Genre = 'classic'
where ID=3;


select * from books;

delete from books 
where ID=9;

select * from books;


--Creating new table
create table student(
	Student_ID int not null primary key,
	Student_Name varchar(255) ,
	Dept varchar(255),
	Book_Id int
);

insert into student(Student_ID,Student_Name,Dept,Book_Id)
values
(311,'Rahul','MCT',1),
(312,'Vijay','MCA',2),
(313,'Venkatesh','MCA',3),
(314,'Suresh','MECH',4),
(315,'Naveen','ECE',5),
(316,'Girish','EEE',6),
(317,'Sanjay','EEE',7);

Select * from student;

--Fetching from the 2 tables

SELECT student.Student_Name, books.Genre
FROM student
JOIN books ON student.Book_Id = books.Book_Id
where Dept = 'MCA';

--Updating in the book
UPDATE books
SET Genre = 'Romance'
FROM books
JOIN student ON books.Book_Id = student.Book_Id
WHERE student.Book_Id = 7;

select * from books;

delete 
from books where Book_id = 8;

UPDATE student
SET Book_Id = 5
where Student_ID = 311;

select * from student;

-- Deleting in student
delete 
from student
where Student_ID = 316;
