const { environment } = require("@rails/webpacker");
const webpack = require("webpack");
const purescript =  require('./loaders/purescript')

environment.loaders.prepend('purescript', purescript)

module.exports = environment;
