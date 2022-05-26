from dash import  dcc, html
from plots import service_stats, customer_stats, item_stats, volume_stats

"""
Read all the individaal plots in one layout.
TODO: make this dynamic, auto load/render all *_stats module from `plots`
"""
layout = html.Div([
    service_stats.layout,
    customer_stats.layout,
    item_stats.layout,
    volume_stats.layout,
])