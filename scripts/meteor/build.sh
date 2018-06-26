echo "Building meteor app..."

meteor build $BUILD_DIR/compilation --directory --server-only --architecture os.linux.x86_64

cd $BUILD_DIR/compilation/bundle/programs/server
meteor npm install --production
cd $BUILD_DIR/compilation/bundle

export NODE_VERSION=$(node -pe 'JSON.parse(process.argv[1]).nodeVersion' "$(cat star.json)")
echo "Node version: $NODE_VERSION"

echo '{
  "name": "waves-meteor-app",
  "version": "0.0.1",
  "scripts": {
    "start": "node main.js"
  },
  "dependencies": {
    "fibers": "*",
    "semver": "*",
    "source-map-support": "*",
    "underscore": "*"
  }
}' > package.json

echo 'option_settings:
  - namespace: aws:elasticbeanstalk:container:nodejs
    option_name: NodeVersion
    value: '$NODE_VERSION'
' > .ebextensions

mv $BUILD_DIR/compilation/bundle/ $BUILD_DIR/build/
