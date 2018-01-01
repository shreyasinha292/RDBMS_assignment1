create database restaurant;
use restaurant;
create table customer (
	cust_id integer not null auto_increment,
    cust_name varchar(30) not null,
    dob date,
    address varchar(30),
    gender char(1) check (gender in ('M','F')),
    primary key(cust_id)
    );
    
create table orders(
	order_id integer not null auto_increment,
    cust_id integer,
    date_of_arrival date not null,
    time_of_arrival time not null,
    primary key(order_id),
	constraint `forkey1` foreign key(`cust_id`) references `customer`(`cust_id`)
    );
    



create table menu(
	item_id integer not null auto_increment,
    item_name varchar(30) not null,
    price numeric(4,2) not null,
    primary key(item_id)
    );
    

create table item(
	item_id integer not null,
    order_id integer not null ,
    quantity integer not null,
    constraint `primkey1` primary key(`item_id`,`order_id`),
    constraint `forkey1` foreign key(`item_id`) references `menu`(`item_id`),
    constraint `forkey2` foreign key(`order_id`) references `orders`(`order _id`)
    );
    
create table bill(
	bill_id integer not null,
    order_id integer not null ,
    method_of_payment varchar(30),
    total_amount numeric(6,2) ,
    constraint `primkey1` primary key(`bill_id`),
    constraint `forkey3` foreign key(`order_id`) references `orders`(`order_id`)
    );
    
    
insert into customer values (1,'david','1997-01-12','ferret street','M');
insert into customer values (2,'daisy','1995-03-15','fer street','F');
insert into customer values (3,'dalmia','1989-02-07','park street','M');
insert into customer values (4,'disha','1993-05-19','k2 street','F');
insert into customer values (5,'dino','1994-11-22','tally ho street','M');

insert into orders values (1,1,'2017-10-12','20:00:00');
insert into orders values (2,2,'2017-09-14','21:00:00');
insert into orders values (3,1,'2017-08-13','20:20:00');
insert into orders values (4,3,'2017-07-28','19:56:00');
insert into orders values (5,1,'2017-10-11','18:59:00');
insert into orders values (6,5,'2017-11-08','20:15:00');
insert into orders values (7,4,'2017-12-01','20:05:00');

    
insert into menu values(1,'chocolate milkshake',50.00);
insert into menu values(2,'blueberry milkshake',55.00);
insert into menu values(3,'strawberry milkshake',45.00);
insert into menu values(4,'caramel milkshake',60.00);
insert into menu values(5,'orange milkshake',55.00);
insert into menu values(6,'mango milkshake',30.00);
insert into menu values(7,'papaya milkshake',48.00);    
  

insert into item values(1,1,1);
insert into item values(3,1,2);
insert into item values(7,1,1);
insert into item values(2,2,1);
insert into item values(2,3,4);
insert into item values(5,4,1);
insert into item values(6,4,1);
insert into item values(4,4,1);
insert into item values(7,5,2);
insert into item values(6,6,1);
insert into item values(1,6,1);
insert into item values(7,6,1);
insert into item values(2,6,1);
insert into item values(5,7,4);
insert into item values(3,7,3);

insert into bill values(1,1,'cash',0);
insert into bill values(2,2,'cash',0);
insert into bill values(3,3,'card',0);
insert into bill values(4,4,'card',0);
insert into bill values(5,5,'cash',0);
insert into bill values(6,6,'card',0);
insert into bill values(7,7,'cash',0);


#Q5 view creation
create view vw_customerSnapshot as 
select * from customer
where cust_id = 
(select cust_id from orders group by cust_id order by count(cust_id) desc limit 1);

select * from vw_customerSnapshot;


create view vw_OrderSnapshot as
select * from menu
where item_id =
(select item_id from item group by item_id order by count(item_id) desc limit 1);

select * from vw_OrderSnapshot;


#Q6 function to fetch the time since order was placed by a customer

delimiter $$
create function fn_GetOrderTimeElapsed(customer_id int)
returns time
begin
	declare wait_time time;
    declare curr_time time;
    declare time_arrival time;
    
    select time_of_arrival into time_arrival
    from orders 
    where cust_id = customer_id and date_of_arrival = 
    (select date_of_arrival 
    from orders 
    where cust_id = customer_id 
    order by date_of_arrival limit 1) ;
    set curr_time = current_time();
    
    set wait_time = curr_time - time_arrival;
    return wait_time;
end $$
delimiter ;

#drop function fn_GetOrderTimeElapsed;
select current_time();

select fn_GetOrderTimeElapsed(4);

 #Q7  Procedure to get Order for a customer
 
delimiter $$
create procedure sp_GetOrder(IN CustomerID int)
begin
	
	select i.order_id,cust_id,i.item_id,item_name,price,quantity,date_of_arrival,time_of_arrival
    from item i,orders o,menu m where o.cust_id = CustomerID and o.order_id = i.order_id and i.item_id = m.item_id;
    
end$$
delimiter ;
#drop procedure sp_GetOrder;
call sp_GetOrder(1);

#Q8 Procedure to Generate bill for an order

delimiter $$
create procedure sp_GenerateBill(IN OrderID int , OUT BillAMT numeric(6,2))
begin
	select sum(price) into billAMT from menu m,item i 
    where i.order_id = OrderID and m.item_id = i.item_id;
    
end$$
delimiter ;

#drop procedure sp_GenerateBill;

call sp_GenerateBill(7,@total_amount);
select @total_amount;
