process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment')
const { resolve } = require('path');

environment.config.merge({
  devServer: {
    contentBase: [
      environment.config.devServer.contentBase,
      resolve('./app')
    ],
    watchContentBase: true,
  }
});

module.exports = environment.toWebpackConfig()
