const { environment } = require("@rails/webpacker");
const webpack = require("webpack");
const typescript = require("./loaders/typescript");

environment.plugins.prepend(
  "Provide",
  new webpack.ProvidePlugin({
    $: "jquery/src/jquery",
    jQuery: "jquery/src/jquery",
    _: "lodash"
  })
);

environment.loaders.prepend("typescript", typescript);
module.exports = environment;
