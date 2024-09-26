# Data Analysis of Maven_movies 

# Create a view that will show the film, its category and the actors name. 
                             #Filter the results for the actor whose first name = ‘Nick’.
create view Film_category_actors as
Select film.title, category.name as Film_Category, actor.first_name from film_category
inner join category on film_category.category_id=category.category_id
inner join film on film.film_id=film_category.film_id 
inner join film_actor on film_actor.film_id=film.film_id
inner join actor on actor.actor_id=film_actor.actor_id
where actor.first_name='Nick';


#  Create a view for inactive customers
create view inactive_customers as (
select * from customer
where active = 0); 


# Create a view for films with rating pg
create view Film_with_PG_RAting as
select title, rating from film
where rating = 'PG';


# List the films from the film table ranked by their length in ascending order. 
                                       #Include the film title and its length in the output.
select title, length,
rank() over(order by length asc) 
as Length_Rank from film;


# Calculate the dense rank of films from the film table based on their Replacement cost 
                   #in descending order. Include the film title and Replacement cost in the output.
select title, replacement_cost,
dense_rank() over( order by replacement_cost desc) as Rank_Replacement_Cost 
from film;


# Determine the row number for each customer from the customer table when ordered 
                                                 #by their first name in ascending order.
select first_name, last_name,
row_number() over( order by first_name asc) as RN
 from customer;


# each film in the film table, list the film title, release year, and the title of the film 
                                           #that comes after it in terms of release year.
select title, release_year,
lead(title) over (order by release_year) as Next_film 
 from film;


# Calculate the running total of rental amounts for payments from the payment table.  
                               #Display the payment date, amount, and the running total.
select amount, payment_date,
sum(amount) over(order by payment_date) as running_total
from payment
order by payment_date;


# Retrieve the first and last rental dates for the film titled "Adaptation holes." 
with RankedRentals as (
select film.title,rental.rental_date, RN_Asc,RN_Desc,
row_number() over(partition by film.title order by rental.rental_date asc) as RN_Asc,
row_number() over(partition by film.title order by rental.rental_date desc) as RN_Desc
from film 
inner join inventory on film.film_id=inventory.film_id
inner join rental on inventory.inventory_id=rental.inventory_id
where film.title='Adaptation holes')
select title, rental_date from RankedRentals
where RN_Asc = 1 OR RN_Desc = 1
order by rental_date;


# Provide details including the film title, its initial rental date, and its most recent rental date.
with RankedRentals as (
select film.title,rental.rental_date, 
row_number() over(partition by film.title order by rental.rental_date asc) as RN_Asc,
row_number() over(partition by film.title order by rental.rental_date desc) as RN_Desc
from film 
inner join inventory on film.film_id=inventory.film_id
inner join rental on inventory.inventory_id=rental.inventory_id)
select title, 
min(case when RN_Asc=1 then rental_date end) as Intial_Rental_Date,
max(case when RN_Desc=1 then rental_date end) as most_recent_rental_date 
from RankedRentals
group by title
order by title;



# Write a query to generate a value for the activity_type column which returns the string  “Active” 
                         # or “Inactive” depending  on the value of the customer.active column
                            
# Table name: Customer
select customer_id, first_name, last_name,
 case 
       when customer.active = 1 then 'Active'
	  else 'Inactive' end as activity_type 
from customer;


# Write a query to retrieve the number of rentals for each active customer. For inactive customers 
                                   #the result should be 0.Use case expression and correlated subquery.
# Table name: Customer
select 
    c.customer_id,
    c.first_name,
    c.last_name,
    case
        when c.active = 1 then 
            (select COUNT(*) 
             from rental r 
             where r.customer_id = c.customer_id)
        else 0
    end as rental_count 
from 
    customer c;


# Write a query to show the number of film rentals for May, June and July of 2005 in a single row.
# Table name: rental
SELECT 
    SUM(CASE WHEN rental_date BETWEEN '2005-05-01' AND '2005-05-31' THEN 1 ELSE 0 END) AS May_rentals,
    SUM(CASE WHEN rental_date BETWEEN '2005-06-01' AND '2005-06-30' THEN 1 ELSE 0 END) AS June_rentals,
    SUM(CASE WHEN rental_date BETWEEN '2005-07-01' AND '2005-07-31' THEN 1 ELSE 0 END) AS July_rentals
FROM 
    rental
