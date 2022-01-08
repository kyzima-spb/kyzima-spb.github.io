fileEnv() {
    local var="$1"
    local fileVar="${var}_FILE"
    eval "local value=\$$var"
    eval "local secretPath=\$$fileVar"
    local default="${2:-}"
    
  	if [[ "$value" ]] && [[ "$secretPath" ]]; then
        echo "Both $var and $fileVar are set (but are exclusive)" >&2
	      exit 1
  	fi
    
    if [[ ! -z "$secretPath" ]]; then
        value="$(cat "$secretPath")"
    fi
    
    if [[ -z "$value" ]]; then
        value="$default"
    fi
    
  	export "$var"="$value"
  	unset "$fileVar"
}