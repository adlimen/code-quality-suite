/** @type {import('dependency-cruiser').IConfiguration} */
const SPEC_FILE_PATTERN =
  "\\.spec\\.(js|mjs|cjs|ts|ls|coffee|litcoffee|coffee\\.md)$";

module.exports = {
  forbidden: [
    /* rules from the 'recommended' preset: */
    {
      name: "no-circular",
      severity: "warn",
      comment:
        "This dependency is part of a circular relationship. You might want to revise " +
        "your solution (i.e. use dependency inversion, make sure the modules have a single responsibility) ",
      from: {},
      to: {
        circular: true,
      },
    },
    {
      name: "no-orphans",
      comment:
        "This is an orphan module - it's likely not used (anymore?). Either use it or " +
        "remove it. If it's logical this module is an orphan (i.e. it's a config file), " +
        "add an exception for it in your dependency-cruiser configuration. By default " +
        "this rule does not scrutinize dot-files (e.g. .eslintrc.js), TypeScript declaration " +
        "files (.d.ts), tsconfig.json and some of the babel and webpack configs.",
      severity: "warn",
      from: {
        orphan: true,
        pathNot: [
          "(^|/)\\.[^/]+\\.(js|cjs|mjs|ts|json)$", // dot files
          "\\.d\\.ts$", // TypeScript declaration files
          "(^|/)tsconfig\\.json$", // TypeScript config
          "(^|/)(babel|webpack)\\.config\\.(js|cjs|mjs|ts|json)$", // babel and webpack configs
        ],
      },
      to: {},
    },
    {
      name: "no-deprecated-core",
      comment:
        "A module depends on a node core module that has been deprecated. Find an alternative - these are " +
        "bound to exist - node doesn't deprecate lightly.",
      severity: "warn",
      from: {},
      to: {
        dependencyTypes: ["core"],
        path: ["^(punycode|domain|constants|sys)$"],
      },
    },
    {
      name: "not-to-deprecated",
      comment:
        "This module uses a (version of an) npm module that has been deprecated. Either upgrade to a later " +
        "version of that module, or find an alternative. Deprecated modules are a security risk.",
      severity: "warn",
      from: {},
      to: {
        dependencyTypes: ["deprecated"],
      },
    },
    {
      name: "no-non-package-json",
      severity: "error",
      comment:
        "This module depends on an npm package that isn't in the 'dependencies' section of your package.json. " +
        "That's problematic as the package either (1) won't be available on live (2) will be available on live " +
        "with an non-guaranteed version. Fix it by adding the package to the dependencies in your package.json.",
      from: {},
      to: {
        dependencyTypes: ["npm-no-pkg", "npm-unknown"],
      },
    },
    {
      name: "not-to-unresolvable",
      comment:
        "This module depends on a module that cannot be found ('resolved to disk'). If it's an npm " +
        "module: add it to your package.json. In all other cases you likely already know what to do.",
      severity: "error",
      from: {},
      to: {
        couldNotResolve: true,
      },
    },
    {
      name: "no-duplicate-dep-types",
      comment:
        "Likely this module depends on an external ('npm') package that occurs more than once " +
        "in your package.json i.e. bot as a devDependencies and in dependencies. This will cause " +
        "maintenance problems later on.",
      severity: "warn",
      from: {},
      to: {
        moreThanOneDependencyType: true,
        // as it's pretty common to have a type import be a type only import
        // _and_ (e.g.) a devDependency - don't consider type-only dependency
        // types for this rule
        dependencyTypesNot: ["type-only"],
      },
    },

    /* rules you might want to tweak for your specific situation: */
    {
      name: "not-to-spec",
      comment:
        "This module depends on a spec (test) file. The sole responsibility of a spec file is to test code. " +
        "If there's something in a spec that's of use to other modules, it doesn't have that single " +
        "responsibility anymore. Factor it out into (e.g.) a separate utility/ helper or a mock.",
      severity: "error",
      from: {
        pathNot: SPEC_FILE_PATTERN,
      },
      to: {
        path: SPEC_FILE_PATTERN,
      },
    },
    {
      name: "not-to-dev-dep",
      severity: "error",
      comment:
        "This module depends on an npm package from the 'devDependencies' section of your " +
        "package.json. It looks like something that ships to production, though. To prevent problems " +
        "with npm packages that aren't there on production declare it (only!) in the 'dependencies'" +
        "section of your package.json. If this module is development only - add it to the " +
        "from.pathNot re of the not-to-dev-dep rule in the dependency-cruiser configuration",
      from: {
        path: "^(src|app|lib)",
        pathNot: SPEC_FILE_PATTERN,
      },
      to: {
        dependencyTypes: ["npm-dev"],
      },
    },
    {
      name: "optional-deps-used",
      severity: "info",
      comment:
        "This module depends on an npm package that is declared as an optional dependency " +
        "in your package.json. As this makes sense in limited situations only, it's flagged here. " +
        "If you're using an optional dependency here by design - add an exception to your" +
        "dependency-cruiser configuration.",
      from: {},
      to: {
        dependencyTypes: ["npm-optional"],
      },
    },
    {
      name: "peer-deps-used",
      comment:
        "This module depends on an npm package that is declared as a peer dependency " +
        "in your package.json. This makes sense if your package is e.g. a plugin, but in " +
        "other cases - maybe not so much. If the use of a peer dependency is intentional " +
        "add an exception to your dependency-cruiser configuration.",
      severity: "warn",
      from: {},
      to: {
        dependencyTypes: ["npm-peer"],
      },
    },
  ],
  options: {
    /* conditions to take into account when following dependencies.
       Defaults to a 'sane' set of conditions. See 
       https://nodejs.org/api/packages.html#resolving-user-conditions 
       for the complete list of conditions node.js supports out of the box.
       You might want to specify conditions explicitly if you have your 
       own conditions of if you run dependency-cruiser on code not meant
       to run on node (e.g. browser code)
    */
    // conditionsUsed: ['import', 'require', 'default'],

    /* pattern specifying which files not to follow further when encountered:
       - node_modules: don't cruise into node_modules
       - \.d\.ts$: don't cruise into .d.ts files (TypeScript type definitions)
    */
    doNotFollow: {
      path: "node_modules",
    },

    /* pattern specifying which files to exclude (regular expression)
       - \\.spec\\.(js|mjs|cjs|ts|ls|coffee|litcoffee|coffee\\.md)$": don't cruise spec files
    */
    exclude: {
      path: "\\.spec\\.(js|mjs|cjs|ts|ls|coffee|litcoffee|coffee\\.md)$",
    },

    /* pattern specifying which files to include (regular expression)
       - \\.(js|mjs|cjs|ts|ls|coffee|litcoffee|coffee\\.md)$: only cruise js, mjs, cjs, ts, ls, coffee and litcoffee files
    */
    includeOnly: {
      path: "\\.(js|mjs|cjs|jsx|ts|tsx|ls|coffee|litcoffee|coffee\\.md)$",
    },

    /* list of module systems to cruise */
    moduleSystems: ["amd", "cjs", "es6", "tsd"],

    /* prefix for links in html and svg output (e.g. 'https://github.com/you/yourrepo/blob/develop/'
       to open it on your online repo or `vscode://file/${process.cwd()}/` to 
       open it in visual studio code),
     */
    // prefix: 'https://github.com/sverweij/dependency-cruiser/blob/develop/',

    /* false (the default): ignore dependencies that only exist before typescript-to-javascript compilation
       true: also detect dependencies that only exist before typescript-to-javascript compilation
       "specify": for each dependency identify whether it only exists before compilation or also after
     */
    tsPreCompilationDeps: true,

    /* 
       list of extensions to scan that aren't javascript or compile-to-javascript. 
       Empty by default. Only put extensions in here that you cannot parse 
       with dependency-cruiser's built-in parsers (i.e. are not typescript,
       javascript, coffeescript, livescript, less, sass or stylus)
     */
    // extraExtensionsToScan: [".mjs", ".cjs"],

    /* if true combines the package.jsons found from the module up to the base
       folder the cruise is initiated from. Useful for how (some) mono-repos
       manage dependencies & dependency definitions.
     */
    // combinedDependencies: false,

    /* if true leave symlinks untouched, otherwise use the realpath */
    // preserveSymlinks: false,

    /* TypeScript project file ('tsconfig.json') to use for
       (1) compilation and
       (2) resolution (e.g. with the paths property)

       The (optional) fileName attribute specifies which file to take (relative to
       dependency-cruiser's current working directory). When not provided
       defaults to './tsconfig.json'.
     */
    tsConfig: {
      fileName: "tsconfig.json",
    },

    /* Webpack configuration to use to get resolve options from.

       The (optional) fileName attribute specifies which file to take (relative
       to dependency-cruiser's current working directory. When not provided defaults
       to './webpack.conf.js'.

       The (optional) `env` attribute sets the environment to pass if your webpack config is a function
       that returns a config for a given environment (see webpack.js.org/configuration/configuration-types/#exporting-a-function)

       The (optional) arguments attribute specifies the arguments to pass if your webpack config
       exports a function. E.g. if you call webpack with --mode=production you'd want to pass
       ["--mode", "production"] here.
     */
    // webpackConfig: {
    //  fileName: 'webpack.config.js',
    //  env: {},
    //  arguments: {}
    // },

    /* How to resolve external modules - use "yarn-pnp" if you're using yarn's Plug'n'Play.
       otherwise leave it out (or set to the default, which is 'node_modules')
    */
    // externalModuleResolutionStrategy: 'node_modules',

    /* List of strings you have in use in addition to cjs/ es6 requires
       & imports to declare module dependencies. Use this e.g. if you've
       re-declared require, use a require-wrapper or use window.require as
       a hack.
    */
    // exoticRequireStrings: [],
    /* options to pass on to enhanced-resolve, the package dependency-cruiser
       uses to resolve module references to disk. You can set most of these
       options in a webpack.config.js - this section is here for those
       projects that don't have a separate webpack config file.

       Note: settings in webpack.config.js override the ones specified here.
     */
    enhancedResolveOptions: {
      /* List of strings to consider as 'exports' fields in package.json. Use
         ['exports'] when you use packages that use such a field and your environment
         supports it (e.g. node ^12.19 || >=14.7 or recent versions of webpack).

        If you have an `exportsFields` attribute in your webpack config, that one
         will have precedence over the one specified here.
      */
      exportsFields: ["exports"],
      /* List of conditions to check for in the exports field. e.g. use ['imports']
         if you're only interested in exposed es6 modules, ['require'] for commonjs,
         or all conditions at once `(['import', 'require', 'node', 'default']`)
         if anything goes for you. Only works when the 'exportsFields' array is
         non-empty.

        If you have a 'conditionNames' attribute in your webpack config, that one will
        have precedence over the one specified here.
      */
      conditionNames: ["import", "require", "node", "default", "types"],
      /*
         The extensions array passed to enhanced-resolve.
       */
      extensions: [".js", ".jsx", ".ts", ".tsx", ".d.ts"],
      /*
         The mainFields array passed to enhanced-resolve. The default is
         ['main'], but most modern projects use the 'module' field
         for the es6 module entrypoint.
       */
      mainFields: ["module", "main", "types", "typings"],
    },
    reporterOptions: {
      dot: {
        /* pattern of modules that can be consolidated in the detailed
           graphical dependency graph. The default pattern in this configuration
           collapses everything in node_modules to one folder deep so you see
           the external modules, but not the innards your app depends upon.
         */
        collapsePattern: "node_modules/(@[^/]+/[^/]+|[^/]+)",

        /* Options to tweak the appearance of your graph.See
           https://github.com/sverweij/dependency-cruiser/blob/develop/doc/options-reference.md#reporteroptions
           for details and some examples. If you don't specify a theme
           don't worry - dependency-cruiser will fall back to the default one.
        */
        // theme: {
        //   graph: {
        //     /* use splines: 'ortho' for straight lines. Be aware though
        //        graphviz might take a long time calculating ortho(gonal)
        //        routings.
        //      */
        //     splines: "true"
        //   },
        //   modules: [
        //     {
        //       criteria: { matchesFocus: true },
        //       attributes: { fillcolor: "lime", penwidth: 2 }
        //     },
        //     {
        //       criteria: { matchesFocus: false },
        //       attributes: { fillcolor: "lightgray" }
        //     },
        //     {
        //       criteria: { matchesReaches: true },
        //       attributes: { fillcolor: "lime", penwidth: 2 }
        //     },
        //     {
        //       criteria: { matchesReaches: false },
        //       attributes: { fillcolor: "lightgray" }
        //     },
        //     {
        //       criteria: { source: "^src/model" },
        //       attributes: { fillcolor: "lightblue" }
        //     }
        //   ],
        //   dependencies: [
        //     {
        //       criteria: { "rules[0].severity": "error" },
        //       attributes: { fontcolor: "red", color: "red" }
        //     }
        //   ]
        // }
      },
      archi: {
        /* pattern of modules that can be consolidated in the high level
          graphical dependency graph. If you use the high level graphical
          dependency graph reporter (`archi`) you probably want to tweak
          this collapsePattern to your situation.
        */
        collapsePattern:
          "^(packages|src|lib|app|bin|test(s?)|spec(s?))/[^/]+|node_modules/(@[^/]+/[^/]+|[^/]+)",
      },
      text: {
        highlightFocused: true,
      },
    },
  },
};
// generated: dependency-cruiser@16.7.0 on 2025-07-10T05:56:46.731Z