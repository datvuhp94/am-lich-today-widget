#!/bin/bash
# ═══════════════════════════════════════════════════════════
# 🏮 Âm Lịch Today — Desktop Widget Installer
#    Tự động tải và cài đặt widget cho KDE Plasma 6 / GNOME
#
#    Cài đặt:
#      curl -sSL https://amlich.today/install-widget | bash
#    Hoặc:
#      wget -qO- https://amlich.today/install-widget | bash
#
#    https://amlich.today
# ═══════════════════════════════════════════════════════════

set -e

REPO_RAW="https://raw.githubusercontent.com/datvuhp94/am-lich-today-widget/main"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

header() {
  echo ""
  echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║${NC}  ${BOLD}🏮 Âm Lịch Today — Desktop Widget${NC}           ${RED}║${NC}"
  echo -e "${RED}║${NC}  ${CYAN}amlich.today${NC}                               ${RED}║${NC}"
  echo -e "${RED}║${NC}  Âm Lịch • Ngày Tốt • Giờ Hoàng Đạo        ${RED}║${NC}"
  echo -e "${RED}║${NC}  Tử Vi • Phong Thủy                         ${RED}║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
  echo ""
}

download() {
  local url="$1" dest="$2"
  if command -v curl &>/dev/null; then
    curl -sSL "$url" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -qO "$dest" "$url"
  else
    echo -e "${RED}❌ Cần curl hoặc wget để tải file${NC}"
    exit 1
  fi
}

detect_de() {
  local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-unknown}}"
  de=$(echo "$de" | tr '[:upper:]' '[:lower:]')
  if echo "$de" | grep -qi "kde\|plasma"; then
    echo "plasma"
  elif echo "$de" | grep -qi "gnome"; then
    echo "gnome"
  elif command -v plasmashell &>/dev/null; then
    echo "plasma"
  elif command -v gnome-shell &>/dev/null; then
    echo "gnome"
  else
    echo "unknown"
  fi
}

# ─── KDE Plasma 6 ─────────────────────────────────────────
install_plasma() {
  echo -e "${CYAN}🖥  Phát hiện: KDE Plasma${NC}"
  echo ""

  local KPKG=""
  if command -v kpackagetool6 &>/dev/null; then
    KPKG="kpackagetool6"
  elif command -v kpackagetool5 &>/dev/null; then
    KPKG="kpackagetool5"
  else
    echo -e "${RED}❌ Không tìm thấy kpackagetool${NC}"
    echo "   sudo pacman -S plasma-sdk     # Arch"
    echo "   sudo apt install plasma-sdk   # Ubuntu/Debian"
    echo "   sudo dnf install plasma-sdk   # Fedora"
    exit 1
  fi

  echo "  → Tải widget từ GitHub..."
  local WIDGET_DIR="$TMPDIR/com.amlich.today/contents/ui"
  mkdir -p "$WIDGET_DIR"
  download "$REPO_RAW/plasmoid/com.amlich.today/metadata.json" "$TMPDIR/com.amlich.today/metadata.json"
  download "$REPO_RAW/plasmoid/com.amlich.today/contents/ui/main.qml" "$WIDGET_DIR/main.qml"

  echo -e "  → Sử dụng: ${BOLD}$KPKG${NC}"

  if $KPKG -t Plasma/Applet -l 2>/dev/null | grep -q "com.amlich.today"; then
    echo "  → Gỡ bản cũ..."
    $KPKG -t Plasma/Applet -r com.amlich.today 2>/dev/null || true
  fi

  echo "  → Cài đặt..."
  $KPKG -t Plasma/Applet -i "$TMPDIR/com.amlich.today"

  rm -rf ~/.cache/plasmashell/qmlcache/ 2>/dev/null || true

  echo ""
  echo -e "${GREEN}✅ Cài đặt thành công!${NC}"
  echo ""
  echo -e "  ${BOLD}Sử dụng:${NC}"
  echo "  1. Chuột phải Desktop → 'Enter Edit Mode' → 'Add Widgets...'"
  echo "  2. Tìm 'Âm Lịch' → Kéo vào Desktop"
  echo ""
  echo -e "  ${BOLD}Gỡ:${NC} $KPKG -t Plasma/Applet -r com.amlich.today"
  echo ""
  echo -e "  ${YELLOW}💡 Nếu không thấy, restart Plasma:${NC}"
  echo "  kquitapp6 plasmashell && kstart plasmashell"
}

