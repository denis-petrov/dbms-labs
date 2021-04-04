-- 1. Добавить внешние ключи.
ALTER TABLE lesson ADD FOREIGN KEY (id_teacher) REFERENCES teacher(id_teacher);
ALTER TABLE lesson ADD FOREIGN KEY (id_subject) REFERENCES subject(id_subject);
ALTER TABLE lesson ADD FOREIGN KEY (id_group) REFERENCES "group"(id_group);

ALTER TABLE mark ADD FOREIGN KEY (id_student) REFERENCES student(id_student);
ALTER TABLE mark ADD FOREIGN KEY (id_lesson) REFERENCES lesson(id_lesson);

ALTER TABLE student ADD FOREIGN KEY (id_group) REFERENCES "group"(id_group);

-- 2. Выдать оценки студентов по информатике если они обучаются данному
-- предмету. Оформить выдачу данных с использованием view.
CREATE VIEW computer_science_marks AS
    SELECT
     sub.name as lession_name, s.id_student, s.name as student_name, mark.mark
    FROM
        mark
    INNER JOIN lesson l on l.id_lesson = mark.id_lesson
    INNER JOIN student s on s.id_student = mark.id_student
    INNER JOIN subject sub on sub.id_subject = l.id_subject
    WHERE sub.id_subject = 2;


-- 3. Дать информацию о должниках с указанием фамилии студента и названия
-- предмета. Должниками считаются студенты, не имеющие оценки по предмету,
-- который ведется в группе. Оформить в виде процедуры, на входе
-- идентификатор группы.
CREATE OR REPLACE FUNCTION get_all_debtors_group ()
    RETURNS TABLE (
        id_group INT,
        subject_name varchar,
        student_name varchar
    )
    LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
          g.id_group, sub.name, st.name
        FROM
            student st
        INNER JOIN lesson les on st.id_group = les.id_group
        INNER JOIN subject sub on sub.id_subject = les.id_subject
        INNER JOIN "group" g on g.id_group = les.id_group
        WHERE id_student NOT IN
        (
            SELECT
                s.id_student
            FROM
                mark m
            INNER JOIN lesson l on l.id_lesson = m.id_lesson
            INNER JOIN student s on s.id_student = m.id_student
        );
END
$$;

SELECT * FROM get_all_debtors_group();



-- 4. Дать среднюю оценку студентов по каждому предмету для тех предметов, по
-- которым занимается не менее 35 студентов.
SELECT
    sub.name, avg(m.mark)
FROM
    mark m
INNER JOIN lesson l on l.id_lesson = m.id_lesson
INNER JOIN "group" g on g.id_group = l.id_group
INNER JOIN student s on s.id_student = m.id_student
INNER JOIN subject sub on sub.id_subject = l.id_subject
GROUP BY sub.name
HAVING count(s.id_student) >= 35;




-- 5. Дать оценки студентов специальности ВМ по всем проводимым предметам с
-- указанием группы, фамилии, предмета, даты. При отсутствии оценки заполнить
-- значениями NULL поля оценки.
SELECT DISTINCT
    g.name, s.name, sub.name, m.mark, l.date
FROM student s
INNER JOIN "group" g on s.id_group = g.id_group
RIGHT JOIN mark m on s.id_student = m.id_student
INNER JOIN lesson l on g.id_group = l.id_group
INNER JOIN subject sub on sub.id_subject = l.id_subject
WHERE g.id_group = 3;




-- 6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
-- БД до 12.05, повысить эти оценки на 1 балл
UPDATE
    mark m
SET
    mark = mark + 1
FROM
    "group" g
INNER JOIN lesson l on g.id_group = l.id_group
WHERE
    g.id_group = 1 AND m.mark < 5 AND l.date < '2019-05-12';



-- 7. Добавить необходимые индексы
CREATE UNIQUE INDEX IX_group_name ON "group"(name);

CREATE INDEX IX_lesson_date ON lesson(date);

CREATE INDEX IX_mark_mark ON mark(mark);

CREATE INDEX IX_student_name ON student(name);
CREATE INDEX IX_student_phone ON student(phone);

CREATE UNIQUE INDEX IX_subject_name ON subject(name);

CREATE INDEX IX_teacher_name ON teacher(name);
CREATE INDEX IX_teacher_phone ON teacher(phone);