#!/opt/dionaea/bin/python3
import sqlite3
import sys
from datetime import datetime

#
# Statistics script for Dionaea
# Mimics output of InfoSanity's submissions2stats.py script written for Nepenthes
#
# Author: Andrew Waite
# Date:   2009-11-10
#
# Patch to mitigate errors with both 0 submissions and/or statistics for < 1 day.
# Provided by Miguel Jacq (www.mig5.net)
# Date:   2010-06-05
#

#
#Print header
sys.stdout.write( '\nStatistics engine written by Andrew Waite - www.infosanity.co.uk\n\n')

#
#Create SQLite connection
conn = sqlite3.connect('/opt/dionaea/var/dionaea/logsql.sqlite')
c = conn.cursor()

#
#Calculate number of binary submissions
c.execute('SELECT count() FROM downloads')
for row in c:
    numSubmissions = row[0]
sys.stdout.write( "Number of submissions: %i \n" %(numSubmissions))

#
#Calculate number of unique submissions
c.execute('SELECT download_md5_hash FROM downloads GROUP BY download_md5_hash')
numSamples = 0
for row in c:
    numSamples += 1
sys.stdout.write( "Number of unique samples: %i\n" %(numSamples))

#
#Calculate unique soure IP addresses
c.execute('SELECT connections.remote_host FROM connections, downloads WHERE downloads.connection = connections.connection GROUP BY connections.remote_host')
numSourceIPs = 0
for row in c:
    numSourceIPs += 1
sys.stdout.write( "Number of unique source IPs: %i\n" %(numSourceIPs))

#
#Find first sample date
if numSubmissions > 0:
    c.execute('SELECT connections.connection_timestamp FROM connections, downloads WHERE downloads.connection = connections.connection ORDER BY connections.connection_timestamp LIMIT 1')
    for row in c:
        firstSampleTimestamp = row[0]
    sys.stdout.write("\nFirst sample seen: %s\n" %(datetime.fromtimestamp(firstSampleTimestamp)))

    #
    #Find last sample date
    c.execute('SELECT connections.connection_timestamp FROM connections, downloads WHERE downloads.connection = connections.connection ORDER BY connections.connection_timestamp DESC LIMIT 1')
    for row in c:
        lastSampleTimestamp = row[0]
    sys.stdout.write("Last sample seen: %s\n" %(datetime.fromtimestamp(lastSampleTimestamp)))

    #
    #Determine duration of uptime
    uptime = datetime.fromtimestamp(lastSampleTimestamp) - datetime.fromtimestamp(firstSampleTimestamp)
    sys.stdout.write("System Uptime: %s\n" %(uptime))

    #
    #Avg downloads per day
    if uptime.days >= 1:
        averageDownloads = numSubmissions / uptime.days
        sys.stdout.write("Average daily submissions: %s\n" %(averageDownloads))

    #
    #List most recent downloads
    sys.stdout.write("\nMost recent submissions:\n")
    c.execute('SELECT connections.connection_timestamp, connections.remote_host, downloads.download_url, downloads.download_md5_hash FROM downloads, connections WHERE connections.connection = downloads.connection ORDER BY connections.connection_timestamp desc limit 5')
    for row in c:
        sys.stdout.write("\t%s, %s, %s, %s\n" %(datetime.fromtimestamp(row[0]), row[1], row[2], row[3]))


# Original Nepenthes script output
#
#Statistics engine written by Andrew Waite - www.InfoSanity.co.uk
#
#Number of submissions: 4189
#Number of unique samples: 1189
#Number of unique source IPs: 2024
#
#First sample seen on 2008-05-09
#Last sample seen on 2009-10-31
#Days running: 540
#Average daily submissions: 7
#
#Most recent submissions:
#   <Cut to protect the guilty>