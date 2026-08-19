USE sakila;
-- 1 --
CREATE VIEW list_of_customers AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS 'customer full name',
    a.address,
    a.postal_code AS 'zip code',
    a.phone,
    ci.city,
    co.country,
    CASE 
        WHEN c.active = 1 THEN 'active' 
        ELSE 'inactive' 
    END AS status,
    c.store_id
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id;

-- 2 --
CREATE VIEW film_details AS
SELECT 
    f.film_id, 
    f.title, 
    f.description, 
    c.name AS category, 
    f.rental_rate AS price, 
    f.length, 
    f.rating, 
    GROUP_CONCAT(CONCAT(a.first_name, ' ', a.last_name) SEPARATOR ', ') AS actors
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
JOIN film_actor fa ON f.film_id = fa.film_id
JOIN actor a ON fa.actor_id = a.actor_id
GROUP BY f.film_id, c.name;

-- 3 --
CREATE VIEW sales_by_film_category AS
SELECT 
    c.name AS category, 
    SUM(p.amount) AS total_rental
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN inventory i ON fc.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.name;

-- 4 --
CREATE VIEW actor_information AS
SELECT 
    a.actor_id, 
    a.first_name, 
    a.last_name, 
    COUNT(fa.film_id) AS amount_of_films
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;


-- 5 --
/*
Analisis de la vista actor_info:
La vista devuelve la informacion basica de cada actor y un listado de todas las peliculas en las que participo agrupadas por categoria.
La subquery hace varios LEFT JOIN entre actor, film_actor, film_category y category para no perder actores sin peliculas. Dentro de la subquery usa GROUP_CONCAT(f.title) para juntar todas las peliculas de una misma categoria separadas por coma, agrupando por actor_id y category.name.
Luego, en la consulta externa, vuelve a aplicar otro GROUP_CONCAT concatenando cada categoria con su lista de peliculas (ej: 'Action: Film1, Film2; Comedy: Film3') usando punto y coma como separador, agrupando por actor_id.
*/

-- 6 --
/*
Vistas materializadas:
A diferencia de una vista normal (que es una query guardada que se ejecuta cada vez que se consulta), una vista materializada almacena fisicamente el resultado en disco como una tabla real.
Se usan para mejorar la performance en consultas pesadas o reportes complejos de Data Warehouse donde los datos no cambian constantemente.
Alternativas en motores que no las soportan nativamente: crear una tabla fisica y actualizarla periodicamente mediante TRIGGERS o eventos/cron jobs programados.
Motores que las soportan nativamente: PostgreSQL, Oracle, SQL Server (Indexed Views). En MySQL no existen de forma nativa.
*/