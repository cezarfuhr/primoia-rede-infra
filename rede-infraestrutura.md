# Documentação da Infraestrutura de Rede

## Visão Geral

Configuração de rede doméstica com duas conexões de internet e infraestrutura de serviços baseada em containers e virtualização.

## Conexões de Internet

### Internet Principal - Domus (IP Fixo)
- **Provedor:** Domus
- **Tipo:** IP Fixo
- **IP Público:** `201.140.250.27`
- **Uso:** Serviços públicos, servidores, VMs
- **Status:** ✅ Ativo

### Internet Secundária - OpcaoNet (IP Dinâmico)
- **Provedor:** OpcaoNet  
- **Tipo:** IP Dinâmico
- **IP Atual:** `186.194.147.208` (varia)
- **Uso:** Navegação, testes, backup
- **Status:** ✅ Ativo

## Configuração de Rede Local

### Roteador Domus
- **Configuração:** DMZ habilitado
- **DMZ Target:** Nginx Proxy Manager
- **Função:** Direciona todo tráfego externo para o proxy reverso

### Segmento de Rede Principal
- **Range:** `192.168.0.x/24`
- **Gateway:** `192.168.0.1`

## Serviços e Servidores

### Nginx Proxy Manager (NPM)
- **IP Local:** `192.168.0.x` (configurado como DMZ)
- **Função:** Proxy reverso para todos os serviços
- **Porta Externa:** 80, 443
- **SSL:** Let's Encrypt automático
- **Status:** ✅ Operacional

### Proxmox VE
- **IP Local:** `192.168.0.151`
- **Porta:** `8006`
- **Domínio:** `proxmox.primoia.dev`
- **Acesso:** Via NPM com SSL
- **Status:** ✅ Operacional

### WordPress Blog
- **IP Local:** `192.168.0.155`
- **Porta:** `80`
- **Domínio:** `blog.primoia.dev`
- **Acesso:** Via NPM com SSL
- **Status:** ✅ Operacional

## Configuração DNS

### Domínio Principal
- **Domínio:** `primoia.dev`
- **Provedor DNS:** Hostinger
- **Configuração:** Registros Tipo A

### Subdomínios Configurados
| Subdomínio | IP Destino | Serviço | Status |
|------------|------------|---------|--------|
| `proxmox.primoia.dev` | `201.140.250.27` | Proxmox VE | ✅ Ativo |
| `blog.primoia.dev` | `201.140.250.27` | WordPress Blog | ✅ Ativo |

## Fluxo de Tráfego

### Acesso Externo a Serviços
```
Internet → DNS (Hostinger) → IP Fixo (201.140.250.27) → 
Roteador Domus (DMZ) → Nginx Proxy Manager → 
Servidor/VM de Destino
```

### Configuração NPM por Serviço
```
proxmox.primoia.dev:
  - Scheme: https
  - Forward Host: 192.168.0.151
  - Forward Port: 8006
  - SSL: Let's Encrypt
  - Websockets: Habilitado

blog.primoia.dev:
  - Scheme: http
  - Forward Host: 192.168.0.155
  - Forward Port: 80
  - SSL: Let's Encrypt
  - Headers: WordPress proxy headers
```

## Portas Testadas e Status

### Portas Abertas no IP Público (201.140.250.27)
| Porta | Serviço | Status | Observações |
|-------|---------|--------|-------------|
| 22 | SSH | ✅ Aberta | Acesso direto |
| 80 | HTTP | ✅ Aberta | NPM |
| 443 | HTTPS | ✅ Aberta | NPM + SSL |
| 3000 | Aplicação | ✅ Aberta | Serviço adicional |

### Portas Fechadas/Filtradas
| Porta | Serviço Esperado | Status | Ação Necessária |
|-------|------------------|--------|------------------|
| 8006 | Proxmox (direto) | ❌ Fechada | Via NPM apenas |
| 8080 | HTTP Alt | ❌ Fechada | Configurar se necessário |
| 8443 | HTTPS Alt | ❌ Fechada | Configurar se necessário |
| 5000 | Aplicação | ❌ Fechada | Configurar se necessário |
| 9000 | Aplicação | ❌ Fechada | Configurar se necessário |

## Ferramentas de Teste

### Scripts Desenvolvidos
1. **test_ports.sh** - Testa portas locais
2. **test_remote_ports.sh** - Testa portas remotas

### Comandos Úteis
```bash
# Testar portas do IP fixo
./test_remote_ports.sh 201.140.250.27

# Testar portas específicas
./test_remote_ports.sh 201.140.250.27 80 443 8006

# Verificar DNS
nslookup proxmox.primoia.dev
dig proxmox.primoia.dev +short

# Testar conectividade HTTP/HTTPS
curl -I http://proxmox.primoia.dev
curl -I -k https://proxmox.primoia.dev
```

## Planos Futuros

### Serviços a Configurar
- [ ] Servidor de arquivos (NAS)
- [ ] Sistema de monitoramento
- [ ] Container registry
- [ ] VPN Server
- [ ] Servidor de desenvolvimento

### Melhorias de Segurança
- [ ] Configurar fail2ban
- [ ] Implementar autenticação 2FA
- [ ] Monitoramento de logs
- [ ] Backup automático de configurações

### Expansão de Rede
- [ ] VLAN para isolamento de serviços
- [ ] Segmentação de rede IoT
- [ ] Rede para guests/visitantes

## Observações Técnicas

### Configurações que Funcionaram
- DMZ para NPM elimina problemas de port forwarding
- SSL Let's Encrypt automático via NPM
- Websockets habilitado para aplicações modernas
- DNS com TTL 300 para mudanças rápidas

### Lições Aprendidas
- Proxmox requer HTTPS na porta 8006
- NPM precisa de websockets para consoles web
- WordPress funciona bem com HTTP interno + SSL via NPM
- Headers proxy são essenciais para WordPress
- Teste sempre conectividade antes de configurar DNS
- DMZ simplifica configuração comparado a port forwarding manual

## Contatos e Suporte

### Provedores
- **Domus:** [Informações de contato]
- **OpcaoNet:** [Informações de contato]
- **Hostinger:** [Painel de controle DNS]

### Documentação Adicional
- [Link para documentação do Proxmox]
- [Link para documentação do NPM]
- [Guias de configuração específicos]

---

**Última Atualização:** $(date '+%d/%m/%Y %H:%M')
**Responsável:** [Seu nome]
**Versão:** 1.0