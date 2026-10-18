create table a(id integer primary key, k int, v real, s text);
with recursive n(i) as (select 1 union all select i+1 from n where i < 300000)
insert into a select i, (i * 2654435761) % 10007, (i % 977) * 1.25 - 300, printf('row%07d-%x', i, i * 31) from n;
create index a_k on a(k);
select count(*), sum(v), count(distinct k) from a;
select k, count(*), round(sum(v), 2) from a group by k order by 3 desc, k limit 5;
select count(*) from a x join a y on x.k = y.k and y.id = x.id + 10007 where x.id < 50000;
select s from a where s like 'row00123%' order by s limit 3;
select sum(length(s)), max(s), min(s) from a where k between 100 and 200;
select id, v from a order by v desc, id limit 3;
select count(*) from (select k, sum(v) t from a group by k having t > 0);
select upper(substr(s, 1, 6)) u, count(*) from a group by u order by u limit 3;
