1.	Find the most senior employee
Select * from employee
order by title Asc
limit 1;

2.	Which country has the most invoices?
Select BillingCountry , COUNT(*)AS Inv
From invoice
group by BillingCountry
order by COUNT(*) Desc
LIMIT 1;

3.	Top 3 invoice totals
Select Total , COUNT(*) AS New_Total
from invoice
Group by Total
order by COUNT(*) DESC
LIMIT 3;

4.	City with highest total invoice amount (best event location)
Select Billingcity , Billingcountry ,SUM(Total) As New_invoice_total
From invoice
Group by Billingcity , Billingcountry
order by New_invoice_total Desc
limit 1;

5.	Customer who spent the most
Select CustomerId , Sum(Total) AS new_spend
From Invoice
GROUP BY CustomerId
ORDER BY new_spend DESC
LIMIT 1

6.	Customers who listen to Rock music (name + email)
Select Concat(FirstName," ",LastName) AS CustomerName, Count(*) AS Trackcount, Email , GenreId from invoice
Join Customer ON invoice.CustomerId = Customer.CustomerId
join invoiceline ON invoice.invoiceId = invoiceline.invoiceId
join track ON invoiceline.TrackId = track .TrackId
where GenreId = 1
Group by CustomerName , Email , GenreId;

7.	Top 10 Rock artists by track count
Select ArtistId ,COUNT(*) As track_count,genre.Name
from track
Join album ON track.AlbumId = album. AlbumId
join genre ON track.GenreId = genre.GenreId
where genre.Name = 'Rock'
Group by ArtistId,genre.Name
Order by track_count DESC
LIMIT 10;

8.	Tracks longer than the average track length
SELECT 
    Name AS TrackName,
    Milliseconds
FROM Track
WHERE Milliseconds > (
    SELECT AVG(Milliseconds) 
    FROM Track
)
ORDER BY Milliseconds DESC;

9.	Customer spending per artist (using CTE)
WITH CTE AS(
Select Customer.CustomerId  ,Customer.FirstName ,Customer.LastName,artist.Name,SUM(invoiceline.unitprice * invoiceline.Quantity) As Total_Sepnd
from Customer
Join invoice ON Customer . CustomerId = invoice . CustomerId
Join  invoiceline ON invoice.invoiceId = invoiceline.invoiceId
Join  track ON invoiceline.TrackId = track.TrackId
Join album ON track.AlbumId = album. AlbumId
Join artist ON album.ArtistId = artist.ArtistId
Group by Customer.CustomerId , Customer.FirstName ,Customer.LastName,artist.Name)
Select *
From CTE
ORDER BY Total_Sepnd DESC;

10.	Most popular genre by country (using window function)
WITH GENREPOPULARITY AS(
Select i.BillingCountry,g.GenreId,g.Name,COUNT(*) AS Name_count,
ROW_NUMBER() OVER (
            PARTITION BY i.BillingCountry
            ORDER BY COUNT(*) DESC
        ) AS GenreRank
 from invoice i
join invoiceline il ON i.invoiceId = il.invoiceId
join track t ON il.TrackId = t.TrackId
Join genre g ON t.GenreId = g.GenreId
Group by i.BillingCountry,g.GenreId,g.Name)
Select i.BillingCountry,g.GenreId,g.Name, Name_count 
From GENREPOPULARITY
WHERE GenreRank = 1
order by Name_count;
(Another method)
WITH GenrePopularity AS (
    SELECT 
        i.BillingCountry,
        g.Name AS GenreName,
        COUNT(*) AS Name_count,
        ROW_NUMBER() OVER (
            PARTITION BY i.BillingCountry
            ORDER BY COUNT(*) DESC
        ) AS GenreRank
    FROM Invoice i
    JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
    JOIN Track t ON il.TrackId = t.TrackId
    JOIN Genre g ON t.GenreId = g.GenreId
    GROUP BY i.BillingCountry, g.Name
)
SELECT BillingCountry, GenreName, Name_count
FROM GenrePopularity
WHERE GenreRank = 1
ORDER BY BillingCountry;
(Another method)
Select i.BillingCountry,g.GenreId,g.Name,COUNT(*) AS Name_count
from invoice i
join invoiceline il ON i.invoiceId = il.invoiceId
join track t ON il.TrackId = t.TrackId
Join genre g ON t.GenreId = g.GenreId
Group by i.BillingCountry,g.GenreId,g.Name
order by Name_count DESC;

11.	Top-spending customer in each country
WITH TOP_SPENDING AS(
Select C.CustomerId,C.FirstName ,C.LastName ,i.BillingCountry , SUM(Total) As New_total
From Customer C
JOIN invoice i ON C.CustomerId = i.CustomerId
GROUP BY C.CustomerId,C.FirstName ,C.LastName ,i.BillingCountry
)
Select * 
From TOP_SPENDING
ORDER BY New_Total DESC;

(Another method)
WITH TOP_SPENDING AS (
    SELECT C.CustomerId,
           C.FirstName,
           C.LastName,
           i.BillingCountry,
           SUM(Total) AS New_total,
           RANK() OVER (PARTITION BY i.BillingCountry ORDER BY SUM(Total) DESC) AS rnk
    FROM Customer C
    JOIN Invoice i ON C.CustomerId = i.CustomerId
    GROUP BY C.CustomerId, C.FirstName, C.LastName, i.BillingCountry
)
SELECT CustomerId, FirstName, LastName, BillingCountry, New_total
FROM TOP_SPENDING
WHERE rnk = 1
ORDER BY BillingCountry;
