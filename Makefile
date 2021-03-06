MAKEFLAGS += -j3

#consider moving to task, but it can not run long tasks in parallel
watch: build_runner_watch

debug:
	@echo "Running dart server"
	@dart run --observe  lib/main.dart

run:
	@echo "Running dart server"
	dart run --enable-vm-service lib/main.dart 

release: 
	#@echo "Running pub get"
	#@dart pub get
	@echo "Running release build"
	@dart compile exe lib/main.dart -o lib/main
	#@webpack

build_runner_watch:
	@echo "Running build_runner watch"
	@dart run build_runner watch --delete-conflicting-outputs

#all-in-one ansible command for deployment
deploy:
	ansible-playbook deploy.yml -K

test: test_config test_db test_controller

test_config:
	dart run test test/config_test.dart --chain-stack-traces

test_db:
	dart run test test/db_test.dart --chain-stack-traces

test_controller:
	dart run test test/controller_test.dart --chain-stack-traces
