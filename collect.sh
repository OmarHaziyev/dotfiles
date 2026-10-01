cat > ~/dotfiles/collect.sh << 'EOF'
#!/usr/bin/env zsh
for d in hypr waybar rofi wlogout alacritty theme matugen nautilus nvim fastfetch spicetify swaync; do
  cp -r ~/.config/"$d" .config/ 2>/dev/null
done
EOF
chmod +x ~/dotfiles/collect.sh
cd ~/dotfiles && ./collect.sh