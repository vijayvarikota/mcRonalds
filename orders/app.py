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
    return "[Stretch TODO] Add api and or pages for adding new orders"

if __name__ == "__main__":
    mysql.init_app(app)

    # Cursor setup
    conn = mysql.connect()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    # Load orders data into database
    f = open('data/orders.json')
    data = json.load(f)
    

    # For each of the entry insert into db
    for entry in data:
        cursor.execute(
            """INSERT INTO orders (
                name,
                service,
                ordered_at
            ) VALUES (%s,%s,%s)
            """, 
            (entry['name'], entry['service'], entry['ordered_at'])
        )

        cursor.execute("SELECT LAST_INSERT_ID() as ID;")
        order_entry = cursor.fetchone()
        

        for item in entry['items']:
            # {"name": "Cassoulet for Today", "paid_per_unit": 262, "quantity": 1}
            cursor.execute(
            """INSERT INTO order_items (
                order_id,
                item_name,
                paid_per_unit,
                quantity
            ) VALUES (%s,%s,%s,%s)
            """, 
            (order_entry['ID'], item['name'], item['paid_per_unit'], item['quantity'])
        )

    # Closing file
    f.close()      

    # TODO: Move this over once the airflow DAG is fixed
    cursor.execute("""
    create or replace table orders_summary as (
        Select 
            orders.service
            , orders.id as order_id
            , orders.name as customer
            , orders.ordered_at
            , cast(orders.ordered_at as date) as order_date
            , items.name as item_name
            , order_items.quantity
            , items.cook_time * order_items.quantity as total_time
            , items.price_per_unit * order_items.quantity as acutal_cost
            , order_items.paid_per_unit * order_items.quantity as price_paid
            , round(items.price_per_unit * order_items.quantity /100, 2) as acutal_cost_usd
            , round(order_items.paid_per_unit * order_items.quantity/100, 2) as price_paid_usd
            , CAST(order_items.paid_per_unit * order_items.quantity AS SIGNED) - CAST(items.price_per_unit * order_items.quantity AS SIGNED) as profits
            , round(
                (CAST(order_items.paid_per_unit * order_items.quantity AS SIGNED) 
                    - CAST(items.price_per_unit * order_items.quantity AS SIGNED)
                )/100, 2) as profits_usd
            , order_items.paid_per_unit/items.cook_time as cost_efficiency_ratio
        from items, orders, order_items  
        where items.name = order_items.item_name and order_items.order_id = orders.id 
    );
    """)

    conn.commit()
    

    app.run(debug=True,host='0.0.0.0',port=5012)