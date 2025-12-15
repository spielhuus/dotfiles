.pragma library

// 1. Mock Node.js environment
var exports = {};
var module = { exports: exports };
function require(name) { return {}; } // Prevents crash if lib calls require()

// 2. Mock Browser environment
var window = this;
var global = this;
var self = this;

// 3. Load the library
// Returns { status: int, exception: var }
var loadResult = Qt.include("js-yaml.min.js");

// 4. Debug Logging
if (loadResult.status !== 0) {
  console.warn("YamlLoader: ERROR loading js-yaml.min.js. Status: " + loadResult.status);
  if (loadResult.exception) console.warn("YamlLoader: Exception: " + JSON.stringify(loadResult.exception));
}

// 5. Locate the API
var api = {};

// Check CommonJS export
if (module.exports && module.exports !== exports && Object.keys(module.exports).length > 0) {
  api = module.exports;
}
// Check global variable (js-yaml v3/v4 often uses 'jsyaml')
else if (typeof jsyaml !== "undefined") {
  api = jsyaml;
}
// Check window attachment
else if (window.jsyaml) {
  api = window.jsyaml;
}
// Check 'this' attachment
else if (this.jsyaml) {
  api = this.jsyaml;
}
else {
  console.log("YamlLoader: Warning - Could not find jsyaml object. Checking for global functions...");
  // Last ditch: did it flatten into global scope?
  if (typeof load === 'function') api.load = load;
  if (typeof safeLoad === 'function') api.safeLoad = safeLoad;
}
