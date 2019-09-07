"use strict";

exports.execCommandImpl = function(cmd, args) {
    const showUI = false;
    return document.execCommand(cmd, showUI, args);
};
