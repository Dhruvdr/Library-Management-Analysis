CREATE DEFINER=`root`@`localhost` PROCEDURE `issue_book`(
    p_issued_id VARCHAR(10),
    p_issued_member_id VARCHAR(30),
    p_issued_book_isbn VARCHAR(30),
    p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Check if the book is available (status = 'yes')
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        -- Insert the issue record into issued_status
        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        -- Update the book status to 'no' (unavailable)
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Success message (using SELECT instead of RAISE NOTICE)
        SELECT CONCAT('Book records added successfully for book isbn: ', p_issued_book_isbn) AS message;

    ELSE
        -- Failure message (if the book is unavailable)
        SELECT CONCAT('Sorry to inform you, the book you have requested is unavailable. Book ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END