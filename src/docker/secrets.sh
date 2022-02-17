clearEnvironment() {
    local varPrefix="$1"
    
    if [[ -z "$varPrefix" ]]; then
      echo "Variable prefix is required." >&2
      exit 1
    fi
    
    for name in $(printenv | grep "${varPrefix}_" | cut -d= -f1); do
        unset "$name"
    done
}


fileEnv() {
    local var="$1"
    local fileVar="${var}_FILE"
    eval "local value=\$$var"
    eval "local secretPath=\$$fileVar"
    local default="${2:-}"
    
    echo "Default: $default"
    
  	if [[ "$value" ]] && [[ "$secretPath" ]]; then
        echo "Both $var and $fileVar are set (but are exclusive)." >&2
	      exit 1
  	fi
    
    if [[ ! -z "$secretPath" ]]; then
        value="$(cat "$secretPath")"
    fi
    
    if [[ -z "$value" ]]; then
      if [[ -z "$default" ]]; then
          echo "$var or $fileVar require a value." >&2
          exit 1
      else
        value="$default"
      fi
    fi
    
  	export "$var"="$value"
  	unset "$fileVar"
}
