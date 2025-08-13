#!/bin/bash

# Script para testar portas entrantes
# Uso: ./test_ports.sh [porta1] [porta2] ...

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Portas comuns para testar se não especificadas
DEFAULT_PORTS=(22 80 443 8080 8443 3000 5000 9000)

# Usa portas passadas como parâmetro ou portas padrão
if [ $# -eq 0 ]; then
    PORTS=(${DEFAULT_PORTS[@]})
else
    PORTS=($@)
fi

echo -e "${YELLOW}=== Teste de Portas Entrantes ===${NC}"
echo "Testando portas: ${PORTS[@]}"
echo

# Função para testar se uma porta está aberta localmente
test_local_port() {
    local port=$1
    if netstat -tuln | grep -q ":$port "; then
        echo -e "${GREEN}✓${NC} Porta $port está aberta localmente"
        return 0
    else
        echo -e "${RED}✗${NC} Porta $port não está aberta localmente"
        return 1
    fi
}

# Função para testar conectividade externa (simula conexão externa)
test_external_connectivity() {
    local port=$1
    echo -e "${YELLOW}  Testando conectividade externa para porta $port...${NC}"
    
    # Tenta conectar via telnet/nc para testar se a porta responde
    if command -v nc &> /dev/null; then
        timeout 3 nc -zv localhost $port 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}  ✓ Porta $port responde a conexões${NC}"
        else
            echo -e "${RED}  ✗ Porta $port não responde ou está bloqueada${NC}"
        fi
    else
        echo -e "${YELLOW}  ! netcat (nc) não encontrado, instalando...${NC}"
        sudo apt-get update -qq && sudo apt-get install -y netcat-openbsd
    fi
}

echo "=== Testando Portas Localmente ==="
for port in "${PORTS[@]}"; do
    test_local_port $port
    if [ $? -eq 0 ]; then
        test_external_connectivity $port
    fi
    echo
done

echo "=== Verificando Firewall ==="
if command -v ufw &> /dev/null; then
    echo "Status do UFW:"
    sudo ufw status verbose
elif command -v iptables &> /dev/null; then
    echo "Regras do iptables (INPUT):"
    sudo iptables -L INPUT -n --line-numbers
fi

echo
echo "=== Informações de Rede ==="
echo "IP interno:"
ip route get 8.8.8.8 | grep -oP 'src \K\S+'

echo
echo "IPs das interfaces:"
ip addr show | grep "inet " | grep -v 127.0.0.1

echo
echo "=== Processos Ouvindo em Portas ==="
echo "Portas TCP abertas:"
sudo netstat -tlnp | head -20

echo
echo -e "${YELLOW}=== Próximos Passos ===${NC}"
echo "1. Se portas estão abertas localmente mas não externamente:"
echo "   - Verificar configuração do roteador/modem"
echo "   - Verificar port forwarding"
echo "   - Verificar firewall do provedor"
echo
echo "2. Para testar externamente, use:"
echo "   - https://www.yougetsignal.com/tools/open-ports/"
echo "   - nmap -p [porta] [seu_ip_externo]"