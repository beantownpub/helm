.PHONY: all test clean

image ?= wavelengths
tag ?= latest

package:
		helm package .

clean:
		rm *.tgz || true

dev_install:
		kubectl config use-context docker-desktop
		helm upgrade --install $(name) . \
			--set dynCustomerName=${DYN_CUSTOMER_NAME} \
			--set dynApiUsername=${DYN_API_USERNAME} \
			--set dynApiPassword=${DYN_API_PASSWORD} \
			--set dynUpdateZone=$(zone) \
			--set dynUpdateHost=$(host) \
			--set awsAlbHost=$(aws_host) \
			--debug

install:
		kubectl config use-context beantown
		helm upgrade --install $(name) . \
			--set image.tag=$(tag) \
			--debug

port_forward:
		kubectl port-forward --namespace default svc/wavelengths 3077:3077 &
