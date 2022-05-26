"""
Loads orders json data into database
"""

from flask import Flask
from flaskext.mysql import MySQL

import json
import pymysql

app = Flask(__name__)
mysql = MySQL()

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'root'
app.config['MYSQL_DATABASE_DB'] = 'css'
app.config['MYSQL_DATABASE_HOST'] = 'db'



@app.route('/')
def index():
    return "[Stretch TODO] Add api and or pages for adding new items"

if __name__ == "__main__":
    mysql.init_app(app)

    # Cursor setup
    conn = mysql.connect()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    # Load orders data into database
    f = open('data/items.json')
    data = json.load(f)
    

    # TODO (if time permits): Use ORM to add new items
    # For each of the entry insert into db
    for entry in data:
        cursor.execute(
            """INSERT INTO items (
                name,
                cook_time,
                price_per_unit
            ) VALUES (%s,%s,%s)
            ON DUPLICATE KEY UPDATE
            cook_time = %s, price_per_unit = %s;
            """, 
            (entry['name'], entry['cook_time'], entry['price_per_unit'], entry['cook_time'], entry['price_per_unit'])
        )

    conn.commit()
    
    # Closing file
    f.close()
    app.run(debug=True,host='0.0.0.0',port=5011)