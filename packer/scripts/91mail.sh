set -exu

apk add --no-cache ssmtp

cat <<EOF > /etc/ssmtp/ssmtp.conf
#
# /etc/ssmtp.conf -- a config file for sSMTP sendmail.
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
root=postmaster
# The place where the mail goes. The actual machine name is required
# no MX records are consulted. Commonly mailhosts are named mail.domain.com
# The example will fit if you are in domain.com and you mailhub is so named.
mailhub=10.7.0.9
# Where will the mail seem to come from?
#rewriteDomain=localhost
# The full hostname
#hostname="localhost"
EOF

exit 0