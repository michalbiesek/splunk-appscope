#!/bin/bash

echo "Stop docker compose"
docker-compose down
rm domain.crt 2> /dev/null
rm domain.key 2> /dev/null
rm foouser_key 2> /dev/null
rm baruser_key 2> /dev/null
rm foouser_key.pub 2> /dev/null
rm baruser_key.pub 2> /dev/null