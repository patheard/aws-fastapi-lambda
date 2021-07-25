fmt:
	black . $(ARGS)

install:
	pip3 install --user -r requirements.txt

install_dev:
	pip3 install --user -r requirements_dev.txt	

serve:
	uvicorn main:app --reload

.PHONY: \
	fmt \
	install \
	install_dev