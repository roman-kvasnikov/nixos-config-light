#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

case "$1" in
  --green)
    if [ $# -lt 2 ]; then
      echo "Usage: print --green <message>"
      exit 1
    fi
    echo -e "${GREEN}${*:2}${NC}"
    ;;
  --red)
    if [ $# -lt 2 ]; then
      echo "Usage: print --red <message>"
      exit 1
    fi
    echo -e "${RED}${*:2}${NC}"
    ;;
  --yellow)
    if [ $# -lt 2 ]; then
      echo "Usage: print --yellow <message>"
      exit 1
    fi
    echo -e "${YELLOW}${*:2}${NC}"
    ;;
  --blue)
    if [ $# -lt 2 ]; then
      echo "Usage: print --blue <message>"
      exit 1
    fi
    echo -e "${BLUE}${*:2}${NC}"
    ;;
  --purple)
    if [ $# -lt 2 ]; then
      echo "Usage: print --purple <message>"
      exit 1
    fi
    echo -e "${PURPLE}${*:2}${NC}"
    ;;
  --cyan)
    if [ $# -lt 2 ]; then
      echo "Usage: print --cyan <message>"
      exit 1
    fi
    echo -e "${CYAN}${*:2}${NC}"
    ;;
  --white)
    if [ $# -lt 2 ]; then
      echo "Usage: print --white <message>"
      exit 1
    fi
    echo -e "${WHITE}${*:2}${NC}"
    ;;
  --success)
    if [ $# -lt 2 ]; then
      echo "Usage: print --success <message>"
      exit 1
    fi
    echo -e "${GREEN}[✓]${NC} ${*:2}"
    ;;
  --error)
    if [ $# -lt 2 ]; then
      echo "Usage: print --error <message>"
      exit 1
    fi
    echo -e "${RED}[✗]${NC} ${*:2}" >&2
    ;;
  --warning)
    if [ $# -lt 2 ]; then
      echo "Usage: print --warning <message>"
      exit 1
    fi
    echo -e "${YELLOW}[!]${NC} ${*:2}"
    ;;
  --info)
    if [ $# -lt 2 ]; then
      echo "Usage: print --info <message>"
      exit 1
    fi
    echo -e "${BLUE}[i]${NC} ${*:2}"
    ;;
  --help)
    echo "Usage: print [OPTION] <message>"
    echo ""
    echo "Color options:"
    echo "  --green     Print message in green"
    echo "  --red       Print message in red"
    echo "  --yellow    Print message in yellow"
    echo "  --blue      Print message in blue"
    echo "  --purple    Print message in purple"
    echo "  --cyan      Print message in cyan"
    echo "  --white     Print message in white"
    echo ""
    echo "Prefix options:"
    echo "  --success   Print message with green [✓] prefix"
    echo "  --error     Print message with red [✗] prefix"
    echo "  --warning   Print message with yellow [!] prefix"
    echo "  --info      Print message with blue [i] prefix"
    echo ""
    echo "Examples:"
    echo "  print --green 'Hello World'"
    echo "  print --success 'Operation completed'"
    ;;
  *)
    if [ $# -eq 0 ]; then
      echo "Usage: print [OPTION] <message>"
      echo "Use 'print --help' for more information"
    else
      echo "${*}"
    fi
    ;;
esac
