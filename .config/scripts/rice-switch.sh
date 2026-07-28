#!/usr/bin/env bash
WALLPAPER="$1"

case "$WALLPAPER" in
    *megumin*)
        FALLBACK="#e8623a"
        ;;
    *cid*)
        FALLBACK="#7146e6"
        ;;
    *)
        FALLBACK="#7aa2f7"
        ;;
esac

matugen image "$WALLPAPER" --prefer closest-to-fallback --fallback-color "$FALLBACK"
pkill -USR2 btop 2>/dev/null
kitty @ --to unix:/tmp/kitty-socket set-colors --all ~/.config/kitty/colors-generated.conf 2>/dev/null

killall waybar
waybar > /tmp/waybar.log 2>&1 &
disown

ACCENT_HEX=$(grep '@define-color accent' ~/.config/waybar/colors.css | grep -oP '#[0-9a-fA-F]{6}')
FG_HEX=$(grep '@define-color fg ' ~/.config/waybar/colors.css | grep -oP '#[0-9a-fA-F]{6}')
SECONDARY_HEX=$(grep '@define-color secondary' ~/.config/waybar/colors.css | grep -oP '#[0-9a-fA-F]{6}')
TERTIARY_HEX=$(grep '@define-color tertiary' ~/.config/waybar/colors.css | grep -oP '#[0-9a-fA-F]{6}')

hex_to_rgb() {
    hex="${1#\#}"
    r=$((16#${hex:0:2}))
    g=$((16#${hex:2:2}))
    b=$((16#${hex:4:2}))
    echo "${r};${g};${b}"
}

ACCENT_RGB=$(hex_to_rgb "$ACCENT_HEX")
FG_RGB=$(hex_to_rgb "$FG_HEX")

sed -i "s/\"keys\": \"38;2;[0-9;]*\"/\"keys\": \"38;2;${ACCENT_RGB}\"/" ~/.config/fastfetch/config.jsonc
sed -i "s/\"title\": \"38;2;[0-9;]*\"/\"title\": \"38;2;${FG_RGB}\"/" ~/.config/fastfetch/config.jsonc

ACCENT_RGB2=$(hex_to_rgb "$ACCENT_HEX")
FG_RGB2=$(hex_to_rgb "$FG_HEX")

sed -i "s/FG_PURPLE='\\\\033\[38;[0-9;]*m'/FG_PURPLE='\\\\033[38;2;${ACCENT_RGB2}m'/" ~/.config/fish/welcome.sh
sed -i "s/FG_ORANGE='\\\\033\[38;[0-9;]*m'/FG_ORANGE='\\\\033[38;2;${ACCENT_RGB2}m'/" ~/.config/fish/welcome.sh
sed -i "s/FG_GREEN='\\\\033\[38;[0-9;]*m'/FG_GREEN='\\\\033[38;2;${FG_RGB2}m'/" ~/.config/fish/welcome.sh
sed -i "s/FG_YELLOW='\\\\033\[38;[0-9;]*m'/FG_YELLOW='\\\\033[38;2;${FG_RGB2}m'/" ~/.config/fish/welcome.sh
sed -i "s/FG_BLUE='\\\\033\[38;[0-9;]*m'/FG_BLUE='\\\\033[38;2;${FG_RGB2}m'/" ~/.config/fish/welcome.sh
sed -i "s/FG_CYAN='\\\\033\[38;[0-9;]*m'/FG_CYAN='\\\\033[38;2;${ACCENT_RGB2}m'/" ~/.config/fish/welcome.sh

BGPILL_HEX=$(grep '@define-color bg_pill' ~/.config/waybar/colors.css | grep -oP '#[0-9a-fA-F]{6}')
FG_DIM_HEX=$(grep '@define-color fg_dim' ~/.config/waybar/colors.css | grep -oP '#[0-9a-fA-F]{6}')

sed "s/PILLCOLOR/${BGPILL_HEX}/g; s/ACCENTCOLOR/${ACCENT_HEX}/g; s/DIMCOLOR/${FG_DIM_HEX}/g; s/FGCOLOR/${FG_HEX}/g; s/SECONDARYCOLOR/${SECONDARY_HEX}/g; s/TERTIARYCOLOR/${TERTIARY_HEX}/g" ~/.config/starship.template.toml > ~/.config/starship.toml

sed "s/ACCENTCOLOR/${ACCENT_HEX}/g; s/FGCOLOR/${FG_HEX}/g; s/BGCOLOR/${BGPILL_HEX}/g" \
~/.config/mako/config.template > ~/.config/mako/config

makoctl reload
