#!/bin/bash -ex

set -e

cd $(dirname "${BASH_SOURCE[0]}")

if [ -z "$GEONODE_REPOSITORY" ]; then
    GEONODE_REPOSITORY="geonode"
fi

for i in {1..3}; do
    cd "$GEONODE_REPOSITORY/scripts/spcgeonode/"
    docker-compose -f docker-compose.yml down --volumes
    docker-compose -f docker-compose.yml up -d --build django geoserver postgres nginx
    cd -

    for i in {1..60}; do
        containers=$(docker ps -q \
                     --filter label=com.docker.compose.project=spcgeonode \
                     --filter health=unhealthy \
                     --filter health=starting)
        if [ -z "$containers" ]; then
            ./test.sh
            exit $?
        fi
        sleep 10
    done
done
exit 125 # git bisect skip
