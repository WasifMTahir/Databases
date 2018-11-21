create or replace function fun_issue_book ( borrower_id IN NUMBER, book_id IN NUMBER, current_date IN DATE) return number as
stat books.status%type;
	return_date date :=NULL;
begin
	begin
	select b.status
	into stat
	from books b
	where book_id = b.book_id;
	end	
	if stat = 'issued' then
		insert into pending_request values( borrower_id, book_id, current_date, return_date);
		return 0;
	end if;
	if stat = 'not_issued' then
		insert into issue values( borrower_id, book_id, current_date, return_date);
		return 1;
	end if;
end;
/
show errors

create or replace function fun_issue_anyedition ( borrower_id IN NUMBER, book_id IN NUMBER, author_name IN author.name%type, current_date IN DATE)
return number as
stat books.status%type;
	return_date date :=NULL;
	edition number :=NULL;
begin
	select b.stat, max(b.edition)
	into stat, edition
	from	(select *
		from books b2, (select book_id
			from book
			minus
			select book_id
			from issue;) b3
		where b2.book_id = b3.book_id;) b
	where book_id = b.book_id
	group by b.book_id;

	if edition !=NULL then
		insert into issue values ( borrower_id, book_id, current_date, return_date);
		return 1;
	else
		insert into pending_request values ( borrower_id, book_id, current_date, return_date);
		return 0;
end;
/
show errors


create or replace function fun_most_popular ( month IN NUMBER, year IN NUMBER)
return varchar2
results varchar2;
begin
	select b2.book_id
	into results
	from
	(select b.book_id, count(b.book_id) as count
	from books b, issue i
	where b.book_id = i.book_id AND month = to_char(i.issue_date, 'mm') AND year = to_char(i.issue_date, 'yyyy');) b2
	where b2.count = (select max(b3.book_id)
			from books b3, issue i3
			where b3.book_id = i3.book_id AND month = to_char(i3.issue_date, 'mm') AND year = to_char(i3.issue_date, 'yyyy')
			group by b3.book_id;);
	return results;
end;
/
show errors

create or replace function fun_return_book ( book_id IN NUMBER, current_date IN NUMBER) return number
checker number :=NULL;
	bor number :=NULL;
	issdate date :=NULL;
begin
	select i.book_id, i.borrower_id, i.issue_date
	into checker, bor, issdate
	from issue i
	where book_id = i.book_id;

	if checker = NULL
		return 0;
	update on issue( bor, book_id, issdate, current_date);
	bor :=NULL;
	select p.requester_id, p.request_date
	into bor, issdate
	from pending_request p
	where checker = p.book_id;
	
	if bor!=NULL then
		insert on issue( bor, book_id, current_date, NULL);
		update on pending_request( book_id, bor, issdate, current_date);
	end if;
	return 1;
end;
/
show errors
