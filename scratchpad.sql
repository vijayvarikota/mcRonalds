/* 
(OLD queries)

-- Peak hours
select Hr , avg(cnt)
From 
(
Select cast(orders.ordered_at as date),hour(orders.ordered_at) as hr, count(1)  as cnt
from items, orders, order_items  
where items.name = order_items.item_name and order_items.order_id = orders.id 
group by 1,2 
) t
Group by 1
Order by 1;



-- Select 
--     orders.service
--     , orders.name as customer
--     , orders.ordered_at
--     , cast(orders.ordered_at as date) as order_dt
--     , items.name
--     , order_items.quantity
--     , items.cook_time * order_items.quantity as total_time
--     , items.price_per_unit * order_items.quantity as acutal_cost
--     , order_items.paid_per_unit * order_items.quantity as price_paid
    
-- from items, orders, order_items  
-- where items.name = order_items.item_name and order_items.order_id = orders.id 
-- --and order_items.paid_per_unit * order_items.quantity != items.price_per_unit * order_items.quantity
-- limit 20
-- ;


-- Item charts
-- Top 10 popular items
Select 
    items.name, count(distinct orders.id)
from items, orders, order_items  
where items.name = order_items.item_name and order_items.order_id = orders.id 
group by 1
order by 2 desc
limit 10;

-- most profitale items
select item_name, sum(CAST(total_price_paid AS SIGNED) - CAST(total_acutal_cost AS SIGNED)) as profits 
from (
    Select 
    orders.service
    , orders.name as customer
    , orders.ordered_at
    , items.name as item_name
    , order_items.quantity
    , items.cook_time * order_items.quantity as total_time
    , items.price_per_unit * order_items.quantity as total_acutal_cost
    , order_items.paid_per_unit * order_items.quantity as total_price_paid
    , items.price_per_unit * order_items.quantity /100 as total_acutal_cost_usd
    , order_items.paid_per_unit * order_items.quantity/100 as total_price_paid_usd
    from items, orders, order_items  
    where items.name = order_items.item_name and order_items.order_id = orders.id 
) t1
group by 1  
order by 2 desc
;

-- most cost efficient item
select 
    item_name, avg(measure) as cost_efficience_ratio
from (
    Select 
    orders.service
    , orders.name as customer
    , orders.ordered_at
    , items.name as item_name
    , order_items.quantity
    , order_items.paid_per_unit/items.cook_time as measure
    from items, orders, order_items  
    where items.name = order_items.item_name and order_items.order_id = orders.id 
) t1
group by 1  
order by 2 desc
;

-- Customer charts

-- valuable customers
select orders.name, max(orders.ordered_at) as last_order, sum(order_items.paid_per_unit * order_items.quantity) as spend
from items, orders, order_items 
where items.name = order_items.item_name and order_items.order_id = orders.id 
group by 1
order by 3 desc;

-- Loyal customers
select customer, avg(orders_per_day) as avg_orders_per_day
from 
(
select orders.name customer, cast(orders.ordered_at as date) dt, count(distinct orders.id) as orders_per_day
from items, orders, order_items 
where items.name = order_items.item_name and order_items.order_id = orders.id 
group by 1, 2
) t
group by 1
order by 2 desc
limit 20
;

-- Service charts
select 
    service
    , sum(case when profits < 0 them profits else 0 end) as discounts 
    , sum(order_items.paid_per_unit * order_items.quantity) as revenue
    , sum(order_items.quantity) as total_quantity
    , count(distinct orders.customer) as customers
from orders_summary 
group by 1;
*/


------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------
--- Using summary table
------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------

-- Summary table
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



------------------------------------------------------------
--->> Service stats
------------------------------------------------------------
-- per service stats
select 
    service
    , sum(case when profits_usd < 0 then profits_usd else 0 end) as discounts_usd 
    , sum(price_paid_usd) as revenue_usd
    , sum(quantity) as total_quantity
    , count(distinct customer) as customers
from orders_summary 
group by 1;
/*
+-----------+---------------+-------------+----------------+-----------+
| service   | discounts_usd | revenue_usd | total_quantity | customers |
+-----------+---------------+-------------+----------------+-----------+
| DoorDish  |       -830.24 |   256472.48 |          52232 |      2087 |
| GrubDub   |          0.00 |    86652.64 |          17934 |      1008 |
| SuperEats |       -293.26 |   512822.04 |         105320 |      3206 |
+-----------+---------------+-------------+----------------+-----------+
3 rows in set (0.294 sec)
*/

-- Daily average Per service 
select 
    service
    , round(avg(order_count)) as avg_orders_per_day
    , round(avg(customers)) as avg_customers_per_day
    , round(avg(revenue),2) as avg_revenue_per_day
    , round(avg(discounts),2) as avg_discounts_per_day
    , round(avg(profits),2) as avg_profits_per_day
from
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
group by 1
;
/*
+-----------+--------------------+-----------------------+---------------------+-----------------------+---------------------+
| service   | avg_orders_per_day | avg_customers_per_day | avg_revenue_per_day | avg_discounts_per_day | avg_profits_per_day |
+-----------+--------------------+-----------------------+---------------------+-----------------------+---------------------+
| DoorDish  |               2040 |                   776 |            32059.06 |               -103.78 |              691.09 |
| GrubDub   |                695 |                   288 |            10831.58 |                  0.00 |              107.03 |
| SuperEats |               4083 |                  1456 |            64102.76 |                -36.66 |              457.08 |
+-----------+--------------------+-----------------------+---------------------+-----------------------+---------------------+
3 rows in set (0.304 sec)
*/



