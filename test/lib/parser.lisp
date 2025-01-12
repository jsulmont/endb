(defpackage :endb-test/lib/parser
  (:use :cl :fiveam :endb/lib/parser)
  (:import-from :trivial-utf-8))
(in-package :endb-test/lib/parser)

(in-suite* :lib)

(test lib-parser
  (let ((sql "SELECT a, b, 123, myfunc(b) FROM table_1 WHERE a > b AND b < 100 ORDER BY a DESC, b"))
    (is (equal
         (prin1-to-string '(:select ((#:|a|) (#:|b|) (123) ((:function #:|myfunc| (#:|b|)))) :from
                            ((#:|table_1|)) :where (:and (:> #:|a| #:|b|) (:< #:|b| 100)) :order-by
                            ((#:|a| :desc) (#:|b| :asc))))
         (prin1-to-string (parse-sql sql))))))

(defvar expected-annotation
  (make-array 160
              :initial-contents #(69 114 114 111 114 58 32 85 110 107 110 111 119 110 32 99 111 108 117 109 110
                                  46 10 32 32 32 226 149 173 226 148 128 91 60 117 110 107 110 111 119 110 62
                                  58 49 58 56 93 10 32 32 32 226 148 130 10 32 49 32 226 148 130 32 83 69 76 69
                                  67 84 32 102 111 111 32 60 32 50 10 32 32 32 226 148 130 32 32 32 32 32 32 32
                                  32 226 148 128 226 148 172 226 148 128 32 32 10 32 32 32 226 148 130 32 32 32
                                  32 32 32 32 32 32 226 149 176 226 148 128 226 148 128 226 148 128 32 85 110
                                  107 110 111 119 110 32 99 111 108 117 109 110 46 10 226 148 128 226 148 128
                                  226 148 128 226 149 175 10)
              :element-type '(unsigned-byte 8)))

(test lib-annotate-input-with-error
  (is (equalp expected-annotation (trivial-utf-8:string-to-utf-8-bytes (annotate-input-with-error "SELECT foo < 2" "Unknown column." 7 10)))))

(test empty-input
  (signals sql-parse-error (parse-sql "")))

(test lib-parse-escapes
  (let ((result (caaadr (parse-sql "SELECT \"\\/f\\bo\\fo\\nb\\\\a\\\"\\tr\\r\\u03BB\""))))
    (is (equalp (format nil "/f~Ao~Ao~Ab\\a\"~Ar~Aλ" #\Backspace #\Page #\NewLine #\Tab #\Return) result)))

  (let ((result (caaadr (parse-sql "SELECT '\\/f\\0o\\fo\\nb\\\\a\\'\\v\\
r\\r\\u03BB'"))))
    (is (equalp (format nil "/f~Ao~Ao~Ab\\a'~Ar~Aλ" #\Nul #\Page #\NewLine #\Vt #\Return) result))))

(test lib-parse-sql
  (is (parse-sql "CREATE TABLE t1(a INTEGER, b INTEGER, c INTEGER, d INTEGER, e INTEGER)"))
  (is (parse-sql "INSERT INTO t1(e,c,b,d,a) VALUES(103,102,100,101,104)"))
  (is (parse-sql "SELECT CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END
  FROM t1
 ORDER BY 1"))
  (is (parse-sql "SELECT a+b*2+c*3+d*4+e*5,
       (a+b+c+d+e)/5
  FROM t1
 ORDER BY 1,2"))
  (is (parse-sql "SELECT a+b*2+c*3+d*4+e*5,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       abs(b-c),
       (a+b+c+d+e)/5,
       a+b*2+c*3
  FROM t1
 WHERE (e>c OR e<d)
   AND d>e
   AND EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
 ORDER BY 4,2,1,3,5"))
  (is (parse-sql "SELECT CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       CASE WHEN a<b-3 THEN 111 WHEN a<=b THEN 222
        WHEN a<b+3 THEN 333 ELSE 444 END,
       a+b*2+c*3+d*4,
       a+b*2+c*3,
       c,
       CASE WHEN c>(SELECT avg(c) FROM t1) THEN a*2 ELSE b*10 END,
       abs(b-c)
  FROM t1
 WHERE EXISTS(SELECT 1 FROM t1 AS x WHERE x.b<t1.b)
    OR b>c
    OR d NOT BETWEEN 110 AND 150
 ORDER BY 4,1,5,2,6,3,7"))
  (is (parse-sql "SELECT c,
       d-e,
       CASE a+1 WHEN b THEN 111 WHEN c THEN 222
        WHEN d THEN 333  WHEN e THEN 444 ELSE 555 END,
       a+b*2+c*3+d*4,
       e
  FROM t1
 WHERE d NOT BETWEEN 110 AND 150
    OR c BETWEEN b-2 AND d+2
    OR (e>c OR e<d)
 ORDER BY 1,5,3,2,4"))
  (is (parse-sql "SELECT a,
       (SELECT count(*) FROM t1 AS x WHERE x.b<t1.b),
       a+b*2+c*3+d*4+e*5,
       d
  FROM t1
 WHERE a IS NULL"))
  (is (parse-sql "CREATE TABLE t1(
  a1 INTEGER PRIMARY KEY,
  b1 INTEGER,
  x1 VARCHAR(40)
)"))
  (is (parse-sql "INSERT INTO t1 VALUES(382,414,67,992,483,'table tn1 row 1')"))
  (is (parse-sql "CREATE INDEX t1i0 ON t1(a1,b1,c1,d1,e1,x1)"))
  (is (parse-sql "CREATE INDEX t8all ON t8(e8 DESC, d8 ASC, c8 DESC, b8 ASC, a8 DESC)"))
  (is (parse-sql "SELECT e1 FROM t1
   WHERE a1 in (767,433,637,363,776,109,451)
      OR c1 in (683,531,654,246,3,876,309,284)
      OR (b1=738)
EXCEPT
  SELECT b8 FROM t8
   WHERE NOT ((761=d8 AND b8=259 AND e8=44 AND 762=c8 AND 563=a8)
           OR e8 in (866,579,106,933))
EXCEPT
  SELECT e6 FROM t6
   WHERE NOT ((825=b6 OR d6=500)
           OR (230=b6 AND e6=731 AND d6=355 AND 116=a6))
UNION
  SELECT b2 FROM t2
   WHERE (d2=416)
UNION
  SELECT a4 FROM t4
   WHERE c4 in (806,119,489,658,366,424,2,471)
      OR (215=c4 OR c4=424 OR e4=405)
UNION ALL
  SELECT a9 FROM t9
   WHERE (e9=195)
      OR (c9=98 OR d9=145)
UNION ALL
  SELECT e5 FROM t5
   WHERE (44=c5 AND a5=362 AND 193=b5)
      OR (858=b5)
UNION
  SELECT d3 FROM t3
   WHERE (b3=152)
      OR (726=d3)
UNION
  SELECT e7 FROM t7
   WHERE d7 in (687,507,603,52,118)
      OR (d7=399 AND e7=408 AND 396=b7 AND a7=97 AND c7=813)
      OR (e7=605 OR 837=b7 OR e7=918)"))
  (is (parse-sql "SELECT * FROM t1"))
  (is (parse-sql "INSERT INTO t1(e,c,b,d,a) VALUES(NULL,102,NULL,101,104)"))
  (is (parse-sql "SELECT cor0.col2 AS col2 FROM tab2 AS cor0 GROUP BY col2 HAVING NOT NULL < NULL"))
  (is (parse-sql "SELECT 20 / - - 96 + CAST ( 90 AS INTEGER ) AS col2"))
  (is (parse-sql "SELECT ALL * FROM tab0 cor0 CROSS JOIN tab2 AS cor1"))
  (is (parse-sql "SELECT + + MIN ( ALL - + 32 ) AS col0, + COUNT ( * ) * + COUNT ( * ) FROM ( tab0 AS cor0 CROSS JOIN tab0 cor1 )"))
  (is (parse-sql "SELECT ALL NULLIF ( - COUNT ( * ), + 67 * - - ( + 25 ) + 89 + - 39 * 63 ) + + 54 AS col2, 11 * 31 * - - ( 70 )"))
  (is (parse-sql "SELECT ALL 74 * - COALESCE ( + CASE - CASE WHEN NOT ( NOT - 79 >= NULL ) THEN 48 END WHEN + + COUNT( * ) THEN 6 END, MIN( ALL + - 30 ) * 45 * 77 ) * - 14"))
  (is (parse-sql "SELECT * FROM tab1 WHERE NULL NOT IN ( col0 * col0 )"))
  (is (parse-sql "SELECT SUM ( + 73 ) * - CASE WHEN NOT ( NOT 27 BETWEEN 15 AND - NULLIF ( - 63, - 28 + + 76 ) ) THEN NULL ELSE + 77 * + 69 END / - CAST ( - 69 AS INTEGER ) AS col0"))
  (is (parse-sql "CREATE UNIQUE INDEX idx_tab2_2 ON tab2 (col1 DESC)"))
  (is (parse-sql "INSERT INTO tab0 VALUES(0,6,5.6,'jtqxx',9,5.19,'qvgba')"))
  (is (parse-sql "DELETE FROM tab0 WHERE col4 > 2.27"))
  (is (parse-sql "DROP TABLE tab0"))
  (is (parse-sql "SELECT ALL col2 FROM tab0 WHERE + col0 IS NOT NULL"))
  (is (parse-sql "DROP VIEW IF EXISTS view_3_tab0_153"))
  (is (parse-sql "CREATE VIEW view_1_tab0_153 AS SELECT pk, col0 FROM tab0 WHERE col0 = 49"))
  (is (parse-sql "DROP VIEW view_1_tab1_153"))
  (is (parse-sql "SELECT pk FROM ( SELECT pk, col0 FROM tab0 WHERE col0 = 49 ) AS tab0_153"))
  (is (parse-sql "SELECT * FROM tab0 cor0 JOIN tab0 AS cor1 ON NULL IS NULL"))
  (is (parse-sql "DROP INDEX t1i1"))
  (is (parse-sql "DROP TABLE IF EXISTS t1"))
  (is (parse-sql "SELECT 1 FROM t1 WHERE 1 IN ()"))
  (is (parse-sql "SELECT 1 FROM t1 WHERE 1 IN (2)"))
  (is (parse-sql "CREATE TABLE t3(z INTEGER UNIQUE)"))
  (is (parse-sql "SELECT x'303132' IN (SELECT * FROM t1)"))
  (is (parse-sql "UPDATE t1 SET x=1 WHERE x>0"))
  (is (parse-sql "UPDATE t1 SET x=3, x=4, x=5"))
  (is (parse-sql "SELECT 1 IN t1"))
  (is (parse-sql "CREATE TEMP VIEW view2 AS SELECT x FROM t1 WHERE x>0"))
  (is (parse-sql "INSERT OR REPLACE INTO view1 VALUES(2,'unknown')"))
  (is (parse-sql "SELECT x FROM t1 WHERE x NOT NULL ORDER BY x"))
  (is (parse-sql "INSERT INTO t1 VALUES(1<<63,'true')"))
  (is (parse-sql "CREATE TABLE partsupp (
  ps_partkey    INTEGER,
  ps_suppkey    INTEGER,
  ps_availqty   INTEGER,
  ps_supplycost INTEGER,
  ps_comment    TEXT,
  PRIMARY KEY (ps_partkey, ps_suppkey),
  FOREIGN KEY (ps_suppkey) REFERENCES supplier(s_suppkey),
  FOREIGN KEY (ps_partkey) REFERENCES part(p_partkey)
)"))
  (is (parse-sql "SELECT * FROM t1 LEFT OUTER JOIN t2 ON t1.a = t2.a"))
  (is (parse-sql "SELECT * FROM t1 LEFT JOIN t2 ON t1.a = t2.a"))
  (is (parse-sql "SELECT * FROM t1 JOIN t2 ON t1.a = t2.a"))
  (is (parse-sql "SELECT DISTINCT * FROM t1"))
  (is (parse-sql "SELECT ALL * FROM t1"))
  (is (parse-sql "SELECT 1; SELECT 1;"))
  (is (parse-sql "SELECT 1;"))
  (is (parse-sql "WITH foo(c) AS (SELECT 1), bar(a, b) AS (SELECT 1, 2) SELECT * FROM foo, bar")))
