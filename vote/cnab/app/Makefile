CNAB_ACTION ?= status
CNAB_INSTALLATION_NAME ?= vote
NAMESPACE ?= vote
HELM_OPTIONS ?= 

install:
	@echo "Do $(CNAB_ACTION) for $(CNAB_INSTALLATION_NAME)"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm install --namespace $(NAMESPACE) $(HELM_OPTIONS)  -n $(CNAB_INSTALLATION_NAME)-$$chart ./charts/$$chart ;\
	done
	@echo All charts installed

uninstall: 
	@echo "Do Uninstall"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm delete --purge $(CNAB_INSTALLATION_NAME)-$$chart $(HELM_OPTIONS) ;\
	done

upgrade:
	@echo "Do Upgrade"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm upgrade --namespace $(NAMESPACE) $(CNAB_INSTALLATION_NAME)-$$chart charts/$$chart $(HELM_OPTIONS) ;\
	done

status:
	@echo "Do Status"
	@for chart in $$(ls charts); do [[ ! -d charts/$$chart ]] || \
		helm status  $(CNAB_INSTALLATION_NAME)-$$chart ;\
	done

.PHONY: install uninstall upgrade status