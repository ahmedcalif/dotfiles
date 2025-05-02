#!/bin/bash
# Catppuccin theme installation script for i3 and i3blocks
# Save this file as catppuccin-install.sh and run: bash catppuccin-install.sh

# Colors for terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Installing Catppuccin theme for i3 and i3blocks...${NC}"

# Install required packages
echo -e "${BLUE}Installing dependencies...${NC}"
sudo apt update
sudo apt install -y i3blocks acpi jq playerctl curl sysstat fonts-font-awesome

# Create required directories
echo -e "${BLUE}Creating config directories...${NC}"
mkdir -p ~/.config/i3
mkdir -p ~/.config/i3blocks
mkdir -p ~/.config/i3blocks/scripts

# Create a volume script
echo -e "${BLUE}Creating scripts...${NC}"
cat > ~/.config/i3blocks/scripts/volume << 'EOF'
#!/bin/bash
volume=$(amixer get Master | grep -E -o '[0-9]{1,3}?%' | head -1)
echo "$volume"
EOF

# Create additional scripts for blocks
cat > ~/.config/i3blocks/scripts/mediaplayer << 'EOF'
#!/bin/bash
player_status=$(playerctl status 2> /dev/null)
if [ "$player_status" = "Playing" ]; then
    echo "$(playerctl metadata artist) - $(playerctl metadata title)"
elif [ "$player_status" = "Paused" ]; then
    echo " $(playerctl metadata artist) - $(playerctl metadata title)"
else
    echo ""
fi
EOF

