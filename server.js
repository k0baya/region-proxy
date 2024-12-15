var exec = require("child_process").exec;
const os = require("os");
var fs = require("fs");
var path = require("path");

function keep_glider_alive() {
    exec("pgrep -laf glider", function (err, stdout, stderr) {
      // 1.查后台系统进程，保持唤醒
      if (stdout.includes("./glider")) {
        console.log("Glider 正在运行");
      }
      else {
        //Glider 未运行，命令行调起
        exec(
          "bash glider.sh 2>&1 &", function (err, stdout, stderr) {
            if (err) {
              console.log("保活-调起Glider-命令行执行错误:" + err);
            }
            else {
              console.log("保活-调起Glider-命令行执行成功!");
            }
          }
        );
      }
    });
}
setInterval(keep_glider_alive, 30 * 1000);

function keep_tor_alive() {
    exec("pgrep -laf tor", function (err, stdout, stderr) {
      // 1.查后台系统进程，保持唤醒
      if (stdout.includes("tor --DataDirectory")) {
        console.log("Tor正在运行");
      }
      else {
        //Tor未运行，命令行调起
        exec(
          "bash tor.sh 2>&1 &", function (err, stdout, stderr) { // Ensure "tor.sh" matches the generated filename
            if (err) {
              console.log("保活-调起Tor-命令行执行错误:" + err);
            }
            else {
              console.log("保活-调起Tor-命令行执行成功!");
            }
          }
        );
      }
    });
}
setInterval(keep_tor_alive, 45 * 1000);

exec("bash entrypoint.sh", function (err, stdout, stderr) {
    if (err) {
      console.error(err);
      return;
    }
    console.log(stdout);
});