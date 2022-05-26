import pandas as pd
import plotly.express as px

from dash import  dcc, html

from utils.db import db_connection

volume_df = pd.read_sql("""
    select 
        seq as hr
        , coalesce(avg(order_cnt),0) as avg_orders
        , coalesce(avg(total_quantity),0) as avg_items
    From seq_0_to_23 t1 left join
    (
        Select 
            order_date
            , hour(ordered_at) as hr
            , count(1)  as order_cnt
            , sum(quantity) as total_quantity
        from orders_summary 
        group by 1,2 
    ) t2
    on t1.seq = t2.hr
    Group by 1
    Order by 1;
""", con=db_connection)

orders_chart = px.line(volume_df, x="hr", y="avg_orders")
items_chart = px.line(volume_df, x="hr", y="avg_items")

layout = html.Div([
    html.H1('Volume (peak hours indicator)'),

    html.Center(html.H3('Hourly orders volume')),
    dcc.Graph(id='volume-stats-orders', figure=orders_chart),

    html.Center(html.H3('Hourly items volume')),
    dcc.Graph(id='volume-stats-items', figure=items_chart),
    
])