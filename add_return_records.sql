CREATE DEFINER=`root`@`localhost` PROCEDURE `add_return_records`(
    p_return_id VARCHAR(10), 
    p_issued_id VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_bk_name VARCHAR(50);

    -- Insert into return_status table based on user input (without book_quality)
    INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE);

    -- Retrieve the ISBN and Book Name from issued_status based on issued_id
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_bk_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Check if the SELECT query found a valid book
    IF v_isbn IS NOT NULL AND v_bk_name IS NOT NULL THEN
        -- Update the books table to mark the book as available ('yes')
        UPDATE books
        SET status = 'yes'
        WHERE isbn = v_isbn;

        -- Inform the user about the returned book
        SELECT CONCAT('Thank you for returning the book: ', v_bk_name) AS message;
    ELSE
        -- Handle case where the issued_id does not exist in issued_status
        SELECT 'Issued ID not found or invalid.' AS message;
    END IF;

END;
