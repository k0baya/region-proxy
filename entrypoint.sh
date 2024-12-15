export FIRST_PORT=9050
WORKDIR="/app"
cd ${WORKDIR}
REGION=${REGION:-'["US"]'}

generate_glider() {
    cat > glider.sh << ABC
#!/bin/bash

case "\$(uname -m)" in
    x86_64)
        ARCH=amd64
        ;;
    aarch64)
        ARCH=arm64
        ;;
    *)
        echo "Unsupported architecture"
        exit 1
        ;;
esac

get_glider() {
    local glider_latest_version=\$(curl -s https://api.github.com/repos/nadoo/glider/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    local version="\${glider_latest_version#v}"
    wget -O glider.tar.gz https://github.com/nadoo/glider/releases/latest/download/glider_\${version}_linux_\${ARCH}.tar.gz
    tar -xvf glider.tar.gz
    mv -f glider_\${version}_linux_\${ARCH}/glider glider
    chmod +x glider
    rm -rf glider_\${version}_linux_\${ARCH} glider.tar.gz
}

parse_regions() {
    local region_str="\${REGION//[\\[\\]\" ]/}"
    IFS=',' read -r -a regions <<< "\$region_str"
    echo "\${regions[@]}"
}

generate_config() {
    local regions
    regions=(\$(parse_regions))

    if [[ \${#regions[@]} -eq 0 ]]; then
        echo "Error: No regions specified."
        exit 1
    fi

    local listen=":8443"
    [[ -n "\$USER" && -n "\$PASSWORD" ]] && listen="\$USER:\$PASSWORD@:8443"

    local port=$FIRST_PORT

    cat > "glider.conf" << EOF
verbose=True
listen=\$listen
EOF

    for country in "\${regions[@]}"; do
        echo "forward=socks5://127.0.0.1:\$port" >> "glider.conf"
        ((port++))
    done

    cat >> "glider.conf" << EOF
strategy=rr
check=http://www.msftconnecttest.com/connecttest.txt#expect=200
checkinterval=3000
EOF
}

run() {
    ./glider -config glider.conf
}

[[ ! -e glider ]] && get_glider

generate_config && run

ABC
}

generate_tor() {
    cat > tor.sh << EOF
#!/bin/bash

parse_regions() {
    local region_str="\${REGION//[\\[\\]\" ]/}"
    IFS=',' read -r -a regions <<< "\$region_str"
    echo "\${regions[@]}"
}

run() {
    local regions
    regions=(\$(parse_regions))

    if [[ \${#regions[@]} -eq 0 ]]; then
        echo "Error: No regions specified."
        exit 1
    fi

    local port=${FIRST_PORT}
    for country in "\${regions[@]}"; do
        local temp_dir
        temp_dir=\$(mktemp -d) || {
            echo "Error: Failed to create temporary directory for \$country"
            continue
        }

        echo "Using temporary data directory: \$temp_dir for \$country"

        tor --DataDirectory "\$temp_dir" --SocksPort "\$port" --ExitNodes "{\$country}" &

        echo "Started Tor for \$country on port \$port"
        ((port++))
    done
}

run
EOF
}

generate_tor

region_str="${REGION//[\\[\\]\" ]/}"
IFS=',' read -r -a regions <<< "$region_str"
region_count=${#regions[@]}
delay=$((15 + 5 * region_count))
sleep "$delay"

generate_glider

[ -e glider.sh ] && chmod +x glider.sh && bash glider.sh
[ -e tor.sh ] && chmod +x tor.sh && bash tor.sh