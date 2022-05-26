import pandas as pd
import plotly.express as px

from dash import  dcc, html

from utils.db import db_connection

totals_df = pd.read_sql("""
    SELECT 
        service
        , sum(case when profits_usd < 0 then profits_usd else 0 end) as discounts_usd 
        , sum(price_paid_usd) as revenue_usd
        , sum(distinct order_id) as total_orders
        , count(distinct customer) as customers
    FROM orders_summary 
    GROUP BY 1;
""", con=db_connection)

avg_df = pd.read_sql("""
    SELECT 
        service
        , round(avg(order_count)) as avg_orders_per_day
        , round(avg(customers)) as avg_customers_per_day
        , round(avg(revenue),2) as avg_revenue_per_day
        , round(avg(discounts),2) as avg_discounts_per_day
        , round(avg(profits),2) as avg_profits_per_day
    FROM
    (
        select 
            service
            , order_date
            , count(distinct order_id) as order_count
            , sum(price_paid_usd) as revenue
            , count(distinct customer) as customers
            , sum(profits_usd) as profits
            , sum(case when profits_usd < 0 then profits_usd else 0 end) as discounts
        from orders_summary 
        group by 1, 2
    ) t
    GROUP BY 1
    ;
""", con=db_connection)

revenue_chart = px.pie(totals_df, values='revenue_usd', names='service')
customers_chart = px.pie(totals_df, names="service", values="customers")
orders_chart = px.pie(totals_df, names="service", values="total_orders")

avg_revenue_chart = px.bar(avg_df, x="service", y="avg_revenue_per_day", color='avg_revenue_per_day')
avg_customers_chart = px.bar(avg_df, x="service", y="avg_customers_per_day", color='avg_customers_per_day')
avg_orders_chart = px.bar(avg_df, x="service", y="avg_orders_per_day", color='avg_orders_per_day')


layout = html.Div([
    html.H1('Sevice Metrics'),

    html.Center(html.H3('Revenue from each service')),
    dcc.Graph(id='service-stats-revenue', figure=revenue_chart),
    dcc.Graph(id='service-stats-avg_revenue', figure=avg_revenue_chart),
    
    html.Center(html.H3('Orders from each service')),
    dcc.Graph(id='service-stats-discounts', figure=orders_chart),
    dcc.Graph(id='service-stats-avg_orders', figure=avg_orders_chart),
    
   html.Center( html.H3('Customers from each service')),
    dcc.Graph(id='service-stats-customers', figure=customers_chart),
    dcc.Graph(id='service-stats-avg_customers', figure=avg_customers_chart),
    
])