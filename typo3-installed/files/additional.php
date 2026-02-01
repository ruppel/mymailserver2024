<?php
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxySSL'] = '127.0.0.1/32,192.168.0.0/16,172.16.0.0/12,10.0.0.0/8';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['trustedHostsPattern'] = '{% for domain in typo3.domains %}{% if loop.index > 1 %}|{% endif %}({{ domain }}){% endfor %}';
$GLOBALS['TYPO3_CONF_VARS']['SYS']['reverseProxyHeaderMultiValue'] = 'first';