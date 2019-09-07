"use strict";

exports.initSidenav = function() {
    var elems = document.querySelectorAll('.sidenav');
    return M.Sidenav.init(elems, {});
}
