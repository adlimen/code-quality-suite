import typescriptParser from "@typescript-eslint/parser";
import sonarPlugin from "eslint-plugin-sonarjs";

export default [
  {
    files: ["**/*.{js,jsx,ts,tsx}"],
    ignores: [
      ".next/**",
      "node_modules/**",
      "dist/**",
      "build/**",
      "reports/**",
    ],
    languageOptions: {
      parser: typescriptParser,
      ecmaVersion: 2021,
      sourceType: "module",
      parserOptions: {
        ecmaFeatures: { jsx: true },
      },
      globals: {
        window: "readonly",
        document: "readonly",
        console: "readonly",
        process: "readonly",
        global: "readonly",
        Buffer: "readonly",
      },
    },
    plugins: {
      sonarjs: sonarPlugin,
    },
    rules: {
      "prefer-const": "error",
      "no-var": "error",
      "no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
      "no-console": "warn",
      "no-debugger": "error",
      eqeqeq: "error",
      curly: "error",
      "no-duplicate-imports": "error",
      "no-empty": "error",
      "no-extra-boolean-cast": "error",
      "no-unreachable": "error",
      "consistent-return": "error",
      "sonarjs/cognitive-complexity": ["error", 15],
      "sonarjs/no-duplicate-string": ["error", { threshold: 3 }],
      "sonarjs/no-identical-functions": "error",
      "sonarjs/no-redundant-boolean": "error",
      "sonarjs/no-unused-collection": "error",
      "sonarjs/prefer-immediate-return": "error",
    },
  },
  // Allow console.log in CLI scripts
  {
    files: ["scripts/**/*.{js,cjs}"],
    rules: {
      "no-console": "off",
    },
  },
];
