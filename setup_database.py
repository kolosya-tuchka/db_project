from app import setup_database
import json
import mysql.connector

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

setup_database()
