DROP TABLE IF EXISTS ticket CASCADE;
DROP TABLE IF EXISTS movie_genre CASCADE;
DROP TABLE IF EXISTS showtime CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS hall CASCADE;
DROP TABLE IF EXISTS movie CASCADE;
DROP TABLE IF EXISTS genre CASCADE;
DROP TABLE IF EXISTS visitor CASCADE;
DROP TABLE IF EXISTS theater CASCADE;

CREATE TABLE theater (
    theater_id    SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    city          VARCHAR(100) NOT NULL,
    address       VARCHAR(200) NOT NULL,
    phone         VARCHAR(30),
    opened_at     DATE,
    CONSTRAINT theater_name_city_uk UNIQUE (name, city)
);

CREATE TABLE hall (
    hall_id    SERIAL PRIMARY KEY,
    theater_id INT NOT NULL,
    name       VARCHAR(50) NOT NULL,
    capacity   INT NOT NULL CHECK (capacity > 0),
    is_3d      BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT hall_theater_name_uk UNIQUE (theater_id, name),
    CONSTRAINT hall_theater_fk
        FOREIGN KEY (theater_id)
        REFERENCES theater (theater_id)
        ON DELETE CASCADE
);

CREATE TABLE genre (
    genre_id  SERIAL PRIMARY KEY,
    name      VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE movie (
    movie_id          SERIAL PRIMARY KEY,
    title             VARCHAR(150) NOT NULL,
    duration_min      INT NOT NULL CHECK (duration_min > 0),
    age_restriction   INT CHECK (age_restriction >= 0),
    release_year      INT CHECK (release_year >= 1900),
    base_ticket_price NUMERIC(8,2) CHECK (base_ticket_price >= 0)
);

CREATE TABLE visitor (
    visitor_id  SERIAL PRIMARY KEY,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(150),
    phone       VARCHAR(30),
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT visitor_email_uk UNIQUE (email)
);

CREATE TABLE staff (
    staff_id    SERIAL PRIMARY KEY,
    theater_id  INT NOT NULL,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(150),
    phone       VARCHAR(30),
    hire_date   DATE NOT NULL,
    position    VARCHAR(50) NOT NULL,
    manager_id  INT,
    CONSTRAINT staff_email_uk UNIQUE (email),
    CONSTRAINT staff_theater_fk
        FOREIGN KEY (theater_id)
        REFERENCES theater (theater_id)
        ON DELETE CASCADE,
    CONSTRAINT staff_manager_fk
        FOREIGN KEY (manager_id)
        REFERENCES staff (staff_id)
        ON DELETE SET NULL,
    CONSTRAINT staff_manager_self_chk CHECK (manager_id IS NULL OR manager_id <> staff_id)
);

CREATE TABLE showtime (
    showtime_id        SERIAL PRIMARY KEY,
    hall_id            INT NOT NULL,
    movie_id           INT NOT NULL,
    start_time         TIMESTAMP NOT NULL,
    language           VARCHAR(50) NOT NULL,
    subtitles_language VARCHAR(50),
    base_price         NUMERIC(8,2) NOT NULL CHECK (base_price >= 0),
    CONSTRAINT showtime_hall_start_uk UNIQUE (hall_id, start_time),
    CONSTRAINT showtime_hall_fk
        FOREIGN KEY (hall_id)
        REFERENCES hall (hall_id)
        ON DELETE RESTRICT,
    CONSTRAINT showtime_movie_fk
        FOREIGN KEY (movie_id)
        REFERENCES movie (movie_id)
        ON DELETE RESTRICT
);

CREATE TABLE movie_genre (
    movie_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (movie_id, genre_id),
    CONSTRAINT movie_genre_movie_fk
        FOREIGN KEY (movie_id)
        REFERENCES movie (movie_id)
        ON DELETE CASCADE,
    CONSTRAINT movie_genre_genre_fk
        FOREIGN KEY (genre_id)
        REFERENCES genre (genre_id)
        ON DELETE CASCADE
);

CREATE TABLE ticket (
    ticket_id     SERIAL PRIMARY KEY,
    showtime_id   INT NOT NULL,
    visitor_id    INT NOT NULL,
    seat_row      INT NOT NULL CHECK (seat_row > 0),
    seat_number   INT NOT NULL CHECK (seat_number > 0),
    price         NUMERIC(8,2) NOT NULL CHECK (price >= 0),
    purchased_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    is_refunded   BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT ticket_seat_uk UNIQUE (showtime_id, seat_row, seat_number),
    CONSTRAINT ticket_showtime_fk
        FOREIGN KEY (showtime_id)
        REFERENCES showtime (showtime_id)
        ON DELETE RESTRICT,
    CONSTRAINT ticket_visitor_fk
        FOREIGN KEY (visitor_id)
        REFERENCES visitor (visitor_id)
        ON DELETE RESTRICT
);

