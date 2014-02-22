function setInvisible(visibleID, invisibleId) {
    document.getElementById(visibleID).style.display = 'block';
    document.getElementById(invisibleId).style.display = 'none';
}

function setAllInvisible(activateRadButtons) {
    var inputs = document.getElementsByTagName('input');
    for (var i = 0; inputs.length > i; i++) {
        if (inputs[i].className == activateRadButtons) {
            inputs[i].click();
        }
    }
}