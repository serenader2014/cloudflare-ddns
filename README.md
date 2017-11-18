# cloudflare ddns

该脚本一般运行在路由器上，作用是定时更新某个域名的dns解析，实现动态域名解析的功能。

## 使用方法

从 cloudflare 的后台里面获取你账号的 API key，然后将 API key 和你的邮箱账号填入 `cloudflare.conf` 文件里面。然后运行：

```bash
./ddns.sh ./cloudflare.conf
```

由于需要定时执行，所以需要在路由上设置一个定时任务，设置每个1小时或者一天执行。