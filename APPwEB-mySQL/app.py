from flask import Flask, render_template, request, redirect, url_for, flash
import pymysql

app = Flask(__name__)
app.secret_key = 'supersecretkey'  

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        
        db_host = request.form['db_host']
        db_user = request.form['db_user']
        db_password = request.form['db_password']
        db_name = request.form['db_name']

        
        try:
            connection = pymysql.connect(host=db_host, user=db_user, password=db_password, db=db_name)
            connection.close()
            # Redirigimos a la página que muestra las tablas si la conexión es exitosa
            return redirect(url_for('tablas', db_host=db_host, db_user=db_user, db_password=db_password, db_name=db_name))
        except Exception as e:
            flash(f"Error de conexión: {str(e)}")

    return render_template('index.html')


@app.route('/tablas')
def tablas():
    db_host = request.args.get('db_host')
    db_user = request.args.get('db_user')
    db_password = request.args.get('db_password')
    db_name = request.args.get('db_name')

    connection = pymysql.connect(host=db_host, user=db_user, password=db_password, db=db_name)
    cursor = connection.cursor()
    cursor.execute("SHOW TABLES;")
    tables = cursor.fetchall()
    connection.close()

    return render_template('tablas.html', tables=tables, db_host=db_host, db_user=db_user, db_password=db_password, db_name=db_name)


@app.route('/mostrar_tabla/<nombre_tabla>')
def mostrar_tabla(nombre_tabla):
    db_host = request.args.get('db_host')
    db_user = request.args.get('db_user')
    db_password = request.args.get('db_password')
    db_name = request.args.get('db_name')

    connection = pymysql.connect(host=db_host, user=db_user, password=db_password, db=db_name)
    cursor = connection.cursor()

    
    cursor.execute(f"SELECT * FROM {nombre_tabla};")
    registros = cursor.fetchall()

    
    column_names = [desc[0] for desc in cursor.description]

    connection.close()

    return render_template('tabla.html', registros=registros, column_names=column_names, nombre_tabla=nombre_tabla, db_host=db_host, db_user=db_user, db_password=db_password, db_name=db_name)


if __name__ == '__main__':
    app.run(debug=True)
