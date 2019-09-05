const path = require("path");
const glob = require("glob");
const webpack = require("webpack");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const VueLoaderPlugin = require("vue-loader/lib/plugin");
const ManifestPlugin = require("webpack-manifest-plugin");

let entries = {};
glob.sync("./frontend/entry/**/*.js").map(function(file) {
  let name = file.replace("./frontend/entry/", "").split(".")[0];
  entries[name] = file;
});

const assets_path = path.join(__dirname, "public", "assets");

module.exports = (env, argv) => {

  return {
    entry: entries,
    output: {
      filename: "js/[name]-[hash].js",
      chunkFilename: "js/[name]-[hash].chunk.js",
      hotUpdateChunkFilename: "js/[id]-[hash].hot-update.js",
      path: assets_path,
      publicPath: "/assets/",
      pathinfo: true
    },
    plugins: [
      new VueLoaderPlugin(),
      new MiniCssExtractPlugin({
        filename: "stylesheets/[name]-[hash].css"
      }),
      new webpack.HotModuleReplacementPlugin(),
      new ManifestPlugin({
        writeToFileEmit: true
      })
    ],
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          loader: "babel-loader",
          options: {
            presets: [
              [
                "@babel/preset-env",
                {
                  targets: {
                    ie: 11
                  },
                  useBuiltIns: "usage"
                }
              ]
            ]
          }
        },
        {
          test: /\.vue$/,
          use: [
            {
              loader: "vue-loader",
              options: { extractCSS: true }
            }
          ]
        },
        {
          test: /\.pug/,
          loader: "pug-plain-loader"
        },
        {
          test: /\.(c|sc)ss$/,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                publicPath: path.resolve(__dirname, "public/assets/stylesheets")
              }
            },
            "css-loader",
            "sass-loader"
          ]
        },
        {
          test: /\.(jpg|png|gif)$/,
          loader: "file-loader",
          options: {
            name: "[name]-[hash].[ext]",
            outputPath: "images",
            publicPath: function(path) {
              return "/assets/images/" + path;
            }
          }
        }
      ]
    },
    resolve: {
      alias: {
        vue: "vue/dist/vue.js"
      },
      extensions: [
        ".vue",
        ".mjs",
        ".js",
        ".sass",
        ".scss",
        ".css",
        ".module.sass",
        ".module.scss",
        ".module.css",
        ".png",
        ".svg",
        ".gif",
        ".jpeg",
        ".jpg"
      ],

      modules: ["node_modules"]
    },

    devServer: {
      clientLogLevel: "info",
      compress: true,
      quiet: false,
      disableHostCheck: true,
      port: 3035,
      https: false,
      host: "0.0.0.0",
      hot: true,
      contentBase: assets_path,
      inline: false,
      useLocalIp: false,
      public: "0.0.0.0:3035",
      publicPath: "/assets/",
      historyApiFallback: { disableDotRule: true },
      headers: { "Access-Control-Allow-Origin": "*" },
      overlay: true,
      watchOptions: { ignored: "**/node_modules/**", poll: true }
    }
  };
};
