var config = module.exports;

config["Browser tests"] = {
  env: 'node',
  rootPath: "../",
  sources: ["lib/**/*.coffee"],
  tests: ["spec/**/*.coffee"],
  extensions: [require("buster-coffee")]
};