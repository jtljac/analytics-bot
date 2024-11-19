#!/bin/sh

# Token for your bot
TOKEN=
# Channel to send notifications on
NOTIFICATION_CHANNEL_ID=
# Guild to analyse messages of
GUILD_ID=
# Directory to write exported messages to
TMP_DIR=
# Directory to write
DST_DIR=
# (Optional) Endpoint of analytics server for posting a link after finishing
ENDPOINT=
# If true, symlink the written file in the DST_DIR to index.html in the DST_DIR
LINK_INDEX=true


function sendNotification()
 {
     if [ ! -z "${VAR}" ]; then
         curl \
         -H "Authorization: Bot ${TOKEN}" \
         -H "User-Agent: myBotThing (http://some.url, v0.1)" \
         -H "Content-Type: application/json" \
         -X POST \
         -d "{\"content\":\"$1\"}" \
         "https://discordapp.com/api/channels/${NOTIFICATION_CHANNEL_ID}/messages"
     fi
     echo "Sent Message: $1"
 }

 # Check required variables set
 if [ -z "${TOKEN}" ]; echo "You must set the bot token to use this" && exit
 if [ -z "${GUILD_ID}" ]; echo "You must set the guild ID to use this" && exit
 if [ -z "${TMP_DIR}" ]; echo "You must set the tmp directory to write the exported messages into" && exit
 if [ -z "${DST_FILE}" ]; echo "You must set the dest file to write the resulting analytics to" && exit

sendNotification "Starting Analytics Update"

rm -rf "${TMP_DIR}"

discord-chat-exporter-plus-cli exportguild -t "${TOKEN}" --include-threads All  -o "${TMP_DIR}" -f Json -g "${GUILD_ID}" --parallel 5

if [ $? -ne 0 ]; then
    sendNotification("Failed to extract messages from Guild")
fi

DST_NAME="$(date +%F).html"
DST_FILE="${DST_DIR}/${DST_NAME}"
INDEX_FILE="${DST_DIR}/index.html"

npx chat-analytics -p "discord" -i "${TMP_DIR}/*.json" -o "${DST_FILE}"

if [ $? -ne 0 ]; then
    sendNotification "Failed to generate analytics"
fi

if [ "$LINK_INDEX" = true ] ; then
    rm -f ${INDEX_FILE}
    ln -s ${DST_FILE} ${INDEX_FILE}
    sendNotification "Analytics updated, ${ENDPOINT}/DST_NAME"
else
    sendNotification "Analytics updated, ${ENDPOINT}"
fi

rm -f "${TMP_FILE}"