# ─── GNOME Shell ───────────────────────────────────────────
install_gnome() {
  local EXT_UUID="amlich-today@amlich.today"
  local EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$EXT_UUID"

  echo -e "${CYAN}🖥  Phát hiện: GNOME Shell $(gnome-shell --version 2>/dev/null | sed 's/GNOME Shell //' | head -1)${NC}"
  echo ""

  echo "  → Tải extension từ GitHub..."
  local SRC="$TMPDIR/$EXT_UUID"
  mkdir -p "$SRC"
  download "$REPO_RAW/gnome-extension/$EXT_UUID/metadata.json" "$SRC/metadata.json"
  download "$REPO_RAW/gnome-extension/$EXT_UUID/extension.js" "$SRC/extension.js"
  download "$REPO_RAW/gnome-extension/$EXT_UUID/stylesheet.css" "$SRC/stylesheet.css"

  if [ -d "$EXT_DIR" ]; then
    echo "  → Xóa bản cũ..."
    rm -rf "$EXT_DIR"
  fi

  echo "  → Cài đặt..."
  mkdir -p "$EXT_DIR"
  cp -r "$SRC"/* "$EXT_DIR"/

  gsettings set org.gnome.shell disable-user-extensions false 2>/dev/null || true

  echo "  → Bật extension..."
  gnome-extensions enable "$EXT_UUID" 2>/dev/null || true

  local session_type="${XDG_SESSION_TYPE:-unknown}"
  if [ "$session_type" = "x11" ]; then
    echo "  → Restart GNOME Shell..."
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart("Restarting…")' 2>/dev/null || true
    sleep 2
  fi

  echo ""
  echo -e "${GREEN}✅ Cài đặt thành công!${NC}"
  echo ""
  if [ "$session_type" = "wayland" ]; then
    echo -e "  ${YELLOW}⚠️  Wayland — cần đăng xuất rồi đăng nhập lại.${NC}"
    echo ""
  fi
  echo -e "  ${BOLD}Kiểm tra:${NC} gnome-extensions info $EXT_UUID"
  echo -e "  ${BOLD}Gỡ:${NC} gnome-extensions uninstall $EXT_UUID"
}

# ─── Uninstall ─────────────────────────────────────────────
uninstall() {
  echo -e "${YELLOW}Gỡ cài đặt Âm Lịch Today...${NC}"
  echo ""

  if command -v kpackagetool6 &>/dev/null; then
    if kpackagetool6 -t Plasma/Applet -l 2>/dev/null | grep -q "com.amlich.today"; then
      echo "  → Gỡ Plasma widget..."
      kpackagetool6 -t Plasma/Applet -r com.amlich.today 2>/dev/null || true
      echo -e "  ${GREEN}✓ Đã gỡ Plasma widget${NC}"
    fi
  fi

  local EXT_DIR="$HOME/.local/share/gnome-shell/extensions/amlich-today@amlich.today"
  if [ -d "$EXT_DIR" ]; then
    echo "  → Gỡ GNOME extension..."
    gnome-extensions uninstall amlich-today@amlich.today 2>/dev/null || rm -rf "$EXT_DIR"
    echo -e "  ${GREEN}✓ Đã gỡ GNOME extension${NC}"
  fi

  echo ""
  echo -e "${GREEN}✅ Hoàn tất.${NC}"
}

# ─── Main ──────────────────────────────────────────────────
header

case "${1:-}" in
  --uninstall|-u) uninstall; exit 0 ;;
  --plasma|-p)    install_plasma; exit 0 ;;
  --gnome|-g)     install_gnome; exit 0 ;;
  --help|-h)
    echo "Sử dụng:"
    echo "  curl -sSL https://amlich.today/install-widget | bash"
    echo ""
    echo "Tùy chọn:"
    echo "  (không có)       Tự nhận diện DE"
    echo "  --plasma, -p     KDE Plasma 6"
    echo "  --gnome, -g      GNOME 45+"
    echo "  --uninstall, -u  Gỡ cài đặt"
    echo "  --help, -h       Trợ giúp"
    exit 0
    ;;
esac

DE=$(detect_de)
case "$DE" in
  plasma) install_plasma ;;
  gnome)  install_gnome ;;
  *)
    echo -e "${YELLOW}⚠️  Không nhận diện được Desktop Environment.${NC}"
    echo ""
    echo "  Chọn thủ công:"
    echo "    curl -sSL https://amlich.today/install-widget | bash -s -- --plasma"
    echo "    curl -sSL https://amlich.today/install-widget | bash -s -- --gnome"
    exit 1
    ;;
esac
