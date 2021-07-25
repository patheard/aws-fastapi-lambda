fmt:
	black . $(ARGS)

install:
	pip3 install --user -r requirements.txt

install-dev:
	pip3 install --user -r requirements-dev.txt	

lint:
	pylint *.py
	
serve:
	uvicorn main:app --reload

test:
	python -m pytest -s -vv tests 

.PHONY: \
	fmt \
	install \
	install-dev \
	serve \
	tests