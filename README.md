A simple shell script to keep a web server up to date with stats from a discord
server

This script uses a discord bot token to pull all messages from the specified
discord server that the bot has access to (Managed by channel permissions for
the bot on the server), processes the messages into a HTML report, then dumps
the report in a specified directory for serving using a webserver.

# How to use
## Dependencies
### Curl (Optional)
Used for sending notifications to the Discord server.

Can be disabled by not providing a value for the `NOTIFICATION_CHANNEL_ID`
variable.

### [Discord chat Exporter Plus CLI](https://github.com/nulldg/DiscordChatExporterPlus)
Used for extracting message content.

The script expects to find DiscordChatExporterPlus.CLI on the path with the
name `discord-chat-exporter-plus-cli`. If this is not the case, then you must
change `line 44` to the correct command.

The plus version was chosen due to the reduced number of dependencies. However
you may switch to the regular version by changing the command as specified
above.

### [Chat Analytics](https://github.com/mlomb/chat-analytics)
Used for generating the stats html file.

The script expects to find the Chat analytics command as a globally insalled
npm package, using `npx chat-analytics`. If this is not the case, then you must
change `line 55` to the correct command,

## Discord Bot
This script relies on a discord bot being setup on the target server.

You can create a discord bot by following these steps:
https://discordjs.guide/preparations/setting-up-a-bot-application.html

The bot will need to have `Read Message History` and `View Channels` 
permissions, as well as the `Message Content Intent` enabled.

## Config
Some config is used to set up and customise the script. This can be found at the
top of the script, starting from line 3.

### TOKEN
The token for the Discord Bot.

You can find how to get this here:
https://github.com/nulldg/DiscordChatExporterPlus/blob/master/.docs/Token-and-IDs.md#how-to-get-a-bot-token

### NOTIFICATION_CHANNEL_ID
The ID of the channel to send notifications to. The selected channel will
receive messages when the Script starts, and once it has finished.

This is optional, by not setting this value, no notifications will be sent. It
will also remove the CURL dependency

You can find how to get this here:
https://github.com/nulldg/DiscordChatExporterPlus/blob/master/.docs/Token-and-IDs.md#how-to-get-a-server-id-or-a-channel-id

### GUILD_ID
The ID of the guild to analyse.


You can find how to get this here:
https://github.com/nulldg/DiscordChatExporterPlus/blob/master/.docs/Token-and-IDs.md#how-to-get-a-server-id-or-a-channel-id

### TMP_DIR
The directory to use for temporary storage of the exported messages.
This directory will be deleted after usage.

### DST_DIR
The directory to write the resulting stats HTML file to. This would normally be
the directory being served by the webserver.

The stats HTML file will have the name `yyyy-mm-dd.html`
(e.g. `2024.11.20.html`).

### ENDPOINT
The http endpoint serving the stats html files. This is used during
notifications to provide a link to the exported content. 
**Do not end with a slash (/)**

This is optional, by not setting this value, the notification will still inform
of completion, but not attach a link to the stats page.

### LINK_INDEX
Whether to create a symbolic link from the exported file to `index.html` in the
`DST_DIR`.

When set to `false`, the notification for completion will have a direct link to
the file (e.g. `http://example.com/2024.11.20.html`).

## Running automatically
This script is intended to be run automatically on a timer using SystemD timers
or CRON. An example setup for SystemD is given below (Note the script is located
at `/bin/discord-stats-update.sh`):

`/etc/systemd/system/discord-stats.service`
```ini
[Unit]
Description=Update Discord Stats

[Service]
Type=oneshot
ExecStart=/bin/discord-stats-update.sh
```

`/etc/systemd/system/discord-stats.timer`
```ini
[Unit]
Description=Discord Stats Weekly

[Timer]
# Friday 5pm
OnCalendar=Fri *-*-* 17:00:00 Europe/London
Persistent=true

[Install]
WantedBy=timers.target
```
