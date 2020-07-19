const EnvironmentPlugin = require("webpack").EnvironmentPlugin;
const HtmlPlugin = require('html-webpack-plugin');
const ManifestPlugin = require("webpack-manifest-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const glob = require('glob');
const path = require('path');

const isDevServer = process.argv.some(a => path.basename(a) === "webpack-dev-server");
const isWatch = process.argv.some(a => a === "--watch");

const context = path.resolve(__dirname, "src");
const targets = glob.sync("src/*.js");
const entry = targets.reduce((entry, target) => {
  const bundle = path.relative(context, target);
  const ext = path.extname(target);
  return Object.assign(entry, {
    [path.basename(target, ext)]: "./" + bundle
  });
}, {});

const publicPath = "/";


module.exports = {
  context,
  entry,
  output: {
    filename: `js/[name]${isDevServer ? "" : "-[hash]"}.js`,
    chunkFilename: `js/[name]${isDevServer ? "" : "-[hash]"}.chunk.js`,
    hotUpdateChunkFilename: `js/[id]${isDevServer ? "" : "-[hash]"}.hot-update.js`,
    path: path.resolve(__dirname, "dist"),
    publicPath
  },
  resolve: {
    extensions: [
      ".purs",
      ".js",
      ".css",
      ".png",
      ".svg",
      ".gif",
      ".jpeg",
      ".jpg"
    ],
    modules: [
      ".",
      "node_modules"
    ]
  },
  resolveLoader: {
    modules: [
      "node_modules"
    ],
  },
  plugins: [
    new EnvironmentPlugin(
      JSON.parse(JSON.stringify(process.env)),
    ),
    new MiniCssExtractPlugin({
      filename: `css/[name]${isDevServer ? "" : "-[contenthash:8]"}.css`,
      chunkFilename: `css/[name]${isDevServer ? "" : "-[contenthash:8]"}.chunk.css`,
      publicPath,
      ignoreOrder: false
    }),
    new HtmlPlugin({
      filename: 'index.html',
      template: `./index.html`,
      // favicon: './static/favicon.ico',
      meta: {
        BASE_URL: process.env.BASE_URL,
      },
      chunks: ["application"],
    }),
    new ManifestPlugin({
      fileName: "manifest.json",
      publicPath,
      writeToFileEmit: true
    })
  ],

  module: {
    rules: [
      {
        test: /\.css$/,
        use:
        [
          { loader: MiniCssExtractPlugin.loader },
          {
            loader: "css-loader",
            options: {
              sourceMap: true
            }
          },
          {
            loader: "postcss-loader",
            options: {
              sourceMap: true
            }
          },
        ]
      },
      {
        test: /\.(tiff|ico|svg|eot|otf|ttf|woff|woff2)$/,
        use: [
          {
            loader: "file-loader",
            options: {
              name: "media/[folder]/[name]-[hash:8].[ext]",
            },
          },
        ]
      },
      {
        test: /\.(png|jpg|jpeg|gif)$/,
        use: [
          { loader: "url-loader",
            options: {
              limit: 8192,
              name: "media/[folder]/[name]-[hash:8].[ext]",
            },
          },
        ]
      },
      {
        test: /\.purs$/,
        use: [
          {
            loader: "purs-loader",
            options: {
              spago: true,
              src: [],
              watch: isDevServer || isWatch,
            }
          },
        ]
      },
    ]
  },

  devServer: {
    host: "0.0.0.0",
    port: "8080",
    disableHostCheck: true,
    hot: true,
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    publicPath
  }
};
