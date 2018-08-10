const fs = require('fs')

console.log(process.env.BUILD_DIR + '/compilation/bundle/programs/server/npm-rebuild.js')

let content = fs
  .readFileSync(process.env.BUILD_DIR + '/compilation/bundle/programs/server/npm-rebuild.js')
  .toString()

content = content.replace(
  'var env = Object.create(process.env, {',
  'var env = Object.assign(process.env, {'
)

content = content.replace('PATH: {value: PATH}', 'PATH: PATH')

console.log(content)
