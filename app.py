from flask import Flask, request, jsonify, render_template, redirect, url_for, session, flash
import mysql.connector
import os
import json
import bcrypt

with open('config.json', 'r') as config_file:
    config = json.load(config_file)

folder = os.getcwd()
app = Flask(__name__, static_folder=folder, template_folder=os.path.join(folder, 'templates'))
app.secret_key = 'your_secret_key'  # Необходима для использования сессий

# Подключение к базе данных
connection = mysql.connector.connect(
    host=config['host'],
    user=config['user'],
    password=config['password'],
    database=config['database'],
)

# Создание объекта курсора
cursor = connection.cursor()


def load_sql_script(file_path):
    with open(file_path, 'r') as file:
        sql_script = file.read()
    return sql_script


def load_migrations():
    sql_script = ''
    for file_name in os.listdir('setup_db/migrations'):
        if file_name.endswith('.sql'):
            sql_script += load_sql_script(os.path.join('setup_db/migrations', file_name))
    return sql_script


# Функция для создания базы данных и таблиц
def setup_database():
    sql_script = load_sql_script('setup_db/create_db.sql')
    sql_script += load_sql_script('setup_db/add_users.sql')
    sql_script += load_sql_script('setup_db/add_requests.sql')
    sql_script += load_sql_script('setup_db/fill_tables.sql')
    sql_script += load_migrations()
    sql_script += load_sql_script('setup_db/triggers.sql')
    sql_script += load_sql_script('setup_db/procedures.sql')
    sql_script += 'COMMIT();'
    cursor.execute(sql_script)


@app.route('/')
def index():
    return redirect(url_for('login'))


user_pages = {
    'soldier': 'soldier_page',
    'officer': 'officer_page',
    'admin': 'admin_dashboard'
}


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user_type = request.form['user_type']

        cursor.callproc('CheckUserLogin', (username, user_type))
        for result in cursor.stored_results():
            user = result.fetchone()
        
        if user and bcrypt.checkpw(password.encode('utf-8'), user[1].encode('utf-8')):
            session['user_id'] = user[0]
            session['username'] = username
            session['user_type'] = user_type
            return redirect(user_pages[user_type])
        else:
            return 'Неверное имя пользователя или пароль'

    return render_template('login.html')


