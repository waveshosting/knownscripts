set -e

echo "Building meteor app..."

meteor build $BUILD_DIR/compilation --directory --server-only --architecture os.linux.x86_64

sed -i '' 's/Object\.create/Object\.assign/g' $BUILD_DIR/compilation/bundle/programs/server/npm-rebuild.js
sed -i '' 's/PATH: { value: PATH }/PATH: PATH/g' $BUILD_DIR/compilation/bundle/programs/server/npm-rebuild.js

cd $BUILD_DIR/compilation/bundle

SETTINGS_FIX="process.env.METEOR_SETTINGS = (process.env.METEOR_SETTINGS || '').replace(/\\\\\\\\\"/g, '\"')"
echo $SETTINGS_FIX | cat - main.js > temp && mv -f temp main.js

NODE_VERSION=$(node -pe 'JSON.parse(process.argv[1]).nodeVersion' "$(cat star.json)")

if [ "$NODE_VERSION" == "undefined" ]; then
  NODE_VERSION="4.6.3"
fi

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

mkdir .ebextensions

echo 'option_settings:
  - namespace: aws:elasticbeanstalk:container:nodejs
    option_name: NodeVersion
    value: '$NODE_VERSION'
' > .ebextensions/npm-version.config

echo 'files:
  "/opt/elasticbeanstalk/hooks/appdeploy/pre/55npm_install.sh":
    mode: "000755"
    owner: root
    group: root
    content: |
      #!/usr/bin/env bash
      # Custom npm install to work with Meteor/s build command
      export USER=root
      export HOME=/tmp
      export NODE_PATH=`ls -td /opt/elasticbeanstalk/node-install/node-* | head -1`/bin
      echo "------------------------------ — Installing NPM modules for Meteor  — -----------------------------------"
      OUT=$([ -d "/tmp/deployment/application" ] && cd /tmp/deployment/application/programs/server && $NODE_PATH/npm install --production) || error_exit "Failed to run npm install.  $OUT" $?
      echo $OUT
' > .ebextensions/customnpminstall.config

mv $BUILD_DIR/compilation/bundle/ $BUILD_DIR/build/
