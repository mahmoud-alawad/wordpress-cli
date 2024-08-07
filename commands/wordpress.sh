#!/bin/bash

function download_wordpress() {
    local targetDir=$1

    if [ -z "$targetDir" ]; then
        bash "$PACKGEPATH/../utils/message.sh" warning "Error: No directory specified."
        display_help
        exit 1
    fi

    pushd ${targetDir} || exit

    bash "$PACKGEPATH/../utils/message.sh" info "Downloading WordPress..."

    curl -o "$targetDir/latest.tar.gz" https://wordpress.org/latest.tar.gz

    bash "$PACKGEPATH/../utils/message.sh" info "Extracting WordPress..."
    tar -xzf "$targetDir/latest.tar.gz" -C "$targetDir"
    rm -rf "$targetDir/latest.tar.gz"

    read -p "Enter folder name or leave blank to put all files in the directory specified: "$'\n' folder
    mkdir "$targetDir/$folder"

    bash "$PACKGEPATH/../utils/message.sh" info "folder name is $folder"

    if [ -d "$PWD/$folder" ]; then
        mv -f "$targetDir/wordpress/"* "$targetDir/$folder"
    else
        bash "$PACKGEPATH/../utils/message.sh" warning "no folder founded fallback to the current directory..."
        mv -f "$targetDir/wordpress/"* "$PWD"
    fi

    dockerizeWordpress $folder

    rm -rf "$targetDir/wordpress/"

    bash "$PACKGEPATH/../utils/message.sh" success "WordPress has been downloaded and extracted to $targetDir/$folder"
}

function download_bedrock() {
    local targetDir=$1

    if command -v git &>/dev/null; then
        bash "$PACKGEPATH/../utils/message.sh" success "Git is installed. Version: $(git --version)"
    else
        bash "$PACKGEPATH/../utils/message.sh" warning "Git is not installed."
        exit 1
    fi

    pushd ${targetDir} || exit
    read -p "Enter folder name or leave blank to put all files in the directory specified: "$'\n' folder

    git clone https://github.com/roots/bedrock.git "$folder"
    dockerizeWordpress $folder true

    while true; do
        read -p "Want to install sage theme with bedrock?" yn
        case $yn in
        [Yy]*)
            download_sage "$PWD/$folder/web/app/themes/"
            break
            ;;
        [Nn]*) exit ;;
        *) bash "$PACKGEPATH/../utils/message.sh" warning "Please answer yes or no." ;;
        esac
    done

}

function download_sage() {
    local targetDir=$1

    if command -v git &>/dev/null; then
        bash "$PACKGEPATH/../utils/message.sh" success "Git is installed. Version: $(git --version)"
    else
        bash "$PACKGEPATH/../utils/message.sh" warning "Git is not installed."
        exit 1
    fi

    pushd ${targetDir} || exit
    read -p "Enter folder name or leave blank to put all files in the directory specified: "$'\n' folder
    if [ -z "$var" ]; then
        git clone https://github.com/roots/sage.git
    else
        git clone https://github.com/roots/sage.git "$PWD/$folder"
    fi

}

function dockerizeWordpress() {
    folder = $1
    isBedrock = $2
    while true; do
        read -p "Do you wish to Dockerize this app? " yn
        case $yn in
        [Yy]*)
            cp -r "$DOCKERFILESDIR/"* "$PWD/$folder/"
            cp -r "$DOCKERFILESDIR/".* "$PWD/$folder/"
            break
            ;;
        [Nn]*) exit ;;
        *) bash "$PACKGEPATH/../utils/message.sh" warning "Please answer yes or no." ;;
        esac
    done

    if [ -z "$isBedrock" ]; then
        bash "$PACKGEPATH/../utils/message.sh" info "lets upate nginx configuration"
        NGINX_CONF="$PWD/$folder/.ma/nginx/default.conf"
        NEW_ROOT="/var/www/html/web"
        sed -i "s|^\(\s*root\s*\).*|\1${NEW_ROOT};|" $NGINX_CONF
        bash "$PACKGEPATH/../utils/message.sh" success "updated nginx configuration."
    fi
}
