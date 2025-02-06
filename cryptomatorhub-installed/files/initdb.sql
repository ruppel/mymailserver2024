CREATE USER {{ cryptomator_db.keycloak_user }} WITH ENCRYPTED PASSWORD '{{ cryptomator_db.keycloak_password }}';
CREATE DATABASE keycloak WITH ENCODING 'UTF8';
GRANT ALL PRIVILEGES ON DATABASE keycloak TO {{ cryptomator_db.keycloak_user }};
CREATE USER {{ cryptomator_db.hub_user }} WITH ENCRYPTED PASSWORD '{{ cryptomator_db.hub_password }}';
CREATE DATABASE hub WITH ENCODING 'UTF8';
GRANT ALL PRIVILEGES ON DATABASE hub TO {{ cryptomator_db.hub_user }};