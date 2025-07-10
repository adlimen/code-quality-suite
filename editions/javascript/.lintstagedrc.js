module.exports = {
  // TypeScript and JavaScript files
  '**/*.{ts,tsx,js,jsx}': [
    'prettier --write',
    'eslint --fix',
    'npm run type-check',
  ],

  // JSON files
  '**/*.json': ['prettier --write'],

  // Markdown files
  '**/*.md': ['prettier --write'],

  // CSS files
  '**/*.{css,scss}': ['prettier --write'],

  // Package.json specific checks
  'package.json': ['prettier --write', 'npm run audit:security'],

  // Configuration files
  '**/*.{yml,yaml}': ['prettier --write'],

  // Docker files
  'Dockerfile*': ['echo "Dockerfile changed - manual review recommended"'],

  // Environment files
  '.env*': ['echo "Environment file changed - security review recommended"'],
};