@app.route('/change_password', methods=['GET', 'POST'])
def change_password():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    if request.method == 'POST':
        new_password = request.form['new_password']
        confirm_password = request.form['confirm_password']

        if new_password != confirm_password:
            return 'Пароли не совпадают'

        hashed_password = bcrypt.hashpw(new_password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

        user_id = session['user_id']
        cursor.callproc("UpdateUserPassword", (hashed_password, user_id))
        connection.commit()

        return 'Пароль успешно изменен'

    return render_template('change_password.html')


@app.route('/admin_page')
def admin_page():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    return redirect(url_for('admin_dashboard'))

@app.route('/soldier_page')
def soldier_page():
    if 'user_id' not in session or session['user_type'] != 'soldier':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Получение данных солдата
    cursor.callproc('GetSoldierInfo', (user_id,))
    for result in cursor.stored_results():
        soldier_data = result.fetchone()

    if soldier_data:
        soldier_name = soldier_data[0]
        rank_name = soldier_data[1]
        unit_name = soldier_data[2]
        commander_name = soldier_data[3]

        # Получение специальностей солдата
        cursor.callproc('GetSoldierSpecialties', (user_id,))
        for result in cursor.stored_results():
            specialties = [row[0] for row in result]

        return render_template('soldier_page.html',
                               soldier_name=soldier_name,
                               rank_name=rank_name,
                               unit_name=unit_name,
                               commander_name=commander_name,
                               specialties=specialties)
    else:
        return "Ошибка: данные солдата не найдены"


@app.route('/officer_page')
def officer_page():
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Получение данных офицера
    cursor.callproc('GetOfficerInfo', (user_id,))
    for result in cursor.stored_results():
        officer_data = result.fetchone()

    if officer_data:
        officer_name = officer_data[0]
        rank_name = officer_data[1]

        # Получение специальностей офицера
        cursor.callproc('GetOfficerSpecialties', (user_id,))
        for result in cursor.stored_results():
            specialties = [row[0] for row in result.fetchall()]

        return render_template('officer_page.html',
                               officer_name=officer_name,
                               rank_name=rank_name,
                               specialties=specialties)
    else:
        return "Ошибка: данные офицера не найдены"


@app.route('/view_commanded_unit')
def view_commanded_unit():
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Получение данных части, дивизии и армии
    cursor.callproc('GetUnitInfo', (user_id,))
    for result in cursor.stored_results():
        unit_data = result.fetchone()

    if unit_data:
        unit_name = unit_data[0]
        commander_name = unit_data[1]
        division_name = unit_data[2]
        army_name = unit_data[3]
        unit_id = unit_data[4]
        soldier_count = unit_data[5]
        total_weaponry = unit_data[6]

        # Получение списка солдат в части
        cursor.callproc('GetSoldiersInUnit', (unit_id,))
        for result in cursor.stored_results():
            soldiers = result.fetchall()

        # Получение сводки по специальностям
        cursor.callproc('GetSpecialtySummaryForUnit', (unit_id,))
        for result in cursor.stored_results():
            specialties_summary = result.fetchall()

        return render_template('unit_info.html',
                               unit_name=unit_name,
                               commander_name=commander_name,
                               division_name=division_name,
                               army_name=army_name,
                               soldier_count=soldier_count,
                               total_weaponry=total_weaponry,
                               soldiers=soldiers,
                               specialties_summary=specialties_summary)
    else:
        return "Ошибка: данные части не найдены"

@app.route('/view_commanded_division')
def view_commanded_division():
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Получение данных дивизии, армии и местоположения
    cursor.callproc('GetDivisionInfo', (user_id,))
    for result in cursor.stored_results():
        division_data = result.fetchone()

    if division_data:
        division_name = division_data[0]
        commander_name = division_data[1]
        army_name = division_data[2]
        location_name = division_data[3]
        division_id = division_data[4]
        soldier_count = division_data[5]
        total_weaponry = division_data[6]

        # Получение списка частей в дивизии
        cursor.callproc('GetUnitsInDivision', (division_id,))
        for result in cursor.stored_results():
            units = result.fetchall()

        return render_template('division_info.html',
                               division_name=division_name,
                               commander_name=commander_name,
                               army_name=army_name,
                               location_name=location_name,
                               soldier_count=soldier_count,
                               total_weaponry=total_weaponry,
                               units=units)
    else:
        return "Ошибка: данные дивизии не найдены"

@app.route('/view_commanded_army')
def view_commanded_army():
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Получение данных армии
    cursor.callproc('GetArmyInfo', (user_id,))
    for result in cursor.stored_results():
        army_data = result.fetchone()

    if army_data:
        army_name = army_data[0]
        commander_name = army_data[1]
        army_id = army_data[2]
        soldier_count = army_data[3]
        total_weaponry = army_data[4]

        # Получение списка дивизий в армии
        cursor.callproc('GetDivisionsInArmy', (army_id,))
        for result in cursor.stored_results():
            divisions = result.fetchall()

        return render_template('army_info.html',
                               army_name=army_name,
                               commander_name=commander_name,
                               soldier_count=soldier_count,
                               total_weaponry=total_weaponry,
                               divisions=divisions)
    else:
        return "Ошибка: данные армии не найдены"


@app.route('/view_unit/<int:unit_id>')
def view_unit(unit_id):
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Проверка, командует ли офицер дивизией, в которую входит часть
    cursor.callproc('GetCommandedUnitInfo', (unit_id, user_id))
    for result in cursor.stored_results():
        unit_data = result.fetchone()

    if unit_data:
        unit_name = unit_data[0]
        commander_name = unit_data[1]
        division_name = unit_data[2]
        army_name = unit_data[3]
        unit_id = unit_data[4]
        soldier_count = unit_data[5]
        total_weaponry = unit_data[6]

        # Получение списка солдат в части
        cursor.callproc('GetSoldiersInUnit', (unit_id,))
        for result in cursor.stored_results():
            soldiers = result.fetchall()

        # Получение сводки по специальностям
        cursor.callproc('GetSpecialtySummaryForUnit', (unit_id,))
        for result in cursor.stored_results():
            specialties_summary = result.fetchall()

        return render_template('unit_info.html',
                               unit_name=unit_name,
                               commander_name=commander_name,
                               division_name=division_name,
                               army_name=army_name,
                               soldier_count=soldier_count,
                               total_weaponry=total_weaponry,
                               soldiers=soldiers,
                               specialties_summary=specialties_summary)
    else:
        return "Ошибка: у вас нет доступа к этой части"


@app.route('/view_division/<int:division_id>')
def view_division(division_id):
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Проверка, командует ли офицер армией, в которую входит дивизия
    cursor.callproc('GetCommandedDivisionInfo', (division_id, user_id))
    for result in cursor.stored_results():
        division_data = result.fetchone()

    if division_data:
        division_name = division_data[0]
        commander_name = division_data[1]
        army_name = division_data[2]
        location_name = division_data[3]
        division_id = division_data[4]
        soldier_count = division_data[5]
        total_weaponry = division_data[6]

        # Получение списка частей в дивизии
        cursor.callproc('GetUnitsInDivision', (division_id,))
        for result in cursor.stored_results():
            units = result.fetchall()

        return render_template('division_info.html',
                               division_name=division_name,
                               commander_name=commander_name,
                               army_name=army_name,
                               location_name=location_name,
                               soldier_count=soldier_count,
                               total_weaponry=total_weaponry,
                               units=units)
    else:
        return "Ошибка: у вас нет доступа к этой дивизии"


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))


