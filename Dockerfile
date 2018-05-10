FROM python:3.6.5-slim-stretch

# workdir
WORKDIR /app
COPY . /app

RUN apt-get update -qq && \
	apt-get install -y --no-install-recommends build-essential && \
	apt-get clean && \
	pip3 install --no-cache-dir scipy spacy sklearn_crfsuite rasa_core && \
	python3 -m spacy download de && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY app_data/stories.md /app/data/stories.md
COPY app_data/nlu.md /app/data/nlu.md
COPY app_data/domain.yml /app/domain.yml
COPY app_data/nlu_model_config.json /app/nlu_model_config.json
COPY app_data/fb_credentials.yml /app/fb_credentials.yml

RUN python3 -m rasa_nlu.train -c nlu_model_config.json --fixed_model_name 
RUN python3 -m rasa_core.train -s data/stories.md -d domain.yml -o models/dialogue --epochs 10

EXPOSE 5001

CMD ["python3","-m","rasa_core.run","-p","5001","-d","models/dialogue","-u","models/nlu/default/current","-c","facebook","--credentials","fb_credentials.yml"]
