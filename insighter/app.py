"""
Entrypoint for insighter (Flask + Dash) app, to render all the plotly charts
"""
from flask import Flask
from dash import Dash, dcc, html, Input, Output, callback
import dashboard

server = Flask(__name__)

app = Dash(
    __name__,
    server=server,
    external_stylesheets=['./styles/app.css'],
    suppress_callback_exceptions=True,
)

app.layout = html.Div([
    dcc.Location(id='url', refresh=False),
    html.Div(id='page-content')
])


@callback(Output('page-content', 'children'),
              Input('url', 'pathname'))
def display_page(pathname):
    if pathname == '/':
        return dashboard.layout
    else:
        return 'Invalid url'

if __name__ == "__main__":
    server.run(host='0.0.0.0', port=5010)