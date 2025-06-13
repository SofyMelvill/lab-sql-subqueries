USE sakila;


-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT * FROM inventory;
SELECT * FROM film;

SELECT 
    f.title,
    COUNT(i.inventory_id) AS total_copies
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE'
GROUP BY f.title;

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT AVG(length) FROM film;

SELECT 
    title, 
    length
FROM film
WHERE length > (
    SELECT AVG(length) FROM film
)
ORDER BY length DESC;

SELECT 
    title, 
    length,
    (SELECT ROUND(AVG(length), 2) FROM film) AS average_length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".

SELECT * FROM film_actor; -- actor_id, film_id
SELECT * FROM actor; -- actor_id
SELECT * FROM film; -- film_id


-- SELECT first_name, last_name FROM actor a
-- JOIN film_actor fa ON a.actor_id = fa.actor_id
-- JOIN film f ON fa.film_id = f.film_id
-- WHERE f.title = 'ALONE TRIP';

SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'ALONE TRIP'));

-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT * FROM category; -- category_id + name
SELECT * FROM film_category; -- film_id + category_id
SELECT * FROM film; -- film_id

SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id = (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    name = 'Family'));

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id = (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);


SELECT 
    c.first_name, 
    c.last_name, 
    c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id 
-- to find the different films that he or she starred in.

SELECT * FROM actor;
SELECT * FROM film;
SELECT * FROM film_actor;

SELECT actor_id, COUNT(*) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count
LIMIT 1;

SELECT 
    f.title
FROM
    film f
        JOIN
    film_actor fa ON f.film_id = fa.film_id
WHERE
    fa.actor_id = (SELECT 
            actor_id
        FROM
            film_actor
        GROUP BY actor_id
        ORDER BY COUNT(*) DESC
        LIMIT 1);
        
-- 7. Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer,
--  i.e., the customer who has made the largest sum of payments.

SELECT * FROM customer; -- customer_id, store_id
SELECT * FROM film; -- film_id
SELECT * FROM payment; -- customer_id

SELECT customer_id
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1;

SELECT DISTINCT f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE p.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);


-- 8.Retrieve the client_id and the total_amount_spent of those clients who spent more than the average 
-- of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.

SELECT 
    customer_id,
    ROUND(SUM(amount), 2) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(total_spent)
    FROM (
        SELECT customer_id, SUM(amount) AS total_spent
        FROM payment
        GROUP BY customer_id
    ) AS avg_table
)
ORDER BY total_amount_spent DESC;
