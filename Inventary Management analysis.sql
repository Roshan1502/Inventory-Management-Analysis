Create database Inventary;
Use Inventary;
select * from customer; 
select * from employee;
select * from orderdetails;
select * from orders;
select * from product;
select * from warehouse;
select * from region;
/* count of total customer */
select count(customerid) from customer;
/* count of employee in each of the jobe title*/
select count(employeeid),warehouseid  from employee
group by employeejobtitle
order by count(employeeid) desc;
select count(productid) from product;
select warehouse.warehousename,count(employee.employeeid),warehouse.WarehouseID from employee 
join warehouse on  employee.WarehouseID=warehouse.WarehouseID
group by warehouse.WarehouseID,warehouse.warehousename
order by count(employee.employeeid) desc;
/* maximum orderitem quantity of an product */
select sum(orderdetails.orderitemquantity),product.productid, product.productname from orderdetails
join product on product.productid=orderdetails.productid
group by product.productname,product.productid
order by sum(orderdetails.orderitemquantity) desc;
/*how many orderitemquantity are shipped ,canceled ,pending */
select sum(orderitemquantity),orderstatus from orderdetails
group by orderstatus;
/* which product have maximum per unit price */
select max(orderdetails.perunitprice),product.productid,product.productname from orderdetails
join product on product.productid=orderdetails.productid
group by product.productname,product.productid 
order by max(orderdetails.perunitprice) desc;
/*  which customer having mamximum total price */
select sum(od.orderitemquantity*od.perunitprice) as total_sales,c.customername from orderdetails as od
join orders as o  on o.orderid=od.orderid
join customer as c on c.customerid=o.customerid
group by c.customername
order by total_sales desc;
/* which product have minleast cost   */
select min(p.productstandardcost) as minleastprice,p.productid,p.productname,p.categoryname from product as p 
group by p.categoryname,p.productname,p.productid
order by minleastprice desc
limit 1;
/* which product product have max profit */
select max(p.profit) ,p.productname,p.categoryname from product as p 
group by p.categoryname,p.productname
order by max(p.profit) desc
limit 1;
/* which product having min peoduct list price  as per category*/
SELECT MIN(p.productlistprice), p.productname, p.categoryname FROM product AS p
GROUP BY p.categoryname, p.productname
ORDER BY MIN(p.productlistprice)
LIMIT 1;
/* which product have maximum productlsitprice */
SELECT Max(p.productlistprice), p.productname, p.categoryname FROM product AS p
GROUP BY p.categoryname, p.productname
ORDER BY Max(p.productlistprice) desc
LIMIT 1;
select max(p.profit),p.productname,p.categoryname from product as p
where categoryname='CPU'
group by p.categoryname,p.productname
order by max(p.profit) desc
limit 1;
/* maximum profit product in each category*/
SELECT p.productid,p.productname,p.categoryname,p.profit
FROM product p
JOIN (
    SELECT 
        categoryname,
        MAX(profit) AS max_profit
    FROM 
        product
    GROUP BY 
        categoryname
) AS max_table
ON 
    p.categoryname = max_table.categoryname
    AND p.profit = max_table.max_profit;
/* max orders in which day */
Select count(orderid),orderdate from orders
group by orderdate
order by count(orderid) desc;
/* count of warehouse in particular address */
Select count(warehouseid), warehouseaddress from warehouse
group by warehouseaddress
order by count(warehouseid) desc;
/* which customer have maximum customerlimit */
SELECT customername, customerid, customeremail, customercreditlimit FROM customer
ORDER BY customercreditlimit DESC
LIMIT 1;
/* which product cancelled */
select p.productid,p.productname,p.categoryname,p.productdescription, o.orderitemquantity from orderdetails as o
join product as p on p.productid=o.productid
where orderstatus='Canceled'
order by o.orderitemquantity desc;
/* what is sum of orderitemquantity of itemin each category and canceled item  */
SELECT 
    p.categoryname,
    SUM(o.orderitemquantity) AS total_items,
    SUM(CASE WHEN o.orderstatus = 'canceled' THEN o.orderitemquantity ELSE 0 END) AS canceled_items,
	sum(case when o.orderstatus='Pending' then o.orderitemquantity else 0 end ) as pending_items,
    sum(case when o.orderstatus='shipped' then o.orderitemquantity else 0 end ) as shipped_items
FROM orderdetails AS o
JOIN product AS p ON p.productid = o.productid
GROUP BY p.categoryname;
/* what is the total profit in each category */
select Round(sum(profit),2) as total_profit,categoryname from product
group by categoryname ;
/* total product listing price and toal profit in each category and orderstatus */
select p.categoryname, o.orderstatus,Round(sum(p.productlistprice),2) as total_productlistprice, Round(sum(p.profit),2) as total_profit from product as p
join orderdetails as o on o.productid=p.productid 
group by categoryname,orderstatus;
/* Which category has the highest average profit per product */
select categoryname ,avg(profit) from product 
group by categoryname 
order by avg(profit) desc;
/*Which product has the highest profit margin (profit/list price)? */
select productname,categoryname,(profit/productlistprice *100) as profit_margin from product
order by profit_margin desc
limit 1;
/*Which product has the highest profit margin (profit/list price)? */
SELECT 
    p.productid,
    p.productname,
    p.categoryname,
    ROUND((p.profit / p.productlistprice) * 100, 2) AS profit_margin
FROM product p
WHERE ROUND((p.profit / p.productlistprice) * 100, 2) = (
    SELECT 
        MAX(ROUND((p2.profit / p2.productlistprice) * 100, 2))
    FROM product p2
    WHERE p2.categoryname = p.categoryname
);
/* What is the cancellation rate by category (canceled / total items × 100)? */
SELECT 
    p.categoryname,
    SUM(o.orderitemquantity) AS total_items,
    SUM(CASE WHEN o.orderstatus = 'canceled' THEN o.orderitemquantity ELSE 0 END) AS canceled_items,
    ROUND(SUM(CASE WHEN o.orderstatus = 'canceled' THEN o.orderitemquantity ELSE 0 END) * 100.0 / 
          SUM(o.orderitemquantity), 2) AS cancellation_rate
FROM orderdetails o
JOIN product p ON p.productid = o.productid
GROUP BY p.categoryname;
/* What is the fulfillment rate (shipped / total orders)? */
SELECT 
    p.categoryname,
    SUM(o.orderitemquantity) AS total_items,
    SUM(CASE WHEN o.orderstatus = 'shipped' THEN o.orderitemquantity ELSE 0 END) AS canceled_items,
    ROUND(SUM(CASE WHEN o.orderstatus = 'shipped' THEN o.orderitemquantity ELSE 0 END) * 100.0 / 
		SUM(o.orderitemquantity), 2) AS fulfillment_rate
FROM orderdetails o
JOIN product p ON p.productid = o.productid
GROUP BY p.categoryname;
/*Which day of the week sees the most orders on average? */
select weekday(o.orderdate),avg(od.orderitemquantity) as avg_order from orderdetails as od
join orders as o on o.orderid=od.orderid
group by weekday(o.orderdate)
order by avg_order desc;
/*Top 5 customers with the highest number of canceled orders. */
select c.customername,c.customeremail, sum(od.orderitemquantity) as total_orders from customer as c
join orders as o on o.customerid=c.customerid
join orderdetails as od on od.orderid=o.orderid
where od.orderstatus='canceled'
group by customername,customeremail
order by total_orders desc
limit 5;
