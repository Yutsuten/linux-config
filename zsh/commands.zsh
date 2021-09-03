function termcolors() {
  for COLOR1 in {0..7}; do
    COLOR2=$((COLOR1+8))
    print -P "%F{${COLOR1}}Color${COLOR1}  %F{${COLOR2}}Color${COLOR2}"
  done
}

function countdown() {
  termdown --no-bell --font doh --critical 30 "$1"
  fellow finish
}

function aur_update() {
  WHITE="\033[0;37m"
  NOCOLOR="\033[0m"
  (
    cd "${HOME}/Packages/AUR"
    count=$(ls -1 | wc -l)
    cur=1
    for package in *; do
      (
        cd "${package}"
        echo -e "${WHITE}[${cur}/${count}] Building ${package}${NOCOLOR}"
        echo -e "${WHITE}> git pull${NOCOLOR}"
        git pull
        echo -e "${WHITE}> makepkg${NOCOLOR}"
        makepkg --nocolor --syncdeps --install --needed --clean || true
      )
      (( cur+=1 ))
    done
  )
}
