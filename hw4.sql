-- Primary keys
alter table actor add primary key (actor_id);
alter table address add primary key (address_id);
alter table category add primary key (category_id);
alter table city add primary key (city_id);
alter table country add primary key (country_id);
alter table customer add primary key (customer_id);
alter table film add primary key (film_id);
alter table rental add primary key (rental_id);
alter table staff add primary key (staff_id);
alter table store add primary key (store_id);
alter table inventory add primary key (inventory_id);
alter table language add primary key (language_id);
alter table payment add primary key (payment_id);

-- Foreign keys and Unique keys
alter table address add foreign key (city_id) references city(city_id);
alter table city add foreign key (country_id) references country(country_id);
alter table customer add foreign key (store_id) references store(store_id),
    add foreign key (address_id) references address(address_id);
alter table film add foreign key (language_id) references language(language_id);
alter table film_actor add foreign key (actor_id) references actor(actor_id),
    add foreign key (film_id) references film(film_id);
alter table rental add foreign key (inventory_id) references inventory(inventory_id),
	add foreign key (customer_id) references customer(customer_id),
	add foreign key (staff_id) references staff(staff_id);
alter table staff add foreign key (address_id) references address(address_id),
	add foreign key (store_id) references store(store_id);
alter table store add foreign key (address_id) references address(address_id);
alter table film_category add foreign key (film_id) references film(film_id),
    add foreign key (category_id) references category(category_id);
alter table inventory add foreign key (film_id) references film(film_id),
	add foreign key (store_id) references store(store_id);
alter table payment add foreign key (customer_id) references customer(customer_id),
	add foreign key (staff_id) references staff(staff_id),
	add foreign key (rental_id) references rental(rental_id);
alter table rental modify rental_date datetime,
	modify return_date datetime;
alter table payment modify payment_date datetime;

-- Constraints
alter table category add constraint check (name in ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'));
alter table film add constraint check (special_features in ('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers'));
alter table film add constraint check (release_year is not null);
alter table rental add constraint check (rental_date is not null),
	add constraint check (return_date is not null);
alter table payment add constraint check (payment_date is not null);
alter table staff add constraint check (active in (0, 1));
alter table film add constraint check (rental_duration between 2 and 8),
	add constraint check (rental_rate between 0.99 and 6.99),
    add constraint check (length between 30 and 200),
    add constraint check (replacement_cost between 5 and 100);
alter table film add constraint check (rating in ('PG', 'G', 'NC-17', 'PG-13', 'R'));
alter table payment add constraint check (amount >= 0);


-- Queries
-- 1) What is the average length of films in each category? List the results in alphabetic order of categories.
select name, avg(length)
from category join film_category on category.category_id = film_category.category_id 
join film on film_category.film_id = film.film_id
group by name;

-- 2) Which categories have the longest and shortest average film lengths?
/*
select name, avg(length)
	from film 
	join film_category on film.film_id = film_category.film_id 
	join category on film_category.category_id = category.category_id
	group by name
	having avg(length) <= ALL (
		select avg(length)
		from film 
		join film_category on film.film_id = film_category.film_id 
		join category on film_category.category_id = category.category_id
		group by name)
        
select name, avg(length)
	from film 
	join film_category on film.film_id = film_category.film_id 
	join category on film_category.category_id = category.category_id
	group by name
	having avg(length) >= ALL (
		select avg(length)
		from film 
		join film_category on film.film_id = film_category.film_id 
		join category on film_category.category_id = category.category_id
		group by name)
        order by avg(length);
*/
create view low as
select name, avg(length)
	from film 
	join film_category on film.film_id = film_category.film_id 
	join category on film_category.category_id = category.category_id
	group by name
    order by avg(length)
    limit 1;

create view high as
select name, avg(length)
	from film 
	join film_category on film.film_id = film_category.film_id 
	join category on film_category.category_id = category.category_id
	group by name
    order by avg(length) desc
    limit 1;
    
select * from low join high; -- answer
	
-- 3) Which customers have rented action but not comedy or classic movies?
select distinct(last_name)
from customer
join rental using (customer_id)
join inventory using (inventory_id)
join film_category using (film_id)
join category using (category_id)
where name = 'action'
except
select distinct(last_name)
from customer
join rental using (customer_id)
join inventory using (inventory_id)
join film_category using (film_id)
join category using (category_id)
where name = 'classics' or name = 'comedy'
order by last_name asc;

-- 4) Which actor has appeared in the most English-language movies?
select distinct first_name, last_name, count(*) from actor
join film_actor using (actor_id)
join film using (film_id)
where language_id = 1
group by actor_id
having count(actor_id) >= All 
	(select first_name from actor
	join film_actor using (actor_id)
	join film using (film_id)
	where language_id = 1
    group by film_id)
order by count(*) desc
limit 1;

-- 5) How many distinct movies were rented for exactly 10 days from the store where Mike works?
select count(distinct film_id)
from rental
join inventory using (inventory_id) 
join film using (film_id)
join staff using (store_id)
where datediff(return_date, rental_date) = 10 and first_name = 'Mike';

-- 6) Alphabetically list actors who appeared in the movie with the largest cast of actors.
select distinct first_name, last_name, count(actor_id) from actor
join film_actor using (actor_id)
group by actor_id
order by first_name;