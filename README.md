# cloudflare ddns

该脚本一般运行在路由器上，作用是定时更新某个域名的dns解析，实现动态域名解析的功能。

## 使用方法

根据实际情况编辑 `cloudflare.conf` 配置文件，然后运行：

```bash
./ddns.sh ./cloudflare.conf
```

# 配置文件

```
API_KEY="YOUR_CLOUDFLARE_API_KEY"
EMAIL="YOUR_CLOUDFLARE_EMAIL"
DOMAIN="YOUR_DOMAIN"
HOSTS="YOUR_HOSTS DIVIDED_BY_SPACE"
LAST_IP_FILE="LOG_FILE"
```

由于需要定时执行，所以需要在路由上设置一个定时任务，设置每个1小时或者一天执行。