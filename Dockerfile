FROM python:3.6-slim AS builder
WORKDIR /code

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y \
		build-essential \
		default-libmysqlclient-dev \
		git \
		libcurl4-openssl-dev \
		libssl-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./requirements.txt
RUN set -ex \
	&& python -m venv /venv \
	&& bash -c ': \
	&& source /venv/bin/activate \
	&& pip install -U pip==19.3.1 uwsgi \
	&& pip install -r requirements.txt'

COPY . ./

FROM python:3.6-slim
WORKDIR /code

RUN set -ex \
	&& apt-get update \
	&& apt-get install -y \
		build-essential \
		default-libmysqlclient-dev \
		libcurl4-openssl-dev \
		libssl-dev \
		nginx \
		supervisor \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo "\ndaemon off;" >> /etc/nginx/nginx.conf \
	&& rm /etc/nginx/sites-enabled/default \
	&& chown -R www-data:www-data /var/lib/nginx \
	&& ln -sf /code/nginx.conf /etc/nginx/sites-enabled/ \
	&& ln -sf /code/supervisor-app.conf /etc/supervisor/conf.d/

COPY --from=builder /venv /venv
COPY --from=builder /code /code
CMD ["bash", "-c", "source /venv/bin/activate && supervisord -n"]