@app.route('/admin_dashboard')
def admin_dashboard():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    return render_template('admin_dashboard.html')


@app.route('/add_speciality_request', methods=['GET', 'POST'])
def add_speciality_request():
    if 'user_id' not in session or session['user_type'] not in ['soldier', 'officer']:
        return redirect(url_for('login'))

    user_id = session['user_id']
    user_type = session['user_type']

    if request.method == 'POST':
        speciality_id = request.form['speciality_id']

        # Проверка, чтобы пользователь не выбирал уже имеющуюся специальность
        if user_type == 'soldier':
            cursor.execute("SELECT COUNT(*) FROM SoldierSpecialties WHERE SoldierID = (SELECT ID FROM Soldier WHERE UserID = %s) AND SpecialityID = %s", (user_id, speciality_id))
        else:
            cursor.execute("SELECT COUNT(*) FROM OfficerSpecialties WHERE OfficerID = (SELECT ID FROM Officer WHERE UserID = %s) AND SpecialityID = %s", (user_id, speciality_id))

        if cursor.fetchone()[0] > 0:
            return 'У вас уже есть эта специальность'

        # Добавление запроса в таблицу Request
        request_details = json.dumps({"speciality_id": speciality_id})
        cursor.execute("INSERT INTO Request (UserID, UserType, RequestType, RequestDetails) VALUES (%s, %s, 'add_speciality', %s)", (user_id, user_type, request_details))
        connection.commit()

        return 'Запрос успешно отправлен'

    cursor.execute("SELECT ID, Name FROM MilitarySpecialties")
    specialties = cursor.fetchall()

    return render_template('add_speciality_request.html', specialties=specialties)


@app.route('/add_soldier_request', methods=['GET', 'POST'])
def add_soldier_request():
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))
    if request.method == 'POST':
        soldier_name = request.form['soldier_name']
        soldier_rank_id = request.form['soldier_rank']  # Получаем id ранга
        # Формируем данные о солдате в формате JSON
        soldier_details = json.dumps({'name': soldier_name, 'rank_id': soldier_rank_id})

        # Запрос к базе данных для добавления нового запроса на добавление солдата
        cursor.execute("INSERT INTO Request (UserID, RequestType, RequestDetails) VALUES (%s, %s, %s)",
                       (session['user_id'], 'add_soldier', soldier_details))
        connection.commit()
        return redirect(url_for('officer_page'))  # Перенаправляем на главную страницу после отправки запроса

    # Запрос к базе данных для извлечения списка доступных рангов для солдата
    cursor.execute("SELECT ID, Name FROM `Rank` WHERE RankType = 'soldier'")
    soldier_ranks = cursor.fetchall()  # Получаем список кортежей (id, name) рангов

    return render_template('add_soldier_request.html', soldier_ranks=soldier_ranks)


