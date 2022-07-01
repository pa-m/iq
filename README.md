# iq - small tool to query or update ini-style linux configuration files

syntax is inspired from jq for json and yq for yaml

examples

```bash
iq -e .section1.setting1 sometool.conf

iq -e .section1.setting1=value1 sometool.conf > sometool-new.conf

iq -i -e .section1.setting1=value1 sometool.conf

```