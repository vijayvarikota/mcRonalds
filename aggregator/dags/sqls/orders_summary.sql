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