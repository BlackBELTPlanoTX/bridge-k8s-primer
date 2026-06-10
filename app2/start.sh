#!/bin/sh
set -eu

BG_COLOR_VALUE="${BG_COLOR:-#f2efe8}"
cat > /usr/share/nginx/html/runtime.css <<EOF
:root {
  --page-bg: ${BG_COLOR_VALUE};
}
EOF

exec nginx -g 'daemon off;'