@app.route('/add_weaponry_request', methods=['GET', 'POST'])
def add_weaponry_request():
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))
    if request.method == 'POST':
        user_id = session['user_id']
        user_type = session['user_type']
        weapon_type = request.form['weapon_type']
        quantity = request.form['quantity']
        unit_id = request.form['unit']

        request_details = json.dumps({
            'weapon_type': weapon_type,
            'quantity': quantity,
            'unit_id': unit_id
        })

        cursor.execute("INSERT INTO Request (UserID, UserType, RequestType, RequestDetails) VALUES (%s, %s, 'add_weaponry', %s)",
                       (user_id, user_type, request_details))
        connection.commit()
        return redirect(url_for('officer_page'))

    cursor.execute("SELECT ID, Model FROM Weaponry")
    weapons = cursor.fetchall()

    # Определение частей, подчиненных офицеру
    user_id = session['user_id']
    cursor.callproc('GetOfficerUnits', (user_id,))
    for result in cursor.stored_results():
        units = result.fetchall()
    return render_template('add_weaponry_request.html', weapons=weapons, units=units)


@app.route('/promote_soldier_request', methods=['GET', 'POST'])
def promote_soldier_request():
    if 'user_id' not in session or session['user_type'] != 'soldier':
        return redirect(url_for('login'))
    if request.method == 'POST':
        rank_id = request.form['rank_id']
        user_id = session['user_id']

        # Проверка существования запроса
        cursor.execute(
            "SELECT COUNT(*) FROM Request WHERE UserID = %s AND RequestType = 'promote_soldier' AND Status = 'pending'",
            (user_id,))
        if cursor.fetchone()[0] > 0:
            flash('У Вас уже есть запрос на повышение. Дождитесь его запроса.', 'warning')
            return redirect(url_for('promote_soldier_request'))

        # Создание запроса
        request_details = json.dumps({'new_rank_id': rank_id})
        cursor.execute(
            "INSERT INTO Request (UserID, UserType, RequestType, RequestDetails) VALUES (%s, 'soldier', 'promote_to_officer', %s)",
            (user_id, request_details))
        connection.commit()
        flash('Запрос на повышение отправлен успешно.', 'success')
        return redirect(url_for('soldier_page'))

    # Получение доступных рангов для офицера
    cursor.execute("SELECT ID, Name FROM `Rank` WHERE RankType = 'officer'")
    ranks = cursor.fetchall()
    return render_template('promote_request.html', ranks=ranks)


@app.route('/admin_requests', methods=['GET', 'POST'])
def admin_requests():
    if 'user_id' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))

    if request.method == 'POST':
        request_id = request.form['request_id']
        action = request.form['action']

        cursor.execute("SELECT UserID, UserType, RequestDetails, RequestType FROM Request WHERE ID = %s", (request_id,))
        request_data = cursor.fetchone()

        if not request_data:
            return 'Запрос не найден'

        user_id, user_type, request_details, request_type = request_data
        request_details = json.loads(request_details)

        if action == 'approve':
            if request_type == 'add_speciality':
                speciality_id = request_details['speciality_id']
                if user_type == 'soldier':
                    cursor.execute(
                        "INSERT INTO SoldierSpecialties (SoldierID, SpecialityID) VALUES ((SELECT ID FROM Soldier WHERE UserID = %s), %s)",
                        (user_id, speciality_id))
                else:
                    cursor.execute(
                        "INSERT INTO OfficerSpecialties (OfficerID, SpecialityID) VALUES ((SELECT ID FROM Officer WHERE UserID = %s), %s)",
                        (user_id, speciality_id))
            elif request_type == 'add_soldier':
                name = request_details['name']
                rank_id = request_details['rank_id']
                cursor.execute(
                    "INSERT INTO Soldier (Name, RankID) VALUES (%s, %s)",
                    (name, rank_id)
                )
            elif request_type == 'add_weaponry':
                unit_id = request_details['unit_id']
                quantity = request_details['quantity']
                weapon_type = request_details['weapon_type']
                cursor.execute("SELECT Quantity FROM WeaponryInUnit WHERE UnitID = %s AND WeaponryID = %s",
                               (unit_id, weapon_type))
                result = cursor.fetchone()
                if result:
                    cursor.execute("UPDATE WeaponryInUnit SET Quantity = Quantity + %s WHERE UnitID = %s AND WeaponryID = %s",
                                   (quantity, unit_id, weapon_type))
                else:
                    cursor.execute("INSERT INTO WeaponryInUnit (UnitID, WeaponryID, Quantity) VALUES (%s, %s, %s)",
                               (unit_id, weapon_type, quantity,))
            elif request_type == 'promote_to_officer':
                new_rank_id = request_details['new_rank_id']
                cursor.callproc('PromoteSoldierToOfficer', (user_id, new_rank_id))
            connection.commit()
            cursor.execute("UPDATE Request SET Status = 'approved' WHERE ID = %s", (request_id,))
        elif action == 'reject':
            cursor.execute("UPDATE Request SET Status = 'rejected' WHERE ID = %s", (request_id,))

        connection.commit()

    cursor.execute(
        "SELECT r.ID, u.Username, r.UserType, r.RequestType, r.RequestDetails, r.Status FROM Request r JOIN User u ON r.UserID = u.ID WHERE r.Status = 'pending'")
    requests = cursor.fetchall()

    return render_template('admin_requests.html', requests=requests)


