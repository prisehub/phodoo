FROM ubuntu:16.04

ARG OE_USER=odoo
ARG OE_HOME=/odoo
ARG OE_HOME_EXT=/odoo/odoo-server
ARG WKHTMLTOPDF_VERSION=0.12.5
ARG ODOO_VERSION=10.0

EXPOSE 8069 8069
EXPOSE 8072 8072

RUN apt-get update && apt-get upgrade -y

# system deps
RUN apt-get install -y wget curl zip git python-pip \
	libldap2-dev libsasl2-dev zlibc libssl-dev \
	bzip2 ca-certificates curl gettext-base \
	fontconfig libfreetype6 libxml2-dev libxslt1-dev libxml2 libxslt1.1 zlib1g \
	&& curl https://bootstrap.pypa.io/get-pip.py | python /dev/stdin \
	&& curl -sL https://deb.nodesource.com/setup_6.x | bash - \
	&& apt-get install -yqq nodejs \
	&& curl -SLo wkhtmltox.deb https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/${WKHTMLTOPDF_VERSION}/wkhtmltox_${WKHTMLTOPDF_VERSION}-1.trusty_amd64.deb \
	&& (dpkg --install wkhtmltox.deb || true) \
	&& apt-get install -yqq --no-install-recommends --fix-broken \
	&& rm -f wkhtmltox.deb \
	&& wkhtmltopdf --version

# odoo python deps
RUN pip install -r https://raw.githubusercontent.com/odoo/odoo/${ODOO_VERSION}/requirements.txt

RUN ln -s /usr/bin/nodejs /usr/local/bin/node
RUN npm install -g less
RUN npm install -g less-plugin-clean-css

RUN adduser --system --quiet --shell=/bin/bash --home=${OE_HOME} --gecos 'ODOO' --group ${OE_USER}

RUN mkdir /var/log/odoo \
	&& chown odoo:odoo /var/log/odoo

RUN mkdir -p /var/lib/odoo \
	&& chown -R odoo:odoo /var/lib/odoo \
	&& sync

# odoo config
COPY config.d/00-base.conf /etc/odoo-server.conf

RUN chown odoo:odoo /etc/odoo-server.conf \
	&& chmod 640 /etc/odoo-server.conf

# odoo code
RUN wget https://github.com/odoo/odoo/archive/${ODOO_VERSION}.zip

RUN unzip ${ODOO_VERSION}.zip \
	&& mv odoo-${ODOO_VERSION} ${OE_HOME_EXT} \
	&& rm ${ODOO_VERSION}.zip

# mount project on custom directory
RUN mkdir ${OE_HOME}/custom

WORKDIR /odoo/odoo-server

USER odoo

# test odoo version
RUN /odoo/odoo-server/odoo-bin --version


ENTRYPOINT ["/odoo/odoo-server/odoo-bin"]

# odoo as service
CMD ["-c", "/etc/odoo-server.conf"]
