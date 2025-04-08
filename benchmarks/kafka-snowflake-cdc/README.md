# Kafka -> Snowflake CDC Benchmark

The Kafka -> Snowflake CDC benchmark requires a few manual steps before it can
run.

## Steps

1. **Create a Snowflake account**: If you don't have a Snowflake account, create one
   [here](https://signup.snowflake.com/).
2. **Create a database called `BENCHI`**: This is where the benchmark will
   create the tables and streams.

There are a few specific steps 

## Conduit

For the Conduit tool, you will need to create a `.env` file in the `conduit`
folder, which contains the Snowflake account name, username and password. The
`.env` file should look like this:

```env
SNOWFLAKE_URL_NAME="ABCDEFG-AB12345.snowflakecomputing.com"
SNOWFLAKE_USERNAME="myusername"
SNOWFLAKE_PASSWORD="mypassword"
```

## Kafka Connect

Kafka Connect is using key pair authentication. More information how to set it
up: https://docs.snowflake.com/en/user-guide/kafka-connector-install#using-key-pair-authentication-key-rotation

The `Makefile` in this folder contains a target to create the key pair and
output the SQL commands to alter the Snowflake user.

```sh
make setup-kafka-connect
openssl genrsa -out snowflake_key.pem 2048
openssl rsa -in snowflake_key.pem  -pubout -out snowflake_key.pub
writing RSA key

Writing key to ./kafka-connect/.env
Alter user statement:

ALTER USER [>INSERT_USERNAME<] SET RSA_PUBLIC_KEY='MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomZXLbQSynz5VvQC6Gf1IWveKkC3eb6lTluKQJY2Jg3v4885qn0VEFNDuvPRnbuxgyQvjZ90c4shQoA9mke0A6BjHfQ9BKVqfnOKNqOMdghwVMk+dChiyWI8nYGsE8xfG/nzeZ/yul5f9qAmxfEz9VLOhtOOZtob2U2Xm7wji38D3ZJR6AIXDtP6o3cGe/QLw92e57n2QgXjQ7kpmRPD1eEgumgUK28U1WEC1M5Jx2HNNKX7FzzLQ+HKhpRXYRjE3nlXDkAaRd8ugp53p04/nz+0DPf+wA3ZZBlOdimLXcC0NX6Azr30xcwmrhOGAUvCjV/xoQTqrGl9cFvWS5HDWwIDAQAB';
```

After running the command, you will need to copy the `ALTER USER` statement and
paste it into the Snowflake console to update the user with the public key. You
will also need to update the `.env` file in the `kafka-connect` folder with the
username and host of the Snowflake account. The `.env` file should look like this:

```env
SNOWFLAKE_HOST="ABCDEFG-AB12345.snowflakecomputing.com"
SNOWFLAKE_USERNAME="myusername"
SNOWFLAKE_PRIVATE_KEY="MIIEvAIB..." # created by make setup-kafka-connect
```