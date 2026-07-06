# SQL 题模板 + 往年题改写（SQL Server / T-SQL）

> 目标：专门拿 SQL 语句编写题 30 分。  
> 原则：用 SQL Server 写法；中文字符串用 `N'...'`；多表查询优先写显式 `JOIN`；多表更新用 `UPDATE ... FROM ... JOIN ...`。

---

## 0. SQL Server 考试避坑表

| 场景 | 推荐 SQL Server 写法 | 避坑 |
|---|---|---|
| 中文字符串 | `N'张三'` | 不写 N 通常也能懂，但 SQL Server 标准中文建议写 N |
| 自增列 | `IDENTITY(1,1)` | 不是 MySQL 的 `AUTO_INCREMENT` |
| 取前 N 行 | `SELECT TOP 5 * FROM S;` | 不是 MySQL 的 `LIMIT 5` |
| 当前时间 | `GETDATE()` | 不是 `NOW()` |
| 建表注释 | 考试一般不写 `COMMENT` | SQL Server 不用 MySQL 的列注释写法 |
| 多表更新 | `UPDATE A SET ... FROM A JOIN B ...` | 不是 `UPDATE A JOIN B SET ...` |
| 删除连接结果 | `DELETE A FROM A JOIN B ...` | 要写清删除哪个表 |
| 赋权限给所有用户 | `TO public` | SQL Server 的 public 是固定数据库角色 |
| 排除某用户 | 可 `DENY ... TO Gary` | 仅 `REVOKE FROM public` 不能表示“除了 Gary” |

---

## 1. 标准样例库：学生-课程-选课

考试最常见模式：

- 学生表 `Student(Sno, Sname, Ssex, Sage, Sdept)`
- 课程表 `Course(Cno, Cname, Credit, Teacher)`
- 选课表 `SC(Sno, Cno, SelectTime, Grade)`

### 1.1 建表模板

```sql
CREATE TABLE Student (
    Sno CHAR(10) NOT NULL,
    Sname NVARCHAR(20) NOT NULL,
    Ssex NCHAR(1) NOT NULL,
    Sage INT NULL,
    Sdept NVARCHAR(30) NULL,
    CONSTRAINT PK_Student PRIMARY KEY (Sno),
    CONSTRAINT CK_Student_Ssex CHECK (Ssex IN (N'男', N'女')),
    CONSTRAINT CK_Student_Sage CHECK (Sage BETWEEN 15 AND 45)
);

CREATE TABLE Course (
    Cno CHAR(10) NOT NULL,
    Cname NVARCHAR(50) NOT NULL,
    Credit INT NULL,
    Teacher NVARCHAR(20) NULL,
    CONSTRAINT PK_Course PRIMARY KEY (Cno),
    CONSTRAINT CK_Course_Credit CHECK (Credit BETWEEN 1 AND 100)
);

CREATE TABLE SC (
    Sno CHAR(10) NOT NULL,
    Cno CHAR(10) NOT NULL,
    SelectTime DATE NOT NULL,
    Grade TINYINT NULL,
    CONSTRAINT PK_SC PRIMARY KEY (Sno, Cno, SelectTime),
    CONSTRAINT FK_SC_Student FOREIGN KEY (Sno) REFERENCES Student(Sno),
    CONSTRAINT FK_SC_Course FOREIGN KEY (Cno) REFERENCES Course(Cno),
    CONSTRAINT CK_SC_Grade CHECK (Grade BETWEEN 0 AND 100)
);
```

说明：

- 主键：`Student.Sno`、`Course.Cno`、`SC(Sno, Cno, SelectTime)`。
- 外键：`SC.Sno -> Student.Sno`，`SC.Cno -> Course.Cno`。
- 自定义完整性：性别、年龄、学分/学时、成绩范围。

### 1.2 索引模板

若题目说“选课时间和分数经常作为筛选条件”：

```sql
CREATE INDEX IX_SC_SelectTime ON SC(SelectTime);
CREATE INDEX IX_SC_Grade ON SC(Grade);
```

答题理由：经常出现在 `WHERE` 条件中的列适合建立索引，可加快查询速度；但索引会占用空间，并降低插入、删除、修改速度。

---

## 2. SELECT 基础模板

### 2.1 单表查询

```sql
SELECT Sno, Sname
FROM Student
WHERE Sage > 20;
```

### 2.2 去重

```sql
SELECT DISTINCT Sdept
FROM Student;
```

### 2.3 模糊查询

```sql
-- 姓王
SELECT *
FROM Student
WHERE Sname LIKE N'王%';

-- 课程名包含 DB
SELECT *
FROM Course
WHERE Cname LIKE N'%DB%';
```

