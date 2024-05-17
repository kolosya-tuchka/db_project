from flask import Flask, request, jsonify, render_template, redirect, url_for, session
import mysql.connector
import os
import json
import bcrypt

with open('config.json', 'r') as config_file:
    config = json.load(config_file)

folder = os.getcwd()
app = Flask(__name__, static_folder=folder, template_folder=folder)
app.secret_key = 'your_secret_key'  # Необходима для использования сессий

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


@app.route('/')
def index():
    return redirect(url_for('login'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user_type = request.form['user_type']

        cursor.execute("SELECT ID, Password FROM User WHERE Username = %s AND UserType = %s", (username, user_type))
        result = cursor.fetchone()

        if result and bcrypt.checkpw(password.encode('utf-8'), result[1].encode('utf-8')):
            session['user_id'] = result[0]
            session['username'] = username
            session['user_type'] = user_type
            return redirect(url_for('success'))
        else:
            return 'Неверное имя пользователя или пароль'

    return render_template('login.html')


@app.route('/success')
def success():
    if 'user_id' in session:
        username = session['username']
        user_type = session['user_type']
        return render_template('success.html', username=username, user_type=user_type)
    return redirect(url_for('login'))


@app.route('/logout')
def logout():
    session.pop('user_id', None)
    session.pop('username', None)
    session.pop('user_type', None)
    return redirect(url_for('login'))


if __name__ == '__main__':
    #setup_database()
    app.run(host='185.196.117.180')
