## -------------------------------------------------------------------
## Helper to build and run an Onboarding dockerized environment for local
## development. This tool is very useful to avoid problems witg arm 
## environments, specially with Mac ARM64.
## -------------------------------------------------------------------

## Run the application in the foreground
run:
	docker-compose up --build

## Run the application in detached mode
run-detached:
	docker-compose up --build -d

## Stop the application
stop:
	docker-compose down

## Restart the application
restart:
	docker-compose restart

## View the application logs
logs:
	docker-compose logs -f

## View the application status
status:
	docker-compose ps

## Access the Erlang console/shell
## Example console commands:
## role_service:get_all_roles().
## role_service:get_role_by_mrn(<<"1">>).
## Repository level calls
## role_repository:get_all_roles().
## role_repository:get_role_by_mrn(<<"1">>).
console:
	docker-compose exec staff_roles /app/_build/default/rel/staff_roles/bin/staff_roles remote_console
