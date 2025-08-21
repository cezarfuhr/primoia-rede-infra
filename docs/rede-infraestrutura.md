# Documentação da Infraestrutura - Ecossistema Primoia

Este documento serve como fonte central de verdade para a infraestrutura que suporta os projetos "Primoia". O objetivo é fornecer contexto para desenvolvedores e para o assistente de IA Gemini.

## 1. Visão Geral da Arquitetura

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

## 2. Computação e Orquestração

### Contêineres
- **Tecnologia:** Docker e LXC (Linux Containers)
- **Orquestração:** Proxmox VE para VMs e containers LXC
- **Registry:** Docker Registry privado em `registry.codenoob.dev`

### Orquestração
- **Plataforma:** Proxmox VE (Virtual Environment)
- **Acesso:** `proxmox.primoia.dev:8006`
- **Gestão:** Interface web com SSL via Nginx Proxy Manager

### Serviços Principais e seus Repositórios
- **primoia-inference-api:** API de inferência para modelos de IA
- **primoia-vosk-api:** API de reconhecimento de voz usando Vosk
- **primoia-log-watcher:** Serviço responsável por coletar e processar logs de outros serviços
- **primoia-mobile:** Aplicativo mobile
- **primoia-social-profile-fe:** Frontend para o perfil social

## 3. Rede

### VPC (Virtual Private Cloud)
- **Rede Local:** `192.168.0.x/24`
- **Gateway:** `192.168.0.1` (Roteador Domus)
- **DMZ:** Configurado para Nginx Proxy Manager
- **Segmentação:** VMs e containers isolados por IP

### Gateway de API
- **Solução:** Nginx Proxy Manager
- **Função:** Proxy reverso para todos os serviços
- **SSL:** Let's Encrypt automático
- **Portas:** 80 (HTTP) e 443 (HTTPS)

### Balanceador de Carga (Load Balancer)
- **Solução:** Nginx Proxy Manager
- **Configuração:** Proxy reverso com SSL termination
- **Websockets:** Habilitado para aplicações modernas

### Conexões de Internet
- **Internet Principal:** Domus (IP Fixo: `201.140.250.27`)
- **Internet Secundária:** OpcaoNet (IP Dinâmico: `186.194.147.208`)
- **Failover:** Configuração manual (planejado automático)

## 4. Armazenamento de Dados (Data Stores)

### Banco de Dados Principal
- **WordPress:** MySQL/MariaDB para blog
- **Aplicações:** Bancos específicos por serviço
- **Localização:** VMs dedicadas no Proxmox

### Cache
- **Redis:** Para cache de sessão (planejado)
- **Nginx:** Cache de arquivos estáticos

### Armazenamento de Arquivos (Object Storage)
- **Docker Registry:** `registry.codenoob.dev:5000`
- **Repositórios:** 4 repositórios ativos
- **Backup:** Configurações e dados em VMs

## 5. CI/CD (Integração e Entrega Contínua)

### Ferramenta de CI/CD
- **Status:** Em planejamento
- **Ferramentas Consideradas:** GitHub Actions, Jenkins
- **Registry:** Docker Registry já configurado

### Fluxo de Build/Deploy
- **Atual:** Deploy manual via Proxmox VE
- **Planejado:** Pipeline automatizado
- **Processo:** Push → Build → Deploy → Test

## 6. Observabilidade (Monitoramento e Logs)

### Logs
- **Centralização:** primoia-log-watcher
- **Coleta:** Logs de todos os serviços
- **Armazenamento:** Local em VMs dedicadas

### Métricas
- **Proxmox VE:** Métricas nativas da plataforma
- **Planejado:** Prometheus para coleta de métricas

### Dashboards
- **Proxmox VE:** Dashboard nativo
- **Planejado:** Grafana para visualização

## 7. Estrutura dos Repositórios

### Organização
- **`primoia-monorepo`:** Meta-repositório que agrega todos os projetos como submódulos Git
- **`primoia-rede-infra`:** Este repositório. Contém toda a documentação da infraestrutura
- **`primoia-log-watcher`:** Serviço de observabilidade
- **`primoia-mobile`:** Aplicativo mobile
- **`primoia-social-profile-fe`:** Frontend para o perfil social

## 8. Serviços Ativos

### Serviços em Produção
| Serviço | IP Local | Domínio | Status | Descrição |
|---------|----------|---------|--------|-----------|
| Proxmox VE | `192.168.0.151` | `proxmox.primoia.dev` | ✅ Ativo | Virtualização e orquestração |
| WordPress Blog | `192.168.0.155` | `blog.primoia.dev` | ✅ Ativo | Blog corporativo |
| Docker Registry | `192.168.0.114` | `registry.codenoob.dev` | ✅ Ativo | Registry privado |
| Jupyter Lab | `192.168.0.156` | `lab.primoia.dev` | ✅ Ativo | Ambiente de ML/DS |

### Configuração DNS
- **Domínio Principal:** `primoia.dev`
- **Provedor DNS:** Hostinger
- **Registros:** Tipo A apontando para `201.140.250.27`

## 9. Segurança

### Configurações Ativas
- **SSL:** Let's Encrypt automático via NPM
- **DMZ:** Configurado para isolamento
- **Firewall:** UFW/iptables (configuração básica)

### Melhorias Planejadas
- [ ] Fail2ban para proteção contra ataques
- [ ] Autenticação 2FA
- [ ] VPN Server (WireGuard/OpenVPN)
- [ ] Monitoramento de logs centralizado

## 10. Ferramentas de Teste

### Scripts Disponíveis
- **`test_ports.sh`:** Testa portas locais
- **`test_remote_ports.sh`:** Testa portas remotas

### Comandos Úteis
```bash
# Testar conectividade externa
./test_remote_ports.sh 201.140.250.27

# Verificar DNS
nslookup proxmox.primoia.dev

# Testar Docker Registry
curl -s https://registry.codenoob.dev/v2/_catalog
```

## 11. Planos Futuros

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

## 12. Contatos e Suporte

### Provedores
- **Domus:** Internet principal com IP fixo
- **OpcaoNet:** Internet secundária
- **Hostinger:** DNS e domínios

### Documentação Adicional
- [Documentação Proxmox VE](https://pve.proxmox.com/wiki/Main_Page)
- [Documentação Nginx Proxy Manager](https://nginxproxymanager.com/)
- [Documentação Docker Registry](https://docs.docker.com/registry/)

---

**Última Atualização:** $(date '+%d/%m/%Y %H:%M')
**Responsável:** Equipe Primoia
**Versão:** 2.0