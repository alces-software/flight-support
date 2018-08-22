#!/bin/bash

set -euo pipefail

package_name='flight-support-cli'
build_dest='data/opt/flight-support'

cw_ROOT="${cw_ROOT:-/opt/clusterware}"
PATH="${cw_ROOT}"/opt/git/bin:"${cw_ROOT}"/opt/ruby/bin:$PATH
REPO_ROOT="$(git rev-parse --show-toplevel)"
PACKAGE_DIR="${REPO_ROOT}/package"

cd "${PACKAGE_DIR}"

if [ -f ./${package_name}.zip ]; then
  echo "Replacing existing ${package_name}.zip in ${PACKAGE_DIR}"
  rm ./${package_name}.zip
fi

temp_dir=$(mktemp -d /tmp/${package_name}-build-XXXXX)

cp -r * "${temp_dir}"
mkdir -p "${temp_dir}"/"${build_dest}"

echo "Creating Forge package ${package_name} from git rev $(git rev-parse --short HEAD)"

pushd "${REPO_ROOT}" > /dev/null
git archive HEAD | tar -x -C "${temp_dir}"/"${build_dest}"
popd > /dev/null

pushd "${temp_dir}"/"${build_dest}" > /dev/null
bundle install --without="development test" --path=vendor

rm -rf Rakefile vendor/cache .gitignore README.md
rm -rf vendor/ruby/2.2.0/bundler/gems/extensions \
  vendor/ruby/2.2.0/cache
popd

pushd "${temp_dir}" > /dev/null
zip -r ${package_name}.zip *
popd > /dev/null

mv "${temp_dir}"/${package_name}.zip "${PACKAGE_DIR}"

rm -rf "${temp_dir}"

echo "Created Forge package ${package_name} (from git rev $(git rev-parse --short HEAD)) at ${PACKAGE_DIR}/${package_name}.zip"
