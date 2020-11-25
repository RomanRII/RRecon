#!/usr/bin/python
import sys, discord, os

TOKEN = ''
channel_id = ''

def amassASN():
    path = "/tmp/amassExec.txt"
    amassCMD = open(path,'r')
    res = amassCMD.read()
    res = res.replace('"', '')
    os.system(res)
    os._exit(1)

if len(sys.argv) < 2:
    print("\nPlease supply argument:\nneedassistance - Script needs intervention\nscancomplete - Scan is complete\n")
    exit()
elif len(sys.argv) > 2:
        print("\nToo many args\n")
        exit()

class MyClient(discord.Client):
    async def on_message(self, message):
        if message.author == client.user:
            return

#Start of Connection
    async def on_ready(self):
        channel = client.get_channel(channel_id)
        if str(sys.argv[1]) == "needassistance":
            server_enter = "Your assistance is needed"            
        elif str(sys.argv[1]) == "scancomplete":
            server_enter = "Scan has completed"
        elif str(sys.argv[1]) == "amassASN":
            amassASN()
        elif str(sys.argv[1]) == "rapid7Complete":
            server_enter = "Rapid7 Scan Complete"
        await channel.send(server_enter)
        os._exit(1)
#End of Connection

#Connection Attempt Start
client = MyClient()
client.run(TOKEN)
#Connection Attempt End


            


