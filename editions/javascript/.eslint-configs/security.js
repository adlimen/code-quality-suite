import typescriptParser from "@typescript-eslint/parser";
import securityPlugin from "eslint-plugin-security";

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
      security: securityPlugin,
    },
    rules: {
      "security/detect-bidi-characters": "error",
      "security/detect-buffer-noassert": "error",
      "security/detect-child-process": "error",
      "security/detect-disable-mustache-escape": "error",
      "security/detect-eval-with-expression": "error",
      "security/detect-new-buffer": "error",
      "security/detect-no-csrf-before-method-override": "error",
      "security/detect-non-literal-fs-filename": "error",
      "security/detect-non-literal-regexp": "error",
      "security/detect-non-literal-require": "error",
      "security/detect-object-injection": "error",
      "security/detect-possible-timing-attacks": "error",
      "security/detect-pseudoRandomBytes": "error",
      "security/detect-unsafe-regex": "error",
    },
  },
  // Relax security rules for CLI scripts - these are legitimate uses
  {
    files: ["scripts/**/*.{js,cjs}"],
    rules: {
      "security/detect-object-injection": "off",
      "security/detect-non-literal-fs-filename": "off",
      "security/detect-non-literal-regexp": "off",
    },
  },
];
