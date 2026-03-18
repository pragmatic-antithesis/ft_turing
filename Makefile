CABAL_NAME := ft-turing
PROJECT_NAME := ft_turing

find-exe = $(shell find dist-newstyle/build -type f -name "$(CABAL_NAME)" -executable 2>/dev/null | head -n1)

all: $(PROJECT_NAME)

build:
	@cabal build

$(PROJECT_NAME): build
	@EXECUTABLE="$(call find-exe)"; \
	if [ -n "$$EXECUTABLE" ]; then \
		if [ ! -f "$(PROJECT_NAME)" ] || [ "$$EXECUTABLE" -nt "$(PROJECT_NAME)" ]; then \
			cp "$$EXECUTABLE" ./$(PROJECT_NAME); \
			chmod +x ./$(PROJECT_NAME); \
		else \
			echo "$(PROJECT_NAME) is already up to date"; \
		fi \
	else \
		echo "Error: Could not find executable. Check build?"; \
		exit 1; \
	fi

change: $(PROJECT_NAME)

clean:
	@cabal clean

fclean: clean
	@rm -f ./$(PROJECT_NAME)

.PHONY: all build change clean
