import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.figure_factory as ff

from dash import  dcc, html
from utils.db import db_connection

valuable_df = pd.read_sql("""
    select * 
    from 
    (
        select 
            customer
            , max(ordered_at) as last_order
            , sum(price_paid_usd) as spend_usd
            , RANK() OVER (order by spend_usd desc, last_order desc) as rnk
        from orders_summary
        group by 1
    ) t1
    where rnk <= 10
    order by rnk
    ;
""", con=db_connection)

loyal_df = pd.read_sql("""
    select 
        customer
        , round(avg(orders_per_day)) as avg_orders_per_day
        , round(avg(profits)) as avg_profits_per_day
    from 
    (
        select 
            customer
            , order_date
            , count(distinct order_id) as orders_per_day
            , sum(profits_usd) as profits
        from orders_summary
        group by 1, 2
    ) t1
    group by 1
    order by 2 desc
    limit 10
    ;
""", con=db_connection)

valuable_chart = ff.create_table(valuable_df)
loyal_chart = ff.create_table(loyal_df)

layout = html.Div([
    html.H1('Customer Metrics'),

    html.Center(html.H3('Top 10 Valuable customers')),
    dcc.Graph(figure=valuable_chart),

    html.Center(html.H3('Top 10 Loyal customers')),
    dcc.Graph(figure=loyal_chart),
])