WHERE 
    rental_date BETWEEN '2005-05-01' AND '2005-07-31';


# Write a query to categorise films based on the inventory level.
# If the count of copies is 0 then ‘Out of stock’
# If the count of copies is 1 or 2 then ‘Scarce’
# If the count of copies is 3 or 4 then ‘Available’
# If the count of copies is >= 5 then ‘Common’
# Table name: film


# Write a query to get each customer along with their total payments, number of payments and 
                                                                      #average payment
# Table name : customer
select c.customer_id, c.first_name, c.last_name,
                      sum(p.amount) as Total_Payments, 
					  count(p.amount) as Number_of_Payments, 
                      avg(p.amount) as Avg_Payment
from customer c inner join payment p 
on c.customer_id=p.customer_id
group by c.customer_id, c.first_name, c.last_name;


# Write a query to create a single row containing the number of films based on the ratings 
                                                      #(G, PG and NC17)
# Table name: film
select 
        sum(case when rating = 'G' then 1 else 0 end) as Rating_G,
        sum(case when rating = 'PG' then 1 else 0 end) as Rating_PG,
        sum(case when rating = 'NC-17' then 1 else 0 end) as Rating_NC17
from film;


# Create a CTE with two named subqueries. The first one gets the actors with last names starting with s. 
            #  The second one gets all the pg films acted by them. Finally show the film id and title.
# Table name: film
 with cte as (
  select film.film_id, film.title, actor.last_name, film.rating
  from film inner join film_actor
  on film.film_id=film_actor.film_id
  inner join actor on film_actor.actor_id=actor.actor_id
  where last_name like 's%' ) 
  select film_id, title   from cte
  where rating = 'PG';
  
  
  

# List the titles of films and the corresponding first and last names of actors who have played 
#roles in those films using inner join on film,film_actor and actor tables.
# Table name: film
select film.title,actor.first_name,actor.last_name from film inner join film_actor on film.film_id=film_actor.film_id
inner join actor on actor.actor_id=film_actor.actor_id ;


#  List the film titles and their respective category name using an INNER JOIN 
                 #between film and film_category and category tables.
#Table name: film
select film.title,category.name from film inner join film_category on film.film_id=film_category.film_id
inner join category on category.category_id=film_category.category_id;


# List the first names, last names, and store IDs of staff members using left join 
                         #between staff and store tables
#Table name: staff
select staff.first_name,staff.last_name,store.store_id from staff left join store on staff.store_id=store.store_id;


# List the first and last names of customers, along with the titles of films they have rented and 
#the corresponding rental dates using left join between customer ,rental ,inventory and film tables.
#Table name: film
select customer.first_name,customer.last_name,film.title,rental.rental_date from customer 
left join rental on customer.customer_id=rental.customer_id
left join inventory on customer.store_id=inventory.store_id
left join film on film.film_id=inventory.film_id;


#  Retrieve the first and last names of actors and their associated awards, including those actors who have awards and 
# their last names start with the letter 'S' using right join between actor and actor_award tables.
#Table name: actor
select actor.first_name,actor.last_name,actor_award.awards from actor right join actor_award on actor.actor_id=actor_award.actor_id
where actor.last_name like 'S%';


# List the first and last names of customers, along with the corresponding city and country names, for customers whose 
# first names start with the letter 'J' using right join between customer,address ,city and country tables .
#Table name: Customer
select customer.first_name,customer.last_name,city.city,country.country from customer 
right join address on customer.address_id=address.address_id 
right join city on address.city_id=city.city_id
right join country on country.country_id=city.country_id
where customer.first_name like 'J%';


# List the first and last names of actors who have not appeared in any films assigned to the "Action" category using
# right join between actor, film_actor, film, film_category and category tables.
#Table name: film
SELECT DISTINCT actor.first_name, actor.last_name
FROM actor
RIGHT JOIN film_actor ON actor.actor_id = film_actor.actor_id
RIGHT JOIN film ON film.film_id = film_actor.film_id
RIGHT JOIN film_category ON film_category.film_id = film.film_id
RIGHT JOIN category ON category.category_id = film_category.category_id
WHERE actor.actor_id NOT IN (
    SELECT actor.actor_id
    FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film ON film.film_id = film_actor.film_id
    JOIN film_category ON film_category.film_id = film.film_id
    JOIN category ON category.category_id = film_category.category_id
    WHERE category.name = 'Action'
);