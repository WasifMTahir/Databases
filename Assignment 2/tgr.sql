create or replace trigger trg_maxbooks
before insert on issue
for each row
declare 
	counter number :=0;
	id issue.borrower_id%type :=NULL;
	stat borrower.status%type :=NULL;
begin
	begin
	select i2.borrower_id, b2.status, count(b2.borrower_id)
	into id, stat, counter from issue i2, borrower b2
	where :new.borrower_id = b2.borrower_id AND i2.borrower_id = b2.borrower_id
	group by i2.borrower_id, b2.status;
	end;
if stat = 'faculty' AND counter = 3 then
		RAISE_APPLICATION_ERROR(-20999, 'Faculty members are not allowed to issue >3 books');
		end if;
if stat = 'student' AND counter = 2 then
		RAISE_APPLICATION_ERROR(-20999, 'Students are not allowed to issue >2 books');
		end if;
end;
/

create or replace trigger trg_issue
after insert on issue
for each row
begin
	update books b
	set b.status = 'issued'
	where b.book_id = :new.book_id;
end;
/

create or replace trigger trg_notissue
before update of return_date on issue
for each row
begin
	update books b
	set b.status = 'not_issued'
	where b.book_id = :new.book_id;
end;
/
