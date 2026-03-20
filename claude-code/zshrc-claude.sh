# === Claude Code ===
# Bedrock 接入请按看云接入手册配置:
# https://confluence.zhenguanyu.com/pages/viewpage.action?pageId=913905429

# 默认跳过权限确认（提高效率），claude-safe 恢复确认模式
alias claude="claude --dangerously-skip-permissions"
alias claude-safe="command claude"

# === 代理 ===
PROXY_HTTP="proxy-aws-us.zhenguanyu.com:8118"
PROXY_SOCKS5="proxy-jp.zhenguanyu.com:8388"

proxy_on() {
    export http_proxy="http://${PROXY_HTTP}"
    export https_proxy="http://${PROXY_HTTP}"
    export HTTP_PROXY="http://${PROXY_HTTP}"
    export HTTPS_PROXY="http://${PROXY_HTTP}"
    export all_proxy="socks5://${PROXY_SOCKS5}"
    export ALL_PROXY="socks5://${PROXY_SOCKS5}"
    export no_proxy="localhost,127.0.0.1,*.local,10.*,192.168.*"
    export NO_PROXY="localhost,127.0.0.1,*.local,10.*,192.168.*"
    echo "Proxy ON: ${PROXY_HTTP}"
}

proxy_off() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
    unset all_proxy ALL_PROXY no_proxy NO_PROXY
    echo "Proxy OFF"
}

# 默认开启代理（Bedrock API 需要）
proxy_on
