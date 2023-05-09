
import instantcli
import renew
import json
def printme(result):
    print(result)

instantcli.post_call = printme

instantcli.load_module( renew)
instantcli.cli()
