module.exports = {
  apps: [{
    "name":             "tests",
    "script":           "./test/test_executeBid.js",
    "interpreter_args": "test",
    "interpreter":      "./node_modules/.bin/truffle",
    "cwd":              ".",
    "log_date_format":  "YYYY-MM-DD HH:mm Z",
    "merge_logs":       false,
    "watch":            false,
    "exec_mode":        "fork_mode"
  }]
}