------------------------------------------------------------
--->> Customer stats
------------------------------------------------------------

-- valuable customers
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
/*
+-------------------+---------------------+-----------+-----+
| customer          | last_order          | spend_usd | rnk |
+-------------------+---------------------+-----------+-----+
| Julie Wright      | 2020-01-27 06:24:00 |    823.34 |   1 |
| Chelsea Diaz      | 2020-01-27 06:21:00 |    735.72 |   2 |
| Joseph Smith      | 2020-01-27 05:59:00 |    728.06 |   3 |
| Kyle Morgan       | 2020-01-26 21:46:00 |    721.92 |   4 |
| Brandon Howard    | 2020-01-27 08:19:00 |    713.50 |   5 |
| Kaitlyn Walker    | 2020-01-26 22:05:48 |    707.40 |   6 |
| Austin Green      | 2020-01-27 06:44:00 |    699.06 |   7 |
| Caitlin Alexander | 2020-01-27 07:16:00 |    679.98 |   8 |
| Travis Bell       | 2020-01-27 05:55:00 |    679.94 |   9 |
| Joshua Walker     | 2020-01-26 21:34:00 |    663.26 |  10 |
+-------------------+---------------------+-----------+-----+
10 rows in set (0.142 sec)
*/

-- Loyal customers
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
/*
+-----------------+--------------------+---------------------+
| customer        | avg_orders_per_day | avg_profits_per_day |
+-----------------+--------------------+---------------------+
| Ashley Phillips |                 10 |                   6 |
| Blake Johnson   |                  8 |                   1 |
| Noah Scott      |                  8 |                   0 |
| Taylor Campbell |                  8 |                   1 |
| Noah Perez      |                  8 |                   0 |
| Julia Rogers    |                  7 |                   2 |
| Alexander L     |                  7 |                   0 |
| Alexandra Cook  |                  7 |                   1 |
| Steven Howard   |                  7 |                   1 |
| Angela Perry    |                  7 |                   0 |
+-----------------+--------------------+---------------------+
10 rows in set (0.305 sec)
*/

------------------------------------------------------------
--->> Item stats
------------------------------------------------------------
-- Top 10 most ordered items
Select 
    item_name, count(distinct order_id) as order_count
from orders_summary
group by 1
order by 2 desc
limit 10;

-- most profitale items
select item_name, sum(profits_usd) as profits
from orders_summary
group by 1  
order by 2 desc
limit 10
;
/*
+--------------------------------------+---------------+
| item_name                            | profits       |
+--------------------------------------+---------------+
| Creamy Paprika Pork                  |        193.92 |
| Chicken Potpie Casserole             |        193.72 |
| Standing Rib Roast                   |        192.06 |
| Country Ribs Dinner                  |        178.24 |
| Sage Pork Chops with Cider Pan Gravy |        178.14 |
| Danish Meatballs with Pan Gravy      |        174.72 |
| Garlic Herbed Beef Tenderloin        |        171.88 |
| Chicken Ranch Mac & Cheese           |        169.82 |
| Skillet Ham & Rice                   |        168.88 |
| Slow-Roasted Chicken with Vegetables |        161.98 |
+--------------------------------------+---------------+
10 rows in set (0.119 sec)
*/

-- most cost efficient item
select 
    item_name
    , round(avg(cost_efficiency_ratio),2) as measure
from orders_summary
group by 1
order by 2 desc
limit 10
;
/*
+--------------------------------------+---------+
| item_name                            | measure |
+--------------------------------------+---------+
| Spaghetti Pie Casserole              |    3.28 |
| Bean & Beef Slow-Cooked Chili        |    2.95 |
| Skillet Ham & Rice                   |    2.63 |
| Sage Pork Chops with Cider Pan Gravy |    2.53 |
| Country Ribs Dinner                  |    2.19 |
| Tuna Mushroom Casserole              |    2.19 |
| Mom's Roast Beef                     |    2.02 |
| Hungarian Short Ribs                 |    1.91 |
| Meat Loaf & Mashed Red Potatoes      |    1.85 |
| Slow-Roasted Chicken with Vegetables |    1.81 |
+--------------------------------------+---------+
10 rows in set (0.151 sec)
*/


-- least cost efficient item
select 
    item_name
    , round(avg(cost_efficiency_ratio),2) as measure
from orders_summary
group by 1
order by 2 
limit 10
;
/*
+--------------------------------------------+---------+
| item_name                                  | measure |
+--------------------------------------------+---------+
| The Ultimate Chicken Noodle Soup           |    0.32 |
| Potluck Macaroni and Cheese                |    0.34 |
| Contest-Winning Broccoli Chicken Casserole |    0.36 |
| Slow-Simmered Burgundy Beef Stew           |    0.42 |
| Quicker Chicken and Dumplings              |    0.45 |
| Easy Chicken Cordon Bleu                   |    0.45 |
| Slow Cooker Beef Tips                      |    0.46 |
| Creole Jambalaya                           |    0.46 |
| Golden Chicken Cordon Bleu                 |    0.47 |
| Dad's Famous Stuffies                      |    0.47 |
+--------------------------------------------+---------+
10 rows in set (0.137 sec)
*/


------------------------------------------------------------
--->> Overall stats
------------------------------------------------------------
-- Peak hours
select seq, coalesce(avg(order_cnt),0) as avg_orders, coalesce(avg(total_quantity),0) as avg_quatity
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