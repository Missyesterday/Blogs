drop table if exists sc,s,c;
CREATE TABLE SC (
SNO VARCHAR(200), CNO VARCHAR(200), SCGRADE VARCHAR(200)
) default charset=utf8;
CREATE TABLE S (
SNO VARCHAR(200 ),
SNAME VARCHAR(200) ) default charset=utf8;
CREATE TABLE C (
CNO VARCHAR(200), CNAME VARCHAR(200), CTEACHER VARCHAR(200)
) default charset=utf8;
INSERT INTO C ( CNO, CNAME,CTEACHER ) VALUES ( '1', '语文', '张');
INSERT INTO C ( CNO, CNAME, CTEACHER ) VALUES ( '2', '政治', '王');
INSERT INTO C ( CNO, CNAME, CTEACHER ) VALUES ( '3', '英语', '李');
INSERT INTO C ( CNO, CNAME, CTEACHER ) VALUES ( '4', '数学', '赵');
INSERT INTO C ( CNO, CNAME,CTEACHER ) VALUES ( '5', '物理', '黎明'); 
commit;
INSERT INTO S ( SNO, SNAME ) VALUES ( '1', '学生 1');
INSERT INTO S ( SNO, SNAME ) VALUES ( '2', '学生 2');
INSERT INTO S ( SNO, SNAME ) VALUES ( '3', '学生 3');
INSERT INTO S ( SNO, SNAME ) VALUES ( '4', '学生 4');
commit;
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '1', '1', '40'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '1', '2', '30'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '1', '3', '20'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '1', '4', '80');
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '1', '5', '60'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '2', '1', '60'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '2', '2', '60'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '2', '3', '60'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '2', '4', '60'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '2', '5', '40'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '3', '1', '60'); 
INSERT INTO SC ( SNO, CNO, SCGRADE ) VALUES ( '3', '3', '80'); 
commit;