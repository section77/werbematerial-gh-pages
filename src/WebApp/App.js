"use strict";


exports.scrollElementByIdIntoView = function(id) {
    var element = document.getElementById(id);
    if(element == null) {
        console.log("element by id: " + id + " not found");
    } else {
        element.scrollIntoView();
    }
}
