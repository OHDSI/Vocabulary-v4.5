----------------------------------------------------------------------------------------------------------------
-- Create the user 
create user DevV4 identified by "123" default tablespace USERS temporary tablespace TEMP quota unlimited on users;

grant create cluster to DevV4;
grant create indextype to DevV4;
grant create operator to DevV4;
grant create procedure to DevV4;
grant create sequence to DevV4;
grant create session to DevV4;
grant create synonym to DevV4;
grant create table to DevV4;
grant create trigger to DevV4;
grant create type to DevV4;
grant create view to DevV4;
grant select any dictionary to DevV4;
grant select any table to DevV4;

