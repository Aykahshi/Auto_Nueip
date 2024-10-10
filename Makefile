MAKEFLAGS += --no-print-directory
SHELL := /bin/bash
## Set LANG=en_US.UTF-8;LC_ALL=en_US.UTF-8 in your IDE or shell environment.

.PHONY: all lint help format clean get build_apk build_ipa clean_get upgrade run_test run_dev run_sit run_uat run_prof run_prod run_release code code_watch devtool

##

help: ## All available commands.
				@IFS=$$'\n' ; \
				help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
				for help_line in $${help_lines[@]}; do \
						IFS=$$'#' ; \
						help_split=($$help_line) ; \
						help_command=`printf $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
						help_info=`printf $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
						printf "%-30s    %s\n" $$help_command $$help_info ; \
				done

##
## --- Basic ---

all: lint format run_dev ## Run the default task.

lint: ## Check the code quality.
		@printf "\U1F50D Checking the code quality... \n"
		@dart analyze . || (printf "\U274C Error in analyzing, some code need to optimize."; exit 1)
		@printf "\U2705 Code quality is perfect! \n"

format: ## Format the code.
		@printf "\U1F6E0\UFE0F Formatting code...\n"
		@dart format .
		@printf "\U2705 Code formatted successfully! \n"

clean: ## Clean the environment.
		@printf "\U1F9F9 Cleaning the project... \n"
		@flutter clean
		@printf "\U2705 Project cleaned successfully! \n"

get: ## Get the dependencies.
		@printf "\U1F4E6 Getting flutter pub... \n"
		@flutter pub get || (printf "\U274C Error in getting dependencies. Please check the dependencies and try again."; exit 1)
		@printf "\U2705 Dependencies fetched successfully! \n"

build_apk: ## Build the Android app.
		@printf "\U1F4F1 Building the Android app...\n"
		@flutter build apk || (printf "\U274C Error in building Android app."; exit 1)
		@printf "\U2705 Android app built successfully! \n"

build_ipa: ## Build the iOS app.
		@printf "\U1F34F Building the iOS app...\n"
		@flutter build ios || (printf "\U274C Error in building iOS app."; exit 1)
		@printf "\U2705 iOS app built successfully! \n"

clean_get: ## Clean the environment and get the dependencies.
		@make clean
		@make get

upgrade: ## Update the dependencies.
		@printf "\U2B06\UFE0F Upgrading flutter pub...\n"
		@flutter pub upgrade || (printf "\U274C Error in upgrading dependencies. Please check the dependencies and try again."; exit 1)
		@printf "\U2705 Dependencies upgraded successfully! \n"

##
## --- Run ---

run_test: ## Run unit tests.
		@printf "\U1F9EA Starting unit tests.\n"
		@flutter test || (printf "\U274C Error in testing."; exit 1)
		@printf "\U2705 All unit tests passed! \n"

run_dev: ## Run the development environment.
		@printf "\U1F680 Running the development environment..."
		@flutter run \
			--debug || (printf "\U274C Error in running dev."; exit 1)
		@flutter attach --debug || (printf "\U274C Error: Failed to attach debugger."; exit 1)
		@printf "\U1F6D1 Development is shutdown.\n"

run_sit: ## Run the SIT environment.
		@printf "\U1F680 Running the SIT environment...\n"
		@flutter run \
			--flavor sit \
			--debug \
 			--target lib/main_sit.dart || (printf "\U274C Error in running SIT environment."; exit 1)
		@flutter attach --debug || (printf "\U274C Error: Failed to attach debugger."; exit 1)
		@printf "\U1F6D1 SIT Development is shutdown.\n"

run_uat: ## Run the UAT environment.
		@printf "\U1F680 Running the UAT environment...\n"
		@flutter run \
			--flavor uat \
			--debug \
			--target lib/main_uat.dart || (printf "\U274C Error in running UAT environment."; exit 1)
		@flutter attach --debug || (printf "\U274C Error: Failed to attach debugger."; exit 1)
		@printf "\U1F6D1 UAT Development is shutdown.\n"

run_prod: ## Run the PROD environment.
		@printf "\U1F680 Running the PROD environment...\n"
		@flutter run \
 			--flavor prod \
 			--profile \
 			--target lib/main.dart || (printf "\U274C Error in running PROD environment."; exit 1)
		@flutter attach --profile || (printf "\U274C Error: Failed to attach debugger."; exit 1)
		@printf "\U1F6D1 PROD Development is shutdown.\n"

run_prof: ## Run app in profile.
		@printf "\U1F680 Running app in profile mode...\n"
		@flutter run --profile || (printf "\U274C Error in running profile mode."; exit 1)
		@flutter attach --profile || (printf "\U274C Error: Failed to attach debugger."; exit 1)
		@printf "\U1F6D1 App is finished in profile mode!"

run_release: ## Run app in release.
		@printf "\U1F680 Running app in release mode...\n"
		@flutter run --release || (printf "\U274C Error in running release mode."; exit 1)
		@flutter attach --release || (printf "\U274C Error: Failed to attach debugger."; exit 1)
		@printf "\U1F6D1 App is finished in release mode!\n"

code: ## Run the build_runner to generate the code.
		@printf "\U1F527 Running build_runner to generate code...\n"
		@dart run build_runner build --delete-conflicting-outputs
		@printf "\U2705 Code generation completed!\n"

code_watch: ## Run the build_runner in watch mode to generate the code.
		@printf "\U1F527 Running build_runner in watch mode to generate code...\n"
		@dart run build_runner watch --delete-conflicting-outputs
		@printf "\U2705 Code is being generated in watch mode!\n"

devtool: ## Start Flutter DevTools.
	@printf "\U1F6E0 Starting Flutter DevTools...\n"
	@dart devtools || (printf "\U274C Error: Failed to start DevTools."; exit 1)
	@printf "\U1F680 DevTools started successfully!\n"

##