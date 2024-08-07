# MESSAGER

sms.sh is a command-line script that allows users to manage text messages. With this tool, you can send, remove, and search for text messages stored locally on your system. The script is designed to be user-friendly and provides a variety of functionalities through different command-line arguments.

### Features

Help: Displays a synopsis of available commands with brief descriptions.
Send: Sends a text message from one number to another and stores the message in both sender and receiver's files.
Remove: Removes all messages associated with a specified number.
Search: Searches for messages based on the sender, message content, or destination number.

### Command Usage

1) Displays a list of all available commands and their descriptions: **./sms.sh help**

2) Sends a text message from MyNumber to DestinationNumber: **./sms.sh send "MyNumber" "DestinationNumber" "Message"**

3) Removes all messages associated with Number1 after user confirmation: **./sms.sh remove "Number1"**

4) Searches for messages from FromNumber. Optionally, search by message content or destination number:
**./sms.sh search "FromNumber" [--message] [--number]**

### Data Storage

All message data is stored in the .messages directory in the same location as the sms.sh script. 

Each phone number has a corresponding file where messages are stored. 

Messages are stored as follows:

Outgoing: o;*message*;@DestinationNumber

Incoming: i;*message*;@SenderNumber

### Additional Information
The .messages directory and associated files are created as needed.

Ensure that .messages is not hardcoded and the script works if moved to another directory.

Use ls -al to view hidden directories and files.
