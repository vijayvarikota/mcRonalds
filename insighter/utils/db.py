# from app import app
# from flaskext.mysql import MySQL

# mysql = MySQL()

# # MySQL configurations
# # app.config['MYSQL_DATABASE_USER'] = 'root'
# # app.config['MYSQL_DATABASE_PASSWORD'] = 'root'
# # app.config['MYSQL_DATABASE_DB'] = 'css'
# # app.config['MYSQL_DATABASE_HOST'] = 'db'
# # mysql.init_app(app)


# app.server.config['MYSQL_DATABASE_USER'] = 'root'
# app.server.config['MYSQL_DATABASE_PASSWORD'] = 'root'
# app.server.config['MYSQL_DATABASE_DB'] = 'css'
# app.server.config['MYSQL_DATABASE_HOST'] = 'db'

# mysql = MySQL(app.server)


from sqlalchemy import create_engine

db_connection_str = 'mysql+pymysql://root:root@db/css'
db_connection = create_engine(db_connection_str)