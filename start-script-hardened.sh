#start-script-hardened.sh

#!/bin/bash
docker build --network=host -f Dockerfile.hardened -t my-app:hardened .