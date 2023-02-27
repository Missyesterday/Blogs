--  按照部门分组，找出每组的最大值
select 
    deptno,max(sal) as maxsal
from 
    emp
group BY
    deptno;

select 
    e.ename,t.*
from 
    emp e
JOIN
    (select deptno,max(sal) as maxsal from 
    emp
group BY
    deptno) t
on 
    t.deptno = e.deptno and t.maxsal = e.sal;

-- 哪些人的薪水在部门平均水平之上
select ename,sal
from emp a
join (select avg(sal) as avgsal, deptno from emp group by deptno ) b
on  a.sal > b.avgsal and a.deptno = b.deptno;