### 2.4 范围查询

```sql
SELECT *
FROM SC
WHERE Grade BETWEEN 60 AND 80;
```

### 2.5 空值判断

```sql
SELECT *
FROM SC
WHERE Grade IS NULL;
```

注意：空值不能写 `= NULL`，必须写 `IS NULL`。

---

## 3. JOIN 连接查询模板

### 3.1 查询学生姓名、课程名、成绩

```sql
SELECT S.Sname, C.Cname, SC.Grade
FROM Student AS S
JOIN SC ON S.Sno = SC.Sno
JOIN Course AS C ON SC.Cno = C.Cno;
```

### 3.2 查询选修“DB”的学生姓名和分数

```sql
SELECT S.Sname, SC.Grade
FROM Student AS S
JOIN SC ON S.Sno = SC.Sno
JOIN Course AS C ON SC.Cno = C.Cno
WHERE C.Cname = N'DB';
```

### 3.3 查询“英语”专业所有男同学姓名

```sql
SELECT Sname
FROM Student
WHERE Sdept = N'英语'
  AND Ssex = N'男';
```

---

## 4. 聚合、分组、排序模板

### 4.1 每个学生的平均分

```sql
SELECT Sno, AVG(CAST(Grade AS DECIMAL(5,2))) AS AvgGrade
FROM SC
WHERE Grade IS NOT NULL
GROUP BY Sno;
```

也可连接显示姓名：

```sql
SELECT S.Sno, S.Sname, AVG(CAST(SC.Grade AS DECIMAL(5,2))) AS AvgGrade
FROM Student AS S
JOIN SC ON S.Sno = SC.Sno
WHERE SC.Grade IS NOT NULL
GROUP BY S.Sno, S.Sname;
```

### 4.2 每门课最高分和选课人数

```sql
SELECT Cno, MAX(Grade) AS MaxGrade, COUNT(*) AS StudentCount
FROM SC
GROUP BY Cno;
```

### 4.3 分组后筛选

```sql
SELECT Sno, AVG(CAST(Grade AS DECIMAL(5,2))) AS AvgGrade
FROM SC
GROUP BY Sno
HAVING AVG(CAST(Grade AS DECIMAL(5,2))) >= 80;
```

`WHERE` 筛选行，`HAVING` 筛选分组。

### 4.4 排序

```sql
SELECT Cno, COUNT(*) AS Cnt
FROM SC
GROUP BY Cno
ORDER BY Cnt DESC, Cno ASC;
```

---

## 5. 子查询模板

### 5.1 IN 子查询

查询选修“数据库原理”的学生学号：

```sql
SELECT Sno
FROM SC
WHERE Cno IN (
    SELECT Cno
    FROM Course
    WHERE Cname = N'数据库原理'
);
```

### 5.2 比任何一个都小：`< ALL` 或 `< MIN`

题：检索其他专业中比计算机专业任何学生年龄都小的学生姓名和年龄。

```sql
SELECT Sname, Sage
FROM Student
WHERE Sdept <> N'计算机'
  AND Sage < ALL (
      SELECT Sage
      FROM Student
      WHERE Sdept = N'计算机'
        AND Sage IS NOT NULL
  );
```

等价常用写法：

```sql
SELECT Sname, Sage
FROM Student
WHERE Sdept <> N'计算机'
  AND Sage < (
      SELECT MIN(Sage)
      FROM Student
      WHERE Sdept = N'计算机'
  );
```

### 5.3 EXISTS 模板

查询至少选修一门课程的学生：

```sql
SELECT S.Sno, S.Sname
FROM Student AS S
WHERE EXISTS (
    SELECT 1
    FROM SC
    WHERE SC.Sno = S.Sno
);
```

### 5.4 NOT EXISTS 模板

查询没有选课的学生：

```sql
SELECT S.Sno, S.Sname
FROM Student AS S
WHERE NOT EXISTS (
    SELECT 1
    FROM SC
    WHERE SC.Sno = S.Sno
);
```

---

## 6. 插入、修改、删除模板

### 6.1 插入

```sql
INSERT INTO Student(Sno, Sname, Ssex, Sage, Sdept)
VALUES ('20090216', N'王伟', N'男', 20, N'is');
```

若表有 6 个字段，必须写满或指定列名。推荐永远指定列名。

### 6.2 单表更新

```sql
UPDATE Student
SET Sdept = N'计算机'
WHERE Sno = '20090216';
```

### 6.3 多表更新：将李明的数据库原理成绩改为 90

