#start-script-vulnerable.sh

#!/bin/bash
docker build --network=host -f Dockerfile.vulnerable -t vulnerable-app .