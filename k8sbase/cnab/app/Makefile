CNAB_ACTION ?= status
CNAB_INSTALLATION_NAME ?= helmtest

HELM_OPTIONS ?= --dry-run --debug

install:
	@echo "Do $(CNAB_ACTION) for $(CNAB_INSTALLATION_NAME)"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm install $(HELM_OPTIONS) -n $(CNAB_INSTALLATION_NAME)-$$chart charts/$$chart ;\
	done
	@echo All charts installed

uninstall: 
	@echo "Do Uninstall"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm delete $(HELM_OPTIONS) $(CNAB_INSTALLATION_NAME)-$$chart ;\
	done

upgrade:
	@echo "Do Upgrade"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm upgrade $(HELM_OPTIONS) $(CNAB_INSTALLATION_NAME)-$$chart charts/$$chart ;\
	done

status:
	@echo "Do Status"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm status $(HELM_OPTIONS) $(CNAB_INSTALLATION_NAME)-$$chart ;\
	done

.PHONY: install uninstall upgrade status