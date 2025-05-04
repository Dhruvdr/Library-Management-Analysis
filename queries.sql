USE library_management;
-- Select * From books;
-- Select * From issued_status;
-- Select * From members;
-- Select * From employees;
-- Select * From branch;
-- Select * From return_status;

-- CRUD Operations
-- Create a New Book Record --> "978-0-8223-2435-4","Lost Treasure of the Emerald Eye" , "Fiction" , 6.5 , 'yes' , "Geronimo Stilton" ,  "Scholastic Incorporated"
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES("978-0-8223-2435-4","Lost Treasure of the Emerald Eye" , "Fiction" , 6.5 , 'yes' , "Geronimo Stilton" ,  "Scholastic Incorporated");
SELECT * FROM books;

-- Delete a Record from the Issued Status Table -- of issued id = IS124
DELETE FROM issued_status
WHERE   issued_id =   'IS124';
-- Select * From issued_status;

-- Update an Existing Member's Address
UPDATE members
SET member_address = '420 Manhattan '
WHERE member_id = 'C103';
Select * From members;

-- Retrieve All Books Issued by a Specific Employee 
SELECT * FROM issued_status
WHERE issued_emp_id = 'E107';

-- List Members Who Have Issued More Than Two Book 
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 2;

-- Create Summary Tables
CREATE TABLE book_iss_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
Select * from book_iss_cnt;

-- the Most Borrowed Books
Select * From book_iss_cnt
order by issue_count DESC
LIMIT 3;

 -- Find Total Rental Income by Category
 SELECT 
    b.category,
    SUM(b.rental_price) as total_rent,
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;

-- List Members Who Registered in the Last 2 years:
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 2 year ;

-- List Employees with Their Branch Manager's Name and their branch details
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id;

-- Make the List of Books Not Yet Returned
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

-- Identify Members with Overdue Books
SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1;

-- Update Book Status on Return
-- making procedure to update table 

-- Testing FUNCTION add_return_records

SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-7432-7357-1';

SELECT * FROM return_status
WHERE issued_id = 'IS136';

-- calling function 
CALL add_return_records('RS119', 'IS136');
-- calling function 
CALL add_return_records('RS120', 'IS135');
SELECT * FROM return_status;

 -- Branch Performance Report
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as num_bk_iss,
    COUNT(rs.return_id) as num_bk_ret,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;

-- Create a Table of Active Members

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL 1 year
                    )
;

SELECT * FROM active_members;

--  Find Employees with the Most Book Issues Processed
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY no_book_issued DESC;

-- Create a stored procedure to manage the status of books in a library system.
-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';