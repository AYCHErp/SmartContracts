module.exports = {
    extends: [
      "eslint:recommended"
    ],
    env: {
        browser: true,
        mocha: true,
        node: true,
    },
    parserOptions: {
      "ecmaVersion": 2018,
      "sourceType": "module"
    },
    globals: {
      "web3": true,
      "artifacts": true,
      "contract": true
    },
    rules: {
        "arrow-body-style": "off",
        "comma-dangle": [
          "error", 
          "always-multiline"
        ],
        "quotes": [
          "error",
          "double",
          {
            "allowTemplateLiterals": true
          }
        ],
        "import/no-dynamic-require": "off",
        "import/no-extraneous-dependencies": "off",
        indent: [
            "error",
            2,
            {
                SwitchCase: 1,
            },
        ],
        "linebreak-style": [
          "error",
          "unix"
        ],
        "max-len": [
            "warn",
            120,
            {
                ignoreComments: true,
            },
            {
                ignoreTrailingComments: true,
            },
        ],
        "no-console": "off",
        "no-trailing-spaces": [
            "error",
            {
                ignoreComments: true,
            },
        ],
        "no-underscore-dangle": [
            "error"
        ],
        "no-useless-concat": [
          "error"
        ],
        "no-unused-vars": [
            "error",
            {
                varsIgnorePattern: "_",
            },
        ],
        "prefer-template": [
          "error"
        ],
        strict: "off",
        "require-atomic-updates": "off"
    },
};
