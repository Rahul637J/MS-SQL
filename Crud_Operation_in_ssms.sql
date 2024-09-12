


create database library_management_system;

use library_management_system;

create table books(
	ID int not null,
	Book_Name varchar(255) ,
	Author varchar(255),
	Genre varchar(255)
);

alter table books
alter column ID int not null;

alter table books
add constraint pk_Books_ID primary key(ID);

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

select * from library_management_system.dbo.books;

update books
set Book_Name = 'To Kill a Mockingbird',Author = 'Harper Lee',Genre = 'classic'
where ID=3;

select * from books;

delete from books 
where ID=9;

select * from books;