@app.route('/new_soldier_request', methods=['POST'])
def new_soldier_request():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']
    user_type = session['user_type']
    request_type = request.form['request_type']
    request_details = json.dumps({
        'soldier_name': request.form['soldier_name'],
        'soldier_rank': request.form['soldier_rank']
    })

    cursor.execute("INSERT INTO Request (UserID, UserType, RequestType, RequestDetails) VALUES (%s, %s, %s, %s)", (user_id, user_type, request_type, request_details))
    connection.commit()

    return redirect(url_for(session['user_type'] + '_page'))


@app.route('/request_history', methods=['GET'])
def request_history():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user_id = session['user_id']
    user_type = session['user_type']

    cursor.execute("SELECT * FROM Request WHERE UserID = %s AND UserType = %s ORDER BY CreatedAt DESC", (user_id, user_type))
    requests = cursor.fetchall()

    return render_template('request_history.html', requests=requests)


@app.route('/create_db')
def create_db():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    try:
        setup_database()
        flash('База данных успешно создана')
    except Exception as e:
        flash(f'Ошибка при создании базы данных: {str(e)}')
    return redirect(url_for('admin_dashboard'))


@app.route('/view_soldier_specialties/<int:soldier_id>')
def view_soldier_specialties(soldier_id):
    if 'user_id' not in session or session['user_type'] != 'officer':
        return redirect(url_for('login'))

    user_id = session['user_id']

    # Проверка, командует ли офицер частью, в которой служит солдат
    cursor.callproc('CheckOfficerCommandingSoldier', (soldier_id, user_id))
    for result in cursor.stored_results():
        soldier_data = result.fetchone()

    if soldier_data:
        soldier_name = soldier_data[0]
        rank_name = soldier_data[1]
        unit_name = soldier_data[2]
        commander_name = soldier_data[3]

        # Получение списка специальностей солдата
        cursor.callproc('GetSoldierSpecialties', (soldier_id,))
        for result in cursor.stored_results():
            specialties = result.fetchall()

        return render_template('soldier_specialties.html',
                               soldier_name=soldier_name,
                               rank_name=rank_name,
                               unit_name=unit_name,
                               commander_name=commander_name,
                               specialties=specialties)
    else:
        return "Ошибка: у вас нет доступа к этому солдату"



# Маршруты для управления частями, дивизиями и армиями
@app.route('/units', methods=['GET'])
def view_units():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    cursor.callproc('GetUnits')
    for result in cursor.stored_results():
        units = result.fetchall()
    return render_template('view_units.html', units=units)


@app.route('/edit_unit/<int:unit_id>', methods=['GET', 'POST'])
def edit_unit(unit_id):
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    if request.method == 'POST':
        name = request.form['name']
        commander_id = request.form['commander_id']
        division_id = request.form['division_id']
        cursor.execute('''
            UPDATE Unit
            SET Name = %s, CommanderID = %s, DivisionID = %s
            WHERE ID = %s
        ''', (name, commander_id, division_id, unit_id))
        connection.commit()
        return redirect(url_for('view_units'))
    cursor.execute('SELECT ID, Name FROM Division')
    divisions = cursor.fetchall()
    cursor.execute('SELECT ID, Name FROM Officer')
    officers = cursor.fetchall()
    cursor.execute('SELECT Name, CommanderID, DivisionID FROM Unit WHERE ID = %s', (unit_id,))
    unit = cursor.fetchone()
    return render_template('edit_unit.html', unit=unit, divisions=divisions, officers=officers)