```sql
UPDATE SC
SET Grade = 90
FROM SC
JOIN Student AS S ON SC.Sno = S.Sno
JOIN Course AS C ON SC.Cno = C.Cno
WHERE S.Sname = N'李明'
  AND C.Cname = N'数据库原理';
```

### 6.4 删除某学生全部选课记录

题：删除“李莉”的全部选课记录。

写法一：子查询。

```sql
DELETE FROM SC
WHERE Sno IN (
    SELECT Sno
    FROM Student
    WHERE Sname = N'李莉'
);
```

写法二：连接删除。

```sql
DELETE SC
FROM SC
JOIN Student AS S ON SC.Sno = S.Sno
WHERE S.Sname = N'李莉';
```

### 6.5 删除学生记录时注意外键

若 `SC` 引用 `Student`，应先删 `SC`，再删 `Student`：

```sql
DELETE FROM SC WHERE Sno = '999';
DELETE FROM Student WHERE Sno = '999';
```

---

## 7. 视图、授权、回收模板

### 7.1 创建视图

```sql
CREATE VIEW V_DBGrade AS
SELECT S.Sno, S.Sname, C.Cname, SC.Grade
FROM Student AS S
JOIN SC ON S.Sno = SC.Sno
JOIN Course AS C ON SC.Cno = C.Cno
WHERE C.Cname = N'数据库';
```

### 7.2 授权

```sql
GRANT SELECT ON Student TO User1;
GRANT SELECT, INSERT ON Student TO User1;
GRANT UPDATE(Grade) ON SC TO User1;
```

### 7.3 回收权限

```sql
REVOKE SELECT ON Student FROM User1;
REVOKE UPDATE(Grade) ON SC FROM User1;
```

### 7.4 往年题：将“数据库”成绩的查询权、成绩字段修改权授予除 Gary 之外所有用户

SQL Server 更严谨写法：先用视图限制到“数据库”课程，再授予 public，最后明确拒绝 Gary。

```sql
CREATE VIEW V_DBGrade AS
SELECT SC.Sno, SC.Cno, SC.Grade
FROM SC
JOIN Course AS C ON SC.Cno = C.Cno
WHERE C.Cname = N'数据库';

GRANT SELECT, UPDATE(Grade) ON V_DBGrade TO public;
DENY SELECT, UPDATE(Grade) ON V_DBGrade TO Gary;
```

如果老师按教材而不考 `DENY`，可写成文字说明：建立不包含 Gary 的角色，把除 Gary 外用户加入该角色，再对角色授权。

```sql
CREATE ROLE ExceptGaryRole;
-- 将除 Gary 外用户加入该角色，考试不需要枚举所有用户时可文字说明
GRANT SELECT, UPDATE(Grade) ON V_DBGrade TO ExceptGaryRole;
```

注意：`REVOKE ... FROM public` 是回收 public 的权限，不是“只回收 Gary”。

---

## 8. 关系代数速记

| 操作 | 符号 | SQL 对应 |
|---|---|---|
| 选择 | `σ条件(R)` | `WHERE` |
| 投影 | `π列名(R)` | `SELECT 列名` |
| 连接 | `R ⋈ S` | `JOIN ... ON ...` |
| 并 | `R ∪ S` | `UNION` |
| 差 | `R - S` | `EXCEPT` 或 `NOT EXISTS` |
| 笛卡尔积 | `R × S` | `CROSS JOIN` |
| 除 | `R ÷ S` | “至少包含全部……”题，常用双重 `NOT EXISTS` |

例：检索年龄大于 20 的学生姓名：

```text
π姓名(σ年龄>20(学生表))
```

例：检索选修了“操作系统”课程的学生学号：

```text
π学号(σ课程名称='操作系统'(课程表 ⋈ 选课表))
```

---

## 9. 往年题改写一：成绩管理数据库

### 9.1 题干抽象

学生：学号、姓名、性别、年龄、专业、院系。  
课程：课程编号、课程名称、学时、任课教师。  
选课：学号、课程编号、选课时间、分数。  
每个学生可选多门课，每门课可被多个学生选修；每个学生每门课程在一个学期/选课时间只能选一次；成绩百分制，学时不超过 100。

### 9.2 SQL Server 建表

