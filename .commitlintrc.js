module.exports = {
  extends: ['@commitlint/config-conventional'],
  ignores: [(message) => message.trim() === 'initial commie'],
};