# Аналогичные маршруты для дивизий и армий
@app.route('/divisions', methods=['GET'])
def view_divisions():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    cursor.callproc('GetDivisions')
    for result in cursor.stored_results():
        divisions = result.fetchall()
    return render_template('view_divisions.html', divisions=divisions)


@app.route('/edit_division/<int:division_id>', methods=['GET', 'POST'])
def edit_division(division_id):
    if request.method == 'GET':
        cursor.execute("SELECT * FROM Division WHERE ID = %s", (division_id,))
        division = cursor.fetchone()

        cursor.execute("SELECT * FROM Location")
        locations = cursor.fetchall()

        cursor.execute("SELECT ID, Name FROM Officer")
        officers = cursor.fetchall()

        return render_template('edit_division.html', division=division, locations=locations, officers=officers)
    name = request.form['name']
    commander_id = request.form['commander']
    location_id = request.form['location']

    cursor.execute("UPDATE Division SET Name = %s, CommanderID = %s, LocationID = %s WHERE ID = %s",
                   (name, commander_id, location_id, division_id))
    connection.commit()

    return redirect(url_for('view_divisions'))


@app.route('/armies', methods=['GET'])
def view_armies():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    cursor.execute('''
        SELECT a.ID, a.Name, o.Name
        FROM Army a
        LEFT JOIN Officer o ON a.CommanderID = o.ID
    ''')
    armies = cursor.fetchall()
    return render_template('view_armies.html', armies=armies)

@app.route('/edit_army/<int:army_id>', methods=['GET', 'POST'])
def edit_army(army_id):
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    if request.method == 'POST':
        name = request.form['name']
        commander_id = request.form['commander_id']
        cursor.execute('''
            UPDATE Army
            SET Name = %s, CommanderID = %s
            WHERE ID = %s
        ''', (name, commander_id, army_id))
        connection.commit()
        return redirect(url_for('view_armies'))
    cursor.execute('SELECT ID, Name FROM Officer')
    officers = cursor.fetchall()
    cursor.execute('SELECT Name, CommanderID FROM Army WHERE ID = %s', (army_id,))
    army = cursor.fetchone()
    return render_template('edit_army.html', army=army, officers=officers)


@app.route('/soldiers')
def view_soldiers():
    cursor.callproc('GetSoldiers')
    for result in cursor.stored_results():
        soldiers = result.fetchall()
    return render_template('view_soldiers.html', soldiers=soldiers)


@app.route('/officers')
def view_officers():
    cursor.callproc('GetOfficers')
    for result in cursor.stored_results():
        officers = result.fetchall()
    return render_template('view_officers.html', officers=officers)


@app.route('/view_users')
def view_users():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    cursor.execute("SELECT ID, Username, UserType FROM User WHERE UserType != 'admin'")
    users = cursor.fetchall()
    return render_template('view_users.html', users=users)


@app.route('/add_soldier', methods=['GET', 'POST'])
def add_soldier():
    if request.method == 'POST':
        name = request.form['name']
        rank_id = request.form['rank_id']
        unit_id = request.form['unit_id']
        user_id = request.form['user_id']

        cursor.execute("INSERT INTO Soldier (Name, RankID, UnitID, UserID) VALUES (%s, %s, %s, %s)",
                       (name, rank_id, unit_id, user_id))
        connection.commit()
        return redirect(url_for('admin_dashboard'))
    cursor.execute("SELECT ID, Name FROM `Rank` r WHERE r.RankType = 'soldier'")
    ranks = cursor.fetchall()
    cursor.execute("SELECT ID, Name FROM Unit")
    units = cursor.fetchall()
    cursor.execute("SELECT ID, Username FROM User WHERE UserType = 'soldier'")
    users = cursor.fetchall()
    return render_template('add_soldier.html', ranks=ranks, units=units, users=users)


@app.route('/add_officer', methods=['GET', 'POST'])
def add_officer():
    if request.method == 'POST':
        name = request.form['name']
        rank_id = request.form['rank_id']
        user_id = request.form['user_id']

        cursor.execute("INSERT INTO Officer (Name, RankID, UserID) VALUES (%s, %s, %s)",
                       (name, rank_id, user_id))
        connection.commit()
        return redirect(url_for('admin_dashboard'))
    cursor.execute("SELECT ID, Name FROM `Rank` WHERE RankType = 'officer'")
    ranks = cursor.fetchall()
    cursor.execute("SELECT ID, Username FROM User WHERE UserType = 'officer'")
    users = cursor.fetchall()
    return render_template('add_officer.html', ranks=ranks, users=users)


