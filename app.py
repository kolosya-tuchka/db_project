from flask import Flask, request, jsonify, render_template
import mysql.connector
import os
import json

folder = os.getcwd()
app = Flask(__name__, static_folder=folder, template_folder=folder)

with open('config.json', 'r') as config_file:
    config = json.load(config_file)

# Подключение к базе данных
connection = mysql.connector.connect(
        host=config['host'],
        user=config['user'],
        password=config['password'],
        database=config['database']
)

# Создание объекта курсора
cursor = connection.cursor()


def execute_sql_script(file_path):
    with open(file_path, 'r') as file:
        sql_script = file.read()
    cursor.execute(sql_script)


def execute_migrations():
    for file_name in os.listdir('migrations'):
        if file_name.endswith('.sql'):
            execute_sql_script(os.path.join('migrations', file_name))


# Функция для создания базы данных и таблиц
def setup_database():
    execute_sql_script('create_db.sql')
    execute_sql_script('fill_tables.sql')
    execute_migrations()
    execute_sql_script('triggers.sql')
    execute_sql_script('procedures_and_functions.sql')


if __name__ == '__main__':
    setup_database()
    app.run(host='185.196.117.180')
