pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config

Singleton {
    id: root

    property bool isSystemd: Quickshell.env("INVOCATION_ID") !== "" || Quickshell.env("SYSTEMD_EXEC_PID") !== ""

    FileView {
        path: "/proc/1/comm"
        onLoaded: root.isSystemd = text().trim() === "systemd"
    }

    function exec(command: list<string>, workingDirectory: string = ""): void {
        const args = root.isSystemd ? ["app2unit", "--", ...command] : command;
        const options = {command: args};

        if (workingDirectory)
            options.workingDirectory = workingDirectory;

        Quickshell.execDetached(options);
    }

    function execTerminal(command: list<string>, workingDirectory: string = ""): void {
        exec([...Config.general.apps.terminal, `${Quickshell.shellDir}/assets/wrap_term_launch.sh`, ...command], workingDirectory);
    }

    function open(url: string): void {
        if (root.isSystemd)
            Quickshell.execDetached(["app2unit", "-O", "--", url]);
        else
            Quickshell.execDetached(["xdg-open", url]);
    }
}
