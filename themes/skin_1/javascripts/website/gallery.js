// This script is for picpops
function PicPop(url,w,h) {
var dim = eval('"width=' + w + ',height=' + h + ',toolbar=0, location=0, directories=0, status=0, menubar=0, scrollbars=0, resizable=0, top=50, left=50"');
Npop = window.open(url,"instruct",dim);
oldWin = Npop.opener;
}