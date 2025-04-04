#!/bin/bash

confluent-hub install --no-prompt snowflakeinc/snowflake-kafka-connector:latest

su -c "/etc/confluent/docker/run" appuser
