# Docker 配置

## 1. 看云 Registry 登录

看云 Docker Registry 使用阿里云容器镜像服务，需要先设置固定密码再登录。

### 1.1 设置固定密码（首次）

1. 用 LDAP 账号登录阿里云：https://signin.aliyun.com/yfd.onaliyun.com/login.htm
2. 进入容器镜像服务，设置固定密码：https://cr.console.aliyun.com/cn-beijing/instance/cri-szw6f6bhrky0c8jk/credentials
3. 设置一个 Docker 登录专用密码（不是 LDAP 密码）

### 1.2 登录

```bash
# 格式: <LDAP账号>@yfd
docker login --username=<你的LDAP>@yfd docker-registry.zhenguanyu.com

# 例如:
docker login --username=wupengfeibj01@yfd docker-registry.zhenguanyu.com
```

输入上一步设置的固定密码。

### 1.3 验证

```bash
docker pull docker-registry.zhenguanyu.com/yuanfd/yfd_nodejs_ct8:22.19.0
```

---

## 2. Docker Desktop 代理配置（macOS）

### 问题

docker.io 被墙，`docker pull` 官方镜像超时。需要配代理拉 docker.io，同时保证看云 registry 不走代理。

### 配置步骤

1. 打开 Docker Desktop → **Settings** → **Resources** → **Proxies**
2. 勾选 **Manual proxy configuration**
3. 填写：

| 字段 | 值 |
|------|-----|
| Web Server (HTTP) | `http://proxy.zhenguanyu.com:8118` |
| Secure Web Server (HTTPS) | `http://proxy.zhenguanyu.com:8118` |
| Bypass proxy | `localhost,127.0.0.1,*.zhenguanyu.com,docker-registry.zhenguanyu.com,*.cn-beijing.aliyuncs.com` |

4. 点 **Apply & Restart**

### 验证

```bash
# 官方镜像（包括 arm64）
docker pull --platform linux/arm64 node:22-slim

# 看云 registry（不走代理）
docker pull docker-registry.zhenguanyu.com/yuanfd/yfd_nodejs_ct8:22.19.0
```

---

## 3. Linux 服务器配置

Linux 上 Docker 直接读 `/etc/docker/daemon.json`：

```json
{
  "proxies": {
    "http-proxy": "http://proxy.zhenguanyu.com:8118",
    "https-proxy": "http://proxy.zhenguanyu.com:8118",
    "no-proxy": "100.0.0.0/8,127.0.0.0/8,10.0.0.0/8,172.0.0.0/8,*.cn-beijing.aliyuncs.com,docker-registry.zhenguanyu.com,yfd-registry-vpc.cn-beijing.cr.aliyuncs.com"
  },
  "data-root": "/home/data"
}
```

配好后：`sudo systemctl restart docker`

---

## 常见问题

#### Q: macOS 上 `daemon.json` 里配 `proxies` 不生效？

macOS Docker Desktop 用内部代理 `http.docker.internal:3128` 覆盖了 `daemon.json`。**只有 GUI 里配的代理才生效。**

验证：
```bash
docker info | grep -i proxy
# 看到 http.docker.internal:3128 说明是 Docker Desktop 内部代理在转发
```

#### Q: 配了代理后看云 registry 连不上？

确保 Bypass proxy 里包含 `*.zhenguanyu.com,docker-registry.zhenguanyu.com`。

#### Q: `docker login` 报 `unauthorized`？

- 确认用户名格式是 `<LDAP>@yfd`（不是邮箱）
- 确认已在阿里云设置了[固定密码](https://cr.console.aliyun.com/cn-beijing/instance/cri-szw6f6bhrky0c8jk/credentials)
- 密码是阿里云上设置的固定密码，不是 LDAP 密码

---

## 参考配置文件

- [daemon.json (macOS)](daemon-macos.json) — macOS 的 daemon.json（代理在 GUI 配，这里不含）
- [daemon.json (Linux)](daemon-linux.json) — Linux 服务器的完整配置
