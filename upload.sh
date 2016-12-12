#!/bin/bash

### This script publish the project jars as a maven artifact on to bintray.

set -e
set -o pipefail

TOP_DIR=$(python -c "import os; print os.path.dirname(os.path.realpath('$0'))")
cd $TOP_DIR

bintray_repo=bintray-scrapinghub-maven
bintray_org=scrapinghub
bintray_pkg=shc

version=1.0.3-2.0-s_2.11
group_id=com.hortonworks
artifact_id=shc-core
parent_artifact_id=shc
pom=${TOP_DIR}/core/pom.xml
parent_pom=${TOP_DIR}/pom.xml

fn=${TOP_DIR}/core/target/${artifact_id}-${version}.jar

if [[ ! -e $fn ]]; then
    echo "$fn doesn't exist!"
    exit 1
fi

if ! grep -q $bintray_repo ~/.m2/settings.xml; then
    echo "repo $bintray_repo not found in ~/.m2/settings.xml!"
    exit 1
fi

echo "Uploading $fn to bintray ..."

(
    set -x

    mvn -e deploy:deploy-file \
        -DgroupId=${group_id} \
        -DartifactId=${artifact_id} \
        -Dversion=${version} \
        -Dpackaging=jar \
        -DpomFile=${pom} \
        -Dfile=${fn} \
        -DrepositoryId=${bintray_repo} \
        -Durl="https://api.bintray.com/maven/${bintray_org}/maven/${bintray_pkg}/;publish=1"

    mvn -e deploy:deploy-file \
        -DgroupId=${group_id} \
        -DartifactId=${parent_artifact_id} \
        -Dversion=${version} \
        -Dpackaging=pom \
        -DpomFile=${parent_pom} \
        -Dfile=${parent_pom} \
        -DrepositoryId=${bintray_repo} \
        -Durl="https://api.bintray.com/maven/${bintray_org}/maven/${bintray_pkg}/;publish=1"
)
