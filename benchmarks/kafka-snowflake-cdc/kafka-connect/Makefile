COMPOSE_FILE = compose.yml

.PHONY: setup
setup:
	docker-compose -f $(COMPOSE_FILE) up -d

.PHONY: clean
clean:
	docker-compose -f $(COMPOSE_FILE) down --volumes --remove-orphans
	rm -rf plugins

.PHONY: deploy-sink-connector
deploy-sink-connector:
	curl -X POST -H "Content-Type: application/json" --data @sink-snowflake.json http://localhost:8083/connectors

.PHONY: kafka-connect-logs
kafka-connect-logs:
	docker logs -f kafka-connect

.PHONY: produce-messages
produce-messages:
	../produce-messages.sh

.PHONY: open-control-center
open-control-center:
	open http://localhost:9021/clusters

.PHONY: create-private-key
create-private-key:
	openssl genrsa -out snowflake_key.pem 2048
	openssl rsa -in snowflake_key.pem  -pubout -out snowflake_key.pub

.PHONY: show-private-key
show-private-key:
	grep -v "BEGIN PUBLIC" snowflake_key.pub | grep -v "END PUBLIC"|tr -d '\r\n'
