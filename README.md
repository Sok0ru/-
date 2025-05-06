    Команды для тестов БД




    Проверка создания таблицы
SELECT * FROM information_schema.tables 
WHERE table_schema = 'gibdd_fines';

    Проверка данных
SELECT * FROM inspectors LIMIT 5;

mysql -u gibdd_admin -p gibdd_fines < script.sql
    Или в интерактивном режиме:
mysql -u gibdd_admin -p
USE gibdd_fines;
SOURCE script.sql;
