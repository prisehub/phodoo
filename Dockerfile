FROM ubuntu:16.04

ARG OE_USER=odoo
ARG OE_HOME=/odoo
ARG OE_HOME_EXT=/odoo/odoo-server
ARG WKHTMLTOPDF_VERSION=0.12.5
ARG ODOO_VERSION=10.0

RUN apt-get update && apt-get upgrade -y

RUN apt-get install wget git python-pip \
	python-dateutil python-feedparser python-ldap \
	python-libxslt1 python-lxml python-mako python-openid \
	python-psycopg2 python-pybabel python-pychart python-pydot \
	python-pyparsing python-reportlab python-simplejson python-tz \
	python-vatnumber python-vobject python-webdav python-werkzeug \
	python-xlwt python-yaml python-zsi python-docutils python-psutil \
	python-mock python-unittest2 python-jinja2 python-pypdf \
	python-decorator python-requests python-passlib python-pil \
	python-suds python-gevent npm node-clean-css node-less \
	&& curl https://bootstrap.pypa.io/get-pip.py | python /dev/stdin \
	&& curl -SLo wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox_${WKHTMLTOPDF_VERSION}-1.trusty_amd64.deb \
	&& (dpkg --install wkhtmltox.deb || true) \

RUN pip install -r https://raw.githubusercontent.com/odoo/odoo/${ODOO_VERSION}/requirements.txt

RUN npm install -g less
RUN npm install -g less-plugin-clean-css

RUN ln -s /usr/local/bin/wkhtmltopdf /usr/bin

RUN ln /s /usr/local/bin/wkhtmltoimage /usr/bin

RUN adduser --system --quiet --shell=/bin/bash --home=${OE_HOME} --gecos 'ODOO' --group ${OE_USER}

RUN mkdir /var/log/odoo \
	&& chown odoo:odoo /var/log/odoo

RUN mkdir -p /var/lib/odoo \
	&& chown -R odoo:odoo /var/lib/odoo \
	&& sync

# mount odoo code

RUN cp ${OE_HOME_EXT}/debian/odoo.conf /etc/odoo-server.conf \
	&& chown odoo:odoo /etc/odoo-server.conf \
	&& chmod 640 /etc/odoo-server.conf

RUN sed -i s/"db_user = .*"/"db_user = odoo"/g /etc/odoo-server.conf
RUN sed -i s/"; admin_passwd.*"/"admin_passwd = ${OE_SUPERADMIN}"/g /etc/odoo-server.conf
RUN echo 'logfile = /var/log/odoo/odoo-server.log' >> /etc/odoo-server.conf



# script to run odoo as service
