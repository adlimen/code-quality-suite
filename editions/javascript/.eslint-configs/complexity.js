import typescriptParser from "@typescript-eslint/parser";

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
    rules: {
      complexity: ["error", { max: 15 }], // Aligned with SonarJS cognitive complexity
      "max-depth": ["error", 4],
      "max-lines": [
        "error",
        { max: 500, skipBlankLines: true, skipComments: true },
      ],
      "max-lines-per-function": [
        "error",
        { max: 100, skipBlankLines: true, skipComments: true },
      ],
      "max-nested-callbacks": ["error", 3],
      "max-params": ["error", 4],
      "max-statements": ["error", 20],
      "max-statements-per-line": ["error", { max: 1 }],
    },
  },
  // Relaxed rules for utility scripts and CLI tools
  {
    files: ["scripts/**/*.{js,cjs}"],
    rules: {
      complexity: ["error", { max: 25 }], // CLI scripts are naturally more complex
      "max-lines": [
        "error",
        { max: 1000, skipBlankLines: true, skipComments: true },
      ], // Utility scripts can be longer
      "max-lines-per-function": [
        "error",
        { max: 200, skipBlankLines: true, skipComments: true },
      ], // CLI functions need more space
      "max-params": ["error", 8], // CLI functions often need more params
      "max-statements": ["error", 50], // More statements for CLI logic
    },
  },
];
