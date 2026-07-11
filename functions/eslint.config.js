const tseslint = require('typescript-eslint');

module.exports = tseslint.config(
  {
    ignores: ['lib/**', 'node_modules/**'],
  },
  {
    files: ['**/*.ts'],
    languageOptions: {
      parser: tseslint.parser,
    },
    plugins: {
      '@typescript-eslint': tseslint.plugin,
    },
    rules: {
      ...tseslint.configs.recommended.rules,
    },
  },
  {
    files: ['**/*.js'],
    rules: {},
  },
);
