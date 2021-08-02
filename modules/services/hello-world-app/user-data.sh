#!/usr/bin/env bash
cat > index.html <<EOF
<h1>${server_port}</h1>
<h1>${server_text}</h1>
<h1>${db_address}</h1>
<h1>${db_port}</h1>
<h1>
EOF
nohup busybox httpd -f -p ${server_port} &