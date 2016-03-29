$(document).ready(function() {
    var vueApp = new Vue({
        el: '#app',
        data: {
            has_login: false,
            nickname: '昵称',
            password: '密码',
            message: [],
            messageToSend: '请输入文字',
            confirm: function(){
                $.ajax({
                    url: '/login',
                    method: 'post',
                    data: JSON.stringify({username: vueApp.nickname, password: vueApp.password}),
                    success: function(data){
                        data = JSON.parse(data);
                        if (data['result'] == '1'){
                            vueApp.has_login = true;
                        } else {
                            alert('密码错误');
                        }
                    }
                }
                );
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