MAKEFLAGS += -j3

#consider moving to task, but it can not run long tasks in parallel
watch: webpack_watch build_runner_watch

webpack_watch:
	@echo "Running webpack watch"
	@webpack --watch --mode=development

debug:
	@echo "Running dart server"
	@dart run --observe  lib/main.dart

run:
	@echo "Running dart server"
	@pub run lib/main.dart

build_runner_watch:
	@echo "Running build_runner watch"
	@pub run build_runner watch --delete-conflicting-outputs

#all-in-one ansible command for deployment
deploy:
	ansible-playbook deploy.yml -K

npm_install:
	sudo npm i -g npm-check-updates
	ncu -u
	npm i
npm_update:
	ncu -u
	npm i

tst: test_config test_db test_controller

test_config:
	pub run test test/config_test.dart

test_db:
	pub run test test/db_test.dart

test_controller:
	pub run test test/controller_test.dart
