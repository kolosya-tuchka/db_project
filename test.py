import mysql.connector

# Подключение к MySQL
try:
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
	password="12345678"
    )
    print("Подключение успешно!")
except mysql.connector.Error as err:
    print(f"Ошибка подключения: {err}")

