import paramiko
import json
import io

#%%
# Initialize the SSH client
client = paramiko.SSHClient()

#%%
# Add the SSH public key
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

#%%
# Read the SSH key from the ssh_test.txt file and parse it as JSON
with open('/Users/dbouquin/Library/CloudStorage/OneDrive-NationalParksConservationAssociation/Documents_Daina/Analysis/SFTP/ssh_test.txt', 'r') as f:
    secret = json.load(f)

#%%
# Create a file-like object from the SSH key string
my_ssh_key = paramiko.RSAKey(file_obj=io.StringIO(secret['SSH_KEY']))

#%%
# Connect to the SFTP server
client.connect(hostname='inbound.roisolutions.net', port=22, username='npca_dbouquin9335', pkey=my_ssh_key)

# Initialize the SFTP client
sftp = client.open_sftp()

# List directories in the current directory on the server
directories = sftp.listdir()
for directory in directories:
    print(directory)

# Close the connection
sftp.close()
client.close()