```sql
CREATE TABLE 学生表 (
    学号 CHAR(10) NOT NULL,
    姓名 NVARCHAR(20) NOT NULL,
    性别 NCHAR(1) NOT NULL,
    年龄 INT NULL,
    专业 NVARCHAR(30) NULL,
    院系 NVARCHAR(50) NULL,
    CONSTRAINT PK_学生表 PRIMARY KEY (学号),
    CONSTRAINT CK_学生表_性别 CHECK (性别 IN (N'男', N'女')),
    CONSTRAINT CK_学生表_年龄 CHECK (年龄 BETWEEN 15 AND 45)
);

CREATE TABLE 课程表 (
    课程编号 CHAR(10) NOT NULL,
    课程名称 NVARCHAR(50) NOT NULL,
    学时 INT NOT NULL,
    任课教师 NVARCHAR(20) NULL,
    CONSTRAINT PK_课程表 PRIMARY KEY (课程编号),
    CONSTRAINT CK_课程表_学时 CHECK (学时 BETWEEN 1 AND 100)
);

CREATE TABLE 选课表 (
    学号 CHAR(10) NOT NULL,
    课程编号 CHAR(10) NOT NULL,
    选课时间 DATE NOT NULL,
    分数 TINYINT NULL,
    CONSTRAINT PK_选课表 PRIMARY KEY (学号, 课程编号, 选课时间),
    CONSTRAINT FK_选课表_学生 FOREIGN KEY (学号) REFERENCES 学生表(学号),
    CONSTRAINT FK_选课表_课程 FOREIGN KEY (课程编号) REFERENCES 课程表(课程编号),
    CONSTRAINT CK_选课表_分数 CHECK (分数 BETWEEN 0 AND 100)
);
```

### 9.3 查询题改写

检索英语专业所有男同学姓名：

```sql
SELECT 姓名
FROM 学生表
WHERE 专业 = N'英语'
  AND 性别 = N'男';
```

检索每个学生的学号和平均分：

```sql
SELECT 学号, AVG(CAST(分数 AS DECIMAL(5,2))) AS 平均分
FROM 选课表
WHERE 分数 IS NOT NULL
GROUP BY 学号;
```

检索所有选修课程名称为 DB 的学生姓名和分数：

```sql
SELECT S.姓名, X.分数
FROM 学生表 AS S
JOIN 选课表 AS X ON S.学号 = X.学号
JOIN 课程表 AS C ON X.课程编号 = C.课程编号
WHERE C.课程名称 = N'DB';
```

检索其他专业中比计算机专业任何学生年龄都小的学生姓名和年龄：

```sql
SELECT 姓名, 年龄
FROM 学生表
WHERE 专业 <> N'计算机'
  AND 年龄 < (
      SELECT MIN(年龄)
      FROM 学生表
      WHERE 专业 = N'计算机'
  );
```

将李明的数据库原理成绩修改为 90：

```sql
UPDATE X
SET 分数 = 90
FROM 选课表 AS X
JOIN 学生表 AS S ON X.学号 = S.学号
JOIN 课程表 AS C ON X.课程编号 = C.课程编号
WHERE S.姓名 = N'李明'
  AND C.课程名称 = N'数据库原理';
```

删除李莉的全部选课记录：

```sql
DELETE X
FROM 选课表 AS X
JOIN 学生表 AS S ON X.学号 = S.学号
WHERE S.姓名 = N'李莉';
```

插入学生记录：

```sql
INSERT INTO 学生表(学号, 姓名, 性别, 年龄, 专业)
VALUES ('20090216', N'王伟', N'男', 20, N'is');
```

---

## 10. 往年题改写二：供应商-零件-工程 SPJ

关系模式：

```text
S(SNO, SNAME, CITY)
P(PNO, PNAME, COLOR, WEIGHT)
J(JNO, JNAME, CITY)
SPJ(SNO, PNO, JNO, QTY)
```

### 10.1 求供应 J1 工程零件的供应商号

```sql
SELECT DISTINCT SNO
FROM SPJ
WHERE JNO = 'J1';
```

### 10.2 求供应 J1 工程 P1 零件的供应商号

```sql
SELECT DISTINCT SNO
FROM SPJ
WHERE JNO = 'J1'
  AND PNO = 'P1';
```

### 10.3 求供应 J1 工程红色零件的供应商号

```sql
SELECT DISTINCT SPJ.SNO
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
WHERE SPJ.JNO = 'J1'
  AND P.COLOR = N'红';
```

### 10.4 求至少使用过天津供应商供应的红色零件的工程号

```sql
SELECT DISTINCT SPJ.JNO
FROM SPJ
JOIN S ON SPJ.SNO = S.SNO
JOIN P ON SPJ.PNO = P.PNO
WHERE S.CITY = N'天津'
  AND P.COLOR = N'红';
```

若题目是“没有使用天津供应商供应的红色零件的工程号”，写：