# Make scripts executable
chmod +x ~/.config/i3blocks/scripts/*

# Set the path for scripts in the i3blocks config
SCRIPT_DIR="$HOME/.config/i3blocks/scripts"

# Create or copy the theme file
echo -e "${BLUE}Creating Catppuccin theme files...${NC}"

# Create the Catppuccin theme file for i3
cat > ~/.config/i3/catppuccin-theme << 'EOF'
# Catppuccin theme for i3
# File location: ~/.config/i3/catppuccin-theme
# To use this theme, add this line to your i3 config:
# include ~/.config/i3/catppuccin-theme

# Catppuccin Mocha colors
set $rosewater #f5e0dc
set $flamingo  #f2cdcd
set $pink      #f5c2e7
set $mauve     #cba6f7
set $red       #f38ba8
set $maroon    #eba0ac
set $peach     #fab387
set $yellow    #f9e2af
set $green     #a6e3a1
set $teal      #94e2d5
set $sky       #89dceb
set $sapphire  #74c7ec
set $blue      #89b4fa
set $lavender  #b4befe
set $text      #cdd6f4
set $subtext1  #bac2de
set $subtext0  #a6adc8
set $overlay2  #9399b2
set $overlay1  #7f849c
set $overlay0  #6c7086
set $surface2  #585b70
set $surface1  #45475a
set $surface0  #313244
set $base      #1e1e2e
set $mantle    #181825
set $crust     #11111b

# Window Colors
# class                 border     bkg         text      indicator   child_border
client.focused          $mauve     $mauve      $crust    $sapphire   $mauve
client.focused_inactive $overlay0  $surface1   $text     $surface1   $overlay0
client.unfocused        $overlay0  $base       $text     $base       $overlay0
client.urgent           $peach     $peach      $crust    $peach      $peach
client.placeholder      $overlay0  $base       $text     $base       $overlay0
client.background       $base

# Font for window titles
font pango:JetBrainsMono Nerd Font 10

# Gaps (requires i3-gaps)
gaps inner 10
gaps outer 5
smart_gaps on
smart_borders on

# Border settings
for_window [class=".*"] border pixel 2

# i3 Bar configuration with Catppuccin colors
bar {
    status_command i3blocks -c ~/.config/i3blocks/config
    position top
    height 30
    tray_padding 4
    
    colors {
        background $base
        statusline $text
        separator  $overlay0
        
        # class             border      bkg         text
        focused_workspace   $mauve      $mauve      $crust
        active_workspace    $surface1   $surface1   $text
        inactive_workspace  $base       $base       $text
        urgent_workspace    $peach      $peach      $crust
        binding_mode        $lavender   $lavender   $crust
    }
}
EOF

# Create the i3blocks config file
cat > ~/.config/i3blocks/config << 'EOF'
# i3blocks config file with Catppuccin theme
# File location: ~/.config/i3blocks/config

# Global properties
command=$SCRIPT_DIR/$BLOCK_NAME
separator_block_width=15
markup=pango
separator=true
align=center

# Catppuccin colors
# Base colors
color_base="#1e1e2e"     # Base
color_text="#cdd6f4"     # Text
# Accent colors
color_rosewater="#f5e0dc" # Rosewater
color_flamingo="#f2cdcd"  # Flamingo
color_pink="#f5c2e7"      # Pink
color_mauve="#cba6f7"     # Mauve
color_red="#f38ba8"       # Red
color_maroon="#eba0ac"    # Maroon
color_peach="#fab387"     # Peach
color_yellow="#f9e2af"    # Yellow
color_green="#a6e3a1"     # Green
color_teal="#94e2d5"      # Teal
color_sky="#89dceb"       # Sky
color_sapphire="#74c7ec"  # Sapphire
color_blue="#89b4fa"      # Blue
color_lavender="#b4befe"  # Lavender

# Workspace indicator
[focused]
command=i3-msg -t get_workspaces | jq -r '.[] | select(.focused).name'
interval=1
color=$color_mauve

# Media player
[mediaplayer]
label=<span color="$color_mauve"> </span>
command=playerctl metadata --format "{{ artist }} - {{ title }}" 2>/dev/null || echo ""
interval=5
color=$color_pink

# Volume
[volume]
label=<span color="$color_sapphire"> </span>
command=amixer get Master | grep -E -o "[0-9]+%" | head -1
interval=1
signal=10
color=$color_sapphire

# Memory
[memory]
label=<span color="$color_green"> </span>
command=free -h | awk '/^Mem:/ {print $3}'
interval=10
color=$color_green

# CPU usage
[cpu_usage]
label=<span color="$color_yellow"> </span>
command=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print sprintf("%.1f%", usage)}'
interval=5
color=$color_yellow

# Temperature
[temperature]
label=<span color="$color_peach"> </span>
command=sensors | grep -A 0 "Core 0" | cut -c16-19 | xargs echo
interval=10
color=$color_peach

# Network
[iface]
label=<span color="$color_lavender"> </span>
command=ip route get 1.1.1.1 | grep -Po '(?<=dev\s)\w+' | xargs -I{} ip addr show {} | grep -Po 'inet \K[\d.]+'
interval=10
color=$color_lavender

# Battery
[battery]
label=<span color="$color_teal"> </span>
command=acpi | grep -o "[0-9]\+%" || echo "No battery"
interval=30
color=$color_teal

# Date and time
[time]
label=<span color="$color_blue"> </span>
command=date '+%a %d %b %H:%M'
interval=1
color=$color_blue
EOF

# Replace $SCRIPT_DIR with actual path
sed -i "s|\$SCRIPT_DIR|$SCRIPT_DIR|g" ~/.config/i3blocks/config

# Update i3 config to include Catppuccin theme
if grep -q "^include ~/.config/i3/catppuccin-theme" ~/.config/i3/config; then
    echo -e "${GREEN}Theme include line already exists in i3 config.${NC}"
else
    # Add include line to i3 config
    echo -e "\n# Include Catppuccin theme\ninclude ~/.config/i3/catppuccin-theme" >> ~/.config/i3/config
    echo -e "${GREEN}Added theme include line to i3 config.${NC}"
fi

# Remove any waybar related lines
if grep -q "waybar" ~/.config/i3/config; then
    sed -i '/waybar/d' ~/.config/i3/config
    echo -e "${GREEN}Removed waybar references from i3 config.${NC}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${BLUE}To apply the theme, restart i3 with Super+Shift+r${NC}"
echo -e "${BLUE}Note: If you have an existing bar configuration in your i3 config, it will be overridden by the theme.${NC}"