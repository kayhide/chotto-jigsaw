const { environment } = require("@rails/webpacker");
const webpack = require("webpack");
const config = require("./config");
const purescript =  require('./loaders/purescript')

config.injectEnv("firestore");

environment.plugins.prepend(
  'Environment',
  new webpack.EnvironmentPlugin(
    JSON.parse(JSON.stringify(process.env))
  )
);

environment.loaders.prepend('purescript', purescript)
module.exports = environment;
