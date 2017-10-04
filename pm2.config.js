module.exports = {
  apps: [{
    "name":             "testrpc",
    "script":           `${__dirname}/testrpc.js`,
    "cwd":              ".",
    "log_date_format":  "YYYY-MM-DD HH:mm Z",
    "merge_logs":       false,
    "watch":            false,
    "exec_mode":        "fork_mode"
  },{
    "name":             "unit_tests",
    "script":           "./test/test_executeBid.js",
    "interpreter_args": "test",
    "interpreter":      "./node_modules/truffle/build/cli.bundle.js",
    "cwd":              ".",
    "log_date_format":  "YYYY-MM-DD HH:mm Z",
    "merge_logs":       false,
    "watch":            false,
    "exec_mode":        "fork_mode"
  }]
}
