create database css;
use css;

create table `items` (
  `name` varchar(250) NOT NULL primary key,
  `cook_time` int unsigned NOT NULL,
  `price_per_unit` int unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


create table `orders` (
  `id` int unsigned AUTO_INCREMENT primary key NOT NULL,
  `name` varchar(250) NOT NULL,
  `service` varchar(250),
  `ordered_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

create table `order_items` (
  `id` int unsigned AUTO_INCREMENT primary key NOT NULL,
  `order_id` int unsigned,
  `item_name` varchar(250) NOT NULL,
  `paid_per_unit` int unsigned NOT NULL,
  `quantity` int unsigned NOT NULL,
  
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (item_name) REFERENCES items(name)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;