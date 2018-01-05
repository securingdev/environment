// Register babel to transpile before our tests run
require('babel-register')();

// Disable webpack features that Mocah can't understand
require.extensions['.css'] = function() {};
