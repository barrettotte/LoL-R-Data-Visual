-- Make database to cache API data for better speed and less API requests --
BEGIN
    PRINT N'Creating RIOT_API database...'
    IF (db_id(N'RIOT_API') IS NULL) 
        BEGIN
            CREATE DATABASE RIOT_API;
            PRINT N'RIOT_API database created.'
        END
    ELSE
        PRINT N'RIOT_API database already exists.'
END