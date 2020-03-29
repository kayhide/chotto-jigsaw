const yaml = require("js-yaml");
const execSync = require('child_process').execSync;

module.exports = {
  injectEnv: (basename) => {
    const file = `./config/${basename}.yml`;
    const raw = execSync(`erb  ${file}`);
    const config = yaml.safeLoad(raw)[process.env.NODE_ENV];
    for (const key in config) {
      const k = `${basename}_${key}`.toUpperCase();
      const v = config[key];
      Object.assign(process.env, {[k]: v});
    }
  }
};
