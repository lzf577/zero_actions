# Zero Actions 🌐

> 基于 GitHub Actions 的自动化 ZeroTier 虚拟组网、网络稳定性检验与高速 UDP 中继矩阵

[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-Automated-blue?logo=githubactions)](https://github.com/lzf577/zero_actions/actions)
[![ZeroTier](https://img.shields.io/badge/ZeroTier-Integrated-FF9800?logo=zerotier)](https://www.zerotier.com/)
[![TUIC](https://img.shields.io/badge/Protocol-TUIC_v5-8A2BE2)](https://github.com/tuic-protocol/tuic)
[![Shadowsocks](https://img.shields.io/badge/Protocol-Shadowsocks--UDP-blue)](https://github.com/shadowsocks/go-shadowsocks2)
[![Gost](https://img.shields.io/badge/Protocol-Gost_KCP-009688)](https://github.com/ginuerzh/gost)
[![License](https://img.shields.io/badge/License-Apache_2.0-lightgrey)](./LICENSE)

---

## 📖 项目简介

**Zero Actions** 是一套利用 GitHub Actions 基础设施构建的自动化 ZeroTier 节点测试与中继服务系统。用于跨地域异地组网的连通性压测、稳定性验证及高速中继加速。

通过结合 ZeroTier 虚拟局域网与现代高吞吐、低延迟传输协议（TUIC v5、Shadowsocks-UDP、Gost KCP），提供全套开箱即用的网络连接、性能基准测试与实时监控方案。

---

## ✨ 核心特性

- **一键自动化部署**：通过 GitHub Actions `workflow_dispatch` 手动触发，开箱即用，自动拉起多协议服务并维持后台守护保活。
- **固定身份与自建根节点**：
  - 内置 `identity.public` 和 `identity.secret` 固定 ZeroTier Node ID (`c03df9b0f6`) 与分配的局域网 IP (`10.3.3.2`)，避免频繁变动。
  - 内置自建 Moon / Planet 根节点配置文件（`planet`），实现自定义中继调度。
- **深度内核与网络协议栈优化**：
  - 调整内核 UDP 缓冲区至 32MB（`rmem_max` / `wmem_max` / `udp_mem`），防止 QUIC/TUIC 高并发下丢包。
  - 关闭反向路径过滤（`rp_filter=0`），确保 ZeroTier 复杂网络拓扑下 UDP 报文不被丢弃。
  - 启用 TCP BBR 拥塞控制与 FQ 队列规则。
  - 锁定 ZeroTier 接口 MTU 为 1280，避免公网链路分片损耗。
- **多协议加速与测速矩阵**：
  - **TUIC v5 (QUIC/HTTP3)**：基于 QUIC 协议的多路复用，自动生成自签名证书，弱网抗丢包。
  - **Shadowsocks-UDP**：采用 `AEAD_AES_256_GCM` 加密，提供稳健的高速纯 UDP 中继。
  - **Gost v2 KCP**：基于 KCP 极速通道（`fast2` 模式，1280 MTU），穿透 NAT 极限加速。
  - **iperf3 Server**：内置测速服务（默认 5201 端口），支持双向吞吐量与时延基准测试。
  - **内网 SSH 远程管理**：开放 SSH 访问，便于远程排障与实时交互。
- **二维码与连接链接自动更新**：
  - 工作流运行后自动使用 `qrencode` 生成 TUIC 及 Shadowsocks 的配置二维码并提交更新回仓库。
  - 在 GitHub Actions Step Summary 中直接输出可导入的连接链接及 Gost 本地配置命令。
- **实时监控与运维工具**：
  - 内置 `monitor.sh` 脚本，可实时监控 TUIC 运行状态及网卡上传/下载瞬时速率。
  - 提供定时轮换任务（Cron + GitHub API），实现 24 小时无缝衔接。

---

## 📂 项目结构

```bash
zero_actions/
├── .github/
│   └── workflows/
│       └── zero_acritons.yml   # 核心 GitHub Actions 工作流定义
├── identity.public             # ZeroTier 公钥（固定 Node ID: c03df9b0f6）
├── identity.secret             # ZeroTier 私钥（固定身份）
├── planet                      # ZeroTier 自定义根节点文件
├── monitor.sh                  # TUIC 实时流量与健康监控脚本
├── tuic_qr.png                 # TUIC 节点配置二维码（Actions 自动更新）
├── ss_qr.png                   # Shadowsocks 节点配置二维码（Actions 自动更新）
├── cron.txt                    # 定时轮换 Cron 示例
├── cron/                       # 定时任务执行脚本目录
└── README.md                   # 项目使用与配置说明文档
```

---

## 🚀 节点网络信息与参数配置

### ZeroTier 组网参数

| 配置项 | 参数值 | 说明 |
| :--- | :--- | :--- |
| **Network ID** | `645ae69a72a847d5` | 加入的 ZeroTier 网络 ID |
| **Node ID** | `c03df9b0f6` | 预置身份公钥绑定的设备 ID |
| **分配内网 IP** | `10.3.3.2` | 固定分配的 ZeroTier 局域网 IPv4 地址 |

### 工作流触发入参（`workflow_dispatch`）

| 参数名称 | 描述 | 默认值 |
| :--- | :--- | :--- |
| `ZT_NETWORK_ID` | 需要加入的 ZeroTier 网络 ID | `645ae69a72a847d5` |
| `PROXY_PASSWORD`| 代理认证密码 (用于 TUIC / Shadowsocks) | `password123` |
| `TUIC_PORT`     | TUIC v5 监听端口 | `10004` |
| `TUIC_UUID`     | TUIC v5 鉴权 UUID | `83f6d100-0544-4bd5-88f0-da835c2604af` |
| `SS_PORT`       | Shadowsocks-UDP 监听端口 | `10008` |
| `GOST_PORT`     | Gost KCP 监听端口 | `10005` |
| `GOST_KEY`      | Gost KCP 传输加密密钥 | `password123` |

---

## 📱 客户端配置与连接（原版配置）

工作流启动完成后，会在 GitHub Step Summary 以及仓库根目录生成二维码与连接信息：

| TUIC v5 节点二维码 | Shadowsocks-UDP 节点二维码 |
| :---: | :---: |
| ![TUIC QR](./tuic_qr.png) | ![SS QR](./ss_qr.png) |

### 1. TUIC v5
- **连接链接**：
  ```text
  tuic://83f6d100-0544-4bd5-88f0-da835c2604af:password123@10.3.3.2:10004?insecure=1&alpn=h3&sni=baidu.com#A-TUIC5
  ```
- **导入 JSON**：
  ```json
  {"h":"10.3.3.2","p":10004,"w":"password123","u":"83f6d100-0544-4bd5-88f0-da835c2604af","d":["1.1.1.1","8.8.8.8"]}
  ```
- **节点详细参数**：
  - **服务器地址**：`10.3.3.2`
  - **端口**：`10004`
  - **UUID**：`83f6d100-0544-4bd5-88f0-da835c2604af`
  - **密码**：`password123`
  - **TLS / SNI**：`baidu.com`
  - **ALPN**：`h3`
  - **跳过证书验证**：是（`insecure=1` / `Allow Insecure`）
  - **拥塞控制算法**：`bbr`

### 2. Shadowsocks-UDP
- **连接链接**：
  ```text
  ss://YWVzLTI1Ni1nY206cGFzc3dvcmQxMjM=@10.3.3.2:10008#A-SS-UDP
  ```
- **节点详细参数**：
  - **服务器地址**：`10.3.3.2`
  - **端口**：`10008`
  - **加密方式**：`AEAD_AES_256_GCM`
  - **密码**：`password123`

### 3. Gost v2 KCP 隧道加速
本地安装 [Gost v2](https://github.com/ginuerzh/gost/releases) 客户端后，执行如下命令在本地开启 `1234` 端口的 Socks5 代理：
```bash
./gost_v2 -L :1234 -F "kcp://10.3.3.2:10005?key=password123&crypt=aes-128&mode=fast2&mtu=1280&sndwnd=2048&rcvwnd=2048"
```

### 4. SSH 远程管理
Actions 内网开通 SSH 服务，可在 ZeroTier 内网直接登录管理：
- **用户名**：`runner` 或 `root`
- **密码**：`kkk`
- **连接命令**：
  ```bash
  ssh runner@10.3.3.2
  # 或者以 root 身份登录：
  ssh root@10.3.3.2
  ```

### 5. iperf3 网络吞吐压测
在已加入 ZeroTier 局域网的客户端上测试双向吞吐性能：
```bash
# 测试 TCP 带宽吞吐
iperf3 -c 10.3.3.2

# 测试 UDP 带宽吞吐 (设定 100Mbps 目标速率)
iperf3 -c 10.3.3.2 -u -b 100M
```

---

## 📊 监控与日常维护

### 流量与健康监控 (`monitor.sh`)
在 Runner 机器或本地端运行 `monitor.sh` 脚本，可实时查看 TUIC 状态与实时上下行速率：
```bash
chmod +x monitor.sh
./monitor.sh 10004
```
**输出示例**：
```text
==================================================
       TUIC v5 实时健康与流量监控 (A点)          
==================================================
 监控时间: 2026-10-29 12:45:00
 监控网卡: zt0
--------------------------------------------------
 [状态监测] TUIC 进程: ● 正在运行
 [端口监测] UDP/10004: ● 正常监听
--------------------------------------------------
 流量实时统计 (Ctrl+C 退出):
 下载 (RX): 1.45 MB/s | 上传 (TX): 2.18 MB/s
```

### 定时轮换保活 (Cron)
GitHub Actions 单次运行通常有 6 小时时间上限。可使用 `cron/` 目录下的自动化重跑脚本配合系统 crontab，定时调用 GitHub Rerun API 实现连续无缝轮换：
```text
0 0 * * * sleep 30 && /root/cron/restart_actions_1.sh >> /root/cron/restart_actions_1.log 2>&1
0 6 * * * sleep 30 && /root/cron/restart_actions_2.sh >> /root/cron/restart_actions_2.log 2>&1
0 12 * * * sleep 30 && /root/cron/restart_actions_3.sh >> /root/cron/restart_actions_3.log 2>&1
0 18 * * * sleep 30 && /root/cron/restart_actions_4.sh >> /root/cron/restart_actions_4.log 2>&1
```

---

## ⚠️ 免责声明与注意事项

1. **仅供学习与测试**：本项目所有代码与配置仅供网络技术研究、私有虚拟局域网互联及网络稳定性测试使用。
2. **遵守平台规则**：请自觉遵守 [GitHub Terms of Service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service) 以及 [GitHub Actions Acceptable Use Policy](https://docs.github.com/en/site-policy/acceptable-use-policies/github-actions-acceptable-use-policy)，禁止滥用计算资源或从事违法违规活动。
