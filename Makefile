CC=tcc

notarget:
	@echo "use make dev or make prod"


prod: *.v Makefile test
	v -o bin/iq -prod -show-timings . && [ ! -f /usr/bin/upx ] || /usr/bin/upx bin/iq

dev: *.v Makefile test
	v -o bin/iq-dev .

test:
	v fmt -w .
	v -stats test .

.PHONY: test notarget

