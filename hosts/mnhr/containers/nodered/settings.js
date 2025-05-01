/**
 * This is the default settings file provided by Node-RED.
 *
 * It can contain any valid JavaScript code that will get run when Node-RED
 * is started.
 *
 * Lines that start with // are commented out.
 * Each entry should be separated from the entries above and below by a comma ','
 *
 * For more information about individual settings, refer to the documentation:
 *    https://nodered.org/docs/user-guide/runtime/configuration
 *
 * The settings are split into the following sections:
 *  - Flow File and User Directory Settings
 *  - Security
 *  - Server Settings
 *  - Runtime Settings
 *  - Editor Settings
 *  - Node Settings
 *
 **/

module.exports = {

    /** The file containing the flows. If not set, defaults to flows_<hostname>.json **/
    flowFile: process.env.NODE_RED_DEFAULT_FLOW_FILE || "flows.json",

    /** By default, the flow JSON will be formatted over multiple lines making
     * it easier to compare changes when using version control.
     * To disable pretty-printing of the JSON set the following property to false.
     */
    flowFilePretty: true,

    /** the tcp port that the Node-RED web server is listening on */
    uiPort: process.env.PORT || 1880,

    /** Configure diagnostics options
     * - enabled:  When `enabled` is `true` (or unset), diagnostics data will
     *   be available at http://localhost:1880/diagnostics
     * - ui: When `ui` is `true` (or unset), the action `show-system-info` will
     *   be available to logged in users of node-red editor
    */
    diagnostics: {
        /** enable or disable diagnostics endpoint. Must be set to `false` to disable */
        enabled: true,
        /** enable or disable diagnostics display in the node-red editor. Must be set to `false` to disable */
        ui: true,
    },
    /** Configure runtimeState options
     * - enabled:  When `enabled` is `true` flows runtime can be Started/Stopped
     *   by POSTing to available at http://localhost:1880/flows/state
     * - ui: When `ui` is `true`, the action `core:start-flows` and
     *   `core:stop-flows` will be available to logged in users of node-red editor
     *   Also, the deploy menu (when set to default) will show a stop or start button
     */
    runtimeState: {
        /** enable or disable flows/state endpoint. Must be set to `false` to disable */
        enabled: false,
        /** show or hide runtime stop/start options in the node-red editor. Must be set to `false` to hide */
        ui: false,
    },
    /** Configure the logging output */
    logging: {
        /** Only console logging is currently supported */
        console: {
            /** Level of logging to be recorded. Options are:
             * fatal - only those errors which make the application unusable should be recorded
             * error - record errors which are deemed fatal for a particular request + fatal errors
             * warn - record problems which are non fatal + errors + fatal errors
             * info - record information about the general running of the application + warn + error + fatal errors
             * debug - record information which is more verbose than info + info + warn + error + fatal errors
             * trace - record very detailed logging + debug + info + warn + error + fatal errors
             * off - turn off all logging (doesn't affect metrics or audit)
             */
            level: "info",
            /** Whether or not to include metric events in the log output */
            metrics: false,
            /** Whether or not to include audit events in the log output */
            audit: false
        }
    },

    /** `global.keys()` returns a list of all properties set in global context.
     * This allows them to be displayed in the Context Sidebar within the editor.
     * In some circumstances it is not desirable to expose them to the editor. The
     * following property can be used to hide any property set in `functionGlobalContext`
     * from being list by `global.keys()`.
     * By default, the property is set to false to avoid accidental exposure of
     * their values. Setting this to true will cause the keys to be listed.
     */
    exportGlobalContextKeys: process.env.NODE_RED_EXPORT_GLOBAL_CONTEXT_KEYS || false,

    /** Customising the editor
     * See https://nodered.org/docs/user-guide/runtime/configuration#editor-themes
     * for all available options.
     */
    editorTheme: {
        /** The following property can be used to set a custom theme for the editor.
         * See https://github.com/node-red-contrib-themes/theme-collection for
         * a collection of themes to chose from.
         */
        theme: process.env.NODE_RED_EDITOR_THEME || "",

        /** To disable the 'Welcome to Node-RED' tour that is displayed the first
         * time you access the editor for each release of Node-RED, set this to false
         */
        tours: false,

        projects: {
            /** To enable the Projects feature, set this value to true */
            enabled: false,
            workflow: {
                /** Set the default projects workflow mode.
                 *  - manual - you must manually commit changes
                 *  - auto - changes are automatically committed
                 * This can be overridden per-user from the 'Git config'
                 * section of 'User Settings' within the editor
                 */
                mode: "manual"
            }
        },

        codeEditor: {
            /** Select the text editor component used by the editor.
             * As of Node-RED V3, this defaults to "monaco", but can be set to "ace" if desired
             */
            lib: "monaco",
        },

        markdownEditor: {
            mermaid: {
                /** enable or disable mermaid diagram in markdown document
                 */
                enabled: true
            }
        },

    },

    /** Allow the Function node to load additional npm modules directly */
    functionExternalModules: true,

    /** Default timeout, in seconds, for the Function node. 0 means no timeout is applied */
    functionTimeout: 0,

    /** The following property can be used to set predefined values in Global Context.
     * This allows extra node modules to be made available with in Function node.
     * For example, the following:
     *    functionGlobalContext: { os:require('os') }
     * will allow the `os` module to be accessed in a Function node using:
     *    global.get("os")
     */
    functionGlobalContext: {
        // os:require('os'),
    },

    /** The maximum length, in characters, of any message sent to the debug sidebar tab */
    debugMaxLength: 1000,

    /** Retry time in milliseconds for MQTT connections */
    mqttReconnectTime: 15000,

    /** Retry time in milliseconds for Serial port connections */
    serialReconnectTime: 15000,
}
