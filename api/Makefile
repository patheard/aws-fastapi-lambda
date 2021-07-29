fmt:
	black . $(ARGS)

install:
	pip3 install --user --requirement requirements.txt

install-dev:
	pip3 install --user --requirement requirements-dev.txt	

lint:
	pylint *.py
	
serve:
	uvicorn main:app --reload

test:
	python -m pytest -s -vv tests

zip:
	pip3 install --target ./libs --requirement requirements.txt
	cd ./libs && zip -rq ../lambda.zip .
	zip -gq lambda.zip main.py
	mv lambda.zip ../infra/modules/api-gateway
	rm -r ./libs

.PHONY: \
	fmt \
	install \
	install-dev \
	serve \
	tests \
	zip