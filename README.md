google-api-python-client
========================

This is a standalone installation of the google-api-python-client that relies on PYTHONPATH to provide
access to the installed modules. This allows the installation to be tuned independently of the hosting
environment, facilitates multiple parallel installations for different applications or testing, and
makes uninstallation trivial.

Dependencies
============

This is not a complete Python installation, and only covers the main dependencies required to support
the google-api-python-client: httplib2, oauth2client, pycrypto, and uritemplate. The pyopenssl module
is also provided, but it is only a partial configuration and its presence is primarily to force
oauth2client to prefer pycrypto.

Use
===

The bin/googleapi script is provided to configure PYTHONPATH and then launch the actual Python application
that will be the Google API client.

Service Accounts and Certificates
=================================

One important way the google-api-python-client package can be used is to automate activities on Google
accounts. A Google Service Account is typically required to enable such functionality. The most important
thing to understand is that the Google Service Account creates a new **account**. This account is associated
with the email address generated for the account, and logging into the account requires the use of the PKCS12
credentials generated for the account.

In the case of Google Calendar, access to other calendars (say your work or personal calendar) requires
sharing those calendars with the Google Service Account in much the same way as you would share the
calendar with, say, a family member.

Logging into the Google Service Account requires presenting the Private Key from the PKCS12 file. The
downloaded PKCS12 file will be ASN.1 encoded and contains certificates and keys, but only the
Private Key is required to log in. Furthermore, pycrypto can only deal with PEM encoded material.

The most straightforward approach is to use bin/googlecertpem to convert the PKCS12 ASN.1 file to
a PEM file containing the same certificates and keys. PEM uses plain text to store data, so it is
a trivial matter to isolate the Private Key using simple text manipulation tools:

    -----BEGIN PRIVATE KEY-----
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    xxxxxxxxxxxxxxxx
    -----END PRIVATE KEY-----

Once extracted, the Private Key can be used to authenticate and log into the Service Account:

    accountName = 'xxxxxx@developer.gserviceaccount.com'
    privateKey  = '-----BEGIN PRIVATE KEY----- ...'
    credentials = oauth2client.client.SignedJwtAssertionCredentials(
        accountName,
        privateKey,
        'https://www.googleapis.com/auth/calendar.readonly')
        
    client = apiclient.discovery.build(
        serviceName = 'calendar',
        version     = 'v3',
        http        = credentials.authorize( httplib2.Http() ))
