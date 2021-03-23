set -eu

executable=$1
workspace="$(pwd)"

echo "-------------------------------------------------------------------------"
echo "preparing docker build image"
echo "-------------------------------------------------------------------------"
docker build . -t builder
echo "done"

echo "-------------------------------------------------------------------------"
echo "building \"$executable\" lambda in workspace $workspace"
echo "-------------------------------------------------------------------------"
docker run --rm -v "$workspace":/workspace -w /workspace builder \
       bash -cl "swift build --product $executable --enable-test-discovery -c release"
echo "done"

echo "-------------------------------------------------------------------------"
echo "packaging \"$executable\" lambda"
echo "-------------------------------------------------------------------------"
docker run --rm -v "$workspace":/workspace -w /workspace builder \
       bash -cl "./scripts/package.sh $executable"
echo "done"
