function _otpassword() {
    echo "$(whoami)@$(hostname)-$(date --rfc-3339=date)" | sha512sum | awk -e '{ print $1 }'
}

function debug(){
    if [ $DEBUG ]; then
        echo -e "\e[01;31m$@\e[00m"
    fi
}

function encrypt_file() {
    debug "encrypting ${1}"
    gpg --no-use-agent --batch --passphrase $(_otpassword) --cipher-algo AES256 --sign --force-mdc --symmetric "${1}"

    if [ $? == 0 ]; then
        debug "deleting unencrypted file"
        rm $1
    else
        echo 'failed to encrypt file'
    fi
}
