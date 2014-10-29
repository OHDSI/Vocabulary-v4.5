----------------------------------------------------------------------------------------------------------------
-- Create the user 
create user ProdV4 identified by "123" default tablespace USERS temporary tablespace TEMP quota unlimited on users;

grant create cluster to ProdV4;
grant create indextype to ProdV4;
grant create operator to ProdV4;
grant create procedure to ProdV4;
grant create sequence to ProdV4;
grant create session to ProdV4;
grant create synonym to ProdV4;
grant create table to ProdV4;
grant create trigger to ProdV4;
grant create type to ProdV4;
grant create view to ProdV4;
grant select any dictionary to ProdV4;
grant select any table to ProdV4;

