# Primoia Rede Infra

Repositório contendo a documentação e ferramentas de infraestrutura do ecossistema Primoia.

## 🏗️ Sobre o Projeto

Este repositório serve como fonte central de verdade para a infraestrutura que suporta os projetos "Primoia". Contém documentação completa da arquitetura, scripts de teste e ferramentas de monitoramento.

## 📋 Conteúdo

### Documentação
- **`rede-infraestrutura.md`** - Documentação completa da infraestrutura
- **`README.md`** - Este arquivo

### Ferramentas de Teste
- **`test_ports.sh`** - Script para testar portas locais
- **`test_remote_ports.sh`** - Script para testar portas remotas

## 🏛️ Arquitetura da Infraestrutura

### Modelo Arquitetural
- **Tipo:** Infraestrutura Híbrida (On-premise + Cloud)
- **Virtualização:** Proxmox VE para orquestração de VMs e containers LXC
- **Contêinerização:** Docker para aplicações e serviços

### Provedor de Nuvem Principal
- **Principal:** Infraestrutura On-premise com Proxmox VE
- **DNS e Domínios:** Hostinger (cloud)
- **Backup e Armazenamento:** Local + Docker Registry

### Ambientes
- **Desenvolvimento:** VMs isoladas no Proxmox VE
- **Homologação:** Containers LXC dedicados
- **Produção:** Serviços expostos via Nginx Proxy Manager com SSL

## 🌐 Rede

### VPC (Virtual Private Cloud)
- **Rede Local:** `192.168.0.x/24`
- **Gateway:** `192.168.0.1` (Roteador Domus)
- **DMZ:** Configurado para Nginx Proxy Manager
- **Segmentação:** VMs e containers isolados por IP

### Conexões de Internet
- **Internet Principal:** Domus (IP Fixo: `201.140.250.27`)
- **Internet Secundária:** OpcaoNet (IP Dinâmico: `186.194.147.208`)
- **Failover:** Configuração manual (planejado automático)

## 🖥️ Serviços Ativos

| Serviço | IP Local | Domínio | Status | Descrição |
|---------|----------|---------|--------|-----------|
| Proxmox VE | `192.168.0.151` | `proxmox.primoia.dev` | ✅ Ativo | Virtualização e orquestração |
| WordPress Blog | `192.168.0.155` | `blog.primoia.dev` | ✅ Ativo | Blog corporativo |
| Docker Registry | `192.168.0.114` | `registry.codenoob.dev` | ✅ Ativo | Registry privado |
| Jupyter Lab | `192.168.0.156` | `lab.primoia.dev` | ✅ Ativo | Ambiente de ML/DS |

## 🛠️ Ferramentas de Teste

### Scripts Disponíveis

#### `test_ports.sh`
Testa portas locais e conectividade interna.

```bash
# Testar portas padrão
./test_ports.sh

# Testar portas específicas
./test_ports.sh 80 443 8080 3000
```

**Funcionalidades:**
- Verifica se portas estão abertas localmente
- Testa conectividade externa
- Mostra status do firewall
- Exibe informações de rede
- Lista processos ouvindo em portas

#### `test_remote_ports.sh`
Testa portas de um IP remoto (ex: IP fixo Domus).

```bash
# Testar IP fixo Domus
./test_remote_ports.sh 201.140.250.27

# Testar portas específicas
./test_remote_ports.sh 201.140.250.27 80 443 22 8080
```

**Funcionalidades:**
- Testa conectividade com IPs remotos
- Suporte a múltiplas ferramentas (netcat, nmap, telnet)
- Instalação automática de dependências
- Relatório detalhado de conectividade

## 🔧 Comandos Úteis

```bash
# Testar conectividade externa
./test_remote_ports.sh 201.140.250.27

# Verificar DNS
nslookup proxmox.primoia.dev

# Testar Docker Registry
curl -s https://registry.codenoob.dev/v2/_catalog

# Verificar status do Proxmox
curl -k https://proxmox.primoia.dev:8006/api2/json/version
```

## 📊 Monitoramento

### Logs
- **Centralização:** primoia-log-watcher
- **Coleta:** Logs de todos os serviços
- **Armazenamento:** Local em VMs dedicadas

### Métricas
- **Proxmox VE:** Métricas nativas da plataforma
- **Planejado:** Prometheus para coleta de métricas

## 🔒 Segurança

### Configurações Ativas
- **SSL:** Let's Encrypt automático via NPM
- **DMZ:** Configurado para isolamento
- **Firewall:** UFW/iptables (configuração básica)

### Melhorias Planejadas
- [ ] Fail2ban para proteção contra ataques
- [ ] Autenticação 2FA
- [ ] VPN Server (WireGuard/OpenVPN)
- [ ] Monitoramento de logs centralizado

## 🚀 Planos Futuros

### Expansão de Serviços
- [ ] Servidor de arquivos (NAS)
- [ ] Sistema de monitoramento (Prometheus + Grafana)
- [ ] VPN Server para acesso remoto
- [ ] CI/CD Pipeline automatizado
- [ ] Load balancing entre conexões

### Melhorias de Infraestrutura
- [ ] VLAN para isolamento de serviços
- [ ] Segmentação de rede IoT
- [ ] Backup automático de configurações
- [ ] Failover automático de conexões

## 📚 Documentação Adicional

- [Documentação Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Documentação Nginx Proxy Manager](https://nginxproxymanager.com/)
- [Documentação Docker Registry](https://docs.docker.com/registry/)

## 👥 Equipe

- **Infraestrutura:** Equipe Primoia
- **Provedores:** Domus, OpcaoNet, Hostinger

## 📞 Contatos e Suporte

### Provedores
- **Domus:** Internet principal com IP fixo
- **OpcaoNet:** Internet secundária
- **Hostinger:** DNS e domínios

---

**Versão**: 2.0  
**Última Atualização**: $(date '+%d/%m/%Y')  
**Responsável**: Equipe Primoia
