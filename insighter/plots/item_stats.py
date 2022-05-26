import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import plotly.figure_factory as ff

from dash import  dcc, html
from utils.db import db_connection

profitable_df = pd.read_sql("""
    select 
        item_name
        , sum(profits_usd) as profits
    from orders_summary
    group by 1  
    order by 2 desc
    limit 10
    ;
""", con=db_connection)

most_efficient_df = pd.read_sql("""
    select 
        item_name
        , round(avg(cost_efficiency_ratio),2) as measure
    from orders_summary
    group by 1
    order by 2 desc
    limit 10
    ;
""", con=db_connection)

least_efficient_df = pd.read_sql("""
    select 
        item_name
        , round(avg(cost_efficiency_ratio),2) as measure
    from orders_summary
    group by 1
    order by 2
    limit 10
    ;
""", con=db_connection)


profitable_chart = px.bar(profitable_df, x="item_name", y="profits", color='profits')
most_efficient_chart = px.bar(most_efficient_df, x="item_name", y="measure", color='measure')
least_efficient_chart = px.bar(least_efficient_df, x="item_name", y="measure", color='measure')


layout = html.Div([
    html.H1('Item Metrics'),

    html.Center(html.H3('Top profitable')),
    dcc.Graph(figure=profitable_chart),

    html.Center(html.H3('Top efficient (low cook time, more profit)')),
    dcc.Graph(figure=most_efficient_chart),

    html.Center(html.H3('least efficient (high cook time, low profit)')),
    dcc.Graph(figure=least_efficient_chart),
])