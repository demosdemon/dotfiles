#!/usr/bin/env bash

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
  local domain host tmp certText cn san
  domain=$1
  host=${2:-$1}
  port=${3:-443}

  if [ -z "$host" ]; then
    echo "Usage: getcertnames <domain> [[host] port]" >&2
    echo "  host == domain if host is not provided." >&2
    return 1
  fi

  printf 'Testing %s on https://%s:%d\n\n' "$domain" "$host" "$port"

  tmp=$(
    printf 'GET / HTTP1.1\r\nHost: %s\r\nUser-Agent: getcertnames/1.0\r\nAccept: */*\r\n\r\n' "$domain" |
      openssl s_client -connect "${host}:${port}" -servername "${domain}" 2>&1
  )

  if [[ ${tmp} == *"-----BEGIN CERTIFICATE-----"* ]]; then
    certText=$(
      echo "$tmp" |
        openssl x509 -text -noout
    )

    cn=$(
      echo "$certText" |
        grep 'Subject:' |
        sed -e 's/^.*CN=//' |
        sed -e 's!/emailAddress=.*!!'
    )

    san=$(
      echo "$certText" |
        grep -A 1 'Subject Alternative Name:' |
        sed -e '2s/DNS://g' -e 's/ //g' |
        tr ',' $'\n' |
        tail -n +2
    )

    printf 'Common Name:\n%s\n\nSubject Alternative Names(s):\n%s\n' "$cn" "$san"
    return 0
  else
    echo "ERROR: Certificate not found." >&2
    return 1
  fi
}
