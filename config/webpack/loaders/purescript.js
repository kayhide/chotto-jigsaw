const { resolve } = require('path')

module.exports = {
  test: /\.purs(\.erb)?$/,
  loader: 'purs-loader',
  exclude: [/node_modules/],
  query: {
    spago: true,
    src: []
  }
}
