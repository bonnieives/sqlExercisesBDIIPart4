-- First of first, let's connect to sys as sysdba
connect sys/sys as sysdba;

-- Now let's create a spool file
SPOOL C:\BD2\project_part4.txt

-- And we need to show the date and time the script was run
SELECT to_char(sysdate,'DD Month YYYY Day HH:MI"SS') FROM dual;

-- QUESTION 1

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE q1p4a (side1 IN NUMBER, side2 IN NUMBER, quad OUT VARCHAR2) AS
		
	BEGIN
		IF side1 = side2 THEN
			quad := 'EQUAL';
		ELSE
			quad := 'DIFFERENT';
		END IF;
	END;
/

CREATE OR REPLACE PROCEDURE l4q1 (p_side1 IN NUMBER, p_side2 IN NUMBER) AS
	out_quad VARCHAR2(10);
	
	BEGIN
		q1p4a(p_side1,p_side2,out_quad);	

		IF out_quad = 'EQUAL' THEN
			DBMS_OUTPUT.PUT_LINE('The area of the square size ' || p_side1 || ' by ' || p_side2 || 
			' is ' || (p_side1 * p_side2) || '. Its perimeter is ' || 2 * (p_side1 + p_side2) || '.');
		ELSIF out_quad = 'DIFFERENT' THEN
			DBMS_OUTPUT.PUT_LINE('The area of the rectangle size ' || p_side1 || ' by ' || p_side2 || 
			' is ' || (p_side1 *p_side2) || '. Its perimeter is ' || 2 * (p_side1 + p_side2) || '.');
		END IF;

		EXCEPTION
			WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('There is something wrong!');
	
	END;
/

EXEC l4q1(3,3)
EXEC l4q1(5,9)


-- QUESTION 2


CREATE OR REPLACE PROCEDURE pseudo_fun (side1 IN NUMBER, side2 IN NUMBER, out_area OUT NUMBER, out_perimeter OUT NUMBER) AS

	BEGIN
		out_area := side1 * side2;
		out_perimeter := 2 * (side1 + side2);
	END;
/

CREATE OR REPLACE PROCEDURE l4q2 (in_side1 IN NUMBER, in_side2 IN NUMBER) AS
	area NUMBER;
	perimeter NUMBER;

	BEGIN
		
		pseudo_fun(in_side1,in_side2,area,perimeter);
		
		IF in_side1 = in_side2 THEN
			DBMS_OUTPUT.PUT_LINE('The area of the square size ' || in_side1 || ' by ' || in_side2 || 
			' is ' || area || '. Its perimeter is ' || perimeter || '.');
		ELSIF in_side1 <> in_side2 THEN
			DBMS_OUTPUT.PUT_LINE('The area of the rectangle size ' || in_side1 || ' by ' || in_side2 || 
			' is ' || area || '. Its perimeter is ' || perimeter || '.');
		END IF;

		EXCEPTION
			WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE('There is something wrong!');
		
	END;
/
	
EXEC l4q2(12,12)
EXEC l4q2(34,0.4)

-- QUESTION 3

connect sys/sys as sysdba;
DROP USER des02 CASCADE;
@C:\BD1\7clearwater.sql

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE price_update (in_inv_id IN NUMBER, in_perc IN NUMBER, out_price OUT NUMBER, out_qoh OUT NUMBER) AS
	t_inv_id NUMBER;
	t_price NUMBER;
	t_qoh NUMBER;

	BEGIN
		SELECT inv_id, inv_price, inv_qoh
		INTO t_inv_id, t_price, t_qoh
		FROM inventory
		WHERE inv_id = in_inv_id;

		out_price := t_price * (1 + in_perc/100);
		out_qoh := t_qoh;

		UPDATE inventory SET inv_price = out_price
		WHERE inv_id = in_inv_id;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Item number ' || in_inv_id || ' does not exist.');

	END;
/

CREATE OR REPLACE PROCEDURE l4q3 (invid IN NUMBER, perc IN NUMBER) AS
	price_out NUMBER;
	qoh_out NUMBER;

	BEGIN
		price_update(invid, perc, price_out, qoh_out);
		
		IF (price_out IS NULL) THEN
		DBMS_OUTPUT.PUT_LINE('Try again.');
		ELSE
		DBMS_OUTPUT.PUT_LINE('The item number ' || invid || ' had the price updated.');
		DBMS_OUTPUT.PUT_LINE('The percentual updated is of ' || perc || '%.');
		DBMS_OUTPUT.PUT_LINE('The new price of the inventory is $' || ROUND((qoh_out * price_out),2) || '.');		
		END IF;
	END;
/

EXEC l4q3(23,12)
EXEC l4q3(120,12)
EXEC l4q3(30,-30)


SPOOL OFF;


