.PHONY: genrsa
genrsa:
	openssl genrsa -out snowflake_key.pem 2048
	openssl rsa -in snowflake_key.pem  -pubout -out snowflake_key.pub

.PHONY: alter-user-sql
alter-user-sql:
	@cat snowflake_key.pub | grep -vE "BEGIN|END" | tr -d '\r\n' | xargs -S2048 -I{} echo "ALTER USER [>INSERT_USERNAME<] SET RSA_PUBLIC_KEY='{}';"

.PHONY: setup-kafka-connect
setup-kafka-connect: genrsa
	@echo ""
	@echo "Writing key to ./kafka-connect/.env"
	@cp -u ./kafka-connect/.env.sample ./kafka-connect/.env
	@cat snowflake_key.pem | grep -vE "BEGIN|END" | tr -d '\r\n' | xargs -S2048 -I{} echo "SNOWFLAKE_PRIVATE_KEY=\"{}\"" >> ./kafka-connect/.env
	@if [ $$(grep -c "^SNOWFLAKE_PRIVATE_KEY" ./kafka-connect/.env) -gt 1 ]; then \
  		echo ""; \
    	echo "  [WARNING] Multiple SNOWFLAKE_PRIVATE_KEY entries found in ./kafka-connect/.env, remove all but the last one."; \
  		echo ""; \
    fi
	@echo "Alter user statement:"
	@echo ""
	@$(MAKE) alter-user-sql
