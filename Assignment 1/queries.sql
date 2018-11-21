rem CS 340 Proframming Assignment 1
rem Wasif Tahir
rem s19100192

//Query #1
select p.pat_id
from patent p, categories c
where p.cat = c.cat
  AND p.subcat = c.subcat
  AND (c.catnamelong = 'Chemical'
   OR c.catnamelong = 'Drugs AND Medical');


//Query #2
select i.lastname, i.firstname, i.country, i.postate
from inventor i, categories c, patent p
where i.patentnum = p.pat_id
  AND p.cat = c.cat
  AND p.subcat = c.subcat
  AND (c.catnamelong = 'Chemical'
   OR c.catnamelong = 'Drugs AND Medical');

//Query #3
select i.lastname, i.firstname, i.country, i.postate
from inventor i, categories c, patent p
where i.patentnum = p.pat_id
  AND p.cat = c.cat
  AND p.subcat = c.subcat
  AND c.catnamelong = 'Chemical'
  AND not exists (select *
		from inventor i2, categories c2, patent p2
		where c2.cat = c.cat
		  AND p2.cat = p.cat
		  AND i2.patentnum = i.patentnum
		  AND c.catnamelong <> 'Chemical');

//Query #4
select p.pat_id
from patent p, inventor i
where p.pat_id = i.patentnum
  AND i.country = 'US'
  AND (i.postate = 'CA'
   OR i.postate = 'NJ');

//Query #5
select p.pat_id
from patent p, inventor i, (select p.pat_id, i2.invseq, i2.postate
        from patent p, inventor i2
        where p.pat_id = i2.patentnum
          AND i2.invseq = 2
          AND i2.country = 'US'
          AND (i2.postate = 'CA'
           OR i2.postate = 'NJ')) subq
where p.pat_id = subq.pat_id
  AND i.invseq = 1
  AND i.country = 'US'
  AND (i.postate = 'CA'
   OR i.postate = 'NJ');

//Query #6
select subq.compname
from (select c.compname, count(*) as counts
	from company c, patent p
	where c.assignee = p.assignee
	group by c.compname) subq
where subq.counts = (select max(subq1.counts)
		from (select c2.compname, count(*) as counts
			from company c2, patent p2
			where c2.assignee = p2.assignee
			group by c2.compname) subq1);
//Query #7
select c2.compname
from company c2
where c2.assignee IN (select p.assignee
                        from patent p
                        group by p.assignee
                        having count(*) = (select max(count(*))
                                       	from patent p2, categories c
					where p2.cat = c.cat
					  AND p2.subcat = c.subcat
					  AND c.catnamelong = 'Chemical'
                                       	group by p2.assignee));

//Query #8
select c2.compname
from company c2
where c2.assignee IN (select p.assignee
                        from patent p, categories c
			where p.cat = c.cat
			  AND p.subcat = c.subcat
			  AND c.catnamelong = 'Chemical'
			group by p.assignee
                        having count(*) >= 3);

//Query #9
select subq.assignee, subq.totalpatents
from (select c.compname, c.assignee, ct.subcatname, count(*) as totalpatents
	from patent p, company c, categories ct
	where p.cat = ct.cat
	  AND p.subcat = ct.subcat
	  AND ct.catnamelong = 'Chemicals'
	  AND c.assignee = p.assignee
	group by c.assignee, ct.catnamelong, ct.subcatname) subq
where subq.totalpatents = (select max(sub.subpatents)
			from (select p.assignee, ct.subcatname, count(*) as subpatents
                        	from patent p, company c, categories ct
				where p.cat = ct.cat
				  AND p.subcat = ct.subcat
				  AND ct.catnamelong = 'Chemical'
				  AND c.assignee = p.assignee
				group by c.assignee, ct.catnamelong, ct.subcatname) sub
			where sub.subcatname = subq.subcatname);


//Query #10
select i.firstname, i.lastname, (select max(count(*))
                                       	from patent p3, categories c, inventor i2
                                       	where p3.cat = c.cat
                                          AND p3.subcat = c.subcat
                                          AND c.catnamelong = 'Electrical AND Electronic'
                                       	group by i2.patentnum)
from inventor i
where i.patentnum IN (select i1.patentnum
                        from inventor i1
                        group by i1.patentnum
                        having count(*) = (select max(count(*))
                                        from patent p2, categories c
                                        where p2.cat = c.cat
                                          AND p2.subcat = c.subcat
                                          AND c.catnamelong = 'Electrical AND Electronic'
                                        group by p2.pat_id));

//Query #14
select subq.cited, subq.counts
from (select c.cited, count(*) as counts
	from citations c
	group by c.cited) subq
where subq.counts = (select max(counts1)
		from (select c1.cited, count(*) as counts1
			from citations c1
			group by c1.cited));

//Query #15
select subq2.cat, subq2.cited, subq2.counts
from (select subq.cat, max(subq.counts) as counts
	from (select p.cat, c.cited, count(*) as counts
		from citations c, patent p
		where p.pat_id = c.cited
		group by p.cat, c.cited) subq
	group by subq.cat) subq1
,
	(select p.cat, c.cited, count(*) as counts
	from citations c, patent p
	where p.pat_id = c.cited
	group by p.cat, c.cited) subq2
where subq1.counts = subq2.counts
  AND subq1.cat = subq2.cat;

//Query #16
select subq.citing, subq.counts
from (select c.citing, count(*) as counts
	from citations c
	group by c.citing) subq
where subq.counts = (select max(subq1.counts)
		from (select c.citing, count(*) as counts
			from citations c
			group by c.citing) subq1);


//Query #20
select p.pat_id
from patent p
where not exists (select *
		from citations c
		where c.cited = p.pat_id);

//Query #22
select avg(subq.counts)
from (select c2.compname, count(*) as counts
      from company c2, patent p2, inventor i
      where c2.assignee = p2.assignee
	AND i.patentnum = p2.pat_id
	AND i.country = 'US'
	AND i.postate = 'NJ') subq;

//Query #23
select subq1.compname
from (select c.compname, count(*) as counts
	from company c
	group by c.compname) subq1
where subq1.counts > (select avg(subq.counts)
from (select c2.compname, count(*) as counts
      from company c2, patent p2, inventor i
      where c2.assignee = p2.assignee
        AND i.patentnum = p2.pat_id
	AND i.country = 'US'
        AND i.postate = 'NY') subq);

/*
//View 1
create view view1
as select i.patentnum, i.firstname, i.lastname, p.gyear, c.compname, ct.catnamelong, ct.subcatname
from inventor i, company c, categories ct, patent p
where i.patentnum = p.pat_id
  AND p.cat = ct.cat
  AND p.subcat = ct.subcat
  AND i.invseq = 1
  AND p.assignee = c.assignee;

//View 2
create view view2
as select subq.assignee, subq.compname, subq.catnamelong, subq.subcatname, subq.counts
from (select c.assignee, c.compname, ct.catnamelong, ct.subcatname, count(*) as counts
	from patent p, company c, categories ct
	where i.patentnum = p.pat_id
  	  AND p.cat = ct.cat
 	  AND p.subcat = ct.subcat
 	  AND i.invseq = 1
	  AND p.assignee = c.assignee;
	group by p.pat_id);
*/
