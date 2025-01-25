USE mintclassics;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM offices;
SELECT * FROM orders;
SELECT * FROM payments;
SELECT * FROM productlines;
SELECT * FROM products;
SELECT * FROM warehouses;

SHOW tables;


-- Are Some Items Sold More Often Than Others?
SELECT
 p.productName, 
 SUM(od.quantityOrdered) as Total_quantity_sold
FROM products p 
LEFT JOIN orderdetails od 
ON p.productCode = od.productCode 
GROUP BY p.productName
ORDER BY Total_quantity_sold DESC;

-- Does the price seem to affect sales?
SELECT 
    (n * sum_xy - sum_x * sum_y) / 
    SQRT((n * sum_x2 - POW(sum_x, 2)) * (n * sum_y2 - POW(sum_y, 2))) AS price_sales_correlation
FROM (
    SELECT 
        COUNT(*) AS n,
        SUM(p.buyPrice) AS sum_x,
        SUM(od.quantityOrdered) AS sum_y,
        SUM(p.buyPrice * od.quantityOrdered) AS sum_xy,
        SUM(POW(p.buyPrice, 2)) AS sum_x2,
        SUM(POW(od.quantityOrdered, 2)) AS sum_y2
    FROM products p
    LEFT JOIN orderdetails od 
    ON p.productCode = od.productCode
) AS stats;

-- Conduct what-if analysis. For example, what impact would it have on the company and customer service if we reduced the quantity on hand for every item by 5%?
SELECT 
  p.productCode,
  p.productName,
  p.quantityInStock as currentstock,
  ROUND(p.quantityInStock * 0.95,0) as reducedstock,
  CASE 
      WHEN ROUND(p.quantityInStock * 0.95,0) < od.quantityOrdered then 'risk of stockout'
      ELSE 'sufficient stock'
     END AS Stockimpact
     
      
FROM products p
LEFT JOIN 
(
		SELECT productCode, SUM(quantityOrdered) AS quantityOrdered
		FROM orderdetails
		GROUP BY productCode
) od
ON p.productCode = od.productCode
ORDER BY StockImpact, ReducedStock ASC


-- Analyze Warehouse Utilization

SELECT 
    w.warehouseCode,
    w.warehouseName,
    SUM(p.quantityInStock) AS totalstock,
    SUM(od.quantityOrdered) AS totalsales,
    CASE 
        WHEN SUM(p.quantityInStock) = 0 THEN 'No Stock Available'
        WHEN SUM(od.quantityOrdered) / SUM(p.quantityInStock) < 0.2 THEN 'Consider Closure'
        ELSE 'Effective Warehouse'
    END AS WarehouseUtilization
FROM warehouses w
JOIN products p 
ON w.warehouseCode = p.warehouseCode 
LEFT JOIN orderdetails od
ON od.productCode = p.productCode
GROUP BY w.warehouseCode, w.warehouseName 
ORDER BY totalsales ASC;

   