@app.route('/add_user', methods=['GET', 'POST'])
def add_user():
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))
    if request.method == 'POST':
        username = request.form['username']
        password = bcrypt.hashpw(request.form['password'].encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        user_type = request.form['user_type']
        cursor.execute("INSERT INTO User (Username, Password, UserType) VALUES (%s, %s, %s)", (username, password, user_type))
        connection.commit()
        return redirect(url_for('view_users'))
    return render_template('add_user.html')


@app.route('/edit_soldier/<int:id>', methods=['GET', 'POST'])
def edit_soldier(id):
    if request.method == 'POST':
        name = request.form['name']
        rank_id = request.form['rank_id']
        unit_id = request.form['unit_id']
        user_id = request.form['user_id']

        cursor.execute("UPDATE Soldier SET Name=%s, RankID=%s, UnitID=%s, UserID=%s WHERE ID=%s",
                       (name, rank_id, unit_id, user_id, id))
        connection.commit()
        return redirect(url_for('view_soldiers'))
    cursor.execute("SELECT * FROM Soldier WHERE ID=%s", (id,))
    soldier = cursor.fetchone()
    cursor.execute("SELECT ID, Name FROM `Rank` WHERE RankType = 'soldier'")
    ranks = cursor.fetchall()
    cursor.execute("SELECT ID, Name FROM Unit")
    units = cursor.fetchall()
    cursor.execute("SELECT ID, Username FROM User WHERE UserType = 'soldier'")
    users = cursor.fetchall()
    return render_template('edit_soldier.html', soldier=soldier, ranks=ranks, units=units, users=users)


@app.route('/edit_officer/<int:id>', methods=['GET', 'POST'])
def edit_officer(id):
    if request.method == 'POST':
        name = request.form['name']
        rank_id = request.form['rank_id']
        user_id = request.form['user_id']

        cursor.execute("UPDATE Officer SET Name=%s, RankID=%s, UserID=%s WHERE ID=%s",
                       (name, rank_id, user_id, id))
        connection.commit()
        return redirect(url_for('view_officers'))
    cursor.execute("SELECT * FROM Officer WHERE ID=%s", (id,))
    officer = cursor.fetchone()
    cursor.execute("SELECT ID, Name FROM `Rank` WHERE RankType = 'officer'")
    ranks = cursor.fetchall()
    cursor.execute("SELECT ID, Username FROM User WHERE UserType = 'officer'")
    users = cursor.fetchall()
    return render_template('edit_officer.html', officer=officer, ranks=ranks, users=users)


@app.route('/edit_user/<int:user_id>', methods=['GET', 'POST'])
def edit_user(user_id):
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))

    if request.method == 'POST':
        username = request.form['username']
        user_type = request.form['user_type']
        cursor.execute("UPDATE User SET Username = %s, UserType = %s WHERE ID = %s", (username, user_type, user_id))
        connection.commit()
        return redirect(url_for('view_users'))

    cursor.execute("SELECT * FROM User WHERE ID = %s", (user_id,))
    user = cursor.fetchone()
    return render_template('edit_user.html', user=user)


@app.route('/delete_soldier/<int:soldier_id>')
def delete_soldier(soldier_id):
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))

    cursor.execute("DELETE FROM Soldier WHERE ID = %s", (soldier_id,))
    connection.commit()
    return redirect(url_for('view_soldiers'))


@app.route('/delete_officer/<int:officer_id>')
def delete_officer(officer_id):
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))

    cursor.execute("DELETE FROM Officer WHERE ID = %s", (officer_id,))
    connection.commit()
    return redirect(url_for('view_officers'))


@app.route('/delete_user/<int:user_id>')
def delete_user(user_id):
    if 'username' not in session or session['user_type'] != 'admin':
        return redirect(url_for('login'))

    cursor.execute("DELETE FROM User WHERE ID = %s", (user_id,))
    connection.commit()
    return redirect(url_for('view_users'))


if __name__ == '__main__':
    app.run(host='185.196.117.180', port=5002)