```sql
SELECT J.JNO
FROM J
WHERE NOT EXISTS (
    SELECT 1
    FROM SPJ
    JOIN S ON SPJ.SNO = S.SNO
    JOIN P ON SPJ.PNO = P.PNO
    WHERE SPJ.JNO = J.JNO
      AND S.CITY = N'天津'
      AND P.COLOR = N'红'
);
```

### 10.5 找出工程 J2 使用的各种零件名称及数量

```sql
SELECT P.PNAME, SPJ.QTY
FROM SPJ
JOIN P ON SPJ.PNO = P.PNO
WHERE SPJ.JNO = 'J2';
```

### 10.6 找出上海供应商供应的所有零件号码

```sql
SELECT DISTINCT SPJ.PNO
FROM SPJ
JOIN S ON SPJ.SNO = S.SNO
WHERE S.CITY = N'上海';
```

### 10.7 删除 S2 供应商及其供应记录

```sql
DELETE FROM SPJ
WHERE SNO = 'S2';

DELETE FROM S
WHERE SNO = 'S2';
```

### 10.8 插入供应记录

```sql
INSERT INTO SPJ(SNO, PNO, JNO, QTY)
VALUES ('S2', 'P4', 'J6', 200);
```

---

## 11. 往年题改写三：STUDENT-TEACHER-COURSE-SCORE

关系模式：

```text
STUDENT(NO, NAME, SEX, BIRTHDAY, CLASS)
TEACHER(NO, NAME, SEX, BIRTHDAY, PROF, DEPART)
COURSE(CNO, CNAME, TNO)
SCORE(NO, CNO, DEGREE)
```

### 11.1 显示每个学生姓名和出生日期

```sql
SELECT NAME, BIRTHDAY
FROM STUDENT;
```

### 11.2 显示所有姓王的学生记录

```sql
SELECT *
FROM STUDENT
WHERE NAME LIKE N'王%';
```

### 11.3 显示成绩在 60 到 80 之间的记录

```sql
SELECT *
FROM SCORE
WHERE DEGREE BETWEEN 60 AND 80;
```

### 11.4 显示男教师及其所上的课程

```sql
SELECT T.NAME AS TeacherName, C.CNAME
FROM TEACHER AS T
JOIN COURSE AS C ON T.NO = C.TNO
WHERE T.SEX = N'男';
```

### 11.5 选出和李军同性别且同班的学生姓名

```sql
SELECT S.NAME
FROM STUDENT AS S
WHERE S.SEX = (
    SELECT SEX FROM STUDENT WHERE NAME = N'李军'
)
AND S.CLASS = (
    SELECT CLASS FROM STUDENT WHERE NAME = N'李军'
);
```

若不包括李军本人：

```sql
AND S.NAME <> N'李军'
```

### 11.6 插入学生

```sql
INSERT INTO STUDENT(NO, NAME, SEX, BIRTHDAY, CLASS)
VALUES ('999', N'程功', N'男', '1980-10-01', '95035');
```

### 11.7 修改学生班号

```sql
UPDATE STUDENT
SET CLASS = '95031'
WHERE NO = '999';
```

### 11.8 删除学生

```sql
DELETE FROM STUDENT
WHERE NO = '999';
```

---

## 12. “全部/至少所有”除法题模板

题型关键词：“选修了某老师所授全部课程”“供应了某供应商供应的全部零件”。

通用结构：找 X，使得不存在一个 Y，不满足 X 与 Y 的关系。

例：查询选修了 LIU 老师所授全部课程的学生姓名。

```sql
SELECT S.Sname
FROM S
WHERE NOT EXISTS (
    SELECT 1
    FROM C
    WHERE C.Teacher = 'LIU'
      AND NOT EXISTS (
          SELECT 1
          FROM SC
          WHERE SC.Sno = S.Sno
            AND SC.Cno = C.Cno
      )
);
```

记忆：两个 `NOT EXISTS` = “对于所有”。

---

## 13. 考试写 SQL 的 8 条规则

1. 表名、列名先看题目，不要自己改名。
2. 中文字符串用 `N'中文'`。
3. 多表查询尽量写 `JOIN ... ON ...`，少写逗号连接。
4. 聚合查询中，`SELECT` 里的非聚合列必须出现在 `GROUP BY` 中。
5. 分组前筛选写 `WHERE`，分组后筛选写 `HAVING`。
6. 修改/删除一定写 `WHERE`。
7. 有外键时，删除先删子表，再删父表。
8. 授权题看清楚对象：表、视图、列级权限。
