$(document).ready(function() {
    var vueApp = new Vue({
        el: '#app',
        data: {
            has_login: false,
            nickname: '昵称',
            message: [],
            messageToSend: '请输入文字',
            confirm: function(){
               vueApp.has_login = true;
            },
            send: function(){
                ws.send('[' + new Date().toLocaleString() + '] ' + this.nickname + ': ' + this.messageToSend);
            }
        }
    });

    var ws = new WebSocket('ws://' + window.location.host + '/room/1');
    ws.onopen    = function()  {};
    ws.onclose   = function()  {};
    ws.onmessage = function(m) {
        vueApp.message = vueApp.message.concat(JSON.parse(m.data));
    };

});