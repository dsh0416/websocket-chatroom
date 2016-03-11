$(document).ready(function() {
    var vueApp = new Vue({
        el: '#app',
        data: {
            has_login: false,
            username: '用户名',
            password: '密码',
            message: [],
            messageToSend: '请输入文字',
            login: function(){
                $.ajax({
                    url: "/login",
                    method: 'post',
                    data: JSON.stringify({username: this.username, password: this.password}),
                    success: function(data){
                        data = JSON.parse(data);
                        if (data['result'] != '1'){
                            alert('密码错误');
                        } else{
                            vueApp.has_login = true;
                        }
                    }
                })
            },
            send: function(){
                ws.send('[' + new Date().toLocaleString() + '] ' + this.username + ': ' + this.messageToSend);
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