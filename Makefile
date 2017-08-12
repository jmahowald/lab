
BUILD_DIR = build-$(ENV_NAME)
LAYER_TEMPLATE_FILE  := $(wildcard templates/*.yml)
LAYER_FILES :=  $(addprefix $(BUILD_DIR)/,$(notdir $(LAYER_TEMPLATE_FILE)))
# Don't rerun apply more than once
APPLY_GUARD_FILES := $(addprefix $(BUILD_DIR)/,$(notdir $(LAYER_FILES:.yml=.apply)))

FORMTERRA_CMD ?= formterra
# FORMTERRA_CMD ?= docker run -v $(shell pwd):/data joshmahowald/formterra 
LAYER_DIR ?= layers-$(ENV_NAME)

.PRECIOUS: $(BUILD_DIR)/%.yml $(BUILD_DIR)/%.plan $(BUILD_DIR)/%.apply  $(BUILD_DIR)/%.remote 

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)


$(BUILD_DIR)/%.yml: templates/%.yml $(BUILD_DIR) 
	dockerize -template $<:$@
	$(FORMTERRA_CMD) module gen -i $(BUILD_DIR)/$*.yml -d $(LAYER_DIR)



$(BUILD_DIR)/%.plan: $(BUILD_DIR)/%.yml 
	$(MAKE) -C $(LAYER_DIR)/$* plan
	@echo `date` > $@



$(BUILD_DIR)/%.apply: $(BUILD_DIR)/%.plan $(BUILD_DIR)/%.remote
	$(MAKE) -C $(LAYER_DIR)/$* apply
	@echo `date` > $@


$(BUILD_DIR)/%.remote: 
	echo "initialise remote statefile with key $* for project" 
	cd $(LAYER_DIR)/$* && echo "terraform { backend \"s3\" {} }" > backend.tf && \
	terraform init -backend-config="bucket=$(REMOTE_STATE_BUCKET)" \
	-backend-config="key=$*/terraform.tfstate" \
	-backend-config="region=$(REMOTE_STATE_BUCKET_REGION)" && \
	terraform env select $(ENV_NAME) || terraform env new $(ENV_NAME)
	echo "remote state initialized with $(REMOTE_STATE_BUCKET) and $*" > $@
	

