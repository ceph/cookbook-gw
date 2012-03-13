OpenVPN cookbook
================

NOTE: This is not a general-purpose cookbook, this is aimed at doing
exactly what we needed. Grab ideas but beware the assumptions.


No client certs
---------------

The one significant gimmick we're pulling off here is, we're avoiding
the SSL and CA dance. Normally, clients need to generate a key, then
hand a "Certificate Signing Request" to the CA, that needs to create a
certificate, and this needs to be handed back to client. Too much
interaction! We're not using third-party CAs anyway, there's no reason
to pay the price of the PKI bureaucracy.

We still use a CA, and check the servers certificate against it, but
the clients don't even have an SSL key. Instead, we're letting
OpenVPN's auth-user-pass-verify feature verify a "username and
password" pair.

Now, this is normally a bad idea, because it lets attackers guess the
passwords, but:

1. You need to know the tlsauth secret to get past the initial handshake
2. I'm not letting the users pick the passwords

Instead of passwords, we just generate a bunch of random bytes.

To avoid having these secrets left around in people's email inboxes,
we actually ship a seeded hash of the secret to the server.

This means, all a user does to create a new VPN client is unpack a few
files, run a script that generates the randomness, and email a single
line of output that looks like "USER@HOST SALT HASH" to the admin. All
an admin has to do to add a user is to copy that line into a list of
allowed users. To revoke a clients access, just remove the line.

We put the hostname (really, any label you want) in the username so
that a single user can intuitively have multiple VPN clients.
