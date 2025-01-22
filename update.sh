#!/bin/bash
set -Eeuo pipefail

# Source all versions
# shellcheck disable=SC1091
. ./versions.conf

DEFAULT_IFS=${IFS}
TEMPLATE_DOCKERFILE=template.Dockerfile
TMP_DOCKERFILE_FILE="/tmp/php_tmp_variant_Dockerfile"
TMP_FINAL_DOCKERFILE_FILE="/tmp/php_tmp_final_variant_Dockerfile"

declare -A VERSION_LIST
VERSION_LIST=(
    [8.3]="${PHP83_VERSION}"
    [8.4]="${PHP84_VERSION}"
)

declare -A VARIANTS_LIST
VARIANTS_LIST=(
    [cli]='base vipsffmpeg'
    [fpm]='vipsffmpeg-nginx'
)

# Get all parameter names to replace in Dockerfile
REPLACE_PARAMETERS=$(sed <versions.conf -e '/^#/d' -e '/^$/d' -e 's/export \(.*\)=.*/$\1/g' | tr '\n' ':'):\$PHP_SOURCE_TAG

rm -rf build

function generated_warning() {
    cat <<-EOH
		#
		# NOTE:
		# THIS DOCKERFILE IS GENERATED VIA "update.sh".
		# PLEASE DO NOT EDIT IT DIRECTLY!
		# CHECK README FOR MORE INFO.
		#
	EOH
}

mkdir -p .github/workflows
cat docker.yml.template >.github/workflows/docker.yml

readarray -t VERSION_TAGS < <(printf '%s\n' "${!VERSION_LIST[@]}" | sort -V)
for version in "${VERSION_TAGS[@]}"; do
    PHP_VERSION_TAG="php${version//./}"
    PHP_VERSION=${VERSION_LIST[$version]}
    readarray -t PHP_VARIANTS < <(printf '%s\n' "${!VARIANTS_LIST[@]}" | sort)
    for i in "${PHP_VARIANTS[@]}"; do
        export PHP_VARIANT=$i
        export PHP_SOURCE_TAG="${PHP_VERSION}-${PHP_VARIANT}"
        VARIANTS=${VARIANTS_LIST[$i]}
        for VARIANT in ${VARIANTS}; do
            # Cleanup before script run
            rm -f ${TMP_DOCKERFILE_FILE}
            # Temporary variant dockerfile
            IFS='-'
            for type in ${VARIANT}; do
                variant_dockerfile_name="variant-${type}.Dockerfile"
                if [ -f "$variant_dockerfile_name" ]; then
                    cat "$variant_dockerfile_name" >>${TMP_DOCKERFILE_FILE}
                fi
            done
            IFS=${DEFAULT_IFS}
            # Variables
            export PHP_VERSION_TAG
            export VARIANT
            export BUILD_DIR="build/${PHP_VERSION_TAG}/${PHP_VARIANT}/${VARIANT}"
            TMP_VARIANT_TAG="${PHP_VERSION_TAG}-${PHP_VARIANT}-${VARIANT}"
            export VARIANT_TAG="${TMP_VARIANT_TAG//-base/}"
            TMP_GITHUB_JOB_ID="${PHP_VERSION_TAG}-${PHP_VARIANT}-${VARIANT}"
            export GITHUB_JOB_ID="${TMP_GITHUB_JOB_ID//_base/}"
            echo "Creating variant folder ${BUILD_DIR}"
            mkdir -p "${BUILD_DIR}"

            GENERATED_DOCKERFILE="${BUILD_DIR}/Dockerfile"
            echo "Generating dockerfile ${GENERATED_DOCKERFILE}"
            {
                generated_warning
                cat "${TEMPLATE_DOCKERFILE}"
            } >"${TMP_FINAL_DOCKERFILE_FILE}"

            gawk -i inplace -v dockerfile="${TMP_DOCKERFILE_FILE}" '
                $1 == "##</autogenerated>##" { ia = 0 }
                !ia { print }
                $1 == "##<autogenerated>##" { ia = 1; ac = 0; if (system("test -f " dockerfile) != 0) { ia = 0 } }
                ia { ac++ }
                ia && ac == 1 { system("cat " dockerfile) }
            ' "${TMP_FINAL_DOCKERFILE_FILE}"

            envsubst "${REPLACE_PARAMETERS}" <"${TMP_FINAL_DOCKERFILE_FILE}" >"${GENERATED_DOCKERFILE}"

            echo "Copying common config files to ${BUILD_DIR}"
            if [ -d "config/all" ]; then
                cp -ar config/all/. "${BUILD_DIR}"
            fi
            IFS='-'
            for type in ${VARIANT}; do
                if [ -d "config/all-${type}" ]; then
                    echo "Copying common ${type} config files to ${BUILD_DIR}"
                    cp -ar "config/all-${type}/." "${BUILD_DIR}"
                fi
            done

            echo "Copying common ${PHP_VERSION_TAG} config files to ${BUILD_DIR}"
            if [ -d "config/all-${version}" ]; then
                cp -ar "config/all-${version}/." "${BUILD_DIR}"
            fi
            IFS='-'
            for type in ${VARIANT}; do
                if [ -d "config/all-${version}-${type}" ]; then
                    echo "Copying common ${PHP_VERSION_TAG} ${type} config files to ${BUILD_DIR}"
                    cp -ar "config/all-${version}-${type}/." "${BUILD_DIR}"
                fi
            done

            if [ -d "config/${PHP_VARIANT}" ]; then
                cp -ar "config/${PHP_VARIANT}"/. "${BUILD_DIR}"
            fi
            for type in ${VARIANT}; do
                if [ -d "config/${PHP_VARIANT}-${type}" ]; then
                    echo "Copying ${PHP_VARIANT} ${type} config files to ${BUILD_DIR}"
                    cp -ar "config/${PHP_VARIANT}-${type}/." "${BUILD_DIR}"
                fi
            done

            if [ -d "config/${PHP_VARIANT}-${version}" ]; then
                cp -ar "config/${PHP_VARIANT}-${version}"/. "${BUILD_DIR}"
            fi
            for type in ${VARIANT}; do
                if [ -d "config/${PHP_VARIANT}-${version}-${type}" ]; then
                    echo "Copying ${PHP_VARIANT} ${PHP_VERSION_TAG} ${type} config files to ${BUILD_DIR}"
                    cp -ar "config/${PHP_VARIANT}-${version}-${type}/." "${BUILD_DIR}"
                fi
            done
            IFS=${DEFAULT_IFS}

            envsubst "\
                \${GITHUB_JOB_ID} \
                \${BUILD_DIR} \
                \${PHP_VARIANT} \
                \${PHP_VERSION_TAG} \
                \${VARIANT} \
                \${VARIANT_TAG} \
            " <docker.yml.job.template >>.github/workflows/docker.yml
            # Cleanup after script run
            rm -f ${TMP_DOCKERFILE_FILE}
        done
    done
done
