# usage: file_env VAR [DEFAULT]
# ie: file_env 'XYZ_DB_PASSWORD' 'example'
#     (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#     "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
# author: https://github.com/docker-library/mysql/blob/master/8.0/docker-entrypoint.sh
file_env() {
    local var="$1"
    local fileVar="${var}_FILE"
    local default="${2:-}"
    
    if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
        echo "Both $var and $fileVar are set (but are exclusive)" >&2
        exit 1
    fi
    
    local value="$default"
    
    if [ "${!var:-}" ]; then
        value="${!var}"
    elif [ "${!fileVar:-}" ]; then
        value="$(< "${!fileVar}")"
    fi
    
    export "$var"="$value"
    unset "$fileVar"
}