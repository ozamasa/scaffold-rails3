function submit(url, formname, method){
    var form = document.forms[0];
    if (formname != null) {
        form = document.forms[formname];
    }
    if (method == null || method == '') {
        method = 'POST'
    }
    form.action = url;
    form.method = method;
    form.submit();
}

function sort(col, order){
    var formname = 'form_search';
    var form = document.forms[formname];
    document.getElementById('sort' ).value=col;
    document.getElementById('order').value=order;
    submit('', formname, 'GET');
}

function pop(url, h, winName){
  if(h == undefined || h == null){
    h = 300;
  }
    var win = window.open( url, winName, 'width=700, height=' + h + ', menubar=no, toolbar=no, scrollbars=yes, resizable=yes' );
    win.focus();

}

function windowClose(){
  window.close();
}

function pageTop(targetID){
  var x1 = x2 = x3 = 0;
  var y1 = y2 = y3 = 0;
  if (document.documentElement) {
    x1 = document.documentElement.scrollLeft || 0;
    y1 = document.documentElement.scrollTop || 0;
  }
  if (document.body) {
    x2 = document.body.scrollLeft || 0;
    y2 = document.body.scrollTop || 0;
  }
  x3 = window.scrollX || 0;
  y3 = window.scrollY || 0;
  var x = Math.max(x1, Math.max(x2, x3));
  var y = Math.max(y1, Math.max(y2, y3));
  window.scrollTo(Math.floor(x / 2), Math.floor(y / 2));
  if (x > 0 || y > 0) {
    window.setTimeout("pageTop()", 25);
  }
}

function insertComma(str) {
  var num = new String( str ).replace( /,/g, "" );
  while ( num != ( num = num.replace( /^(-?\d+)(\d{3})/, "$1,$2" ) ) );
  return num;
}

function deleteComma(str){
  var num = new String( str ).replace( /,/g, "" ); return num;
}

function checkNum(val){
  flg = false;

  if(!isNull(val)){
    if(isNum(val)){
      flg = true;
    }
  }
  return flg;
}

function isNum(elm){
  flg = true;
  var reg = new RegExp(/[^0-9]/);
  if(elm.match(reg)){
    flg = false;
  }
  return flg;
}

function isNull(val){
  if(val == null || val == ''){
    return true;
  }
  return false;
}
