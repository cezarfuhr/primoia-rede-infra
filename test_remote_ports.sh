#!/bin/bash

# Script para testar portas de um IP remoto (ex: IP fixo Domus)
# Uso: ./test_remote_ports.sh [IP_REMOTO] [porta1] [porta2] ...

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verifica se foi fornecido um IP
if [ $# -lt 1 ]; then
    echo -e "${RED}Erro: Forneça o IP remoto para testar${NC}"
    echo "Uso: $0 [IP_REMOTO] [porta1] [porta2] ..."
    echo "Exemplo: $0 200.100.50.25 80 443 22 8080"
    exit 1
fi

REMOTE_IP=$1
shift

# Portas padrão se não especificadas
DEFAULT_PORTS=(22 80 443 8080 8443 3000 5000 9000 21 25 53 110 143 993 995)

# Usa portas passadas como parâmetro ou portas padrão
if [ $# -eq 0 ]; then
    PORTS=(${DEFAULT_PORTS[@]})
else
    PORTS=($@)
fi

echo -e "${YELLOW}=== Teste de Portas Remotas ===${NC}"
echo -e "${BLUE}IP de destino: $REMOTE_IP${NC}"
echo -e "${BLUE}Portas a testar: ${PORTS[@]}${NC}"
echo

# Verifica se as ferramentas necessárias estão disponíveis
check_tools() {
    local missing_tools=()
    
    if ! command -v nc &> /dev/null; then
        missing_tools+=("netcat")
    fi
    
    if ! command -v nmap &> /dev/null; then
        missing_tools+=("nmap")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${YELLOW}Instalando ferramentas necessárias: ${missing_tools[@]}${NC}"
        if command -v apt-get &> /dev/null; then
            sudo apt-get update -qq
            for tool in "${missing_tools[@]}"; do
                if [ "$tool" = "netcat" ]; then
                    sudo apt-get install -y netcat-openbsd
                else
                    sudo apt-get install -y "$tool"
                fi
            done
        elif command -v yum &> /dev/null; then
            for tool in "${missing_tools[@]}"; do
                if [ "$tool" = "netcat" ]; then
                    sudo yum install -y nc
                else
                    sudo yum install -y "$tool"
                fi
            done
        fi
    fi
}

# Função para testar porta com netcat
test_port_nc() {
    local ip=$1
    local port=$2
    local timeout=3
    
    if timeout $timeout nc -zv "$ip" "$port" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Função para testar porta com telnet
test_port_telnet() {
    local ip=$1
    local port=$2
    local timeout=3
    
    if timeout $timeout bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Função para testar porta com curl (apenas HTTP/HTTPS)
test_port_curl() {
    local ip=$1
    local port=$2
    local timeout=3
    
    if [ "$port" = "80" ]; then
        if timeout $timeout curl -s -I "http://$ip:$port" &>/dev/null; then
            return 0
        fi
    elif [ "$port" = "443" ]; then
        if timeout $timeout curl -s -I -k "https://$ip:$port" &>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Verifica conectividade básica
echo -e "${YELLOW}=== Verificando Conectividade Básica ===${NC}"
if ping -c 1 -W 3 "$REMOTE_IP" &>/dev/null; then
    echo -e "${GREEN}✓ IP $REMOTE_IP está acessível (ping)${NC}"
else
    echo -e "${RED}✗ IP $REMOTE_IP não responde ao ping${NC}"
    echo -e "${YELLOW}  Isso pode ser normal se o ICMP estiver bloqueado${NC}"
fi
echo

# Instala ferramentas se necessário
check_tools

echo -e "${YELLOW}=== Testando Portas Individualmente ===${NC}"
for port in "${PORTS[@]}"; do
    echo -ne "Testando porta $port... "
    
    # Tenta diferentes métodos
    success=false
    
    # Método 1: netcat
    if test_port_nc "$REMOTE_IP" "$port"; then
        echo -e "${GREEN}✓ ABERTA (netcat)${NC}"
        success=true
    # Método 2: telnet/bash
    elif test_port_telnet "$REMOTE_IP" "$port"; then
        echo -e "${GREEN}✓ ABERTA (telnet)${NC}"
        success=true
    # Método 3: curl para HTTP/HTTPS
    elif test_port_curl "$REMOTE_IP" "$port"; then
        echo -e "${GREEN}✓ ABERTA (HTTP)${NC}"
        success=true
    else
        echo -e "${RED}✗ FECHADA/FILTRADA${NC}"
    fi
    
    # Se a porta estiver aberta, tenta identificar o serviço
    if [ "$success" = true ]; then
        case $port in
            22) echo -e "  ${BLUE}→ Provavelmente SSH${NC}" ;;
            80) echo -e "  ${BLUE}→ Provavelmente HTTP${NC}" ;;
            443) echo -e "  ${BLUE}→ Provavelmente HTTPS${NC}" ;;
            21) echo -e "  ${BLUE}→ Provavelmente FTP${NC}" ;;
            25) echo -e "  ${BLUE}→ Provavelmente SMTP${NC}" ;;
            53) echo -e "  ${BLUE}→ Provavelmente DNS${NC}" ;;
            3389) echo -e "  ${BLUE}→ Provavelmente RDP${NC}" ;;
            8080|8443) echo -e "  ${BLUE}→ Provavelmente HTTP alternativo${NC}" ;;
        esac
    fi
done

echo
echo -e "${YELLOW}=== Scan Rápido com Nmap (se disponível) ===${NC}"
if command -v nmap &> /dev/null; then
    echo "Executando scan rápido das portas mais comuns..."
    nmap -Pn --top-ports 20 "$REMOTE_IP" 2>/dev/null | grep -E "(open|closed|filtered)"
else
    echo "nmap não disponível - apenas testes individuais foram realizados"
fi

echo
echo -e "${YELLOW}=== Informações da Conexão Local ===${NC}"
echo "Seu IP público atual:"
if command -v curl &> /dev/null; then
    curl -s ifconfig.me || curl -s ipecho.net/plain || echo "Não foi possível determinar"
else
    echo "curl não disponível para verificar IP público"
fi

echo
echo "Interface de rede ativa:"
ip route get 8.8.8.8 2>/dev/null | grep -oP 'dev \K\S+' || echo "Não determinado"

echo
echo -e "${YELLOW}=== Dicas para Debugging ===${NC}"
echo "1. Se portas específicas estão fechadas:"
echo "   - Verifique firewall no servidor remoto (IP: $REMOTE_IP)"
echo "   - Verifique port forwarding no roteador da Domus"
echo "   - Verifique se o serviço está rodando na porta"

echo
echo "2. Para testar externamente de outros locais:"
echo "   - https://www.yougetsignal.com/tools/open-ports/"
echo "   - https://portchecker.co/"

echo
echo "3. Para diagnosticar mais a fundo:"
echo "   nmap -sV -p [porta] $REMOTE_IP"
echo "   telnet $REMOTE_IP [porta]"